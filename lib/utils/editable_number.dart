/// Formats editable values without display rounding or exponent notation.
/// Numeric input formatters accept decimal digits, rather than `1e-7`.
String editableNumber(num value) {
  if (!value.isFinite) return '';
  final text = value.toString();
  final exponentAt = text.indexOf('e');
  if (exponentAt < 0) return text.replaceFirst(RegExp(r'\.0$'), '');

  final negative = text.startsWith('-');
  final mantissa = text.substring(negative ? 1 : 0, exponentAt);
  final exponent = int.parse(text.substring(exponentAt + 1));
  final dotAt = mantissa.indexOf('.');
  final digits = mantissa.replaceAll('.', '');
  final decimalAt = (dotAt < 0 ? digits.length : dotAt) + exponent;
  final String decimal;
  if (decimalAt <= 0) {
    decimal = '0.${''.padLeft(-decimalAt, '0')}$digits';
  } else if (decimalAt >= digits.length) {
    decimal = digits.padRight(decimalAt, '0');
  } else {
    decimal =
        '${digits.substring(0, decimalAt)}.${digits.substring(decimalAt)}';
  }
  return '${negative ? '-' : ''}$decimal';
}
