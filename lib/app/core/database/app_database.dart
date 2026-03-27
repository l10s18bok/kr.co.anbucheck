import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

/// sqflite 싱글톤 — 앱 전체에서 하나의 DB 인스턴스 공유
class AppDatabase {
  AppDatabase._();

  static Database? _db;

  static Future<Database> get instance async {
    _db ??= await _open();
    return _db!;
  }

  static Future<Database> _open() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'anbucheck.db');

    return openDatabase(
      path,
      version: 2,
      onCreate: (db, version) async {
        // 보호자 알림 이력
        await db.execute('''
          CREATE TABLE notifications (
            id          INTEGER PRIMARY KEY AUTOINCREMENT,
            title       TEXT    NOT NULL,
            body        TEXT    NOT NULL,
            alert_level TEXT    NOT NULL,
            invite_code TEXT,
            received_at TEXT    NOT NULL,
            is_read     INTEGER NOT NULL DEFAULT 0
          )
        ''');

        // heartbeat 전송 실패 큐
        await db.execute('''
          CREATE TABLE heartbeat_queue (
            id         INTEGER PRIMARY KEY AUTOINCREMENT,
            payload    TEXT    NOT NULL,
            created_at TEXT    NOT NULL
          )
        ''');
      },
      onUpgrade: (db, oldVersion, newVersion) async {
        if (oldVersion < 2) {
          await db.execute(
            'ALTER TABLE notifications ADD COLUMN is_read INTEGER NOT NULL DEFAULT 0',
          );
        }
      },
    );
  }
}
