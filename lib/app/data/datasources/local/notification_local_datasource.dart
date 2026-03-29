import 'package:anbucheck/app/core/database/app_database.dart';

/// 보호자 알림 이력 로컬 저장소
/// 보관 정책: 30일 초과 또는 100건 초과 시 오래된 순으로 삭제
class NotificationLocalDatasource {
  static const int _maxDays = 30;
  static const int _maxCount = 100;

  Future<List<Map<String, dynamic>>> getAll() async {
    final db = await AppDatabase.instance;
    return db.query('notifications', orderBy: 'received_at DESC');
  }

  Future<void> insert(Map<String, dynamic> notification) async {
    final db = await AppDatabase.instance;
    await db.insert('notifications', notification);
    await cleanup();
  }

  Future<void> markAsRead(int id) async {
    final db = await AppDatabase.instance;
    await db.update(
      'notifications',
      {'is_read': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> resetAllRead() async {
    final db = await AppDatabase.instance;
    await db.update('notifications', {'is_read': 0});
  }

  /// 30일 초과 + 100건 초과 정리 (앱 실행 시 및 insert 후 자동 호출)
  Future<void> cleanup() async {
    final db = await AppDatabase.instance;

    // 30일 초과 삭제
    final cutoff = DateTime.now()
        .subtract(const Duration(days: _maxDays))
        .toIso8601String();
    await db.delete(
      'notifications',
      where: 'received_at < ?',
      whereArgs: [cutoff],
    );

    // 100건 초과 시 오래된 순 삭제
    final count = (await db.rawQuery('SELECT COUNT(*) FROM notifications'))
        .first
        .values
        .first as int;
    if (count > _maxCount) {
      await db.rawDelete('''
        DELETE FROM notifications WHERE id IN (
          SELECT id FROM notifications ORDER BY received_at ASC LIMIT ?
        )
      ''', [count - _maxCount]);
    }
  }

  /// 테스트용 초기 데이터 — DB가 비어있을 때만 삽입
  Future<void> seedIfEmpty() async {
    final db = await AppDatabase.instance;
    final count = (await db.rawQuery('SELECT COUNT(*) FROM notifications'))
        .first
        .values
        .first as int;
    if (count > 0) return;

    final now = DateTime.now();
    final yesterday = now.subtract(const Duration(days: 1));

    final seeds = [
      {
        'title': '긴급',
        'body': '24시간 이상 활동이 감지되지 않았습니다. 즉시 확인이 필요합니다.',
        'alert_level': 'urgent',
        'invite_code': 'K7M-4PXR',
        'received_at':
            now.subtract(const Duration(minutes: 10)).toIso8601String(),
      },
      {
        'title': '경고',
        'body': '배터리 잔량이 5% 이하입니다. 충전이 필요합니다.',
        'alert_level': 'warning',
        'invite_code': 'ABC-1234',
        'received_at':
            now.subtract(const Duration(hours: 1)).toIso8601String(),
      },
      {
        'title': '주의',
        'body': '설정된 확인 시각으로부터 1시간이 경과했습니다.',
        'alert_level': 'caution',
        'invite_code': 'K7M-4PXR',
        'received_at':
            now.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'title': '정보',
        'body': '안부 확인이 정상 복귀되었습니다.',
        'alert_level': 'info',
        'invite_code': 'K7M-4PXR',
        'received_at':
            now.subtract(const Duration(hours: 3)).toIso8601String(),
      },
      // 지난 알림
      {
        'title': '경고',
        'body': '보호 대상자 폰 사용이 48시간째 감지되지 않습니다.',
        'alert_level': 'warning',
        'invite_code': 'ABC-1234',
        'received_at':
            yesterday.subtract(const Duration(hours: 2)).toIso8601String(),
      },
      {
        'title': '정보',
        'body': '새로운 보호자가 연결되었습니다.',
        'alert_level': 'info',
        'invite_code': 'K7M-4PXR',
        'received_at':
            yesterday.subtract(const Duration(hours: 5)).toIso8601String(),
      },
    ];

    for (final seed in seeds) {
      await db.insert('notifications', seed);
    }
  }
}
