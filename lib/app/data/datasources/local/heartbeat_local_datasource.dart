import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// heartbeat 전송 실패 시 마지막 1건 보관 — 네트워크 복구 후 재전송
/// 복수 보관 불필요: 서버는 최신 1건으로 경고 해소 및 알림 발송 처리
class HeartbeatLocalDatasource {
  static const _key = 'pending_heartbeat';

  Future<void> savePending(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(payload));
  }

  Future<Map<String, dynamic>?> getPending() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
