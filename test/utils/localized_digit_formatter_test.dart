import 'package:env_test/utils/localized_digit_formatter.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('preserveWesternDigits normalizes Bengali numerals only', () {
    expect(
      preserveWesternDigits('১১ আগস্ট, ২০২৬ ৮:৫১ AM', const Locale('bn')),
      '11 আগস্ট, 2026 8:51 AM',
    );
    expect(
      preserveWesternDigits('11 Aug, 2026 8:51 AM', const Locale('en')),
      '11 Aug, 2026 8:51 AM',
    );
  });
}
