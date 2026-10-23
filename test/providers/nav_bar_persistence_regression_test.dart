import 'dart:async';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/providers/nav_bar_config.dart';
import 'package:env_test/screens/profile/settings/nav_bar_settings_page.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Failure injection for the preference backend, without touching device data.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class _Store extends InMemorySharedPreferencesStore {
  _Store() : super.empty();
  int writes = 0;
  int? failAt;
  Completer<bool>? gate;
  final started = Completer<void>();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    writes++;
    if (!started.isCompleted) started.complete();
    final currentGate = gate;
    gate = null;
    if (currentGate != null && !await currentGate.future) return false;
    if (writes == failAt) return false;
    return super.setValue(valueType, key, value);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late _Store store;
  setUp(() {
    SharedPreferences.setMockInitialValues({});
    store = _Store();
    SharedPreferencesStorePlatform.instance = store;
  });
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  Future<NavBarConfig> load() async {
    final config = NavBarConfig();
    addTearDown(config.dispose);
    while (!config.loaded) {
      await Future<void>.delayed(Duration.zero);
    }
    return config;
  }

  test(
    'navigation publishes changes only after both preference writes',
    () async {
      final config = await load();
      final previous = List<TabItem>.of(config.order);
      final next = previous.reversed.toList();
      final gate = Completer<bool>();
      store.gate = gate;
      final saving = config.update(
        newOrder: next,
        newEnabled: config.enabledTabs,
      );
      await store.started.future;
      expect(config.order, previous);
      gate.complete(true);
      await saving;
      expect(config.order, next);
      final prefs = await SharedPreferences.getInstance();
      expect(prefs.getStringList('navBarOrder'), next.map((e) => e.storageKey));
    },
  );

  for (final failedWrite in [1, 2]) {
    test(
      'failed navigation write $failedWrite keeps the original snapshot',
      () async {
        final config = await load();
        final previous = List<TabItem>.of(config.order);
        store.failAt = failedWrite;
        await expectLater(
          config.update(
            newOrder: previous.reversed.toList(),
            newEnabled: {TabItem.train, TabItem.profile},
          ),
          throwsStateError,
        );
        expect(config.order, previous);
        final prefs = await SharedPreferences.getInstance();
        expect(prefs.getStringList('navBarOrder'), isNull);
        expect(prefs.getStringList('navBarEnabled'), isNull);
      },
    );
  }

  testWidgets('navigation editor waits, reports failure, and retains Save', (
    tester,
  ) async {
    final config = NavBarConfig();
    await tester.pumpWidget(
      ChangeNotifierProvider<NavBarConfig>(
        create: (_) => config,
        child: MaterialApp(
          theme: ExpressiveThemeDefinition.light(),
          localizationsDelegates: tonosLocalizationDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const NavBarSettingsPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final tile = find.byKey(const ValueKey('inactive-train2'));
    await tester.scrollUntilVisible(
      tile,
      300,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: tile, matching: find.byType(Switch)));
    await tester.pumpAndSettle();
    final strings = AppLocalizations.of(
      tester.element(find.byType(NavBarSettingsPage)),
    );
    final gate = Completer<bool>();
    store.gate = gate;
    await tester.tap(find.byKey(AppTestKeys.navigationSave));
    await tester.pump();
    expect(find.text(strings.navEditorSavedMessage), findsNothing);
    expect(
      tester
          .widget<FloatingActionButton>(find.byKey(AppTestKeys.navigationSave))
          .onPressed,
      isNull,
    );
    gate.complete(false);
    await tester.pumpAndSettle();
    expect(find.text(strings.safeFailureSaveTitle), findsOneWidget);
    expect(
      tester
          .widget<FloatingActionButton>(find.byKey(AppTestKeys.navigationSave))
          .onPressed,
      isNotNull,
    );
  });
}
