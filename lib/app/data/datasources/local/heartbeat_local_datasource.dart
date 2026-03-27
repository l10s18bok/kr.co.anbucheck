import 'dart:convert';
import 'package:anbucheck/app/core/database/app_database.dart';

/// heartbeat 전송 실패 큐 — 네트워크 오프라인 시 적재, 복구 후 일괄 전송
class HeartbeatLocalDatasource {
  Future<void> enqueue(Map<String, dynamic> payload) async {
    final db = await AppDatabase.instance;
    await db.insert('heartbeat_queue', {
      'payload': jsonEncode(payload),
      'created_at': DateTime.now().toIso8601String(),
    });
  }

  /// 큐 전체 조회 (오래된 순)
  Future<List<({int id, Map<String, dynamic> payload})>> getQueue() async {
    final db = await AppDatabase.instance;
    final rows = await db.query('heartbeat_queue', orderBy: 'created_at ASC');
    return rows.map((r) => (
          id: r['id'] as int,
          payload: jsonDecode(r['payload'] as String) as Map<String, dynamic>,
        )).toList();
  }

  Future<void> dequeue(int id) async {
    final db = await AppDatabase.instance;
    await db.delete('heartbeat_queue', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAll() async {
    final db = await AppDatabase.instance;
    await db.delete('heartbeat_queue');
  }

  Future<int> count() async {
    final db = await AppDatabase.instance;
    return (await db.rawQuery('SELECT COUNT(*) FROM heartbeat_queue'))
        .first
        .values
        .first as int;
  }
}
