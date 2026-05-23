import 'package:intl/intl.dart';

final _numberFormatter = NumberFormat('#,###');
final _dateFormatter = DateFormat('yyyy-MM-dd');

class Formatters {
  static String money(int value) => _numberFormatter.format(value);
  static String moneyWon(int value) => '${_numberFormatter.format(value)}원';
  static String date(DateTime date) => _dateFormatter.format(date);

  // 1234567890 -> 123-45-67890
  static String bizNo(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length != 10) return raw;
    return '${digits.substring(0, 3)}-${digits.substring(3, 5)}-${digits.substring(5)}';
  }

  // 01012345678 -> 010-1234-5678
  static String phone(String raw) {
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length == 11) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 7)}-${digits.substring(7)}';
    }
    if (digits.length == 10) {
      return '${digits.substring(0, 3)}-${digits.substring(3, 6)}-${digits.substring(6)}';
    }
    return raw;
  }

  // ✅ 금액을 한글로: 10000 -> 일만원, 567000 -> 오십육만칠천원
  // - 요구 예시: "일만원" (거래명세서 한글 합계)
  static String amountToHangul(int n) {
    if (n == 0) return '영원';

    final units = ['', '만', '억', '조'];
    String result = '';
    int unitIndex = 0;

    while (n > 0 && unitIndex < units.length) {
      final chunk = n % 10000;
      if (chunk != 0) {
        result = _chunkToHangul(chunk) + units[unitIndex] + result;
      }
      n ~/= 10000;
      unitIndex++;
    }
    return '$result원';
  }

  static String _chunkToHangul(int n) {
    final numKor = ['', '일', '이', '삼', '사', '오', '육', '칠', '팔', '구'];
    final pos = ['', '십', '백', '천'];
    String out = '';

    for (int i = 0; i < 4; i++) {
      final digit = n % 10;
      if (digit != 0) {
        final d = (i > 0 && digit == 1) ? '' : numKor[digit];
        out = d + pos[i] + out;
      }
      n ~/= 10;
    }
    return out;
  }
}
