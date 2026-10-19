import 'package:flutter/services.dart';

/// 고유 코드(invite_code) 입력 정리 — `XXX-XXXX` 형식으로 자동 맞춘다.
///
/// - 영숫자만 대문자로 모아 최대 7자리까지 받고, 3자리 뒤에 `-`를 자동으로 넣는다.
///   (하이픈을 직접 치지 않아도, 하이픈 없이 붙여넣어도 유효한 형식이 된다.)
/// - 이미 하이픈이 섞여 들어와도 위치와 무관하게 다시 정리한다.
/// - 입력 중간을 고쳐도 커서가 끝으로 튀지 않도록 "커서 앞 영숫자 수"로 위치를 계산한다.
class InviteCodeFormatter extends TextInputFormatter {
  const InviteCodeFormatter();

  static const _firstPart = 3;
  static const _maxLength = 7;

  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text.toUpperCase();
    final cursor = newValue.selection.baseOffset;

    final clean = StringBuffer();
    var beforeCursor = 0; // 커서 앞에 놓인 영숫자 수
    for (var i = 0; i < raw.length; i++) {
      final ch = raw[i];
      if (ch == '-') continue;
      if (clean.length >= _maxLength) break;
      clean.write(ch);
      if (cursor < 0 || i < cursor) beforeCursor++;
    }

    final s = clean.toString();
    final text = s.length > _firstPart
        ? '${s.substring(0, _firstPart)}-${s.substring(_firstPart)}'
        : s;
    // 커서 위치: 3자리를 넘긴 만큼 하이픈 1칸이 끼어 있다.
    final offset = beforeCursor > _firstPart ? beforeCursor + 1 : beforeCursor;
    return TextEditingValue(
      text: text,
      selection: TextSelection.collapsed(offset: offset.clamp(0, text.length)),
    );
  }
}
