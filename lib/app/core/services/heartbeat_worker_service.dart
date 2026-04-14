import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
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
      debugPrint(
        '[HeartbeatWorker] 현재: ${now.hour}:${now.minute}:${now.second}, 예약: $hour:$minute',
      );
      if (now.isBefore(scheduled)) {
        debugPrint('[HeartbeatWorker] 예약시각 이전 — 스킵');
        return true;
      }

      final today = formatYmd(now);
      final lastDate = await tokenDs.getLastHeartbeatDate();
      if (lastDate == today) {
        debugPrint('[HeartbeatWorker] 오늘 이미 전송 완료 — 스킵');
        return true;
      }

      debugPrint('[HeartbeatWorker] heartbeat 전송 시도');
      await HeartbeatService().execute();
      debugPrint('[HeartbeatWorker] heartbeat 전송 완료');

      // 전송 성공 시 one-off만 내일로 재등록 (periodic은 그대로 폴링 유지)
      await HeartbeatWorkerService.rescheduleOneOffForNextDay(hour, minute);
    } catch (e) {
      debugPrint('[HeartbeatWorker] 실행 실패: $e');
    }
    return true;
  });
}

/// WorkManager 기반 heartbeat 예약 서비스 (Android 전용)
///
/// 2계층 구조:
///   - one-off: 정확히 예약시각(예: 09:30)에 1회 fire. 메인 전송 담당.
///     전송 성공 후 rescheduleOneOffForNextDay()로 내일 예약시각에 재등록.
///   - periodic 1시간: 안전망 폴링. one-off가 OEM 배터리 절약/Doze 등으로 누락될 때
///     최대 1시간 내 백업 발화. fire 후 재등록하지 않고 그대로 둔다
///     (flutter_workmanager의 UPDATE는 initialDelay를 무시하고, REPLACE는 자기자신을
///     취소하는 이슈가 있어 건드리면 오히려 폴링이 깨진다).
///
/// ─── 동시 발화(race) 방지 — 이중 방어 ───
///
/// flutter_workmanager는 워커마다 새 FlutterEngine/isolate를 생성하므로 Dart
/// `static _busy` 플래그는 cross-isolate에서 무력하다. 따라서 one-off와 periodic이
/// 거의 동시에 fire되면 SharedPreferences 기반 dedup이 유일한 방어선이 되는데,
/// 과거에는 `lastScheduledKey` save가 API 전송 성공 후에 있어 check→전송→save
/// 사이 최대 10~20초의 TOCTOU 윈도우가 열려 있었고, 그 틈에 두 워커가 모두
/// check를 통과해 중복 전송하는 사례가 실측됐다.
///
/// 현재 구조는 두 축으로 race를 차단한다:
///
/// 1) 선점(preempt) save — HeartbeatService._executeInternal
///    check 직후 센서 수집·API 전송을 시작하기 *전에* lastScheduledKey를 먼저
///    박는다. TOCTOU 윈도우가 prefs write 수준(~수 마이크로초)으로 축소되어,
///    같은 isolate가 아니어도 뒤따라 들어온 호출은 check 단계에서 즉시 스킵된다.
///
/// 2) periodic 3분 오프셋 — 이 파일
///    periodic의 첫 fire를 one-off보다 3분 뒤로 미뤄, 정각에 두 워커가 동시에
///    진입하는 케이스 자체를 구조적으로 제거한다. 3분은 비라운드 값으로,
///    사용자가 예약시각을 00/30분 같은 라운드 값으로 설정하는 일반적 패턴과
///    절대 겹치지 않아(09:30 → periodic 09:33) 로그 구분이 명확하다.
///      - one-off 정상 fire (예약시각 정각) → 전송 성공 → lastHeartbeatDate·
///        lastScheduledKey 기록 (수 초 내 완료)
///      - 3분 뒤 periodic 첫 fire → lastHeartbeatDate == 오늘 검사에서 스킵
///      - one-off가 누락된 경우에만 periodic이 실제 전송 → 원래 안전망 의도 유지
///        (백업 지연이 1시간에서 3분으로 단축)
///      - OEM 절전으로 one-off이 3분+ 지연되면 periodic이 먼저 전송하고 상태를
///        쓰며, 뒤늦은 one-off은 dedup으로 스킵된다 — 순서만 바뀔 뿐 중복 전송은
///        여전히 차단됨
///
/// 콜백 내 dedup 2중 방어선(lastHeartbeatDate + lastScheduledKey)은 그대로 남겨두어
/// periodic이 이후 매 1시간 폴링할 때 당일 재전송을 막는 역할을 수행한다.
///
/// iOS는 이 서비스를 호출하지 않는다 — iOS G+S는 LocalAlarmService의
/// 오늘의 안부 확인 메시지 로컬 알림 + 앱 열기 자동 전송만으로 동작하며,
/// BGTaskScheduler를 사용하지 않는다.
class HeartbeatWorkerService {
  static const _taskName = 'heartbeat_task';
  static const _periodicName = 'heartbeat_periodic';
  static const _oneOffName = 'heartbeat_scheduled';

  static const _pollFrequency = Duration(hours: 1);

  /// Workmanager 초기화 (main()에서 1회 호출, Android에서만)
  static Future<void> init() async {
    await Workmanager().initialize(heartbeatWorkerCallback);
  }

  /// 예약 등록 (one-off + periodic 1시간 동시 등록)
  static Future<void> schedule(int hour, int minute) async {
    final delay = _computeNextDelay(hour, minute);

    // one-off: 정확히 예약시각에 1회 fire
    await Workmanager().cancelByUniqueName(_oneOffName);
    await Workmanager().registerOneOffTask(
      _oneOffName,
      _taskName,
      initialDelay: delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    // periodic 1시간: 안전망 폴링
    // 첫 fire를 one-off보다 3분 뒤로 오프셋 — 두 워커가 같은 초에 fire되어
    // SharedPreferences 기반 dedup(TOCTOU)이 무력화되는 race를 구조적으로 차단.
    // 3분은 비라운드 값으로, 사용자가 예약시각을 00/30분 같은 라운드 값으로
    // 설정해도 periodic이 절대 겹치지 않아 로그 구분이 명확하다.
    // one-off 정상 동작 시: 3분 뒤 periodic 진입 시점엔 lastHeartbeatDate가 이미 오늘로
    // 저장돼 있어 콜백 1차 방어선에서 스킵. one-off 누락 시엔 3분 내 백업 발화.
    final periodicDelay = delay + const Duration(minutes: 3);
    await Workmanager().registerPeriodicTask(
      _periodicName,
      _taskName,
      frequency: _pollFrequency,
      initialDelay: periodicDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      constraints: Constraints(networkType: NetworkType.connected),
    );

    debugPrint(
      '[HeartbeatWorker] 예약 등록: ${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} '
      '(one-off ${delay.inHours}h ${delay.inMinutes % 60}m / periodic ${periodicDelay.inHours}h ${periodicDelay.inMinutes % 60}m 후 첫 fire)',
    );
  }

  /// 콜백 내부에서 전송 성공 후 호출 — one-off만 내일 예약시각으로 재등록.
  /// periodic은 손대지 않는다 (UPDATE는 무시되고 REPLACE는 자기자신 취소 위험).
  static Future<void> rescheduleOneOffForNextDay(int hour, int minute) async {
    try {
      final now = DateTime.now();
      final tomorrow = DateTime(
        now.year,
        now.month,
        now.day,
        hour,
        minute,
      ).add(const Duration(days: 1));
      final delay = tomorrow.difference(now);

      await Workmanager().cancelByUniqueName(_oneOffName);
      await Workmanager().registerOneOffTask(
        _oneOffName,
        _taskName,
        initialDelay: delay,
        existingWorkPolicy: ExistingWorkPolicy.replace,
        constraints: Constraints(networkType: NetworkType.connected),
      );
      debugPrint(
        '[HeartbeatWorker] one-off 내일로 재등록: ${delay.inHours}시간 ${delay.inMinutes % 60}분 후 fire',
      );
    } catch (e) {
      debugPrint('[HeartbeatWorker] one-off 재등록 실패: $e');
    }
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
