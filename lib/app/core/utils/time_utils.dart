/// "HH:mm" (24시간제) → "오전/오후 H:mm" (12시간제) 변환
String formatTo12Hour(String hhmm) {
  final parts = hhmm.split(':');
  if (parts.length != 2) return hhmm;

  final hour = int.tryParse(parts[0]);
  final minute = parts[1];
  if (hour == null) return hhmm;

  final period = hour < 12 ? '오전' : '오후';
  final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
  return '$period $displayHour:$minute';
}
