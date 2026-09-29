import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart' as material_ui;

/// Lets constructor-started SharedPreferences reads complete in provider tests.
Future<void> settlePreferenceReads() async {
  await Future<void>.delayed(Duration.zero);
  await Future<void>.delayed(Duration.zero);
}

/// Finds standalone Material UI tooltips, which Flutter's SDK [find.byTooltip]
/// does not recognize after the Material library split.
Finder findTonosTooltip(Pattern message, {bool skipOffstage = true}) {
  return find.byWidgetPredicate(
    (widget) {
      if (widget is! material_ui.Tooltip) {
        return false;
      }

      final tooltipMessage =
          widget.message ?? widget.richMessage?.toPlainText();
      if (tooltipMessage == null) {
        return false;
      }

      if (message is String) {
        return tooltipMessage == message;
      }
      if (message is RegExp) {
        return message.hasMatch(tooltipMessage);
      }
      return false;
    },
    skipOffstage: skipOffstage,
    description: 'Tooltip with message "$message"',
  );
}
