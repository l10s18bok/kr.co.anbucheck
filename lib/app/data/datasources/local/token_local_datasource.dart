import 'dart:io';
import 'dart:math';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 인증/사용자 관련 로컬 저장소
/// device_id, device_token, user_id, user_role, invite_code
class TokenLocalDatasource {
  static const _keyDeviceId = 'device_id';
  static const _keyDeviceToken = 'device_token';
  static const _keyUserId = 'user_id';
  static const _keyUserRole = 'user_role';
  static const _keyInviteCode = 'invite_code';
  static const _keyHeartbeatHour = 'heartbeat_hour';
  static const _keyHeartbeatMinute = 'heartbeat_minute';
  static const _keyLastHeartbeatDate = 'last_heartbeat_date';
  static const _keyLastHeartbeatTime = 'last_heartbeat_time';
  static const _keyLastManualReportDate = 'last_manual_report_date';
  static const _keySubscriptionActive = 'subscription_active';
  static const _keySubscriptionPlan = 'subscription_plan';
  static const _keyIsAlsoSubject = 'is_also_subject';
  static const _keyLastScheduledKey = 'last_scheduled_key';
  static const _keyLastRecoveryDate = 'last_recovery_date';
  static const _keyPendingBuy = 'pending_buy';

  // iOS Keychain: 재설치 후에도 device_id 복원용 (identifierForVendor는 vendor 앱
  // 전부 삭제 후 재설치 시 변경되므로, Keychain 백업이 없으면 계정 복원이 불가능)
  // accessibility=unlocked_this_device: iCloud 동기화 차단 → 기기 단위로만 유지
  static const _iosKeychainDeviceIdKey = 'anbucheck_device_id';
  static const _secureStorage = FlutterSecureStorage(
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.unlocked_this_device,
    ),
  );

  // ── device_id ─────────────────────────────────────────────
  Future<String> getOrCreateDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    final existing = prefs.getString(_keyDeviceId);
    if (existing != null) return existing;
    final newId = await _getHardwareDeviceId();
    await prefs.setString(_keyDeviceId, newId);
    // iOS: Keychain에도 저장 (재설치 복원용)
    if (Platform.isIOS) {
      try {
        await _secureStorage.write(key: _iosKeychainDeviceIdKey, value: newId);
      } catch (_) {}
    }
    return newId;
  }

  /// 기기 고유 ID 조회
  /// Android: SSAID(Settings.Secure.ANDROID_ID) 네이티브 채널로 직접 조회 — 앱 재설치 후에도
  ///           유지, 공장 초기화 시에만 변경. device_info_plus의 AndroidDeviceInfo.id는
  ///           Build.ID(펌웨어 빌드 식별자)라 같은 기종·같은 빌드의 모든 기기가 동일한 값을
  ///           반환하므로 절대 사용 금지 — 서로 다른 두 기기가 같은 계정으로 합쳐지는
  ///           계정 탈취급 버그로 이어진다.
  /// iOS: Keychain 우선 → identifierForVendor fallback
  ///       IDFV는 같은 vendor 앱을 모두 삭제 후 재설치하면 바뀌므로, 계정 복원을
  ///       위해 최초 발급값을 Keychain에 백업해두고 재설치 시 그대로 돌려준다.
  static const _androidDeviceIdChannel = MethodChannel('anbucheck/device_id');

  /// ⚠️ 반드시 포그라운드(MainActivity가 살아있는) 컨텍스트에서 호출해야 한다.
  /// `anbucheck/device_id` 채널 핸들러는 `MainActivity`에만 등록되어 있어 WorkManager
  /// 백그라운드 isolate에서 호출하면 예외로 실패 → fallback 랜덤 ID가 그대로 영구
  /// 저장된다. 현재 이 함수는 `getOrCreateDeviceId()`를 통해 모드 선택·온보딩 등
  /// 포그라운드 플로우에서만 호출되며, 이 불변조건이 깨지지 않도록 유지할 것.
  static Future<String> _getHardwareDeviceId() async {
    if (Platform.isAndroid) {
      try {
        final ssaid = await _androidDeviceIdChannel.invokeMethod<String>('getAndroidId');
        if (ssaid != null && ssaid.isNotEmpty) return ssaid;
      } catch (_) {}
      return _generateFallbackId();
    } else if (Platform.isIOS) {
      try {
        final keychainId = await _secureStorage.read(key: _iosKeychainDeviceIdKey);
        if (keychainId != null && keychainId.isNotEmpty) return keychainId;
      } catch (_) {}
      final info = DeviceInfoPlugin();
      final ios = await info.iosInfo;
      return ios.identifierForVendor ?? _generateFallbackId();
    }
    return _generateFallbackId();
  }

  /// SSAID/IDFV 조회 실패 시에만 쓰이는 fallback — 반드시 암호학적으로 안전한 난수를
  /// 사용한다. DateTime 기반 난수는 짧은 시간 창(예: 여러 기기를 동시에 설정하는 상황)
  /// 안에서 같은 값이 나올 수 있어, 지금 고치려는 device_id 충돌 버그를 fallback 안에
  /// 그대로 재현하게 된다.
  static String _generateFallbackId() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 0x0f) | 0x40;
    bytes[8] = (bytes[8] & 0x3f) | 0x80;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-'
        '${hex.substring(12, 16)}-${hex.substring(16, 20)}-'
        '${hex.substring(20)}';
  }

  Future<String?> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceId);
  }

  Future<void> saveDeviceId(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceId, id);
  }

  // ── device_token ──────────────────────────────────────────
  Future<String?> getDeviceToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyDeviceToken);
  }

  Future<void> saveDeviceToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyDeviceToken, token);
  }

  // ── user_id ───────────────────────────────────────────────
  Future<int?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  Future<void> saveUserId(int id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, id);
  }

  // ── user_role (subject | guardian) ────────────────────────
  Future<String?> getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyUserRole);
  }

  Future<void> saveUserRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUserRole, role);
  }

  // ── invite_code (대상자 전용) ──────────────────────────────
  Future<String?> getInviteCode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyInviteCode);
  }

  Future<void> saveInviteCode(String code) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyInviteCode, code);
  }

  // ── heartbeat 스케줄 ──────────────────────────────────────
  Future<(int, int)> getHeartbeatSchedule() async {
    final prefs = await SharedPreferences.getInstance();
    final hour = prefs.getInt(_keyHeartbeatHour) ?? 9;
    final minute = prefs.getInt(_keyHeartbeatMinute) ?? 30;
    return (hour, minute);
  }

  Future<void> saveHeartbeatSchedule(int hour, int minute) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHeartbeatHour, hour);
    await prefs.setInt(_keyHeartbeatMinute, minute);
  }

  // ── 마지막 heartbeat 전송 날짜 (yyyy-MM-dd) ───────────────
  Future<String?> getLastHeartbeatDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastHeartbeatDate);
  }

  Future<void> saveLastHeartbeatDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastHeartbeatDate, date);
  }

  // ── 마지막 heartbeat 전송 시각 (HH:mm) ──────────────────────
  Future<String?> getLastHeartbeatTime() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastHeartbeatTime);
  }

  Future<void> saveLastHeartbeatTime(String time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastHeartbeatTime, time);
  }

  // ── 마지막 수동 보고 날짜 (yyyy-MM-dd) ─────────────────────
  // 수동 보고는 하루 1회로 제한. 컨트롤러에서 reportNow 진입 시 검사하여
  // 동일 날짜 재시도를 차단한다.
  Future<String?> getLastManualReportDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastManualReportDate);
  }

  Future<void> saveLastManualReportDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastManualReportDate, date);
  }

  // ── 마지막 전송 예약키 (yyyy-MM-dd_HH:mm) ─────────────────
  // 동일 예약시각에 대한 중복 전송 방지 (날짜+예약시각 조합)
  Future<String?> getLastScheduledKey() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastScheduledKey);
  }

  Future<void> saveLastScheduledKey(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastScheduledKey, key);
  }

  Future<void> clearLastScheduledKey() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastScheduledKey);
  }

  // ── 마지막 회복 전송 날짜 (yyyy-MM-dd) ─────────────────────
  // 예약시각 이전 회복 전송의 당일 1회 제한 마커. lastScheduledKey와 분리되어
  // 있어 회복 전송이 그 날 정시 슬롯을 소비하지 않는다.
  Future<String?> getLastRecoveryDate() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyLastRecoveryDate);
  }

  Future<void> saveLastRecoveryDate(String date) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastRecoveryDate, date);
  }

  // ── 구독 활성화 여부 ──────────────────────────────────────
  Future<bool> getSubscriptionActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySubscriptionActive) ?? false; // 미설정 시 비활성으로 간주 (신규 설치 기본값 false — true이면 결제 없이 구독 활성으로 보이는 심사 리젝 원인)
  }

  Future<void> saveSubscriptionActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySubscriptionActive, active);
  }

  /// 구독 플랜 (free_trial / yearly / expired) — Settings 카드 첫 표시 시
  /// 서버 응답 도착 전 마지막으로 알려진 plan으로 즉시 hydrate해 회색→인디고
  /// 1초 깜빡임을 차단한다.
  Future<String> getSubscriptionPlan() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keySubscriptionPlan) ?? '';
  }

  Future<void> saveSubscriptionPlan(String plan) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keySubscriptionPlan, plan);
  }

  // ── IAP 사용자 명시 구매 의도 플래그 ─────────────────────────
  // buy() 호출 시 true로 설정하고 .purchased 처리 완료 후 false로 해제.
  // 앱 강제 종료 후 재시작 시에도 pending 트랜잭션을 올바르게 verify할 수 있도록 영속.
  Future<bool> getPendingBuy() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyPendingBuy) ?? false;
  }

  Future<void> savePendingBuy(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyPendingBuy, value);
  }

  // ── 보호자+대상자(G+S) 여부 ────────────────────────────────
  Future<bool> getIsAlsoSubject() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsAlsoSubject) ?? false;
  }

  Future<void> saveIsAlsoSubject(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyIsAlsoSubject, value);
  }

  // ── 전체 삭제 ─────────────────────────────────────────────
  /// 탈퇴·모드 변경 등 "계정 초기화" 시 호출. device_id 관련 SharedPreferences
  /// 키 전체를 제거한다. iOS Keychain의 device_id는 "같은 기기 식별" 용도로
  /// 의도적으로 유지 — 서버에 이미 계정이 삭제된 상태이므로 재가입 시 자연스럽게
  /// 새 계정으로 등록된다.
  ///
  /// subscription_active는 remove만 하면 getter 기본값이 true라 탈퇴 직후
  /// 서버 응답 오기 전까지 "구독 활성"으로 잠깐 보이는 문제가 있어, 명시적으로
  /// false를 저장한다.
  Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyDeviceId);
    await prefs.remove(_keyDeviceToken);
    await prefs.remove(_keyUserId);
    await prefs.remove(_keyUserRole);
    await prefs.remove(_keyInviteCode);
    await prefs.remove(_keyHeartbeatHour);
    await prefs.remove(_keyHeartbeatMinute);
    await prefs.remove(_keyLastHeartbeatDate);
    await prefs.remove(_keyLastHeartbeatTime);
    await prefs.remove(_keyLastManualReportDate);
    await prefs.remove(_keyIsAlsoSubject);
    await prefs.remove(_keyLastScheduledKey);
    await prefs.remove(_keyLastRecoveryDate);
    await prefs.remove(_keySubscriptionPlan);
    await prefs.remove(_keyPendingBuy);
    await prefs.setBool(_keySubscriptionActive, false);
  }

}
