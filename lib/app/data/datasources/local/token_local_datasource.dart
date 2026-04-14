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
  static const _keySubscriptionActive = 'subscription_active';
  static const _keyIsAlsoSubject = 'is_also_subject';
  static const _keyLastScheduledKey = 'last_scheduled_key';

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
    await prefs.remove(_keySubscriptionActive);
    await prefs.remove(_keyIsAlsoSubject);
  }

}
