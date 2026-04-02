import 'package:anbucheck/app/core/config/api_config.dart';

class ApiEndpoints {
  ApiEndpoints._();

  /// 로컬 테스트: ApiConfig.baseUrl (http://10.0.2.2:8000)
  /// 프로덕션 배포 후: ApiConfig.baseUrl을 Railway URL로 교체
  static const String baseUrl = ApiConfig.baseUrl;
  static const Duration timeout = Duration(seconds: 30);

  // ────────────────────────────────────────────────
  // [공통] 사용자 등록
  // ────────────────────────────────────────────────

  /// POST /api/v1/users
  /// - 대상자: role="subject" 로 등록 → 서버가 invite_code 발급 (예: "K7M-4PXR")
  /// - 보호자: role="guardian" 으로 등록 → invite_code 없음
  /// 두 역할 모두 device_token을 응답으로 받아 이후 요청에 사용
  static const String users = '/api/v1/users';

  // ────────────────────────────────────────────────
  // [대상자 전용] 안부 확인 Heartbeat
  // ────────────────────────────────────────────────

  /// POST /api/v1/heartbeat
  /// - 대상자 앱이 서버의 FCM Silent Push(heartbeat_trigger)를 수신했을 때 호출
  /// - 센서 스냅샷(배터리, 화면 잠금 여부 등)을 포함하여 안부 신호를 전송
  /// - 서버는 수신 시각을 기록하고 경고 등급을 정상으로 리셋
  /// ※ 보호자 앱에서는 절대 호출하지 않음
  static const String heartbeat = '/api/v1/heartbeat';

  // ────────────────────────────────────────────────
  // [보호자 전용] 대상자 연결 관리
  // ────────────────────────────────────────────────

  /// POST /api/v1/subjects/link  { invite_code: "K7M-4PXR" }
  /// - 보호자가 대상자의 invite_code를 입력하여 연결 요청
  /// - 성공 시 guardians 테이블에 (subject_user_id, guardian_user_id) 매핑 생성
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String subjectsLink = '/api/v1/subjects/link';

  /// GET /api/v1/subjects
  /// - 보호자가 연결된 대상자 목록 및 각 대상자의 최신 heartbeat 상태 조회
  /// - 반환값: 대상자별 마지막 heartbeat 시각, 경고 등급(정상/주의/경고/긴급) 포함
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String subjects = '/api/v1/subjects';

  /// DELETE /api/v1/subjects/{guardianId}/unlink
  /// - 보호자가 특정 대상자와의 연결을 해제
  /// - guardianId: 보호자 본인의 user_id (경로 파라미터)
  /// ※ 대상자 앱에서는 호출하지 않음
  static String subjectUnlink(int guardianId) =>
      '/api/v1/subjects/$guardianId/unlink';

  // ────────────────────────────────────────────────
  // [보호자 전용] 구독 (인앱 결제)
  // ────────────────────────────────────────────────

  /// POST /api/v1/subscription
  /// - 보호자가 연간 구독(anbu_yearly, $9.99/년) 결제 영수증을 서버에 등록
  /// - 3개월 무료 체험 → 이후 유료 전환 시 호출
  /// ※ 대상자 앱은 완전 무료 — 구독 API 사용 없음
  static const String subscription = '/api/v1/subscription';

  /// POST /api/v1/subscription/verify
  /// - 앱 실행 시 보호자의 구독 유효성을 검증 (Apple/Google 영수증 재확인)
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String subscriptionVerify = '/api/v1/subscription/verify';

  /// POST /api/v1/subscription/restore
  /// - 보호자가 기기 변경 또는 재설치 후 기존 구독을 복원
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String subscriptionRestore = '/api/v1/subscription/restore';

  // ────────────────────────────────────────────────
  // [보호자 전용] 경고 알림 관리
  // ────────────────────────────────────────────────

  /// GET /api/v1/alerts
  /// - 보호자가 수신한 경고 알림 목록 조회
  ///   (주의 / 경고 / 긴급 등급별, 대상자별 필터링 가능)
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String alerts = '/api/v1/alerts';

  /// DELETE /api/v1/alerts/clear-all
  /// - 보호자가 모든 경고 알림을 일괄 해제
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String alertsClearAll = '/api/v1/alerts/clear-all';

  /// DELETE /api/v1/alerts/{alertId}/clear
  /// - 보호자가 특정 경고 알림 1건을 해제
  /// ※ 대상자 앱에서는 호출하지 않음
  static String alertClear(int alertId) => '/api/v1/alerts/$alertId/clear';

  // ────────────────────────────────────────────────
  // [공통] 기기 관리
  // ────────────────────────────────────────────────

  /// PUT /api/v1/devices/fcm-token  { fcm_token: "..." }
  /// - 대상자: FCM Silent Push(heartbeat_trigger) 수신용 토큰 갱신
  /// - 보호자: 경고 알림(Push Notification) 수신용 토큰 갱신
  /// 앱 재설치·기기 변경 시 반드시 호출
  static const String devicesFcmToken = '/api/v1/devices/fcm-token';

  /// GET /api/v1/devices/me
  /// - 현재 로그인된 기기 정보 조회 (device_id, 플랫폼, FCM 토큰 등록 여부)
  /// - 대상자·보호자 모두 사용 가능
  static const String devicesMe = '/api/v1/devices/me';

  /// PUT /api/v1/devices/{deviceId}/heartbeat-schedule  { heartbeat_hour, heartbeat_minute }
  /// - 대상자 전용: heartbeat 예약 시각 변경
  /// - 기본값 09:30, 변경 시 WorkManager/BGTaskScheduler 재예약
  /// ※ 보호자 앱에서는 호출하지 않음
  static String heartbeatSchedule(String deviceId) =>
      '/api/v1/devices/$deviceId/heartbeat-schedule';

  // ────────────────────────────────────────────────
  // [공통] 앱 버전
  // ────────────────────────────────────────────────

  /// GET /api/v1/app/version-check  ?version=1.0.0&platform=android
  /// - 앱 실행 시 강제 업데이트 여부 및 최신 버전 정보 확인
  /// - 대상자·보호자 모두 사용
  static const String versionCheck = '/api/v1/app/version-check';

  // ────────────────────────────────────────────────
  // [보호자 전용] 알림 설정
  // ────────────────────────────────────────────────

  /// GET / PUT /api/v1/guardian/notification-settings
  /// - 보호자가 경고 등급별 Push 알림 수신 여부를 설정
  ///   (예: 주의 등급 알림 끄기, 긴급만 수신 등)
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String guardianNotificationSettings =
      '/api/v1/guardian/notification-settings';

  // ────────────────────────────────────────────────
  // [보호자 전용] 알림 목록
  // ────────────────────────────────────────────────

  /// GET /api/v1/notifications
  /// - 당일 보호자 알림 목록 조회 (시간순)
  /// - 서버가 매일 00:00 KST에 전날 알림 삭제 → 항상 당일 알림만 반환
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String notifications = '/api/v1/notifications';

  /// DELETE /api/v1/notifications
  /// - 당일 보호자 알림 전체 삭제
  /// ※ 대상자 앱에서는 호출하지 않음
  static const String notificationsDeleteAll = '/api/v1/notifications';
}
