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
    // 백그라운드 isolate의 변경사항을 반영하기 위해 캐시 강제 갱신
    await prefs.reload();
    final json = prefs.getString(_key);
    if (json == null) return null;
    return jsonDecode(json) as Map<String, dynamic>;
  }

  Future<void> clearPending() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// **저장된 payload가 [payload] 그대로일 때만** 삭제한다.
  ///
  /// ⚠️ 무조건 [clearPending]을 부르면 **남의 메모를 지운다.** `_sendPendingInternal`은
  /// SQLite 락을 잡지 않으므로, A가 어제 메모를 전송하는 사이 B가 오늘 메모를 저장하면
  /// A의 성공 처리가 B의 오늘 메모를 삭제해버린다. B의 전송까지 실패하면 그날 걸음수가
  /// 통째로 사라진다. 지운 대상이 방금 내가 보낸 그것인지 확인하고 삭제한다.
  Future<void> clearPendingIfMatches(Map<String, dynamic> payload) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();
    final stored = prefs.getString(_key);
    if (stored == null) return;
    if (stored != jsonEncode(payload)) return;
    await prefs.remove(_key);
  }
}
