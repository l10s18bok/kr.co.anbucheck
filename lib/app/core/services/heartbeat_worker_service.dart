import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:screen_state/screen_state.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tzlib;
import 'package:workmanager/workmanager.dart';
import 'package:anbucheck/app/core/network/api_client_factory.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';
import 'package:anbucheck/app/core/services/heartbeat_alarm.dart';
import 'package:anbucheck/app/core/utils/time_utils.dart';
import 'package:anbucheck/app/data/datasources/local/token_local_datasource.dart';

/// WorkManager 백그라운드 콜백 (top-level 함수 필수)
@pragma('vm:entry-point')
void heartbeatWorkerCallback() {
  Workmanager().executeTask((taskName, inputData) async {
    // 백그라운드 isolate는 main()의 debugPrint 오버라이드가 닿지 않으므로 별도 차단.
    if (kReleaseMode) {
      debugPrint = (String? message, {int? wrapWidth}) {};
    }
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

      // 등록 함수들이 "취소 대상 == 나 자신"을 판별할 수 있도록 가장 먼저 심는다.
      //
      // ⚠️ 업데이트 직후 **첫 발화는 구버전이 등록한 work**이라 inputData에 `unique`가
      // 없다. 그대로 null로 두면 자기 자신을 못 알아보고 레거시 이름을 취소해버려,
      // 바로 이 커밋이 없애려던 self-cancel이 업그레이드 시점에 한 번 더 발생한다.
      // `source`로 레거시 이름을 역산해 그 구멍을 막는다.
      HeartbeatWorkerService.triggerSource = inputData?['source'] as String?;
      HeartbeatWorkerService.runningUniqueName =
          inputData?['unique'] as String? ??
              HeartbeatWorkerService.legacyUniqueNameFor(
                  inputData?['source'] as String?);

      final tokenDs = TokenLocalDatasource();
      final role = await tokenDs.getUserRole();
      final isAlsoSubject = await tokenDs.getIsAlsoSubject();
      debugPrint('[HeartbeatWorker] task=$taskName role=$role, '
          'isAlsoSubject=$isAlsoSubject, unique=${HeartbeatWorkerService.runningUniqueName}');
      if (role != 'subject' && !isAlsoSubject) return true;

      final (hour, minute) = await tokenDs.getHeartbeatSchedule();

      // ★ 재무장을 **네트워크보다 먼저** 한다.
      //
      // Doze 유지보수 창은 30초~1분이고, 창이 만료되면 워커는 `onStopJob → stopEngine()`
      // 으로 즉시 죽는다. 재무장이 전송 뒤에 있으면 그 죽음에 걸릴 때마다 다음 날 트리거가
      // 사라진다. 앞으로 옮기면 진입 후 수십 ms만 살아 있어도 트리거가 보존된다.
      //
      // 아래 모든 분기(오늘 전송 완료 스킵 / 예약시각 이전 스킵 / 회복 전송 / 정시 전송)에
      // 공통 적용되며, 성공 경로의 `_onHeartbeatSent → schedule()`이 나중에 같은 값으로
      // 다시 등록해도 dated 이름이라 idempotent다.
      await HeartbeatWorkerService.rescheduleOneOffOnly(hour, minute);

      final now = DateTime.now();
      final today = formatYmd(now);
      final lastDate = await tokenDs.getLastHeartbeatDate();

      // 오늘 정시 전송 이미 완료 → 스킵 (콜백 레벨 1차 거름, 동시 발화 race 차단)
      if (lastDate == today) {
        debugPrint('[HeartbeatWorker] lastHeartbeatDate=$lastDate, today=$today → 스킵(오늘 전송 완료)');
        return true;
      }

      // WorkManager 콜백이 어떤 경로로 fire됐는지 구분한다.
      // isInteractive=true  → 사용자가 폰을 깨워 Doze가 해제된 상태에서 fire (= 사용 흔적)
      // isInteractive=false → Doze maintenance window에서 자연 fire (= 사용 흔적 없음)
      // suspicious 판정 2단계 + 아래 회복 전송 게이트 양쪽에서 이 값을 쓴다.
      final wasInteractive = await ScreenState.isInteractive();
      debugPrint('[HeartbeatWorker] ScreenState.isInteractive=$wasInteractive');

      final scheduled = DateTime(now.year, now.month, now.day, hour, minute);
      // 예약시각 -15분 이전이면 평소엔 스킵. periodic은 +3분 offset으로 등록되지만
      // initialDelay 이후 실제 발화 시점은 Doze maintenance window에 종속되어
      // 예측 불가하다 (Light Doze: 5/10/15분 주기, factor 2.0).
      // -15분 창은 이 변동성을 흡수하기 위한 가드이며, 동일 maintenance window에서
      // one-off과 periodic이 batch fire되어도 서버 측 (device_id, scheduled_key)
      // idempotency가 중복 전송을 차단하므로 조기 통과의 사용자 영향은 없다.
      //
      // 예외 — 회복 전송: 2일 이상(어제 포함 미전송) heartbeat 갭이 있을 때
      // 예약시각을 기다리지 않고 "살아있음" 신호를 보낸다.
      // (전송이 **성공**했다는 것 자체가 기기가 살아 온라인이라는 증거다. 망 제약을
      //  제거한 뒤로는 발화 사실만으로는 온라인을 단정할 수 없으므로 성공을 근거로 삼는다.)
      //
      // **정시 슬롯을 소비하지 않는다**(`recovery: true`) — 포그라운드 진입 회복 전송과
      // 동일한 경로다. 과거에는 여기서 정시 키로 전송해 lastHeartbeatDate를 오늘로
      // 박았고, 그 결과 예약시각 정시 전송이 콜백 상단의 `lastDate == today` 가드에
      // 걸려 스킵되면서 **그날 걸음수가 오전 일부까지만 기록**됐다(폰을 켠 시각이
      // 이르면 사실상 0). 회복 전송은 걸음수를 싣지 않는 생존 신호로 두고, 하루치
      // 걸음수는 예약시각 정시 전송이 온전히 담당하게 한다.
      // (`recovery: true` 경로는 _onHeartbeatSent를 호출하지 않으므로 재예약도 하지
      //  않는다 — 콜백 진입부의 `rescheduleOneOffOnly`가 그 자리를 이미 담당한다.)
      final earliestAllowed = scheduled.subtract(const Duration(minutes: 15));
      if (now.isBefore(earliestAllowed)) {
        final yesterday = formatYmd(now.subtract(const Duration(days: 1)));
        final isRecovery = lastDate != null &&
            lastDate.isNotEmpty &&
            lastDate != today &&
            lastDate != yesterday;
        if (isRecovery) {
          debugPrint('[HeartbeatWorker] 예약시각 이전 — 미전송 갭 감지 → 회복 전송(정시 슬롯 미소비)');
          await HeartbeatService().execute(recovery: true);
        } else {
          debugPrint('[HeartbeatWorker] 예약시각 -15분 이전 → 스킵 '
              '(isRecovery=$isRecovery, isInteractive=$wasInteractive)');
        }
        // 재무장은 콜백 진입부에서 이미 완료됐다(네트워크보다 먼저). 여기서 다시 하지 않는다.
        return true;
      }
      debugPrint('[HeartbeatWorker] schedule=$hour:$minute, lastHeartbeatDate=$lastDate → 통과');
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

  /// dated 이름 도입 **이전**에 쓰던 고정 one-off 이름. 업그레이드 기기에 남아 있으므로
  /// 새 이름으로 등록할 때 한 번 정리한다(자기 자신이면 건너뜀 — [_cancelLegacyOneOff]).
  static const _legacyOneOffName = 'heartbeat_scheduled';

  /// one-off unique name — **대상 발화 날짜를 이름에 넣는다.**
  ///
  /// ⚠️ 이 앱에서 실측으로 확인된 가장 치명적인 결함을 막기 위한 장치다.
  /// 고정 이름을 쓰면 `_registerOneOff`의 `cancelByUniqueName`이 **실행 중인 자기 자신**을
  /// 취소하고, `BackgroundWorker.onStopped() → stopEngine()`이 FlutterEngine을 파괴해
  /// 바로 다음 줄의 `registerOneOffTask`가 실행되지 못한다. 그러면 one-off이 영구 유실되고
  /// 예약시각 트리거가 사라진다(2026-08-18 02:16 실측: `Work [...] was cancelled` 직후
  /// 재등록 로그 없음 → 그날 18:00 트리거 소멸).
  ///
  /// 재무장은 항상 **다른 날짜**를 향하므로 이름이 겹치지 않고, 취소 대상이 자기 자신이 될
  /// 수 없다. 발화가 끝난 dated work는 WorkManager가 자동으로 prune한다.
  static String _oneOffNameFor(DateTime target) =>
      'heartbeat_scheduled_${formatYmd(target)}';

  /// 이 isolate에서 실행 중인 WorkManager unique work 이름 (`inputData['unique']`).
  /// 등록 함수들이 "취소 대상 == 나 자신"을 판별하는 유일한 근거다.
  /// 포그라운드 호출에서는 null이라 어떤 취소도 자기 취소가 될 수 없다.
  static String? runningUniqueName;

  /// 이 발화를 만든 트리거 — 진단 전용. `inputData['source']`를 그대로 담는다.
  ///
  /// 알람이 enqueue한 work는 `'alarm'`(리시버가 `payload_source`로 넣고 플러그인이
  /// `payload_` 접두사를 떼어 전달한다), 평소 등록은 `'one-off'`/`'periodic'`,
  /// 포그라운드 호출은 null이다.
  ///
  /// **판정에 쓰지 말 것.** 전송 실패 알림이 어느 계층에서 났는지 사후에 가리기 위한
  /// 로그용이다 — 2026-08-25에 `send_failed`를 보고 알람 실패로 오진했다가
  /// 프로세스 시작 사유를 뒤져서야 워커였음을 알아냈다.
  static String? triggerSource;

  /// 구버전이 등록한 work의 unique 이름 역산 — `inputData['unique']`가 없을 때만 사용.
  /// 업데이트 직후 첫 발화가 여기 해당한다([runningUniqueName] 참조).
  static String? legacyUniqueNameFor(String? source) => switch (source) {
        'periodic' => _periodicName,
        'one-off' => _legacyOneOffName,
        _ => null,
      };

  /// periodic 폴링 간격. Android WorkManager의 minimum 제약(15분)과 동일.
  static const _pollFrequency = Duration(minutes: 15);

  /// periodic의 flex 창 — **주기 전체**(= [_pollFrequency])로 명시 지정한다.
  ///
  /// ⚠️ 이 값을 넘기지 않으면 플러그인 기본값 `MIN_PERIODIC_FLEX_MILLIS`(5분)가 적용된다
  /// (`workmanager_android`의 `DEFAULT_FLEX_INTERVAL_SECONDS`). WorkManager는 periodic을
  /// `주기 - flex` 시점부터 주기 끝까지만 실행 가능하게 하므로, flex 5분이면 15분 주기의
  /// **마지막 5분 창에서만** 실행 가능해진다. 실행 기회가 1/3로 깎이는데, 그 창이 하필
  /// Doze 유지보수 창(하룻밤 1~5회, 약 64초)과 겹쳐야 하므로 적중률이 곱으로 낮아진다.
  /// 부작용으로 첫 fire도 코드상 오프셋(+3분)이 아니라 `+3분 + (15분 - 5분)` = **+13분**이
  /// 된다(2026-08-16 실측).
  ///
  /// flex = 주기로 두면 창 전체가 실행 가능 구간이 되어 Doze 창과 만날 확률이 회복된다.
  /// 폴링 자체를 약화시키는 변경이 아니라 **의도한 15분 폴링을 실제로 15분으로 되돌리는**
  /// 수정이다(PRD-FrontEnd §2.2 폴링 불변 규칙과 같은 방향).
  static const _periodicFlex = _pollFrequency;

  /// periodic 첫 fire 오프셋.
  /// +3분: one-off(예약시각 정각)가 먼저 fire → 전송 성공 → schedule()로
  /// periodic을 first fire 전에 cancel. 정상(non-Doze) 조건에서 race 자체를 제거.
  ///
  /// ⚠️ **동시 발화 회피라는 이 오프셋의 목적은 Doze에서는 달성되지 않는다** — 둘 다 밀려
  /// 있다가 같은 유지보수 창에서 함께 방출되기 때문(2026-08-18 02:16·15:22 실측 모두
  /// 동시 발화). Doze 배치 동시 fire는 SQLite CAS + `lastScheduledKey`가 막는다.
  static const _periodicStartOffset = Duration(minutes: 3);

  /// Workmanager 초기화 (main()에서 1회 호출, Android에서만)
  static Future<void> init() async {
    await Workmanager().initialize(heartbeatWorkerCallback);
  }

  /// 예약 등록 (periodic 15분 + one-off 동시 등록) — **전송 성공 / 시각 변경 / 앱 진입용**.
  ///
  /// one-off과 periodic 모두 **명시적 cancel 후 재등록**한다.
  /// `ExistingPeriodicWorkPolicy.update`는 frequency/initialDelay 변경을 무시하기
  /// 때문에, 예약시각 재설정이나 frequency 코드 변경이 기기에 반영되려면 기존
  /// 스케줄을 먼저 취소해야 한다. `cancelByUniqueName`은 명시적 취소라 REPLACE
  /// 정책의 self-cancel 이슈와 무관하게 안전하다.
  ///
  /// 전송 성공 경로(`_onHeartbeatSent`)에서 호출되면 periodic도 내일자로 재워
  /// 밤샘 15분 폴링을 꺼 배터리를 아낀다. **전송 실패 경로는 이 함수가 아니라
  /// [rescheduleOneOffOnly]를 호출**한다 — 실패 시 periodic을 끄면 당일 재시도
  /// 안전망이 사라지기 때문(periodic을 살려둬야 같은 날 네트워크 복구를 15분 내 잡음).
  ///
  /// **비원자성 완화 (Defect 2)**: 과거에는 cancel/register 4단계를 한 try로 묶어
  /// 중간 throw 시 cancel만 적용되고 register가 누락되면 **양쪽 task가 영구 유실**될
  /// 수 있었다. 이제 안전망인 periodic을 **먼저** 등록하고, periodic·one-off 등록을
  /// **각각 독립 try + 2회 재시도**로 분리한다. 한쪽 등록이 WorkManager DB 오류로
  /// 실패해도 다른 쪽이 stranded되지 않으며, 가장 중요한 periodic이 우선 자리잡는다.
  /// "둘 다 영구 유실"은 두 독립 연산이 각각 2회씩 실패해야 발생해 확률이 크게 낮다.
  static Future<void> schedule(int hour, int minute) async {
    // [실험] Doze 관통 알람 프로브를 **heartbeat와 같은 시각**으로 무장한다.
    // 같은 순간을 두 메커니즘이 겨루게 해야 비교가 성립한다 —
    // WorkManager one-off은 창을 기다리고(실측 +2.5~3h), 알람은 안 기다린다(기대 +2~15m).
    // 포그라운드에서만 성공하며 실패해도 무해하다(리시버가 매일 자가 재무장).
    unawaited(HeartbeatAlarm.arm(hour, minute));
    // periodic(안전망) 우선 — one-off 등록이 실패해도 15분 폴링은 살아남는다.
    await _retryRegister('periodic', () => _registerPeriodic(hour, minute));
    await _retryRegister('one-off', () => _registerOneOff(hour, minute));
  }

  /// **전송 실패 경로 전용** — one-off만 내일자로 재무장하고 periodic 15분 폴링은
  /// 건드리지 않는다.
  ///
  /// 전송이 한 번이라도 성공하면 [schedule]이 periodic까지 내일로 재워(배터리 절약)
  /// 밤샘 폴링을 끄는 불변식은 유지된다. 단 **전송 실패 동안에는 당일 재시도가 살아
  /// 있어야 하므로 periodic을 끄지 않는다** — 살아있는 periodic이 15분 주기로 같은 날
  /// 네트워크 복구를 잡아 보류 큐를 비운다. 과거에는 실패 분기가 풀 schedule()을 불러
  /// periodic을 내일로 밀어버려, 일시적 통신 장애가 그날의 15분 안전망을 통째로
  /// 해체하던 결함(Defect 1)이 있었다.
  ///
  /// one-off은 이미 fire되어 소비됐으므로 내일자로 재무장만 한다(periodic이 당일을
  /// 커버하고, 성공 시 schedule()이 one-off도 내일자로 재확정한다).
  /// **worker 콜백 진입 시(네트워크보다 먼저)와 전송 실패 경로**에서 호출된다.
  /// one-off은 dated 이름이라 몇 번을 불러도 같은 대상 1건으로 수렴한다(idempotent).
  static Future<void> rescheduleOneOffOnly(int hour, int minute) async {
    await _retryRegister('one-off 재무장', () => _registerOneOff(hour, minute));
  }

  /// 단일 등록 연산을 일시적 WorkManager DB 오류 대비 최대 2회 시도.
  static Future<void> _retryRegister(
      String label, Future<void> Function() op) async {
    for (var attempt = 1; attempt <= 2; attempt++) {
      try {
        await op();
        return;
      } catch (e) {
        debugPrint('[HeartbeatWorker] $label 등록 시도 $attempt 실패: $e');
        if (attempt == 1) await Future.delayed(const Duration(seconds: 2));
      }
    }
    debugPrint(
      '[HeartbeatWorker] $label 등록 최종 실패 — 다음 _onHeartbeatSent 호출 또는 '
      '포그라운드 진입 시 자연 회복 대기',
    );
  }

  /// one-off: 정확히 예약시각에 1회 fire.
  ///
  /// **취소를 하지 않는다.** 이름에 대상 날짜가 들어가므로 등록 대상은 실행 중인 work과
  /// 항상 다른 이름이고, 따라서 self-cancel이 원리적으로 불가능하다([_oneOffNameFor] 참조).
  static Future<void> _registerOneOff(int hour, int minute) async {
    final next = _computeNextFire(hour, minute);
    final name = _oneOffNameFor(next);
    if (name == runningUniqueName) {
      // 같은 날짜로 재등록하려는데 그게 곧 지금 실행 중인 나 자신인 경우.
      // 취소하면 엔진이 죽어 이 뒤가 전부 유실되므로 조용히 건너뛴다.
      debugPrint('[HeartbeatWorker] one-off 재등록 스킵 — 자기 자신 ($name)');
      return;
    }
    final delay = next.difference(DateTime.now());
    await Workmanager().registerOneOffTask(
      name,
      _taskName,
      initialDelay: delay.isNegative ? Duration.zero : delay,
      existingWorkPolicy: ExistingWorkPolicy.replace,
      inputData: {'source': 'one-off', 'unique': name},
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
    debugPrint(
      '[HeartbeatWorker] one-off 등록: $name (${delay.inHours}h ${delay.inMinutes % 60}m 후)',
    );
    await _cancelLegacyOneOff();
  }

  /// 업그레이드 기기에 남아 있는 고정 이름 one-off 정리 (1회성, 이후 no-op).
  /// 자기 자신이면 건너뛴다 — 업데이트 직후 첫 발화는 레거시 이름으로 실행되므로
  /// 여기서 취소하면 그게 바로 우리가 없애려던 self-cancel이 된다.
  static Future<void> _cancelLegacyOneOff() async {
    if (runningUniqueName == _legacyOneOffName) {
      debugPrint('[HeartbeatWorker] 레거시 one-off 정리 보류 — 자기 자신');
      return;
    }
    try {
      await Workmanager().cancelByUniqueName(_legacyOneOffName);
    } catch (_) {}
  }

  /// periodic 15분: 안전망 폴링. 예약시각 +3분부터 첫 fire → 이후 15분마다.
  static Future<void> _registerPeriodic(int hour, int minute) async {
    // ★ 실행 중인 periodic worker 자신은 재등록하지 않는다.
    //
    // periodic은 단일 이름이라 dated one-off처럼 이름으로 갈라낼 수 없다. 그래서
    // "자기 자신이면 아예 건드리지 않는" 방식으로 self-cancel을 막는다. 이 경우 periodic은
    // 재워지지 않고 15분 주기를 유지하지만(세션 예산 소모), **취소했다가 재등록에 실패해
    // 영구 유실되는 것보다 훨씬 낫다.** 다음에 one-off worker나 포그라운드가 `schedule()`을
    // 부를 때 정상적으로 재워진다.
    //
    // one-off이 정상 동작하는 한 이 분기는 드물다 — 평소엔 예약시각 one-off이 먼저 성공해
    // `_onHeartbeatSent`를 호출하고, 그때 runningUniqueName은 dated one-off 이름이다.
    if (runningUniqueName == _periodicName) {
      debugPrint('[HeartbeatWorker] periodic 재등록 스킵 — 자기 자신');
      return;
    }
    final delay = _computeNextDelay(hour, minute);
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
      flexInterval: _periodicFlex,
      initialDelay: periodicDelay,
      existingWorkPolicy: ExistingPeriodicWorkPolicy.update,
      inputData: {'source': 'periodic', 'unique': _periodicName},
      constraints: Constraints(networkType: NetworkType.notRequired),
    );
    debugPrint(
      '[HeartbeatWorker] periodic 등록: ${_hhmm(hour, minute)} '
      '(첫 fire ${periodicDelay.inHours}h ${periodicDelay.inMinutes % 60}m 후 '
      '→ ${_pollFrequency.inMinutes}분 간격, flex ${_periodicFlex.inMinutes}분)',
    );
  }

  static String _hhmm(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  /// 다음 예약시각 발화 시점 (이미 지났으면 내일)
  static DateTime _computeNextFire(int hour, int minute) {
    final now = DateTime.now();
    var next = DateTime(now.year, now.month, now.day, hour, minute);
    if (!next.isAfter(now)) {
      next = next.add(const Duration(days: 1));
    }
    return next;
  }

  /// 다음 예약시각까지의 delay 계산 (이미 지났으면 내일)
  static Duration _computeNextDelay(int hour, int minute) =>
      _computeNextFire(hour, minute).difference(DateTime.now());

  /// 예약 취소 (one-off + periodic 모두).
  ///
  /// one-off은 dated 이름이라 존재할 수 있는 것이 "오늘분"과 "내일분" 둘뿐이다
  /// (재무장은 항상 다음 발화 1건만 등록한다). 레거시 고정 이름도 함께 정리한다.
  static Future<void> cancel() async {
    // [실험] Doze 관통 알람도 함께 해제한다. 이게 없으면 heartbeat 책임이 사라진 뒤에도
    // (401로 계정 삭제·G+S 비활성화·탈퇴·모드 전환) 알람이 매일 발화해 앱을 깨우고
    // 엔진을 띄운 뒤 Dart가 role 체크로 빠져나오는 낭비가 반복된다.
    //
    // ⚠️ 채널이 MainActivity에 있어 **포그라운드에서만 실제로 취소된다.** G+S 비활성화·
    // 탈퇴·모드 전환은 전부 포그라운드라 문제없고, 백그라운드 isolate에서 오는 401 경로는
    // 취소가 스킵되지만 그때도 Dart의 role 가드가 매 발화를 무해하게 만든다.
    unawaited(HeartbeatAlarm.cancel());
    final now = DateTime.now();
    for (final d in [now, now.add(const Duration(days: 1))]) {
      await Workmanager().cancelByUniqueName(_oneOffNameFor(d));
    }
    await Workmanager().cancelByUniqueName(_legacyOneOffName);
    await Workmanager().cancelByUniqueName(_periodicName);
  }
}
