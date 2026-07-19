import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 대상자 연락처 로컬 저장소 — invite_code → phone number 매핑
/// 서버에 전송하지 않으며 보호자 기기에만 보관 (선택 입력)
class SubjectPhoneLocalDatasource {
  static const _key = 'subject_phones';

  Future<Map<String, String>> getAll() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return {};
    final map = jsonDecode(json) as Map<String, dynamic>;
    return map.map((k, v) => MapEntry(k, v as String));
  }

  Future<String?> getPhone(String inviteCode) async {
    final all = await getAll();
    return all[inviteCode];
  }

  Future<void> save(String inviteCode, String phone) async {
    final prefs = await SharedPreferences.getInstance();
    final all = await getAll();
    all[inviteCode] = phone;
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
  }
}
