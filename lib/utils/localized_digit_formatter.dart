import 'package:flutter/widgets.dart';

const _bengaliDigits = <String>[
  '০',
  '১',
  '২',
  '৩',
  '৪',
  '৫',
  '৬',
  '৭',
  '৮',
  '৯',
];

/// Keeps numeric output consistent with Tonos's Western-digit Bangla policy.
String preserveWesternDigits(String value, Locale locale) {
  return preserveWesternDigitsForLocale(value, locale.toLanguageTag());
}

/// Version of [preserveWesternDigits] for APIs that expose a locale tag.
String preserveWesternDigitsForLocale(String value, String localeName) {
  if (!localeName.toLowerCase().startsWith('bn')) return value;

  var normalized = value;
  for (var index = 0; index < _bengaliDigits.length; index++) {
    normalized = normalized.replaceAll(_bengaliDigits[index], '$index');
  }
  return normalized;
}
