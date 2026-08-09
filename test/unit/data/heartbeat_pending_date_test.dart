import 'package:flutter_test/flutter_test.dart';
import 'package:anbucheck/app/core/services/heartbeat_service.dart';

/// 보류 큐 payload의 "오늘 것인가" 판정.
///
/// 이 판정이 틀리면 두 방향 모두 실사용 결함이 된다:
///  · 지난 기록을 오늘 것으로 오판 → 오늘 마커가 찍혀 정시 전송이 스킵되고
///    그날 걸음수 막대가 0이 된다.
///  · 오늘 것을 지난 기록으로 오판 → 같은 날 기록이 서버에 2건 도착해
///    "오늘 안부 확인 완료" Push가 중복된다.
void main() {
  final now = DateTime(2026, 8, 9, 18, 30);

  Map<String, dynamic> payload({String? key, String? ts}) => {
        'device_id': 'dev',
        'timestamp': ts ?? DateTime(2026, 8, 9, 18, 0).toUtc().toIso8601String(),
        'manual': false,
        'suspicious': false,
        'scheduled_key': ?key,
      };

  group('자동 전송 (scheduled_key 있음)', () {
    test('오늘 키는 오늘 것', () {
      expect(heartbeatPayloadIsFromToday(payload(key: '2026-08-09_18:00'), now),
          isTrue);
    });

    test('어제 키는 지난 기록', () {
      expect(heartbeatPayloadIsFromToday(payload(key: '2026-08-08_18:00'), now),
          isFalse);
    });

    test('예약시각이 달라져도 날짜가 오늘이면 오늘 것', () {
      // 18:00에 큐에 담긴 뒤 _syncScheduleFromServer로 예약시각이 20:00로 바뀐 상황.
      // 키 문자열 전체를 비교하면 여기서 "지난 기록"으로 오판해 Push가 중복된다.
      expect(heartbeatPayloadIsFromToday(payload(key: '2026-08-09_18:00'), now),
          isTrue);
      expect(heartbeatPayloadIsFromToday(payload(key: '2026-08-09_09:30'), now),
          isTrue);
    });
  });

  group('수동 보고 (scheduled_key 없음)', () {
    test('오늘 timestamp면 오늘 것', () {
      expect(
        heartbeatPayloadIsFromToday(
          payload(ts: DateTime(2026, 8, 9, 12, 0).toUtc().toIso8601String()),
          now,
        ),
        isTrue,
      );
    });

    test('어제 timestamp면 지난 기록', () {
      expect(
        heartbeatPayloadIsFromToday(
          payload(ts: DateTime(2026, 8, 8, 12, 0).toUtc().toIso8601String()),
          now,
        ),
        isFalse,
      );
    });
  });

  group('예외 입력', () {
    test('회복 전송 키는 정시 슬롯을 소비하지 않는다', () {
      expect(heartbeatPayloadIsFromToday(payload(key: 'recovery_2026-08-09'), now),
          isFalse);
    });

    test('형식이 깨진 키는 timestamp로 폴백', () {
      expect(
        heartbeatPayloadIsFromToday(
          payload(
            key: 'garbage',
            ts: DateTime(2026, 8, 8, 12, 0).toUtc().toIso8601String(),
          ),
          now,
        ),
        isFalse,
      );
    });

    test('둘 다 해석 불가면 오늘로 간주 — 같은 날 이중 전송 방지', () {
      expect(
        heartbeatPayloadIsFromToday(
          {'device_id': 'dev', 'suspicious': false, 'timestamp': 'nope'},
          now,
        ),
        isTrue,
      );
    });
  });
}
