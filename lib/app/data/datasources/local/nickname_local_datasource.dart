import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 대상자 별칭 로컬 저장소 — invite_code → nickname 매핑
///
/// 로컬이 원본(source of truth)이다. 서버에는 보호자 Push 제목에 "누구의
/// 알림인지"를 표시하기 위한 사본만 올라간다 (PUT /api/v1/subjects/aliases).
/// [getSyncedSnapshot] / [saveSyncedSnapshot]은 마지막으로 서버 동기화에
/// 성공한 맵을 기록해, 현재 맵과 다를 때만 재전송하도록 한다 — 이 스냅샷
/// 비교 하나로 백필·개별 저장·실패 후 재시도가 모두 처리된다.
class NicknameLocalDatasource {
  static const _key = 'nicknames';
  static const _syncedKey = 'nicknames_synced';

  Future<Map<String, String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return {};
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as String));
  }

  Future<String?> getNickname(String inviteCode) async {
    final all = await getAll();
    return all[inviteCode];
  }

  Future<void> save(String inviteCode, String nickname) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all[inviteCode] = nickname;
    await prefs.setString(_key, jsonEncode(all));
  }

  Future<void> remove(String inviteCode) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all.remove(inviteCode);
    await prefs.setString(_key, jsonEncode(all));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
    await prefs.remove(_syncedKey);
  }

  /// 마지막으로 서버 동기화에 성공한 별칭 맵 (없으면 null — 아직 한 번도 안 올림)
  Future<Map<String, String>?> getSyncedSnapshot() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_syncedKey);
    if (json == null) return null;
    try {
      final map = jsonDecode(json) as Map<String, dynamic>;
      return map.map((k, v) => MapEntry(k, v as String));
    } catch (_) {
      return null; // 손상된 값은 미동기화로 간주 → 다음 기회에 재전송
    }
  }

  Future<void> saveSyncedSnapshot(Map<String, String> synced) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_syncedKey, jsonEncode(synced));
  }
}
