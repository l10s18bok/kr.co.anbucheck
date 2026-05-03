import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:screen_state/screen_state.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;
import 'package:workmanager/workmanager.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';

/// WorkManager 백그라운드 콜백 (top-level 함수 필수)
@pragma('vm:entry-point')
void heartbeatWorkerCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    WidgetsFlutterBinding.ensureInitialized();
    try {
      tz.initializeTimeZones();
      try {
        final localTzName = await FlutterTimezone.getLocalTimezone();
        tzlib.setLocalLocation(tzlib.getLocation(localTzName));
      } catch (_) {
        tzlib.setLocalLocation(tzlib.getLocation('Asia/Seoul'));
      }

      ApiClientFactory.init(type: HttpClientType.dio);
      await getReloadedPrefs();

      final tokenDs = TokenLocalDatasource();
      final role = await tokenDs.getUserRole();
      final isAlsoSubject = await tokenDs.getIsAlsoSubject();
      debugPrint('[HeartbeatWorker] task=$taskName role=$role, isAlsoSubject=$isAlsoSubject');
      if (role != 'subject' && !isAlsoSubject) return true;

      final (hour, minute) = await tokenDs.getHeartbeatSchedule();
      final now = DateTime.now();
      final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      // 예약시각 -15분 이전이면 스킵. periodic은 +3분 offset으로 등록되지만
      // initialDelay 이후 실제 발화 시점은 Doze maintenance window에 종속되어
      // 예측 불가하다 (Light Doze: 5/10/15분 주기, factor 2.0).
      // -15분 창은 이 변동성을 흡수하기 위한 가드이며, 동일 maintenance window에서
      // one-off과 periodic이 batch fire되어도 서버 측 (device_id, scheduled_key)
      // idempotency가 중복 전송을 차단하므로 조기 통과의 사용자 영향은 없다.
      final earliestAllowed = scheduled.subtract(const Duration(minutes: 15));
      if (now.isBefore(earliestAllowed)) {
        debugPrint('[HeartbeatWorker] schedule=$hour:$minute, now=${now.hour}:${now.minute}:${now.second} → 스킵(예약시각 -15분 이전)');
        return true;
      }
      debugPrint('[HeartbeatWorker] schedule=$hour:$minute, now=${now.hour}:${now.minute}:${now.second} → 통과(예약 -15분 창 이내)');

      final today = formatYmd(now);
      final lastDate = await tokenDs.getLastHeartbeatDate();
      if (lastDate == today) {
        debugPrint('[HeartbeatWorker] lastHeartbeatDate=$lastDate, today=$today → 스킵(오늘 전송 완료)');
        return true;
      }
      debugPrint('[HeartbeatWorker] lastHeartbeatDate=$lastDate, today=$today → 통과');

      // WorkManager 콜백이 어떤 경로로 fire됐는지 구분한다.
      // isInteractive=true  → 사용자가 폰을 깨워 Doze가 해제된 상태에서 fire (= 사용 흔적)
      // isInteractive=false → Doze maintenance window에서 자연 fire (= 사용 흔적 없음)
      // suspicious 판정 2단계에서 이 값이 활용된다.
      final wasInteractive = await ScreenState.isInteractive();
      debugPrint('[HeartbeatWorker] ScreenState.isInteractive=$wasInteractive (execute 호출 직전)');
      await HeartbeatService().execute(isInteractiveAtTrigger: wasInteractive);

      // 재등록 책임은 HeartbeatService._onHeartbeatSent 단일 — 자동/수동/pending/worker
      // 모든 성공 경로에서 일관되게 호출된다. worker callback에서 별도 schedule()을
      // 호출하지 않는다 (이전 안전망 패턴 제거: 한 번의 worker fire에서 cancel+register
      // mutation이 4건 발생하는 부작용을 막고, 단일 책임으로 일원화).
    } catch (e) {
      debugPrint('[HeartbeatWorker] 실행 실패: $e');
    }
    return true;
  });
}

/// WorkManager 기반 heartbeat 예약 서비스 (Android 전용)
///
/// 2계층 실행 구조:
///   - one-off: 예약시각에 1회 fire. 메인 전송 담당. 전송 성공 후 콜백에서
///     schedule()로 내일 예약시각에 재등록 (one-off + periodic 동시).
///   - periodic 15분: 안전망 폴링. one-off이 Doze 등으로 누락될 때 최대 15분 내
///     백업 발화. 첫 fire는 **예약시각 + 3분** (one-off과의 동시 발화 race를
///     물리적으로 회피 — 정상 조건에서 one-off이 먼저 전송 성공 → schedule()로
///     periodic을 first fire 전에 cancel). `schedule()` 호출 시마다
///     명시적 cancel 후 재등록하여 frequency/initialDelay 변경이 반영되도록 한다.
///
/// ─── 동시 발화(race) 방지 — 4계층 방어 ───
///
/// 예약시각 +3분 오프셋으로 one-off과 periodic의 첫 fire 시각을 분리했지만,
/// Doze maintenance window 특성상 두 job이 같은 window에 batch돼 동시 fire되는
/// race가 여전히 가능하다. 이 race는 아래 4계층으로 순차 차단된다:
///
/// 1) 콜백 레벨 — heartbeatWorkerCallback
///    `lastHeartbeatDate == today`면 즉시 스킵. 같은 날 두 번째 이상 진입 차단.
///
/// 2) Service 레벨 — HeartbeatService._executeInternal
///    `lastScheduledKey == 현재 scheduledKey`면 스킵. 성공 마커로 `_sendOrSavePending`
///    에서 API 전송 성공 후 save. 당일 재전송을 막는다.
///
/// 3) Lock 레벨 — HeartbeatLockDatasource.tryAcquire (주 방어선)
///    SQLite UNIQUE INSERT 기반 cross-isolate 원자 락. WorkManager는 워커마다 새
///    isolate를 생성하므로 SharedPreferences reload→check→save는 CAS가 아니다.
///    SQLite UNIQUE는 Android WAL로 cross-isolate writer를 직렬화해 하나만 INSERT
///    성공, 나머지는 UniqueConstraintError로 즉시 실패. TTL 30초 초과 stale 락은
///    tryAcquire 진입 시 자동 정리되어 crashed isolate가 남긴 락도 이어받는다.
///
/// 4) 서버 레벨 — POST /api/v1/heartbeat
///    `(device_id, scheduled_key)` idempotency로 HTTP retry 중복 전송을 차단한다.
///    dio connectionError 같이 응답 유실로 클라가 재시도해도 서버는 같은 key의
///    두 번째 요청은 부수효과(Push/alert) 없이 200 OK만 반환.
///
/// iOS는 이 서비스를 호출하지 않는다 — iOS G+S는 LocalAlarmService의
/// 오늘의 안부 확인 메시지 로컬 알림 + 앱 열기 자동 전송만으로 동작하며,
/// BGTaskScheduler를 사용하지 않는다.
class HeartbeatWorkerService {
  static const _taskName = 'heartbeat_task';
  static const _periodicName = 'heartbeat_periodic';
  static const _oneOffName = 'heartbeat_scheduled';

  /// periodic 폴링 간격. Android WorkManager의 minimum 제약(15분)과 동일.
  static const _pollFrequency = Duration(minutes: 15);

  /// periodic 첫 fire 오프셋.
  /// +3분: one-off(예약시각 정각)가 먼저 fire → 전송 성공 → schedule()로
  /// periodic을 first fire 전에 cancel. 정상(non-Doze) 조건에서 race 자체를 제거.
  /// Doze 배치로 동시 fire되는 경우에는 SQLite CAS + double-schedule로 처리.
  static const _periodicStartOffset = Duration(minutes: 3);

  /// Workmanager 초기화 (main()에서 1회 호출, Android에서만)
  static Future<void> init() async {
    await Workmanager().initialize(heartbeatWorkerCallback);
  }

  /// 예약 등록 (one-off + periodic 15분 동시 등록)
  ///
  /// one-off과 periodic 모두 **명시적 cancel 후 재등록**한다.
  /// `ExistingPeriodicWorkPolicy.update`는 frequency/initialDelay 변경을 무시하기
  /// 때문에, 예약시각 재설정이나 frequency 코드 변경이 기기에 반영되려면 기존
  /// 스케줄을 먼저 취소해야 한다. `cancelByUniqueName`은 명시적 취소라 REPLACE
  /// 정책의 self-cancel 이슈와 무관하게 안전하다.
  ///
  /// 4단계(cancel oneOff → register oneOff → cancel periodic → register periodic)는
  /// 비원자적이라 중간 단계에서 throw하면 cancel만 적용되고 register가 누락되어
  /// 양쪽 task 모두 사라진 상태가 영구 유지될 수 있다. 일시적 WorkManager DB
  /// 오류 대비 최대 2회 시도(첫 시도 실패 시 2초 후 재시도)로 방어한다.
  static Future<void> schedule(int hour, int minute) async {
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        await _doSchedule(hour, minute);
        return;
      } catch (e) {
        debugPrint('[HeartbeatWorker] schedule() 시도 $attempt 실패: $e');
        if (attempt == 1) {
          await Future.delayed(const Duration(seconds: 2));
        }
      }
    }
    debugPrint(
      '[HeartbeatWorker] schedule() 최종 실패 — 다음 _onHeartbeatSent 호출 또는 '
      '포그라운드 진입 시 자연 회복 대기',
    );
  }

  static Future<void> _doSchedule(int hour, int minute) async {
    final delay = _computeNextDelay(hour, minute);

    // one-off: 정확히 예약시각에 1회 fire
    await Workmanager().cancelByUniqueName(_oneOffName);
    await Workmanager().registerOneOffTask(
      _oneOffName,
      _taskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      inputData: {'source': 'one-off'},
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // periodic 15분: 안전망 폴링. 예약시각 +3분부터 첫 fire → 이후 15분마다.
    // 음수 오프셋으로 `delay + offset`이 음수가 되면 Android가 거부하므로
    // `Duration.zero`로 clamp (즉시 첫 fire → 대부분 Doze에 의해 다음
    // maintenance window로 자연 이연).
    final rawPeriodicDelay = delay + _periodicStartOffset;
    final periodicDelay =
        rawPeriodicDelay.isNegative ? Duration.zero : rawPeriodicDelay;
    await Workmanager().cancelByUniqueName(_periodicName);
    await Workmanager().registerPeriodicTask(
      _periodicName,
      _taskName,
      frequency: _pollFrequency,
      initialDelay: periodicDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      inputData: {'source': 'periodic'},
      constraints: Constraints(networkType: NetworkType.connected),
    );

    debugPrint(
      '[HeartbeatWorker] 예약 등록: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} '
      '(one-off ${delay.inHours}h ${delay.inMinutes % 60}m 후, '
      'periodic ${periodicDelay.inHours}h ${periodicDelay.inMinutes % 60}m 후 첫 fire → ${_pollFrequency.inMinutes}분 간격)',
    );
  }

  /// 다음 예약시각까지의 delay 계산 (이미 지났으면 내일)
  static Duration _computeNextDelay(int hour, int minute) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next.difference(now);
  }

  /// 예약 취소 (one-off + periodic 모두)
  static Future<void> cancel() async {
    await Workmanager().cancelByUniqueName(_oneOffName);
    await Workmanager().cancelByUniqueName(_periodicName);
  }
}
