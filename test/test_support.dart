import 'dart:async';

/// Lets constructor-started SharedPreferences reads complete in provider tests.
Future<void> settlePreferenceReads() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}
