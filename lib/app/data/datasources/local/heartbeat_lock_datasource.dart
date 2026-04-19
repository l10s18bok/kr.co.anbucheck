import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart' as sql;
import 'package:sqflite/sqflite.dart' show DatabaseException;

/// heartbeat 전송 시작 직전 획득하는 cross-isolate atomic 락.
///
/// Android WorkManager는 워커(one-off / periodic)마다 새 FlutterEngine/isolate를
/// 생성하므로 Dart static 플래그·SharedPreferences 기반 mutex는 cross-isolate에서
/// CAS(compare-and-swap)가 아니다. 두 isolate가 같은 ms에 `reload → get → save`를
///수행하면 둘 다 in_flight=null을 보고 둘 다 save해 락이 무력화된다.
///
/// 이 datasource는 SQLite `UNIQUE` 제약 + `INSERT` 예외를 cross-isolate 원자 연산으로
/// 사용한다. Android SQLite는 WAL 저널로 동일 DB 파일에 대한 writer를 진짜 직렬화하므로,
/// 동시에 두 isolate가 `INSERT`를 시도해도 하나만 성공하고 나머지는 `UNIQUE` 예외로
/// 즉시 실패한다. 이게 현재 구조에서 얻을 수 있는 유일한 진짜 CAS다.
class HeartbeatLockDatasource {
  static const _dbName = 'heartbeat_locks.db';
  static const _table = 'heartbeat_locks';

  /// 크래시 isolate가 남긴 락을 새 진입자가 이어받기 위한 TTL (ms).
  /// 정상 전송은 센서/API 포함 최대 ~15초 내 끝나므로 30초면 충분하다.
  static const _ttlMs = 30000;

  static Future<sql.Database> _open() async {
    final path = '${await sql.getDatabasesPath()}/$_dbName';
    return sql.openDatabase(
      path,
      version: 1,
      onCreate: (db, _) async {
        await db.execute(
          'CREATE TABLE $_table ('
          'scheduled_key TEXT PRIMARY KEY, '
          'acquired_at INTEGER NOT NULL'
          ')',
        );
      },
    );
  }

  /// 락 획득 시도. 성공 시 true, 이미 다른 isolate가 잡고 있으면 false.
  ///
  /// 호출 직전 TTL(30s) 초과한 stale 행을 일괄 삭제해 크래시한 이전 isolate가
  /// 남긴 락을 새 진입자가 이어받을 수 있게 한다. 이 cleanup과 INSERT는 같은
  /// 트랜잭션으로 묶어야 cross-isolate CAS가 깨지지 않는다.
  Future<bool> tryAcquire(String scheduledKey) async {
    final db = await _open();
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    try {
      await db.transaction((txn) async {
        // TTL 초과분 + 24시간 지난 과거 날짜 행 일괄 청소
        await txn.delete(
          _table,
          where: 'acquired_at < ?',
          whereArgs: [nowMs - _ttlMs],
        );
        await txn.insert(_table, {
          'scheduled_key': scheduledKey,
          'acquired_at': nowMs,
        });
      });
      debugPrint('[HeartbeatLock] 락 획득 ($scheduledKey)');
      return true;
    } on DatabaseException catch (e) {
      if (e.isUniqueConstraintError()) {
        debugPrint('[HeartbeatLock] 다른 isolate 전송 중 — 스킵 ($scheduledKey)');
        return false;
      }
      rethrow;
    } finally {
      await db.close();
    }
  }

  /// 락 해제 (전송 완료 or 실패 후 finally에서 호출)
  Future<void> release(String scheduledKey) async {
    final db = await _open();
    try {
      await db.delete(
        _table,
        where: 'scheduled_key = ?',
        whereArgs: [scheduledKey],
      );
    } finally {
      await db.close();
    }
  }

  /// 탈퇴/모드변경/G+S 비활성화 시 전체 청소
  Future<void> clearAll() async {
    final db = await _open();
    try {
      await db.delete(_table);
    } finally {
      await db.close();
    }
  }
}
