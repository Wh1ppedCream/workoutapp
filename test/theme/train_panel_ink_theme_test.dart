import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/providers/selected_profile.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/train_page.dart';
import 'package:env_test/services/active_plan_store.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/presets_loaded.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  for (final family in AppThemeFamily.values) {
    for (final theme in [
      AppThemeFactory.light(family),
      AppThemeFactory.dark(family),
    ]) {
      testWidgets(
        '${family.name} ${theme.brightness} Train panel ink stays scoped',
        (tester) async {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          final repository = _TrainThemeRepository();
          final profile = _NoProfileSelectedProfile(repository: repository);
          final session = ActiveSession(
            repository: repository,
            retryDelay: (_) async {},
          );
          addTearDown(profile.dispose);
          addTearDown(session.dispose);
          await session.ready;

          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                Provider<ActivePlanStore>.value(
                  value: ActivePlanStore(repository: repository),
                ),
                ChangeNotifierProvider<SelectedProfile>.value(value: profile),
                ChangeNotifierProvider<ActiveSession>.value(value: session),
              ],
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const TickerMode(enabled: false, child: TrainPage()),
              ),
            ),
          );
          await tester.pump();
          await tester.pump();

          final strings = AppLocalizations.of(
            tester.element(find.byType(TrainPage)),
          );
          final usesInkRecipe = theme.surfaceDecorationTokens.panel.outlined;
          final surfaceInk = theme.colorScheme.onPrimaryContainer;
          _expectSplitWorkoutBar(tester, theme, strings);
          _expectPanelText(
            tester,
            strings.trainActivePlans,
            theme: theme,
            usesInkRecipe: usesInkRecipe,
            expectedStyleColor:
                usesInkRecipe ? surfaceInk : theme.textTheme.titleLarge?.color,
          );
          _expectPanelText(
            tester,
            strings.trainSelectProfileForPlans,
            theme: theme,
            usesInkRecipe: usesInkRecipe,
            expectedStyleColor:
                usesInkRecipe ? surfaceInk : theme.colorScheme.onSurfaceVariant,
          );

          await tester.tap(find.byKey(AppTestKeys.trainPlansTab));
          await tester.pump();
          await tester.pump();

          for (final title in [
            strings.trainActivePlans,
            strings.trainArchivedPlans,
            strings.trainPremadePlans,
          ]) {
            _expectPanelText(
              tester,
              title,
              theme: theme,
              usesInkRecipe: usesInkRecipe,
              expectedStyleColor:
                  usesInkRecipe
                      ? surfaceInk
                      : theme.textTheme.titleLarge?.color,
            );
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        },
      );
    }
  }

  testWidgets('profile avatar text uses the theme contrast role', (
    tester,
  ) async {
    for (final family in AppThemeFamily.values) {
      for (final theme in [
        AppThemeFactory.light(family),
        AppThemeFactory.dark(family),
      ]) {
        SharedPreferences.setMockInitialValues(<String, Object>{});
        final repository = _TrainThemeRepository();
        final profile = _SelectedProfileWithProfile(repository: repository);
        final session = ActiveSession(
          repository: repository,
          retryDelay: (_) async {},
        );
        addTearDown(profile.dispose);
        addTearDown(session.dispose);
        await session.ready;

        await tester.pumpWidget(
          MultiProvider(
            providers: [
              Provider<AppRepository>.value(value: repository),
              Provider<ActivePlanStore>.value(
                value: ActivePlanStore(repository: repository),
              ),
              ChangeNotifierProvider<SelectedProfile>.value(value: profile),
              ChangeNotifierProvider<ActiveSession>.value(value: session),
            ],
            child: MaterialApp(
              theme: theme,
              themeAnimationDuration: Duration.zero,
              localizationsDelegates: AppLocalizations.localizationsDelegates,
              supportedLocales: AppLocalizations.supportedLocales,
              home: const TickerMode(enabled: false, child: TrainPage()),
            ),
          ),
        );
        await tester.pump();
        await tester.pump();

        final initial = find.text('T');
        expect(initial, findsOneWidget);
        expect(
          tester.widget<Text>(initial).style?.color,
          theme.semanticColors.onTrainProfileAvatar,
          reason: '${family.name} ${theme.brightness}',
        );
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
  });

  testWidgets(
    'archived empty-state text contrasts with its card in all modes',
    (tester) async {
      for (final family in AppThemeFamily.values) {
        for (final theme in [
          AppThemeFactory.light(family),
          AppThemeFactory.dark(family),
        ]) {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          final repository = _TrainThemeRepository();
          final profile = _SelectedProfileWithProfile(repository: repository);
          addTearDown(profile.dispose);

          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                Provider<ActivePlanStore>.value(
                  value: ActivePlanStore(repository: repository),
                ),
                ChangeNotifierProvider<SelectedProfile>.value(value: profile),
              ],
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const Scaffold(
                  body: PresetsLoaded(
                    excludedPresetIds: <int>{},
                    emptyMessage: 'No archived plans.',
                    onRefresh: _noop,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          final message = find.text('No archived plans.');
          expect(
            message,
            findsOneWidget,
            reason: '${family.name} ${theme.brightness}',
          );
          final text = tester.widget<Text>(message);
          if (theme.surfaceDecorationTokens.panel.outlined) {
            final context = tester.element(message);
            expect(
              text.style?.color,
              tonosForegroundForSurface(context, context.surfaceTokens.card),
              reason: '${family.name} ${theme.brightness}',
            );
          } else {
            expect(
              text.style,
              isNull,
              reason: '${family.name} ${theme.brightness}',
            );
          }
          expect(tester.takeException(), isNull);
        }
      }
    },
  );

  testWidgets(
    'show-more plan action keeps its theme recipe and reveals remaining rows',
    (tester) async {
      for (final family in AppThemeFamily.values) {
        for (final theme in [
          AppThemeFactory.light(family),
          AppThemeFactory.dark(family),
        ]) {
          SharedPreferences.setMockInitialValues(<String, Object>{});
          final repository = _PresetRevealRepository();
          final profile = _SelectedProfileWithProfile(repository: repository);
          addTearDown(profile.dispose);

          await tester.pumpWidget(
            MultiProvider(
              providers: [
                Provider<AppRepository>.value(value: repository),
                Provider<ActivePlanStore>.value(
                  value: ActivePlanStore(repository: repository),
                ),
                ChangeNotifierProvider<SelectedProfile>.value(value: profile),
              ],
              child: MaterialApp(
                theme: theme,
                themeAnimationDuration: Duration.zero,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                supportedLocales: AppLocalizations.supportedLocales,
                home: const Scaffold(
                  body: PresetsLoaded(
                    scale: 0.8,
                    progressiveReveal: true,
                    initialVisibleCount: 2,
                    revealBatchSize: 2,
                    onRefresh: _noop,
                  ),
                ),
              ),
            ),
          );
          await tester.pumpAndSettle();

          for (var index = 1; index <= 2; index++) {
            expect(find.text('Plan $index'), findsOneWidget);
          }
          for (var index = 3; index <= 4; index++) {
            expect(find.text('Plan $index'), findsNothing);
          }

          final showMoreFinder = find.byWidgetPredicate(
            (widget) => widget is OutlinedButton,
            description: 'OutlinedButton',
          );
          expect(showMoreFinder, findsOneWidget);
          final showMore = tester.widget<OutlinedButton>(showMoreFinder);
          final style = showMore.style!;
          final expectedShape =
              BorderRadius.lerp(
                BorderRadius.zero,
                theme.shapeTokens.card,
                0.8,
              )!;
          expect(
            style.foregroundColor?.resolve(const <WidgetState>{}),
            theme.colorScheme.primary,
            reason: '${family.name} ${theme.brightness} foreground',
          );
          expect(
            style.side?.resolve(const <WidgetState>{}),
            BorderSide(
              color: theme.colorScheme.primary.withValues(
                alpha: theme.surfaceTokens.planRevealBorderOpacity,
              ),
            ),
            reason: '${family.name} ${theme.brightness} outline',
          );
          expect(
            (style.shape?.resolve(const <WidgetState>{})
                    as RoundedRectangleBorder)
                .borderRadius,
            expectedShape,
            reason: '${family.name} ${theme.brightness} scaled shape',
          );

          await tester.tap(showMoreFinder);
          await tester.pumpAndSettle();
          expect(
            find.byWidgetPredicate((widget) => widget is OutlinedButton),
            findsNothing,
          );
          for (var index = 3; index <= 4; index++) {
            final planFinder = find.text('Plan $index');
            expect(planFinder, findsOneWidget);
          }
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox.shrink());
        }
      }
    },
  );
}

void _expectSplitWorkoutBar(
  WidgetTester tester,
  ThemeData theme,
  AppLocalizations strings,
) {
  final startButton = find.byKey(AppTestKeys.trainStartWorkout);
  expect(startButton, findsOneWidget);
  final frame = find.ancestor(
    of: startButton,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration! as BoxDecoration).borderRadius ==
              theme.shapeTokens.sheet,
    ),
  );
  expect(frame, findsOneWidget);

  final frameContainer = tester.widget<Container>(frame);
  final frameDecoration = frameContainer.decoration! as BoxDecoration;
  expect(frameDecoration.borderRadius, theme.shapeTokens.sheet);
  expect(tester.getSize(frame).height, inInclusiveRange(64, 68));
  if (theme.surfaceDecorationTokens.panel.outlined) {
    expect(
      (frameDecoration.border! as Border).top.color,
      theme.surfaceTokens.subtleOutline,
    );
    expect(
      (frameDecoration.border! as Border).top.width,
      theme.shapeTokens.outlineWidth,
    );
    expect(frameDecoration.boxShadow, hasLength(1));
    expect(
      frameDecoration.boxShadow!.single.color,
      theme.effectTokens.cardShadow,
    );
    expect(
      frameDecoration.boxShadow!.single.blurRadius,
      theme.effectTokens.cardShadowBlur,
    );
    expect(
      frameDecoration.boxShadow!.single.offset,
      theme.effectTokens.primaryActionShadowOffset,
    );
  } else {
    expect(frameDecoration.border, isNull);
    expect(frameDecoration.boxShadow, isNull);
  }

  final frameMaterialFinder = find.descendant(
    of: frame,
    matching: find.byWidgetPredicate(
      (widget) =>
          widget is Material &&
          widget.type == MaterialType.canvas &&
          widget.color == Colors.transparent,
    ),
  );
  expect(frameMaterialFinder, findsOneWidget);
  final frameMaterial = tester.widget<Material>(frameMaterialFinder);
  expect(frameMaterial.borderRadius, theme.shapeTokens.sheet);
  expect(frameMaterial.clipBehavior, Clip.antiAlias);
  expect(frameMaterial.elevation, theme.effectTokens.sheetElevation);

  final expectedDivider = theme.colorScheme.outline.withValues(
    alpha: theme.surfaceTokens.splitWorkoutDividerOpacity,
  );
  final divider = find.descendant(
    of: frame,
    matching: find.byWidgetPredicate(
      (widget) => widget is Container && widget.color == expectedDivider,
    ),
  );
  expect(divider, findsOneWidget);
  final dividerSize = tester.getSize(divider);
  expect(dividerSize.width == 1 || dividerSize.height == 1, isTrue);

  final startLabel = find.text(strings.trainStartWorkout);
  final startText = tester.widget<Text>(startLabel);
  expect(startText.style?.color, theme.semanticColors.onStartWorkoutAction);
  expect(startText.style?.fontWeight, FontWeight.w800);
  expect(
    find.ancestor(
      of: startLabel,
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Material &&
            widget.color == theme.semanticColors.startWorkoutAction,
      ),
    ),
    findsOneWidget,
  );
  final startInkWell = tester.widget<InkWell>(
    find.ancestor(of: startLabel, matching: find.byType(InkWell)).first,
  );
  expect(startInkWell.onTap, isNotNull);

  final optimizeAction =
      theme.surfaceDecorationTokens.panel.outlined
          ? theme.surfaceTokens.optimizedAction
          : theme.colorScheme.primaryContainer;
  final optimizeForeground =
      theme.surfaceDecorationTokens.panel.outlined
          ? theme.colorScheme.onSecondaryContainer
          : theme.colorScheme.onPrimaryContainer;
  final optimizeLabel = find.text(strings.trainOptimize);
  final optimizeText = tester.widget<Text>(optimizeLabel);
  expect(optimizeText.style?.color, optimizeForeground);
  expect(
    find.ancestor(
      of: optimizeLabel,
      matching: find.byWidgetPredicate(
        (widget) => widget is Material && widget.color == optimizeAction,
      ),
    ),
    findsOneWidget,
  );
  final optimizeInkWell = tester.widget<InkWell>(
    find.ancestor(of: optimizeLabel, matching: find.byType(InkWell)).first,
  );
  expect(optimizeInkWell.onTap, isNotNull);

  final settings = tester.widget<IconButton>(
    find.byWidgetPredicate(
      (widget) =>
          widget is IconButton &&
          widget.tooltip == strings.trainOptimizedSettings,
    ),
  );
  expect(settings.onPressed, isNotNull);
  expect(
    find.descendant(of: frame, matching: find.byType(Row)),
    findsOneWidget,
  );
  expect(tester.takeException(), isNull);
}

void _expectPanelText(
  WidgetTester tester,
  String label, {
  required ThemeData theme,
  required bool usesInkRecipe,
  required Color? expectedStyleColor,
}) {
  final finder = find.text(label);
  expect(finder, findsOneWidget, reason: label);
  final element = tester.element(finder);
  final scopedTheme = Theme.of(element);
  final expectedInk =
      usesInkRecipe ? theme.colorScheme.onPrimaryContainer : null;

  expect(
    scopedTheme.colorScheme.onSurface,
    usesInkRecipe ? expectedInk : theme.colorScheme.onSurface,
  );
  expect(
    scopedTheme.colorScheme.onSurfaceVariant,
    usesInkRecipe ? expectedInk : theme.colorScheme.onSurfaceVariant,
  );
  expect(
    scopedTheme.textTheme.bodyMedium?.color,
    usesInkRecipe ? expectedInk : theme.textTheme.bodyMedium?.color,
  );
  expect(scopedTheme.iconTheme, theme.iconTheme);
  expect(tester.widget<Text>(finder).style?.color, expectedStyleColor);
}

class _NoProfileSelectedProfile extends SelectedProfile {
  _NoProfileSelectedProfile({required super.repository});

  @override
  Future<void> loadProfiles({int? preferredProfileId}) async {}
}

class _TrainThemeRepository extends AppRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async => const [];

  @override
  Future<List<Map<String, dynamic>>> fetchPresetFocusSetCountsRaw({
    required List<int> presetIds,
  }) async => const [];

  @override
  Future<Set<int>> loadActivePlans(int profileId) async => const <int>{};

  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];

  @override
  Future<Map<BodyPart, double>> fetchAllBodyPartSetsOverTimeRange({
    required DateTime start,
    required DateTime end,
  }) async => const <BodyPart, double>{};
}

class _PresetRevealRepository extends _TrainThemeRepository {
  @override
  Future<List<Map<String, dynamic>>> fetchPresetSummariesRaw({
    int? profileId,
  }) async => List<Map<String, dynamic>>.generate(
    4,
    (index) => <String, dynamic>{
      'id': index + 1,
      'name': 'Plan ${index + 1}',
      'is_automatic': 0,
    },
  );
}

class _SelectedProfileWithProfile extends SelectedProfile {
  _SelectedProfileWithProfile({required super.repository}) {
    final profile = GymProfile(
      id: 1,
      name: 'Test profile',
      createdAt: DateTime(2026),
    );
    profiles = [profile];
    currentProfile = profile;
  }

  @override
  Future<void> loadProfiles({int? preferredProfileId}) async {}
}

void _noop() {}
