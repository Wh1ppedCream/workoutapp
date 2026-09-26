import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/providers/active_session.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/exercise/session_screen.dart';
import 'package:env_test/services/workout_exit_preferences.dart';
import 'package:env_test/services/tutorial_state_store.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/widgets/tonos_segmented_action_bar.dart';
import 'package:env_test/utils/app_test_keys.dart';
import 'package:env_test/widgets/drawers.dart';
import 'package:env_test/widgets/exercise_card.dart';
import 'package:env_test/widgets/ongoing_session_fab.dart';
import 'package:env_test/widgets/quick_bar.dart';
import 'package:env_test/widgets/settings_tiles.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Classic settings consumers preserve original surface recipes', (
    tester,
  ) async {
    for (final theme in _classicThemes()) {
      await tester.pumpWidget(
        _localizedApp(
          theme: theme,
          child: Column(
            children: [
              const SettingsHeroCard(
                title: 'Appearance',
                subtitle: 'Control the app appearance.',
                icon: Icons.palette_outlined,
                accentColor: Colors.teal,
              ),
              SettingsSection(
                title: 'Display',
                children: const [SizedBox(height: 24)],
              ),
            ],
          ),
        ),
      );

      final hero = tester.widget<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.borderRadius ==
                  const BorderRadius.all(Radius.circular(28)) &&
              decoration.gradient is LinearGradient;
        }),
      );
      final heroDecoration = hero.decoration! as BoxDecoration;
      final heroGradient = heroDecoration.gradient! as LinearGradient;
      expect(heroGradient.colors.first, Colors.teal.withValues(alpha: 0.26));
      expect(
        heroGradient.colors.last,
        theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.54),
      );
      expect(
        heroDecoration.border!.top.color,
        Colors.teal.withValues(alpha: 0.42),
      );

      final section = tester.widget<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.borderRadius ==
                  const BorderRadius.all(Radius.circular(24)) &&
              decoration.color ==
                  theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: 0.34,
                  );
        }),
      );
      final sectionDecoration = section.decoration! as BoxDecoration;
      expect(
        sectionDecoration.border!.top.color,
        theme.colorScheme.outlineVariant.withValues(alpha: 0.55),
      );
    }
  });

  testWidgets('Classic save bars preserve decorated and plain variants', (
    tester,
  ) async {
    for (final theme in _classicThemes()) {
      await tester.pumpWidget(
        _localizedApp(
          theme: theme,
          child: SettingsSaveBar(
            buttonKey: const ValueKey('decorated-save'),
            label: 'Save',
            onPressed: _noop,
          ),
        ),
      );
      final expectedColor = theme.colorScheme.surface.withValues(alpha: 0.96);
      final decorated = tester.widget<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.color == expectedColor;
        }),
      );
      final decoratedDecoration = decorated.decoration! as BoxDecoration;
      expect(
        decoratedDecoration.border!.top.color,
        theme.colorScheme.outlineVariant,
      );

      await tester.pumpWidget(
        _localizedApp(
          theme: theme,
          child: SettingsSaveBar(
            buttonKey: const ValueKey('plain-save'),
            label: 'Save',
            onPressed: _noop,
            decorated: false,
          ),
        ),
      );
      expect(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.color == expectedColor;
        }),
        findsNothing,
      );
    }
  });

  testWidgets('Classic profile tiles preserve original geometry and motion', (
    tester,
  ) async {
    final profile = GymProfile(
      id: 1,
      name: 'Home gym',
      createdAt: DateTime(2024),
    );
    for (final theme in _classicThemes()) {
      dynamic selected;
      await tester.pumpWidget(
        _localizedApp(
          theme: theme,
          child: ProfileTile(
            profile: profile,
            isSelected: false,
            color: Colors.blue,
            onSelect: (value) => selected = value,
            onEdit: _noopValue,
            onDelete: _noop,
          ),
        ),
      );

      final tile = tester.widget<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(tile.duration, const Duration(milliseconds: 180));
      expect(
        (tile.decoration! as BoxDecoration).borderRadius,
        const BorderRadius.all(Radius.circular(18)),
      );

      await tester.tap(find.text('Home gym'));
      expect(selected, same(profile));
    }
  });

  testWidgets('Classic session timer keeps the original typography', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'guided_tutorial_completed.${TutorialIds.firstWorkoutSession}': true,
    });
    for (final theme in _classicThemes()) {
      final session = _emptySession();
      addTearDown(session.dispose);
      await session.ready;

      await tester.pumpWidget(
        ChangeNotifierProvider<ActiveSession>.value(
          value: session,
          child: _localizedApp(
            theme: theme,
            scaffold: false,
            child: const SessionScreen(),
          ),
        ),
      );
      await tester.pump();

      tester.state<ScaffoldState>(find.byType(Scaffold)).openDrawer();
      await tester.pumpAndSettle();
      final timerTitle = find.text('Workout Timer', skipOffstage: false);
      final timerValue = find.text('0:00', skipOffstage: false);
      expect(tester.widget<Text>(timerTitle).style?.fontSize, 20);
      expect(tester.widget<Text>(timerValue).style?.fontSize, 48);
      Navigator.of(tester.element(find.byType(Scaffold))).pop();
      await tester.pumpAndSettle();
    }
  });

  testWidgets('Classic QuickBar preserves scaled radius and dividers', (
    tester,
  ) async {
    for (final theme in _classicThemes()) {
      await tester.pumpWidget(
        _localizedApp(theme: theme, child: const QuickBar(scale: 0.75)),
      );

      final clip = tester.widget<ClipRRect>(
        find.descendant(
          of: find.byType(TonosSegmentedActionBar),
          matching: find.byType(ClipRRect),
        ),
      );
      expect(clip.borderRadius, const BorderRadius.all(Radius.circular(18)));
      final dividers = tester.widgetList<Container>(
        find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.constraints ==
                  const BoxConstraints.tightFor(width: 0.75, height: 30),
        ),
      );
      expect(dividers, hasLength(2));
      for (final divider in dividers) {
        expect(
          divider.color,
          theme.colorScheme.onSurface.withValues(alpha: 0.12),
        );
      }
    }
  });

  testWidgets('Classic ongoing-session actions and dialog keep their recipes', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    for (final theme in _classicThemes()) {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'workout_exit_behavior': WorkoutExitBehavior.askEveryTime.name,
      });
      final session = _emptySession();
      addTearDown(session.dispose);
      await session.ready;
      session.exercises.add(
        WeightExercise(
          name: 'Squat',
          equipment: 'Barbell',
          sets: [ExerciseSet(), ExerciseSet()],
          completedParents: <int>{0, 1},
        ),
      );
      session.cardTypes.add(CardType.weight);
      expect(session.completedSetCount, 2);

      await tester.pumpWidget(
        ChangeNotifierProvider<ActiveSession>.value(
          value: session,
          child: _localizedApp(
            theme: theme,
            scaffold: false,
            child: Scaffold(
              body: const SizedBox.shrink(),
              floatingActionButton: OngoingSessionFab(
                key: ValueKey(theme.brightness),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(
        tester
            .widget<FloatingActionButton>(
              find.byKey(AppTestKeys.ongoingSessionMenu),
            )
            .backgroundColor,
        Colors.green,
      );
      await tester.tap(find.byKey(AppTestKeys.ongoingSessionMenu));
      await tester.pump();
      expect(
        tester
            .widget<FloatingActionButton>(
              find.byKey(AppTestKeys.ongoingSessionResume),
            )
            .backgroundColor,
        Colors.green,
      );
      expect(
        tester
            .widget<FloatingActionButton>(
              find.byKey(AppTestKeys.ongoingSessionExit),
            )
            .backgroundColor,
        Colors.red,
      );

      await tester.tap(find.byKey(AppTestKeys.ongoingSessionExit));
      await tester.pumpAndSettle();
      expect(find.byType(Dialog), findsOneWidget);
      expect(find.text('End workout?', skipOffstage: false), findsOneWidget);
      expect(
        find.text('Cancel and Delete', skipOffstage: false),
        findsOneWidget,
      );
      expect(
        find.text('End and Save Workout', skipOffstage: false),
        findsOneWidget,
      );
      final choice = tester.widget<Material>(
        find.ancestor(
          of: find.byType(CheckboxListTile, skipOffstage: false),
          matching: find.byWidgetPredicate(
            (widget) =>
                widget is Material &&
                widget.borderRadius ==
                    theme.extension<AppShapeTokens>()!.dialogChoice,
            skipOffstage: false,
          ),
        ),
      );
      expect(
        choice.borderRadius,
        theme.extension<AppShapeTokens>()!.dialogChoice,
      );
      Navigator.of(tester.element(find.byType(Dialog))).pop();
      await tester.pumpAndSettle();
    }
  });
}

List<ThemeData> _classicThemes() => <ThemeData>[
  AppThemeFactory.light(AppThemeFamily.classic),
  AppThemeFactory.dark(AppThemeFamily.classic),
];

Widget _localizedApp({
  required ThemeData theme,
  required Widget child,
  bool scaffold = true,
}) {
  return MaterialApp(
    theme: theme,
    themeAnimationDuration: Duration.zero,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: scaffold ? Scaffold(body: child) : child,
  );
}

ActiveSession _emptySession() =>
    ActiveSession(repository: _EmptyRepository(), retryDelay: (_) async {});

void _noop() {}

void _noopValue(dynamic _) {}

class _EmptyRepository extends AppRepository {
  @override
  Future<Map<String, dynamic>?> loadActiveWorkoutDraft() async => null;

  @override
  Future<List<Map<String, dynamic>>> loadPendingWorkoutProgressions() async =>
      const [];
}
