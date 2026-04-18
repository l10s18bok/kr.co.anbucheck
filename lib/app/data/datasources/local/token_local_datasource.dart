import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
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
  static const _keyIsAlsoSubject = 'is_also_subject';
  static const _keyLastScheduledKey = 'last_scheduled_key';
  static const _keyHeartbeatInFlight = 'heartbeat_in_flight';

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
  /// Android: SSAID (앱 재설치 후에도 유지, 공장 초기화 시 변경)
  /// iOS: Keychain 우선 → identifierForVendor fallback
  ///       IDFV는 같은 vendor 앱을 모두 삭제 후 재설치하면 바뀌므로, 계정 복원을
  ///       위해 최초 발급값을 Keychain에 백업해두고 재설치 시 그대로 돌려준다.
  static Future<String> _getHardwareDeviceId() async {
    final info = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await info.androidInfo;
      return android.id;
    } else if (Platform.isIOS) {
      try {
        final keychainId = await _secureStorage.read(key: _iosKeychainDeviceIdKey);
        if (keychainId != null && keychainId.isNotEmpty) return keychainId;
      } catch (_) {}
      final ios = await info.iosInfo;
      return ios.identifierForVendor ?? _generateFallbackId();
    }
    return _generateFallbackId();
  }

  static String _generateFallbackId() {
    final bytes = List<int>.generate(16, (_) => DateTime.now().microsecondsSinceEpoch % 256);
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

  // ── heartbeat 진행 중 마커 (ms epoch, TTL 30초) ─────────────
  // 동일 예약시각에 여러 isolate가 동시 진입하는 것을 차단하는 mutual
  // exclusion 락. 과거에는 lastScheduledKey를 선점 save해 락과 성공 마커를
  // 겸용했는데, Worker가 Doze/OEM 절전으로 중도 종료되면 성공 마커만 남아
  // 2차 안전망이 영구 차단되는 ghost state 버그가 있었다. 이제는 책임을
  // 분리해 in_flight는 락 전용이며, TTL 초과 시 이전 isolate가 크래시한
  // 것으로 간주하고 새 진입자가 이어받는다.
  Future<int?> getHeartbeatInFlight() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyHeartbeatInFlight);
  }

  Future<void> saveHeartbeatInFlight(int epochMs) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyHeartbeatInFlight, epochMs);
  }

  Future<void> clearHeartbeatInFlight() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyHeartbeatInFlight);
  }

  // ── 구독 활성화 여부 ──────────────────────────────────────
  Future<bool> getSubscriptionActive() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keySubscriptionActive) ?? true; // 미설정 시 활성으로 간주 (서버 응답 전 만료 배너 깜빡임 방지)
  }

  Future<void> saveSubscriptionActive(bool active) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keySubscriptionActive, active);
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
    await prefs.remove(_keyHeartbeatInFlight);
    await prefs.setBool(_keySubscriptionActive, false);
  }

}
