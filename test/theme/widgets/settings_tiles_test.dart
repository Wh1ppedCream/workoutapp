import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/app_theme_family.dart';
import 'package:env_test/theme/app_theme_factory.dart';
import 'package:env_test/theme/theme_extensions.dart';
import 'package:env_test/theme/widgets/tonos_action_depth.dart';
import 'package:env_test/theme/widgets/tonos_expansion_tile_scope.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_settings_presentation_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/widgets/settings_tiles.dart';

const _testShapes = AppShapeTokens(
  compact: BorderRadius.all(Radius.circular(4)),
  control: BorderRadius.all(Radius.circular(10)),
  metric: BorderRadius.all(Radius.circular(14)),
  recordBadge: BorderRadius.all(Radius.circular(7)),
  recordBadgeCompact: BorderRadius.all(Radius.circular(5)),
  workoutSection: BorderRadius.all(Radius.circular(10)),
  planCard: BorderRadius.all(Radius.circular(18)),
  flowControl: BorderRadius.all(Radius.circular(20)),
  flowIcon: BorderRadius.all(Radius.circular(13)),
  card: BorderRadius.all(Radius.circular(18)),
  sheet: BorderRadius.all(Radius.circular(26)),
  pill: BorderRadius.all(Radius.circular(999)),
  settingsAction: BorderRadius.all(Radius.circular(13)),
  settingsPanel: BorderRadius.all(Radius.circular(22)),
  settingsInput: BorderRadius.all(Radius.circular(14)),
  settingsTabIndicator: BorderRadius.all(Radius.circular(17)),
  settingsScopeIcon: BorderRadius.all(Radius.circular(19)),
  settingsTitleCard: BorderRadius.all(Radius.circular(21)),
  settingsField: BorderRadius.all(Radius.circular(16)),
  settingsPicker: BorderRadius.all(Radius.circular(20)),
  settingsIcon: BorderRadius.all(Radius.circular(13)),
  profileTile: BorderRadius.all(Radius.circular(20)),
  hero: BorderRadius.all(Radius.circular(30)),
  actionBar: BorderRadius.all(Radius.circular(22)),
  dialogChoice: BorderRadius.all(Radius.circular(11)),
  exerciseProgressHero: BorderRadius.all(Radius.circular(18)),
  exerciseProgressStat: BorderRadius.all(Radius.circular(14)),
  exerciseProgressSelector: BorderRadius.all(Radius.circular(14)),
  exerciseProgressAddTile: BorderRadius.all(Radius.circular(12)),
  exerciseProgressTooltip: BorderRadius.all(Radius.circular(10)),
  workoutMetricStat: BorderRadius.all(Radius.circular(16)),
  workoutMetricChart: BorderRadius.all(Radius.circular(18)),
  workoutMetricTooltip: BorderRadius.all(Radius.circular(10)),
  workoutMetricRange: BorderRadius.all(Radius.circular(14)),
  workoutMetricRangeOption: BorderRadius.all(Radius.circular(11)),
  workoutMetricDetails: BorderRadius.all(Radius.circular(14)),
  workoutMetricInsight: BorderRadius.all(Radius.circular(14)),
  healthTrendCard: BorderRadius.all(Radius.circular(18)),
  healthTrendEntry: BorderRadius.all(Radius.circular(14)),
  dashboardHero: BorderRadius.all(Radius.circular(22)),
  dashboardSection: BorderRadius.all(Radius.circular(24)),
  dashboardEditor: BorderRadius.all(Radius.circular(20)),
  dashboardAction: BorderRadius.all(Radius.circular(16)),
  dashboardUsage: BorderRadius.all(Radius.circular(13)),
  dashboardRow: BorderRadius.all(Radius.circular(14)),
  dashboardFooter: BorderRadius.all(Radius.circular(22)),
  historySelectedPeriod: BorderRadius.all(Radius.circular(18)),
  outlineWidth: 1.5,
  focusRingWidth: 2,
);

const _testSurfaces = AppSurfaceTokens(
  presetFocus: Color(0xFF181818),
  workoutHandle: Color(0xFF282828),
  sessionSummary: Color(0xFF292929),
  panel: Color(0xFF101010),
  panelRaised: Color(0xFF202020),
  card: Color(0xFF303030),
  planCard: Color(0xFF383838),
  flowControl: Color(0xFF393939),
  planFilter: Color(0xFF3A3A3A),
  planDuration: Color(0xFF3B3B3B),
  planGroup: Color(0xFF3C3C3C),
  metricChip: Color(0xFF3D3D3D),
  planActionBar: Color(0xFF3E3E3E),
  optimizedAction: Color(0xFF3F3F3F),
  subtleOutline: Color(0xFF404040),
  neutralOutline: Color(0xFF414141),
  input: Color(0xFF505050),
  sheet: Color(0xFF606060),
  dialog: Color(0xFF707070),
  media: Color(0xFF808080),
  mediaFrame: Color(0xFF858585),
  mediaPlaceholder: Color(0xFF909090),
  mediaOutline: Color(0xFF959595),
  catalogSelection: Color(0xFF989898),
  catalogUsage: Color(0xFF999999),
  catalogOutline: Color(0xFF9A9A9A),
  exerciseDetailCard: Color(0xFF9B9B9B),
  exerciseDetailTimeframe: Color(0xFF9C9C9C),
  exerciseDetailRecord: Color(0xFF9D9D9D),
  exerciseDetailMetricList: Color(0xFF9E9E9E),
  exerciseDetailState: Color(0xFF9F9F9F),
  exerciseDetailChart: Color(0xFFA1A1A1),
  exerciseDetailChartEmpty: Color(0xFFA2A2A2),
  exerciseDetailTooltip: Color(0xFFA3A3A3),
  divider: Color(0xFFA0A0A0),
  settingsHero: Color(0xFFB0B0B0),
  settingsSection: Color(0xFFC0C0C0),
  settingsInput: Color(0xFFD0D0D0),
  settingsSaveBar: Color(0xFFE0E0E0),
  dialogChoice: Color(0xFFF0F0F0),
  exerciseProgressHero: Color(0xFFF1F1F1),
  exerciseProgressStat: Color(0xFFF2F2F2),
  exerciseProgressSelector: Color(0xFFF3F3F3),
  exerciseProgressTooltip: Color(0xFFF4F4F4),
  workoutMetricStat: Color(0xFFF5F5F5),
  workoutMetricChart: Color(0xFFF6F6F6),
  workoutMetricTooltip: Color(0xFFF7F7F7),
  workoutMetricRange: Color(0xFFF8F8F8),
  workoutMetricDetails: Color(0xFFF9F9F9),
  workoutMetricInsight: Color(0xFFFAFAFA),
  dashboardHero: Color(0xFF010101),
  dashboardSection: Color(0xFF020202),
  dashboardEditor: Color(0xFF030303),
  dashboardUsage: Color(0xFF040404),
  historyPeriodSelector: Color(0xFF050505),
  calendarModeSelector: Color(0xFF060606),
  calendarDayEmpty: Color(0xFF090909),
  historySelectedPeriod: Color(0xFF070707),
  historyDivider: Color(0xFF080808),
);

void main() {
  test('settings category accents retain their stable mapping', () {
    const expected = <String, Color>{
      'account': Color(0xFFB39DDB),
      'appearance': Color(0xFFCE93D8),
      'training': Color(0xFF4DB6AC),
      'progress': Color(0xFF81C784),
      'data': Color(0xFF64B5F6),
      'advanced': Color(0xFFFFB74D),
      'safety': Color(0xFFEF9A9A),
      'muted': Color(0xFF9E9E9E),
    };

    expect(<String, Color>{
      'account': SettingsAccent.account,
      'appearance': SettingsAccent.appearance,
      'training': SettingsAccent.training,
      'progress': SettingsAccent.progress,
      'data': SettingsAccent.data,
      'advanced': SettingsAccent.advanced,
      'safety': SettingsAccent.safety,
      'muted': SettingsAccent.muted,
    }, expected);
  });

  testWidgets('settings info cards do not create a redundant local theme', (
    tester,
  ) async {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
      AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
    ]) {
      await tester.pumpWidget(
        _testApp(
          const SettingsInfoCard(
            key: ValueKey('settings-info-card'),
            title: 'Information',
            body: 'Settings details.',
            icon: Icons.info_outline,
          ),
          theme: theme,
        ),
      );

      expect(
        find.descendant(
          of: find.byKey(const ValueKey('settings-info-card')),
          matching: find.byType(Theme),
        ),
        findsNothing,
      );
    }
  });

  testWidgets('hero switches between Classic gradient and solid recipe', (
    tester,
  ) async {
    for (final gradient in [true, false]) {
      await tester.pumpWidget(
        _testApp(
          const SettingsHeroCard(
            key: ValueKey('hero-recipe'),
            title: 'Appearance',
            icon: Icons.palette,
          ),
          presentation: AppSettingsPresentationTokens(
            heroUsesGradient: gradient,
          ),
        ),
      );
      final container =
          tester
              .widgetList<Container>(
                find.descendant(
                  of: find.byKey(const ValueKey('hero-recipe')),
                  matching: find.byType(Container),
                ),
              )
              .first;
      final decoration = container.decoration! as BoxDecoration;
      expect(decoration.gradient, gradient ? isA<LinearGradient>() : isNull);
      expect(decoration.color, gradient ? isNull : _testSurfaces.settingsHero);
      expect(
        (decoration.border! as Border).top.width,
        _testShapes.outlineWidth,
      );
      expect(decoration.boxShadow, isNull);
    }
  });

  testWidgets('Neo settings use proposal labels, outlines, and depth', (
    tester,
  ) async {
    final theme = AppThemeFactory.light(AppThemeFamily.neoBrutalism);
    await tester.pumpWidget(
      _testApp(
        Column(
          children: [
            const SettingsHeroCard(
              key: ValueKey('neo-settings-hero'),
              title: 'User information',
              icon: Icons.badge_outlined,
            ),
            SettingsSection(
              key: const ValueKey('neo-settings-section'),
              title: 'Identity',
              subtitle: 'Basic personal details.',
              accentColor: Colors.teal,
              children: const [SizedBox(height: 24)],
            ),
            SettingsSaveBar(
              buttonKey: const ValueKey('neo-settings-save'),
              label: 'Save changes',
              onPressed: _noop,
            ),
          ],
        ),
        theme: theme,
      ),
    );

    final hero = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == theme.shapeTokens.hero;
      }),
    );
    final heroDecoration = hero.decoration! as BoxDecoration;
    expect(heroDecoration.color, theme.surfaceTokens.settingsHero);
    expect(
      (heroDecoration.border! as Border).top.color,
      theme.surfaceTokens.subtleOutline,
    );
    expect(
      heroDecoration.boxShadow!.single.offset,
      theme.effectTokens.raisedPanelShadowOffset,
    );

    final categoryLabel = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.color ==
                theme.settingsPresentationTokens.sectionHeaderFill &&
            decoration.borderRadius == theme.shapeTokens.compact;
      }),
    );
    final categoryDecoration = categoryLabel.decoration! as BoxDecoration;
    expect(
      (categoryDecoration.border! as Border).top.color,
      theme.surfaceTokens.subtleOutline,
    );
    final saveBar = tester.widget<Container>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('neo-settings-save')),
            matching: find.byType(Container),
          )
          .last,
    );
    final saveBarDecoration = saveBar.decoration! as BoxDecoration;
    expect(
      (saveBarDecoration.border! as Border).top.color,
      theme.surfaceTokens.subtleOutline,
    );
    final buttonDepthFinder = find.descendant(
      of: find.byKey(const ValueKey('neo-settings-save')),
      matching: find.byWidgetPredicate(
        (widget) =>
            widget is Material && widget.shape is TonosActionShadowBorder,
      ),
    );
    expect(buttonDepthFinder, findsOneWidget);
    final saveDepth = tester.widget<Material>(buttonDepthFinder);
    final saveShape = saveDepth.shape! as TonosActionShadowBorder;
    expect(saveShape.offset, theme.effectTokens.primaryActionShadowOffset);
  });

  testWidgets('save bar respects reduced motion and remains actionable', (
    tester,
  ) async {
    var saves = 0;
    for (final reduced in [false, true]) {
      for (final visible in [false, true]) {
        await tester.pumpWidget(
          _testApp(
            MediaQuery(
              data: MediaQueryData(disableAnimations: reduced),
              child: SettingsSaveBar(
                buttonKey: const ValueKey('reduced-motion-save'),
                label: 'Save',
                onPressed: () => saves++,
                isVisible: visible,
                animate: true,
              ),
            ),
          ),
        );
        final slide = tester.widget<AnimatedSlide>(find.byType(AnimatedSlide));
        final fade = tester.widget<AnimatedOpacity>(
          find.byType(AnimatedOpacity),
        );
        final expected =
            reduced ? Duration.zero : const Duration(milliseconds: 200);
        expect(slide.duration, expected);
        expect(fade.duration, expected);
        expect(slide.offset, visible ? Offset.zero : const Offset(0, 1));
        expect(fade.opacity, visible ? 1 : 0);
        await tester.pumpAndSettle();
        if (visible) {
          await tester.tap(find.byKey(const ValueKey('reduced-motion-save')));
        } else {
          expect(
            tester
                .widget<ButtonStyleButton>(
                  find.byKey(const ValueKey('reduced-motion-save')),
                )
                .onPressed,
            isNull,
          );
        }
      }
    }
    expect(saves, 2);
  });
  testWidgets('shared settings sections resolve active surface recipes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const SettingsSection(
          title: 'Display',
          children: [SizedBox(height: 24)],
        ),
      ),
    );

    final panel = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == _testShapes.sheet;
      }),
    );
    final decoration = panel.decoration! as BoxDecoration;
    expect(decoration.color, _testSurfaces.settingsSection);
    expect(decoration.border, isA<Border>());
    expect((decoration.border! as Border).top.color, isNotNull);
  });

  testWidgets('settings sections can keep category accents out of controls', (
    tester,
  ) async {
    const accent = Colors.teal;
    await tester.pumpWidget(
      _testApp(
        SettingsSection(
          title: 'Training',
          accentColor: accent,
          children: [
            Builder(
              builder:
                  (context) => Text(
                    'primary-role',
                    style: TextStyle(color: context.cs.primary),
                  ),
            ),
          ],
        ),
        presentation: const AppSettingsPresentationTokens(
          sectionUsesAccentForControls: false,
        ),
      ),
    );

    final sectionContext = tester.element(find.byType(SettingsSection));
    final primary = Theme.of(sectionContext).colorScheme.primary;
    expect(
      tester.widget<Text>(find.text('primary-role')).style?.color,
      primary,
    );
  });

  testWidgets(
    'settings section child theme preserves Material roles in every mode',
    (tester) async {
      const accent = Colors.teal;
      for (final entry in _registeredThemes().entries) {
        late BuildContext outerContext;
        late ThemeData childTheme;
        await tester.pumpWidget(
          _testApp(
            Builder(
              builder: (context) {
                outerContext = context;
                return SettingsSection(
                  title: 'Training',
                  accentColor: accent,
                  children: [
                    Builder(
                      builder: (context) {
                        childTheme = Theme.of(context);
                        return const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(title: Text('Scoped settings row')),
                            LinearProgressIndicator(value: 0.5),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            theme: entry.value,
          ),
        );

        final baseTheme = Theme.of(outerContext);
        final presentation = outerContext.settingsPresentationTokens;
        final usesInkRecipe =
            outerContext.surfaceDecorationTokens.panel.outlined;
        final sectionSurface = outerContext.surfaceTokens.settingsSection;
        final foreground = tonosForegroundForSurface(
          outerContext,
          sectionSurface,
        );
        final secondaryForeground = tonosSecondaryForegroundForSurface(
          outerContext,
          sectionSurface,
        );
        final hasLocalTheme =
            usesInkRecipe || presentation.sectionUsesAccentForControls;

        expect(
          childTheme.colorScheme.primary,
          presentation.sectionUsesAccentForControls
              ? accent
              : baseTheme.colorScheme.primary,
          reason: entry.key,
        );
        expect(
          childTheme.colorScheme.surface,
          usesInkRecipe ? sectionSurface : baseTheme.colorScheme.surface,
          reason: entry.key,
        );
        expect(
          childTheme.colorScheme.onSurface,
          hasLocalTheme ? foreground : baseTheme.colorScheme.onSurface,
          reason: entry.key,
        );
        expect(
          childTheme.colorScheme.onSurfaceVariant,
          hasLocalTheme
              ? secondaryForeground
              : baseTheme.colorScheme.onSurfaceVariant,
          reason: entry.key,
        );
        expect(
          childTheme.textTheme.bodyMedium?.color,
          usesInkRecipe ? foreground : baseTheme.textTheme.bodyMedium?.color,
          reason: entry.key,
        );
        expect(
          childTheme.iconTheme.color,
          usesInkRecipe ? foreground : baseTheme.iconTheme.color,
          reason: entry.key,
        );
        expect(
          childTheme.listTileTheme.textColor,
          usesInkRecipe ? foreground : baseTheme.listTileTheme.textColor,
          reason: entry.key,
        );
        expect(
          childTheme.progressIndicatorTheme.color,
          usesInkRecipe ? foreground : baseTheme.progressIndicatorTheme.color,
          reason: entry.key,
        );
        final progressBar = find.byType(LinearProgressIndicator);
        expect(progressBar, findsOneWidget, reason: entry.key);
        final renderedProgressTheme =
            Theme.of(tester.element(progressBar)).progressIndicatorTheme;
        expect(
          renderedProgressTheme.color,
          usesInkRecipe ? foreground : baseTheme.progressIndicatorTheme.color,
          reason: entry.key,
        );
        expect(
          renderedProgressTheme.linearTrackColor,
          baseTheme.progressIndicatorTheme.linearTrackColor,
          reason: entry.key,
        );
        expect(tester.takeException(), isNull, reason: entry.key);
      }
    },
  );

  testWidgets('expandable settings sections preserve themed expansion recipe', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const SettingsExpansionSection(
          title: 'Tutorials',
          subtitle: 'Replay guided help',
          icon: Icons.school_outlined,
          accentColor: Colors.teal,
          children: [Text('Tutorial item')],
        ),
      ),
    );

    final panel = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == _testShapes.sheet;
      }),
    );
    final decoration = panel.decoration! as BoxDecoration;
    expect(decoration.color, _testSurfaces.settingsSection);
    expect(
      (decoration.border! as Border).top.color,
      Colors.teal.withValues(alpha: 0.46),
    );

    final iconBadge = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == _testShapes.settingsAction;
      }),
    );
    final iconDecoration = iconBadge.decoration! as BoxDecoration;
    expect(iconDecoration.color, Colors.teal.withValues(alpha: 0.16));

    await tester.tap(find.text('Tutorials'));
    await tester.pumpAndSettle();
    expect(find.text('Tutorial item'), findsOneWidget);
    expect(
      find.ancestor(
        of: find.text('Tutorial item'),
        matching: find.byType(TonosExpansionTileScope),
      ),
      findsOneWidget,
    );
    final childTheme = Theme.of(tester.element(find.text('Tutorial item')));
    expect(childTheme.dividerColor, Colors.transparent);
    expect(childTheme.colorScheme.primary, Colors.teal);
  });

  testWidgets(
    'expandable settings child theme preserves Material roles in every mode',
    (tester) async {
      const accent = Colors.teal;
      for (final entry in _registeredThemes().entries) {
        late BuildContext outerContext;
        late ThemeData childTheme;
        await tester.pumpWidget(
          _testApp(
            Builder(
              builder: (context) {
                outerContext = context;
                return SettingsExpansionSection(
                  key: ValueKey(entry.key),
                  title: 'Preferences',
                  subtitle: 'Theme-owned controls',
                  icon: Icons.tune,
                  accentColor: accent,
                  children: [
                    Builder(
                      builder: (context) {
                        childTheme = Theme.of(context);
                        return const Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(title: Text('Scoped settings row')),
                            LinearProgressIndicator(value: 0.5),
                          ],
                        );
                      },
                    ),
                  ],
                );
              },
            ),
            theme: entry.value,
          ),
        );

        await tester.tap(find.text('Preferences'));
        await tester.pumpAndSettle();

        final baseTheme = Theme.of(outerContext);
        final presentation = outerContext.settingsPresentationTokens;
        final usesInkRecipe =
            outerContext.surfaceDecorationTokens.panel.outlined;
        final sectionSurface = outerContext.surfaceTokens.settingsSection;
        final foreground = tonosForegroundForSurface(
          outerContext,
          sectionSurface,
        );
        final secondaryForeground = tonosSecondaryForegroundForSurface(
          outerContext,
          sectionSurface,
        );

        expect(
          childTheme.colorScheme.primary,
          presentation.sectionUsesAccentForControls
              ? accent
              : baseTheme.colorScheme.primary,
          reason: entry.key,
        );
        expect(
          childTheme.colorScheme.onSurface,
          usesInkRecipe ? foreground : baseTheme.colorScheme.onSurface,
          reason: entry.key,
        );
        expect(
          childTheme.colorScheme.onSurfaceVariant,
          usesInkRecipe
              ? secondaryForeground
              : baseTheme.colorScheme.onSurfaceVariant,
          reason: entry.key,
        );
        expect(
          childTheme.textTheme.bodyMedium?.color,
          usesInkRecipe ? foreground : baseTheme.textTheme.bodyMedium?.color,
          reason: entry.key,
        );
        expect(childTheme.dividerColor, Colors.transparent, reason: entry.key);
        expect(childTheme.iconTheme, baseTheme.iconTheme, reason: entry.key);
        expect(
          childTheme.listTileTheme,
          baseTheme.listTileTheme,
          reason: entry.key,
        );
        final progressBar = find.byType(LinearProgressIndicator);
        expect(progressBar, findsOneWidget, reason: entry.key);
        final renderedProgressTheme =
            Theme.of(tester.element(progressBar)).progressIndicatorTheme;
        expect(
          renderedProgressTheme.color,
          baseTheme.progressIndicatorTheme.color,
          reason: entry.key,
        );
        expect(
          renderedProgressTheme.linearTrackColor,
          baseTheme.progressIndicatorTheme.linearTrackColor,
          reason: entry.key,
        );
        expect(tester.takeException(), isNull, reason: entry.key);
      }
    },
  );

  testWidgets('shared settings actions preserve callbacks', (tester) async {
    var taps = 0;
    await tester.pumpWidget(
      _testApp(
        SettingsActionTile(
          icon: Icons.settings,
          title: 'Open settings',
          onTap: () => taps++,
        ),
      ),
    );

    await tester.tap(find.text('Open settings'));
    expect(taps, 1);
  });

  testWidgets('shared settings value text uses the active primary role', (
    tester,
  ) async {
    await tester.pumpWidget(_testApp(const SettingsValueText(value: 'Pounds')));

    final valueText = tester.widget<Text>(find.text('Pounds'));
    final context = tester.element(find.text('Pounds'));
    expect(valueText.style?.color, Theme.of(context).colorScheme.primary);
    expect(valueText.style?.fontWeight, FontWeight.w900);
  });

  testWidgets('shared settings value text wraps at large text scale', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: const SettingsValueText(value: 'Simplified Chinese language'),
        ),
      ),
    );

    final valueText = tester.widget<Text>(
      find.text('Simplified Chinese language'),
    );
    expect(valueText.maxLines, 2);
    expect(valueText.overflow, TextOverflow.ellipsis);
    expect(valueText.softWrap, isTrue);
  });

  testWidgets('settings action tiles use a bounded layout for large text', (
    tester,
  ) async {
    await tester.binding.setSurfaceSize(const Size(320, 640));
    addTearDown(() => tester.binding.setSurfaceSize(null));
    await tester.pumpWidget(
      _testApp(
        MediaQuery(
          data: const MediaQueryData(textScaler: TextScaler.linear(2.0)),
          child: const SettingsActionTile(
            icon: Icons.palette_outlined,
            title: 'Theme family',
            subtitle: 'Choose the visual family used throughout the app.',
            trailing: SettingsValueText(value: 'Neo-Brutalism'),
          ),
        ),
      ),
    );

    expect(find.byType(ListTile), findsNothing);
    expect(find.text('Theme family'), findsOneWidget);
    expect(
      find.text('Choose the visual family used throughout the app.'),
      findsOneWidget,
    );
    expect(find.text('Neo-Brutalism'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shared settings status badges resolve surface recipes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(const SettingsStatusBadge(label: 'Later')),
    );

    final badge = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == _testShapes.pill;
      }),
    );
    final decoration = badge.decoration! as BoxDecoration;
    expect(decoration.color, _testSurfaces.panelRaised);
    expect(decoration.border, isA<Border>());
    expect(
      (decoration.border! as Border).top.color,
      Theme.of(tester.element(find.text('Later'))).colorScheme.outlineVariant,
    );
  });

  testWidgets('Classic light and dark badges keep the standard outline role', (
    tester,
  ) async {
    for (final theme in <ThemeData>[
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      await tester.pumpWidget(
        _testApp(const SettingsStatusBadge(label: 'Classic'), theme: theme),
      );
      final badge = tester.widget<Container>(
        find.byWidgetPredicate((widget) {
          if (widget is! Container) return false;
          final decoration = widget.decoration;
          return decoration is BoxDecoration &&
              decoration.borderRadius == theme.shapeTokens.pill;
        }),
      );
      final decoration = badge.decoration! as BoxDecoration;
      expect(decoration.border, isA<Border>());
      expect(
        (decoration.border! as Border).top.color,
        theme.colorScheme.outlineVariant,
      );
    }
  });

  testWidgets(
    'Classic light and dark shared settings primitives preserve their roles',
    (tester) async {
      const accent = Colors.teal;
      for (final theme in <ThemeData>[
        AppThemeFactory.light(AppThemeFamily.classic),
        AppThemeFactory.dark(AppThemeFamily.classic),
      ]) {
        await tester.pumpWidget(
          _testApp(
            Column(
              children: [
                SettingsAccentPill(
                  key: ValueKey('classic-accent-pill'),
                  label: 'Source',
                  color: accent,
                ),
                SettingsLegendChip(
                  key: ValueKey('classic-legend-chip'),
                  color: accent,
                  label: 'Plan scope',
                ),
                SettingsCountBadge(
                  key: ValueKey('classic-count-badge'),
                  count: 3,
                  color: accent,
                ),
                SettingsInlineActionButton(
                  key: ValueKey('classic-inline-action'),
                  label: 'Add item',
                  icon: Icons.add,
                  onPressed: _noop,
                ),
              ],
            ),
            theme: theme,
          ),
        );

        final pill = tester.widget<Container>(
          find.descendant(
            of: find.byKey(const ValueKey('classic-accent-pill')),
            matching: find.byType(Container),
          ),
        );
        final pillDecoration = pill.decoration! as BoxDecoration;
        expect(pillDecoration.borderRadius, theme.shapeTokens.pill);
        expect(pillDecoration.color, accent.withValues(alpha: 0.14));

        final legend = tester.widget<Container>(
          find.descendant(
            of: find.byKey(const ValueKey('classic-legend-chip')),
            matching: find.byWidgetPredicate((widget) {
              if (widget is! Container) return false;
              final decoration = widget.decoration;
              return decoration is BoxDecoration &&
                  decoration.borderRadius == theme.shapeTokens.pill;
            }),
          ),
        );
        final legendDecoration = legend.decoration! as BoxDecoration;
        expect(legendDecoration.color, accent.withValues(alpha: 0.12));
        expect(
          (legendDecoration.border! as Border).top.color,
          accent.withValues(alpha: 0.36),
        );

        final count = tester.widget<Container>(
          find.descendant(
            of: find.byKey(const ValueKey('classic-count-badge')),
            matching: find.byType(Container),
          ),
        );
        final countDecoration = count.decoration! as BoxDecoration;
        expect(countDecoration.borderRadius, theme.shapeTokens.pill);
        expect(countDecoration.color, accent.withValues(alpha: 0.16));

        expect(
          find.descendant(
            of: find.byKey(const ValueKey('classic-inline-action')),
            matching: find.byWidgetPredicate(
              (widget) =>
                  widget is ButtonStyleButton && widget.onPressed != null,
            ),
          ),
          findsOneWidget,
        );
      }
    },
  );

  testWidgets('shared accent pills preserve default and custom label roles', (
    tester,
  ) async {
    const accent = Colors.teal;
    await tester.pumpWidget(
      _testApp(const SettingsAccentPill(label: 'Source', color: accent)),
    );

    var pill = tester.widget<Container>(
      find.descendant(
        of: find.byType(SettingsAccentPill),
        matching: find.byType(Container),
      ),
    );
    var decoration = pill.decoration! as BoxDecoration;
    expect(decoration.color, accent.withValues(alpha: 0.14));
    expect(decoration.borderRadius, _testShapes.pill);
    expect(decoration.border, isNull);
    expect(
      pill.padding,
      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    );
    var text = tester.widget<Text>(find.text('Source'));
    expect(text.style?.color, accent);
    expect(text.style?.fontWeight, FontWeight.w800);

    await tester.pumpWidget(
      _testApp(
        const SettingsAccentPill(
          label: 'Reset',
          color: accent,
          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          backgroundAlpha: 0.13,
          borderAlpha: 0.42,
          fontWeight: FontWeight.w900,
        ),
      ),
    );

    pill = tester.widget<Container>(
      find.descendant(
        of: find.byType(SettingsAccentPill),
        matching: find.byType(Container),
      ),
    );
    decoration = pill.decoration! as BoxDecoration;
    expect(decoration.color, accent.withValues(alpha: 0.13));
    expect(
      pill.padding,
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
    );
    expect(
      (decoration.border! as Border).top.color,
      accent.withValues(alpha: 0.42),
    );
    text = tester.widget<Text>(find.text('Reset'));
    expect(text.style?.fontWeight, FontWeight.w900);
  });

  testWidgets('shared legend chips preserve accent marker and outline roles', (
    tester,
  ) async {
    const accent = Colors.orange;
    await tester.pumpWidget(
      _testApp(const SettingsLegendChip(color: accent, label: 'Plan scope')),
    );

    final chip = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == _testShapes.pill;
      }),
    );
    final decoration = chip.decoration! as BoxDecoration;
    expect(decoration.color, accent.withValues(alpha: 0.12));
    expect(decoration.borderRadius, _testShapes.pill);
    expect(
      (decoration.border! as Border).top.color,
      accent.withValues(alpha: 0.36),
    );
    expect(find.text('Plan scope'), findsOneWidget);
    expect(find.byType(Row), findsOneWidget);
  });

  testWidgets('shared count badges preserve compact count geometry', (
    tester,
  ) async {
    const accent = Colors.indigo;
    await tester.pumpWidget(
      _testApp(const SettingsCountBadge(count: 3, color: accent)),
    );

    final badge = tester.widget<Container>(
      find.descendant(
        of: find.byType(SettingsCountBadge),
        matching: find.byType(Container),
      ),
    );
    final decoration = badge.decoration! as BoxDecoration;
    expect(decoration.color, accent.withValues(alpha: 0.16));
    expect(decoration.borderRadius, _testShapes.pill);
    expect(badge.constraints!.minWidth, 28);
    final text = tester.widget<Text>(find.text('3'));
    expect(text.style?.fontWeight, FontWeight.w900);
  });

  testWidgets('shared inline action buttons preserve padding and callbacks', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _testApp(
        SettingsInlineActionButton(
          label: 'Add item',
          icon: Icons.add,
          onPressed: () => taps++,
        ),
      ),
    );

    final padding = tester.widget<Padding>(
      find.descendant(
        of: find.byType(SettingsInlineActionButton),
        matching: find.byWidgetPredicate(
          (widget) =>
              widget is Padding && widget.padding == const EdgeInsets.all(12),
        ),
      ),
    );
    expect(padding.padding, const EdgeInsets.all(12));

    await tester.tap(find.text('Add item'));
    expect(taps, 1);
  });

  testWidgets('shared settings input decoration resolves surface recipes', (
    tester,
  ) async {
    InputDecoration? decoration;
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) {
            decoration = settingsInputDecoration(
              context,
              label: 'Name',
              hint: 'Your name',
              icon: Icons.person_outline,
              suffixText: 'kg',
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(decoration, isNotNull);
    expect(decoration!.fillColor, _testSurfaces.settingsInput);
    expect(decoration!.labelText, 'Name');
    expect(decoration!.hintText, 'Your name');
    expect(decoration!.suffixText, 'kg');
    expect(decoration!.border, isA<OutlineInputBorder>());
    expect(
      (decoration!.border! as OutlineInputBorder).borderRadius,
      _testShapes.settingsField,
    );
  });

  testWidgets('shared settings field decoration preserves compact geometry', (
    tester,
  ) async {
    InputDecoration? decoration;
    await tester.pumpWidget(
      _testApp(
        Builder(
          builder: (context) {
            decoration = settingsFieldDecoration(
              context,
              label: 'Calories',
              hint: 'Optional',
              suffixText: 'kcal',
              isDense: true,
            );
            return const SizedBox.shrink();
          },
        ),
      ),
    );

    expect(decoration, isNotNull);
    expect(decoration!.labelText, 'Calories');
    expect(decoration!.hintText, 'Optional');
    expect(decoration!.suffixText, 'kcal');
    expect(decoration!.isDense, isTrue);
    expect(
      (decoration!.border! as OutlineInputBorder).borderRadius,
      _testShapes.settingsField,
    );
  });

  testWidgets(
    'Classic light and dark field helpers preserve independent surface roles',
    (tester) async {
      InputDecoration? filled;
      InputDecoration? outlined;
      for (final theme in <ThemeData>[
        AppThemeFactory.light(AppThemeFamily.classic),
        AppThemeFactory.dark(AppThemeFamily.classic),
      ]) {
        await tester.pumpWidget(
          _testApp(
            Builder(
              builder: (context) {
                filled = settingsInputDecoration(
                  context,
                  label: 'Name',
                  icon: Icons.person_outline,
                );
                outlined = settingsFieldDecoration(
                  context,
                  label: 'Calories',
                  isDense: true,
                );
                return const SizedBox.shrink();
              },
            ),
            theme: theme,
          ),
        );

        expect(filled!.filled, isTrue);
        expect(filled!.labelStyle, isNull);
        expect(filled!.floatingLabelStyle, isNull);
        expect(filled!.hintStyle, isNull);
        expect(filled!.prefixIconColor, isNull);
        expect(filled!.enabledBorder, isNull);
        expect(filled!.focusedBorder, isNull);
        expect(filled!.fillColor, theme.surfaceTokens.settingsInput);
        expect(
          (filled!.border! as OutlineInputBorder).borderRadius,
          theme.shapeTokens.settingsField,
        );
        expect(outlined!.filled ?? false, isFalse);
        expect(outlined!.isDense, isTrue);
        expect(
          (outlined!.border! as OutlineInputBorder).borderRadius,
          theme.shapeTokens.settingsField,
        );
      }
    },
  );

  testWidgets('Neo settings input values use ink on bright fields', (
    tester,
  ) async {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
    ]) {
      TextStyle? enabledStyle;
      TextStyle? disabledStyle;
      Color? enabledForeground;
      Color? disabledForeground;
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (context) {
              enabledStyle = settingsInputTextStyle(context);
              disabledStyle = settingsInputTextStyle(context, enabled: false);
              enabledForeground = settingsInputForeground(context);
              disabledForeground = settingsInputForeground(
                context,
                enabled: false,
              );
              return TextField(
                style: enabledStyle,
                decoration: settingsInputDecoration(
                  context,
                  label: 'Name',
                  icon: Icons.person_outline,
                ),
              );
            },
          ),
          theme: theme,
        ),
      );

      expect(enabledStyle?.color, const Color(0xFF161616));
      expect(enabledForeground, const Color(0xFF161616));
      expect(disabledStyle?.color, disabledForeground);
      expect(disabledForeground, enabledForeground!.withValues(alpha: 0.38));
    }

    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
    ]) {
      TextStyle? classicStyle;
      Color? classicForeground;
      Color? classicDisabledForeground;
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (context) {
              classicStyle = settingsInputTextStyle(context);
              classicForeground = settingsInputForeground(context);
              classicDisabledForeground = settingsInputForeground(
                context,
                enabled: false,
              );
              return const SizedBox.shrink();
            },
          ),
          theme: theme,
        ),
      );
      expect(classicStyle, isNull);
      expect(classicForeground, isNull);
      expect(classicDisabledForeground, isNull);
    }
  });

  testWidgets('Neo settings focus contrasts with its colored input', (
    tester,
  ) async {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
    ]) {
      late InputDecoration decoration;
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (context) {
              decoration = settingsInputDecoration(
                context,
                label: 'Name',
                icon: Icons.person_outline,
              );
              return TextField(decoration: decoration);
            },
          ),
          theme: theme,
        ),
      );
      await tester.tap(find.byType(TextField));
      await tester.pump();
      final focus = decoration.focusedBorder!.borderSide;
      expect(
        _contrastRatio(focus.color, decoration.fillColor!),
        greaterThanOrEqualTo(3),
      );
      expect(
        focus.width,
        greaterThan(decoration.enabledBorder!.borderSide.width),
      );
      expect(focus.color, theme.semanticColors.focusRing);
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('Neo validation ink has surface contrast', (tester) async {
    for (final theme in [
      AppThemeFactory.light(AppThemeFamily.classic),
      AppThemeFactory.dark(AppThemeFamily.classic),
      AppThemeFactory.light(AppThemeFamily.neoBrutalism),
      AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
    ]) {
      late List<InputDecoration> decorations;
      final isNeo = theme.surfaceDecorationTokens.panel.outlined;
      final expectedError =
          theme.brightness == Brightness.dark
              ? const Color(0xFF5C102C)
              : const Color(0xFF7A1738);
      await tester.pumpWidget(
        _testApp(
          Builder(
            builder: (context) {
              decorations = [
                settingsInputDecoration(
                  context,
                  label: 'Name',
                  icon: Icons.person_outline,
                ),
                settingsFieldDecoration(context, label: 'Goal'),
              ];
              return TextField(decoration: decorations.first);
            },
          ),
          theme: theme,
        ),
      );

      final inputDecoration = decorations.first;
      final fieldDecoration = decorations.last;
      if (!isNeo) {
        expect(inputDecoration.errorStyle, isNull);
        expect(inputDecoration.errorBorder, isNull);
        expect(inputDecoration.focusedErrorBorder, isNull);
        expect(fieldDecoration.errorStyle, isNull);
        expect(fieldDecoration.errorBorder, isNull);
        expect(fieldDecoration.focusedErrorBorder, isNull);
      } else {
        expect(inputDecoration.errorStyle?.color, expectedError);
        expect(
          (inputDecoration.errorBorder! as OutlineInputBorder).borderSide.color,
          expectedError,
        );
        expect(
          (inputDecoration.focusedErrorBorder! as OutlineInputBorder)
              .borderSide
              .color,
          expectedError,
        );
        expect(
          _contrastRatio(expectedError, theme.surfaceTokens.settingsInput),
          greaterThanOrEqualTo(4.5),
        );
        expect(
          _contrastRatio(expectedError, theme.surfaceTokens.settingsSection),
          greaterThanOrEqualTo(4.5),
        );
      }

      if (isNeo && theme.brightness == Brightness.dark) {
        expect(fieldDecoration.errorStyle?.color, expectedError);
        expect(
          (fieldDecoration.errorBorder! as OutlineInputBorder).borderSide.color,
          expectedError,
        );
        expect(
          (fieldDecoration.focusedErrorBorder! as OutlineInputBorder)
              .borderSide
              .color,
          expectedError,
        );
      } else {
        expect(fieldDecoration.errorStyle, isNull);
        expect(fieldDecoration.errorBorder, isNull);
        expect(fieldDecoration.focusedErrorBorder, isNull);
      }
      await tester.pumpWidget(const SizedBox.shrink());
    }
  });

  testWidgets('shared ranking tiles preserve panel and rank input recipes', (
    tester,
  ) async {
    String? submittedRank;
    await tester.pumpWidget(
      _testApp(
        SettingsRankingTile(
          index: 0,
          name: const Text('Squat'),
          rank: 1,
          icon: Icons.accessibility_new,
          rankLabel: 'Rank',
          onRankSubmitted: (value) => submittedRank = value,
        ),
      ),
    );

    final panel = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.borderRadius == _testShapes.settingsPanel;
      }),
    );
    final panelDecoration = panel.decoration! as BoxDecoration;
    expect(panelDecoration.color, _testSurfaces.settingsSection);
    expect(panelDecoration.border, isA<Border>());

    final rankField = tester.widget<TextFormField>(find.byType(TextFormField));
    expect(rankField.initialValue, '1');
    final inputDecorator = tester.widget<InputDecorator>(
      find.byType(InputDecorator),
    );
    expect(
      (inputDecorator.decoration.border! as OutlineInputBorder).borderRadius,
      _testShapes.settingsInput,
    );

    await tester.enterText(find.byType(TextFormField), '3');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    expect(submittedRank, '3');
  });

  testWidgets('shared settings save bar preserves the button contract', (
    tester,
  ) async {
    var saves = 0;
    await tester.pumpWidget(
      _testApp(
        SettingsSaveBar(
          buttonKey: const ValueKey('save'),
          label: 'Save changes',
          onPressed: () => saves++,
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('save')));
    expect(saves, 1);

    final bar = tester.widget<Container>(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.color == _testSurfaces.settingsSaveBar;
      }),
    );
    final decoration = bar.decoration! as BoxDecoration;
    expect(decoration.border, isA<Border>());
    final context = tester.element(find.byKey(const ValueKey('save')));
    expect(
      (decoration.border! as Border).top.color,
      Theme.of(context).colorScheme.outlineVariant,
    );
  });

  testWidgets('shared settings save bar supports undecorated recipes', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        SettingsSaveBar(
          buttonKey: const ValueKey('plain-save'),
          label: 'Save navigation',
          onPressed: () {},
          decorated: false,
          padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
        ),
      ),
    );

    expect(
      find.byWidgetPredicate((widget) {
        if (widget is! Container) return false;
        final decoration = widget.decoration;
        return decoration is BoxDecoration &&
            decoration.color == _testSurfaces.settingsSaveBar;
      }),
      findsNothing,
    );
    final buttonPadding = tester.widget<Padding>(
      find
          .ancestor(
            of: find.byKey(const ValueKey('plain-save')),
            matching: find.byType(Padding),
          )
          .first,
    );
    expect(buttonPadding.padding, const EdgeInsets.fromLTRB(16, 10, 16, 16));
  });

  testWidgets('shared settings save bar supports cancel and save actions', (
    tester,
  ) async {
    var cancelled = 0;
    var saved = 0;
    await tester.pumpWidget(
      _testApp(
        SettingsSaveBar(
          buttonKey: const ValueKey('dual-save'),
          label: 'Save changes',
          onPressed: () => saved++,
          cancelLabel: 'Cancel',
          onCancel: () => cancelled++,
          decorated: false,
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        ),
      ),
    );

    expect(find.byType(OutlinedButton), findsOneWidget);
    expect(find.byKey(const ValueKey('dual-save')), findsOneWidget);
    await tester.tap(find.text('Cancel'));
    await tester.tap(find.byKey(const ValueKey('dual-save')));

    expect(cancelled, 1);
    expect(saved, 1);
  });

  testWidgets(
    'Classic dual save bars preserve order and disabled progress state',
    (tester) async {
      for (final theme in <ThemeData>[
        AppThemeFactory.light(AppThemeFamily.classic),
        AppThemeFactory.dark(AppThemeFamily.classic),
      ]) {
        await tester.pumpWidget(
          _testApp(
            SettingsSaveBar(
              buttonKey: const ValueKey('classic-dual-save'),
              label: 'Save',
              onPressed: null,
              cancelLabel: 'Cancel',
              onCancel: _noop,
              saveIcon: const SizedBox(key: ValueKey('classic-save-progress')),
              decorated: false,
              padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
            ),
            theme: theme,
          ),
        );

        expect(
          tester
              .widget<FilledButton>(
                find.byKey(const ValueKey('classic-dual-save')),
              )
              .onPressed,
          isNull,
        );
        expect(
          tester.widget<OutlinedButton>(find.byType(OutlinedButton)).onPressed,
          isNotNull,
        );
        expect(
          find.byKey(const ValueKey('classic-save-progress')),
          findsOneWidget,
        );
        expect(
          tester.getCenter(find.text('Cancel')).dx,
          lessThan(tester.getCenter(find.text('Save')).dx),
        );
      }
    },
  );
}

Map<String, ThemeData> _registeredThemes() => <String, ThemeData>{
  'Classic light': AppThemeFactory.light(AppThemeFamily.classic),
  'Classic dark': AppThemeFactory.dark(AppThemeFamily.classic),
  'Neo light': AppThemeFactory.light(AppThemeFamily.neoBrutalism),
  'Neo dark': AppThemeFactory.dark(AppThemeFamily.neoBrutalism),
};

Widget _testApp(
  Widget child, {
  ThemeData? theme,
  AppSettingsPresentationTokens? presentation,
}) {
  final baseTheme =
      theme ??
      ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        extensions: const <ThemeExtension<dynamic>>[_testShapes, _testSurfaces],
      );
  return MaterialApp(
    theme:
        presentation == null
            ? baseTheme
            : baseTheme.copyWith(
              extensions: [...baseTheme.extensions.values, presentation],
            ),
    themeAnimationDuration: Duration.zero,
    home: Scaffold(body: child),
  );
}

void _noop() {}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter =
      foregroundLuminance > backgroundLuminance
          ? foregroundLuminance
          : backgroundLuminance;
  final darker =
      foregroundLuminance > backgroundLuminance
          ? backgroundLuminance
          : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
