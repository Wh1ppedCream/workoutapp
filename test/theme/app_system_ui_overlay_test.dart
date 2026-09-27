import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/main.dart' as app;

void main() {
  for (final brightness in Brightness.values) {
    test(
      'app status-bar overlay remains transparent and legible in ${brightness.name}',
      () {
        final style = app.appSystemUiOverlayStyleFor(brightness);

        expect(style.statusBarColor, Colors.transparent);
        expect(
          style.statusBarIconBrightness,
          brightness == Brightness.dark ? Brightness.light : Brightness.dark,
        );
        expect(style.statusBarBrightness, brightness);
      },
    );
  }
}
