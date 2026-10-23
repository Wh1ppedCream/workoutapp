import 'dart:async';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/locale_preference_provider.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/providers/unit_preference_provider.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/onboarding_flow.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Repository extends AppRepository {
  Completer<List<GymProfile>>? pending;
  int profileReads = 0;
  @override
  Future<List<Equipment>> fetchAllEquipment() async => [];
  @override
  Future<List<GymProfile>> fetchAllProfiles() async {
    profileReads++;
    if (pending != null) return pending!.future;
    return [
      GymProfile(id: 1, name: 'Existing space', createdAt: DateTime(2026)),
    ];
  }

  @override
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(
    int profileId,
  ) async => [];
  @override
  Future<String?> getAppState(String key) async => '1';
  @override
  Future<void> setAppState(String key, String? value) async {}
}

void main() {
  testWidgets(
    'onboarding guards repeated handoffs and recovers from a failed load',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      await tester.binding.setSurfaceSize(const Size(430, 932));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _Repository();
      final selected = SelectedProfile(repository: repository);
      final units = UnitPreferenceProvider();
      final locale = LocalePreferenceProvider();
      await units.ready;
      await locale.ready;
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            Provider<AppRepository>.value(value: repository),
            ChangeNotifierProvider<SelectedProfile>(create: (_) => selected),
            ChangeNotifierProvider<UnitPreferenceProvider>(
              create: (_) => units,
            ),
            ChangeNotifierProvider<LocalePreferenceProvider>(
              create: (_) => locale,
            ),
          ],
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const OnboardingFlow(reviewMode: true),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final pages = tester.widget<PageView>(find.byType(PageView));
      pages.controller!.jumpToPage(8);
      await tester.pumpAndSettle();
      final strings = AppLocalizations.of(
        tester.element(find.byType(OnboardingFlow)),
      );
      await tester.ensureVisible(find.text(strings.onboardingPremadePlanTitle));
      await tester.tap(find.text(strings.onboardingPremadePlanTitle));
      await tester.pumpAndSettle();
      final before = repository.profileReads;
      final pending = Completer<List<GymProfile>>();
      repository.pending = pending;
      final action = tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, strings.onboardingNext),
          )
          .onPressed!;
      action();
      action();
      await tester.pump();
      expect(repository.profileReads, before + 1);
      expect(
        tester
            .widget<FilledButton>(
              find.widgetWithText(FilledButton, strings.onboardingNext),
            )
            .onPressed,
        isNull,
      );
      pending.completeError(StateError('controlled load failure'));
      await tester.pumpAndSettle();
      expect(find.byType(SnackBar), findsOneWidget);
      final retry = tester
          .widget<FilledButton>(
            find.widgetWithText(FilledButton, strings.onboardingNext),
          )
          .onPressed;
      expect(retry, isNotNull);
      repository.pending = Completer<List<GymProfile>>();
      retry!();
      await tester.pump();
      expect(repository.profileReads, before + 2);
      repository.pending!.completeError(StateError('retry failure'));
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    },
  );
}
