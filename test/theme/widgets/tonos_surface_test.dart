import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:env_test/theme/tokens/app_effect_tokens.dart';
import 'package:env_test/theme/tokens/app_shape_tokens.dart';
import 'package:env_test/theme/tokens/app_surface_tokens.dart';
import 'package:env_test/theme/widgets/tonos_surface.dart';

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
  sheet: BorderRadius.all(Radius.circular(24)),
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

const _testEffects = AppEffectTokens(
  cardElevation: 0,
  dialogElevation: 24,
  sheetElevation: 8,
  feedbackElevation: 6,
  cardShadow: Color(0xAA010203),
  cardShadowBlur: 6,
  cardShadowOffset: Offset(1, 2),
  shadowColor: Colors.black,
  shadowOpacity: 0.3,
  shadowBlur: 12,
  backdropBlurSigma: 0,
  noEffectsShadowOpacity: 0,
  noEffectsShadowBlur: 0,
  noEffectsBackdropBlurSigma: 0,
);

void main() {
  testWidgets('resolves a card from surface and shape tokens', (tester) async {
    await tester.pumpWidget(
      _testApp(
        const TonosSurface(
          key: ValueKey('card'),
          variant: TonosSurfaceVariant.card,
          padding: EdgeInsets.all(8),
          child: Text('Card'),
        ),
      ),
    );

    final material = _materialFor(tester, 'card');
    expect(material.color, _testSurfaces.card);
    expect(
      material.shape,
      RoundedRectangleBorder(borderRadius: _testShapes.card),
    );
    expect(material.elevation, 0);
    expect(material.clipBehavior, Clip.none);
  });

  testWidgets('adds the semantic input outline and media clipping', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const Column(
          children: [
            TonosSurface(
              key: ValueKey('input'),
              variant: TonosSurfaceVariant.input,
              child: Text('Input'),
            ),
            TonosSurface(
              key: ValueKey('media'),
              variant: TonosSurfaceVariant.media,
              child: Text('Media'),
            ),
          ],
        ),
      ),
    );

    final input = _materialFor(tester, 'input');
    final inputShape = input.shape! as RoundedRectangleBorder;
    expect(input.color, _testSurfaces.input);
    expect(inputShape.borderRadius, _testShapes.control);
    expect(inputShape.side.color, _testSurfaces.subtleOutline);
    expect(inputShape.side.width, _testShapes.outlineWidth);

    final media = _materialFor(tester, 'media');
    expect(media.color, _testSurfaces.media);
    expect(media.clipBehavior, Clip.antiAlias);
  });

  testWidgets('resolves compact card geometry and shadow tokens', (
    tester,
  ) async {
    await tester.pumpWidget(
      _testApp(
        const TonosSurface(
          key: ValueKey('compact-card'),
          variant: TonosSurfaceVariant.compactCard,
          child: Text('Compact card'),
        ),
      ),
    );

    final material = _materialFor(tester, 'compact-card');
    expect(material.color, _testSurfaces.card);
    expect(
      material.shape,
      RoundedRectangleBorder(borderRadius: _testShapes.control),
    );

    final decorated = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byKey(const ValueKey<String>('compact-card')),
        matching: find.byType(DecoratedBox),
      ),
    );
    final decoration = decorated.decoration as BoxDecoration;
    expect(decoration.borderRadius, _testShapes.control);
    expect(decoration.boxShadow, hasLength(1));
    final shadow = decoration.boxShadow!.single;
    expect(shadow.color, _testEffects.cardShadow);
    expect(shadow.blurRadius, _testEffects.cardShadowBlur);
    expect(shadow.offset, _testEffects.cardShadowOffset);
  });

  testWidgets('preserves tap behavior without exposing raw styling', (
    tester,
  ) async {
    var taps = 0;
    await tester.pumpWidget(
      _testApp(
        TonosSurface(
          onTap: () => taps++,
          semanticLabel: 'Interactive surface',
          child: const Text('Tap'),
        ),
      ),
    );

    await tester.tap(find.text('Tap'));
    expect(taps, 1);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Semantics &&
            widget.properties.label == 'Interactive surface',
      ),
      findsOneWidget,
    );
  });
}

Widget _testApp(Widget child) {
  return MaterialApp(
    theme: ThemeData(
      colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      extensions: const <ThemeExtension<dynamic>>[
        _testShapes,
        _testSurfaces,
        _testEffects,
      ],
    ),
    home: Scaffold(body: child),
  );
}

Material _materialFor(WidgetTester tester, String key) {
  return tester.widget<Material>(
    find.descendant(
      of: find.byKey(ValueKey<String>(key)),
      matching: find.byType(Material),
    ),
  );
}
