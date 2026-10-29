import 'package:env_test/utils/editable_number.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final entry in <num, String>{
    100: '100',
    100.0: '100',
    100.5: '100.5',
    0.00125: '0.00125',
    0.0000001: '0.0000001',
    -0.0000001: '-0.0000001',
    1.25e-8: '0.0000000125',
    1.25e22: '12500000000000000000000',
  }.entries) {
    test('editable number ${entry.key} retains its value', () {
      expect(editableNumber(entry.key), entry.value);
      expect(num.parse(editableNumber(entry.key)), entry.key);
    });
  }
  test('non-finite numbers do not seed invalid input', () {
    expect(editableNumber(double.nan), isEmpty);
    expect(editableNumber(double.infinity), isEmpty);
  });
}
