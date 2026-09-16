import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/widgets/tonos_action_depth.dart';
import 'package:env_test/theme/widgets/workout_actions.dart';
import 'package:env_test/widgets/session_complete_sheet.dart';
import 'package:env_test/widgets/settings_tiles.dart';

void main() {
  for (final dark in [false, true]) {
    final theme =
        dark
            ? AppThemeFactory.dark(AppThemeFamily.neoBrutalism)
            : AppThemeFactory.light(AppThemeFamily.neoBrutalism);

    testWidgets('Neo dark=$dark nested surface roles retain contrast', (
      tester,
    ) async {
      final surfaces = theme.surfaceTokens;
      for (final accent in [null, SettingsAccent.account]) {
        for (final fill in [
          surfaces.settingsSection,
          surfaces.planDuration,
          surfaces.planCard,
          surfaces.card,
          const Color(0xFF171717),
        ]) {
          late BuildContext rowContext;
          await tester.pumpWidget(
            _host(
              theme,
              SettingsSection(
                title: 'Section',
                surfaceColor: fill,
                accentColor: accent,
                children: [
                  Builder(
                    builder: (context) {
                      rowContext = context;
                      return const SettingsActionTile(
                        icon: Icons.settings,
                        title: 'Units',
                        trailing: SettingsValueText(value: 'Pounds'),
                      );
                    },
                  ),
                  const SettingsStatusBadge(label: 'Unavailable'),
                ],
              ),
            ),
          );
          final expected = tonosForegroundForSurface(rowContext, fill);
          expect(Theme.of(rowContext).colorScheme.onSurface, expected);
          expect(IconTheme.of(rowContext).color, expected);
          expect(ListTileTheme.of(rowContext).iconColor, expected);
          expect(
            tester.widget<Text>(find.text('Pounds')).style!.color,
            expected,
          );
          expect(_contrast(expected, fill), greaterThanOrEqualTo(4.5));
          expect(
            _contrast(
              tonosSecondaryForegroundForSurface(rowContext, fill),
              fill,
            ),
            greaterThanOrEqualTo(4.5),
          );
          final badge = tester.widget<Text>(find.text('Unavailable'));
          expect(badge.style!.color, theme.semanticColors.strongContent);
          expect(
            _contrast(badge.style!.color!, surfaces.panelRaised),
            greaterThanOrEqualTo(4.5),
          );
          expect(
            settingsRankingNameTextStyle(rowContext)!.color,
            const Color(0xFF161616),
          );
          expect(tester.takeException(), isNull);
        }
      }
    });

    testWidgets(
      'Neo dark=$dark arbitrary alpha surfaces use painted background',
      (tester) async {
        await tester.pumpWidget(
          _host(
            theme,
            Builder(
              builder: (context) {
                for (final parent in [Colors.white, const Color(0xFF171717)]) {
                  const fill = Color(0x5564DDE0);
                  final foreground = tonosForegroundForSurface(
                    context,
                    fill,
                    parentSurface: parent,
                  );
                  expect(
                    _contrast(foreground, Color.alphaBlend(fill, parent)),
                    greaterThanOrEqualTo(4.5),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ),
        );
      },
    );

    testWidgets(
      'Neo dark=$dark completion states stay bounded and dismissible',
      (tester) async {
        await tester.pumpWidget(
          _host(
            theme,
            const Align(
              alignment: Alignment.bottomCenter,
              child: WorkoutCompletionStatus.loading(),
            ),
          ),
        );
        expect(
          tester.getSize(find.byType(WorkoutCompletionStatus)).height,
          lessThan(300),
        );
        expect(
          tester
              .widget<CircularProgressIndicator>(
                find.byType(CircularProgressIndicator),
              )
              .color,
          theme.semanticColors.strongContent,
        );
        var closes = 0;
        await tester.pumpWidget(
          _host(
            theme,
            Align(
              alignment: Alignment.bottomCenter,
              child: WorkoutCompletionStatus.error(onClose: () => closes++),
            ),
            scale: 2,
          ),
        );
        await tester.tap(find.byType(TextButton));
        expect(closes, 1);
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'Neo dark=$dark completion metrics stay compact and cards stay condensed',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.binding.setSurfaceSize(const Size(420, 900));
        final controller = ScrollController();
        addTearDown(controller.dispose);
        await tester.pumpWidget(
          _host(
            theme,
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 420,
                height: 850,
                child: WorkoutCompletionPresentation(
                  scrollController: controller,
                  exercises: [
                    _plainExercise('Barbell Squat'),
                    _plainExercise('Bench Press'),
                  ],
                  totalSets: 6,
                  duration: '7s',
                  volume: '0 lbs',
                  onDone: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final metrics = find.byWidgetPredicate(
          (widget) =>
              widget is Container &&
              widget.key is ValueKey<String> &&
              (widget.key! as ValueKey<String>).value.startsWith(
                'workout-completion-metric-',
              ),
        );
        expect(metrics, findsNWidgets(4));
        for (var index = 0; index < 4; index++) {
          expect(
            tester.getSize(metrics.at(index)).width,
            greaterThanOrEqualTo(80),
          );
          expect(
            tester.getSize(metrics.at(index)).height,
            lessThanOrEqualTo(78),
          );
        }

        final cards = find.byType(WorkoutCompletionExerciseCard);
        expect(cards, findsNWidgets(2));
        expect(tester.getSize(cards.first).height, lessThan(150));
        expect(tester.takeException(), isNull);
      },
    );

    for (final locale in ['en', 'es']) {
      for (final width in [320.0, 420.0]) {
        for (final scale in [1.0, 2.0]) {
          testWidgets(
            'completion dark=$dark $locale width=$width scale=$scale',
            (tester) async {
              final controller = ScrollController();
              addTearDown(controller.dispose);
              var done = 0;
              await tester.pumpWidget(
                _host(
                  theme,
                  Align(
                    alignment: Alignment.topCenter,
                    child: SizedBox(
                      width: width,
                      height: 560,
                      child: WorkoutCompletionPresentation(
                        scrollController: controller,
                        exercises: [
                          _exercise(
                            'Romanian Deadlift - Barbell with a long name',
                          ),
                          _exercise('Final exercise'),
                        ],
                        totalSets: 6,
                        duration: '12h 59m',
                        volume: '123,456 lbs',
                        onDone: () => done++,
                        doneButtonKey: const ValueKey('done'),
                      ),
                    ),
                  ),
                  locale: Locale(locale),
                  scale: scale,
                ),
              );
              await tester.pump();
              expect(tester.takeException(), isNull);
              for (var i = 0; i < 3; i++) {
                controller.jumpTo(controller.position.maxScrollExtent);
                await tester.pump();
              }
              expect(tester.takeException(), isNull);
              final card = find.byType(WorkoutCompletionExerciseCard).last;
              expect(
                tester.getBottomRight(card).dy,
                lessThanOrEqualTo(
                  tester.getTopLeft(find.byKey(const ValueKey('done'))).dy,
                ),
              );
              await tester.tap(find.byKey(const ValueKey('done')));
              expect(done, 1);
              await tester.pumpWidget(const SizedBox.shrink());
            },
          );
        }
      }
    }

    testWidgets(
      'Neo dark=$dark action depth follows Material, not touch padding',
      (tester) async {
        for (final enabled in [true, false]) {
          for (final busy in [false, true]) {
            await tester.pumpWidget(
              _host(
                theme,
                Center(
                  child: WorkoutFinishAction(
                    label: 'Finish',
                    onPressed: enabled ? () {} : null,
                    busy: busy,
                  ),
                ),
              ),
            );
            await tester.pump(const Duration(milliseconds: 300));
            final material = tester.widget<Material>(
              find.descendant(
                of: find.byType(ElevatedButton),
                matching: find.byType(Material),
              ),
            );
            expect(material.shape is TonosActionShadowBorder, enabled && !busy);
            if (enabled && !busy) {
              final shape = material.shape! as TonosActionShadowBorder;
              expect(shape.offset, const Offset(4, 4));
              expect(shape.color, theme.effectTokens.cardShadow);
              final path = shape.shadowPath(const Rect.fromLTWH(0, 0, 100, 40));
              expect(path.contains(const Offset(50, 20)), isFalse);
              expect(path.contains(const Offset(102, 20)), isTrue);
              expect(path.getBounds().bottom, 44);
            }
          }
        }
        final noEffects = theme.copyWith(
          extensions: [
            for (final extension in theme.extensions.values)
              if (extension is! AppEffectTokens) extension,
            theme.effectTokens.copyWith(
              cardShadow: Colors.transparent,
              primaryActionShadowOffset: Offset.zero,
            ),
          ],
        );
        await tester.pumpWidget(
          _host(
            noEffects,
            WorkoutFinishAction(label: 'Finish', onPressed: () {}),
          ),
        );
        await tester.pump(const Duration(milliseconds: 300));
        expect(
          find.byWidgetPredicate(
            (widget) =>
                widget is Material && widget.shape is TonosActionShadowBorder,
          ),
          findsNothing,
        );
        expect(tester.takeException(), isNull);
      },
    );
  }

  for (final family in [AppThemeFamily.classic, AppThemeFamily.neoBrutalism]) {
    testWidgets(
      '${family.name} completion keeps ERM inline and right aligned',
      (tester) async {
        addTearDown(() => tester.binding.setSurfaceSize(null));
        await tester.binding.setSurfaceSize(const Size(420, 800));
        final controller = ScrollController();
        addTearDown(controller.dispose);
        final theme = AppThemeFactory.light(family);
        await tester.pumpWidget(
          _host(
            theme,
            Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 420,
                height: 760,
                child: WorkoutCompletionPresentation(
                  scrollController: controller,
                  exercises: [_singleSetExercise('Barbell Squat')],
                  totalSets: 1,
                  duration: '7s',
                  volume: '0 lbs',
                  onDone: () {},
                ),
              ),
            ),
          ),
        );
        await tester.pump();

        final erm = find.byWidgetPredicate(
          (widget) => widget is Text && (widget.data ?? '').startsWith('ERM='),
        );
        final set = find.text('0 lbs x 8');
        final card = find.byType(WorkoutCompletionExerciseCard);
        expect(erm, findsOneWidget);
        expect(set, findsOneWidget);
        expect(card, findsOneWidget);
        final ermRect = tester.getRect(erm);
        final setRect = tester.getRect(set);
        final cardRect = tester.getRect(card);
        final ermColumn = find.byWidgetPredicate(
          (widget) => widget is SizedBox && widget.width == 88,
        );
        expect(ermColumn, findsOneWidget);
        expect((ermRect.center.dy - setRect.center.dy).abs(), lessThan(8));
        expect(
          tester.getRect(ermColumn).right,
          greaterThan(cardRect.center.dx),
        );
        expect(
          cardRect.right - tester.getRect(ermColumn).right,
          lessThanOrEqualTo(16),
        );
        expect(tester.takeException(), isNull);
      },
    );
  }
}

WorkoutCompletionExercise _exercise(String name) => WorkoutCompletionExercise(
  exercise: WeightExercise(
    name: name,
    equipment: 'Barbell',
    sets: [for (var i = 0; i < 3; i++) ExerciseSet(weight: 1234.5, reps: 12)],
  ),
  weightUnit: WeightUnit.pounds,
  badges: const WorkoutExerciseRecordBadges(
    isFirstRecord: true,
    setBadges: {
      0: [
        WorkoutRecordBadge(
          tier: WorkoutRecordBadgeTier.monthly,
          type: WorkoutRecordBadgeType.repBest,
          reps: 12,
        ),
        WorkoutRecordBadge(
          tier: WorkoutRecordBadgeTier.allTime,
          type: WorkoutRecordBadgeType.volumeBest,
        ),
      ],
    },
  ),
);

WorkoutCompletionExercise _plainExercise(String name) =>
    WorkoutCompletionExercise(
      exercise: WeightExercise(
        name: name,
        equipment: 'Barbell',
        sets: [for (var i = 0; i < 3; i++) ExerciseSet(weight: 0, reps: 8)],
      ),
      weightUnit: WeightUnit.pounds,
      badges: const WorkoutExerciseRecordBadges(isFirstRecord: false),
    );

WorkoutCompletionExercise _singleSetExercise(String name) =>
    WorkoutCompletionExercise(
      exercise: WeightExercise(
        name: name,
        equipment: 'Barbell',
        sets: [ExerciseSet(weight: 0, reps: 8)],
      ),
      weightUnit: WeightUnit.pounds,
      badges: const WorkoutExerciseRecordBadges(isFirstRecord: false),
    );

Widget _host(
  ThemeData theme,
  Widget child, {
  Locale locale = const Locale('en'),
  double scale = 1,
}) => MaterialApp(
  theme: theme,
  themeAnimationDuration: Duration.zero,
  locale: locale,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  supportedLocales: AppLocalizations.supportedLocales,
  builder:
      (context, child) => MediaQuery(
        data: MediaQuery.of(
          context,
        ).copyWith(textScaler: TextScaler.linear(scale)),
        child: child!,
      ),
  home: Scaffold(body: child),
);

double _contrast(Color foreground, Color background) {
  final first = Color.alphaBlend(foreground, background).computeLuminance();
  final second = background.computeLuminance();
  return first > second
      ? (first + 0.05) / (second + 0.05)
      : (second + 0.05) / (first + 0.05);
}
