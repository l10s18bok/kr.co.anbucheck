import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// 보호자 대상자 표시 순서 로컬 저장소 — invite_code 배열
/// 서버에 전송하지 않으며 보호자 기기에만 보관
class SubjectOrderLocalDatasource {
  static const _key = 'subject_order';

  Future<List<String>> getOrder() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_key);
    if (json == null) return const [];
    final list = jsonDecode(json) as List<dynamic>;
    return list.map((e) => e as String).toList();
  }

  Future<void> saveOrder(List<String> inviteCodes) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, jsonEncode(inviteCodes));
  }

  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}
