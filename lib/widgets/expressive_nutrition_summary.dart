import 'dart:math' as math;

import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/widgets/tonos_expressive_state_motion.dart';
import 'meal_plan_add_bar.dart';
import 'rounded_progress_indicator.dart';

typedef _NutritionMetric = ({
  String id,
  String label,
  int consumed,
  int target,
  String unit,
  Color surface,
  Color ink,
  Color accent,
});

/// One shared, goal-focused presentation for Nutrition and Dashboard.
class ExpressiveNutritionSummary extends StatefulWidget {
  const ExpressiveNutritionSummary({
    super.key,
    required this.caloriesConsumed,
    required this.calorieGoal,
    required this.proteinConsumed,
    required this.proteinTarget,
    required this.carbConsumed,
    required this.carbTarget,
    required this.fatConsumed,
    required this.fatTarget,
    this.scale = 1,
  });

  final int caloriesConsumed;
  final int calorieGoal;
  final int proteinConsumed;
  final int proteinTarget;
  final int carbConsumed;
  final int carbTarget;
  final int fatConsumed;
  final int fatTarget;
  final double scale;

  @override
  State<ExpressiveNutritionSummary> createState() =>
      _ExpressiveNutritionSummaryState();
}

class _ExpressiveNutritionSummaryState extends State<ExpressiveNutritionSummary>
    with TickerProviderStateMixin {
  final _pages = PageController();
  int _view = 0;
  late final AnimationController _nutritionMotion;
  late final AnimationController _ringEntranceMotion;
  bool _wasActive = false;
  late List<double> _fromValues;
  late List<double> _targetValues;
  late List<double> _fromProgress;
  late List<double> _targetProgress;

  List<double> get _values => [
    widget.caloriesConsumed.toDouble(),
    widget.proteinConsumed.toDouble(),
    widget.carbConsumed.toDouble(),
    widget.fatConsumed.toDouble(),
  ];

  List<double> get _progressValues {
    final values = _values;
    final goals = [
      widget.calorieGoal,
      widget.proteinTarget,
      widget.carbTarget,
      widget.fatTarget,
    ];
    return [
      for (var i = 0; i < values.length; i++)
        goals[i] > 0 ? (values[i] / goals[i]).clamp(0.0, 1.0) : 0,
    ];
  }

  double _interpolate(List<double> from, List<double> to, int index) {
    final t = TonosExpressiveStateMotion.effects.transform(
      _nutritionMotion.value,
    );
    return from[index] + (to[index] - from[index]) * t;
  }

  int _metricIndex(String id) => switch (id) {
    'Calories' => 0,
    'Protein' => 1,
    'Carbs' => 2,
    _ => 3,
  };

  int _displayedValue(int index) =>
      _interpolate(_fromValues, _targetValues, index).round();

  @override
  void initState() {
    super.initState();
    _fromValues = _targetValues = _values;
    _fromProgress = _targetProgress = _progressValues;
    _nutritionMotion = AnimationController(
      vsync: this,
      duration: TonosExpressiveStateMotion.data,
      value: 1,
    );
    _ringEntranceMotion = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 630),
      value: 1,
    );
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final active = TickerMode.valuesOf(context).enabled;
    if (!TonosExpressiveStateMotion.enabled(context)) {
      _nutritionMotion.value = 1;
      _ringEntranceMotion.value = 1;
    } else if (active && !_wasActive) {
      // Cached tabs and covered routes keep this State. Replay only when their
      // tickers become active again, not on ordinary data or theme rebuilds.
      _ringEntranceMotion.forward(from: 0);
    }
    _wasActive = active;
  }

  @override
  void didUpdateWidget(covariant ExpressiveNutritionSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    final values = _values;
    final progress = _progressValues;
    if (List.generate(4, (i) => i).every(
      (i) => values[i] == _targetValues[i] && progress[i] == _targetProgress[i],
    )) {
      return;
    }
    // Retarget the visible values instead of restarting from zero. One clock
    // keeps every mode's numbers, arcs and bars in sync, including mid-update.
    _fromValues = [
      for (var i = 0; i < 4; i++) _interpolate(_fromValues, _targetValues, i),
    ];
    _fromProgress = [
      for (var i = 0; i < 4; i++)
        _interpolate(_fromProgress, _targetProgress, i),
    ];
    _targetValues = values;
    _targetProgress = progress;
    if (TonosExpressiveStateMotion.enabled(context)) {
      _nutritionMotion.forward(from: 0);
    } else {
      _nutritionMotion.value = 1;
    }
  }

  static const _outerShape = BorderRadius.only(
    topLeft: Radius.circular(30),
    topRight: Radius.circular(18),
    bottomRight: Radius.circular(30),
    bottomLeft: Radius.circular(18),
  );
  static const _panelShape = BorderRadius.only(
    topLeft: Radius.circular(24),
    topRight: Radius.circular(14),
    bottomRight: Radius.circular(24),
    bottomLeft: Radius.circular(14),
  );
  static const _calorieShape = BorderRadius.only(
    topLeft: Radius.circular(48),
    topRight: Radius.circular(24),
    bottomRight: Radius.circular(48),
    bottomLeft: Radius.circular(24),
  );

  @override
  void dispose() {
    _nutritionMotion.dispose();
    _ringEntranceMotion.dispose();
    _pages.dispose();
    super.dispose();
  }

  double _progress(_NutritionMetric metric) =>
      _interpolate(_fromProgress, _targetProgress, _metricIndex(metric.id));

  String _goal(BuildContext context, _NutritionMetric metric) {
    final strings = AppLocalizations.of(context);
    return metric.target > 0
        ? strings.nutritionGoalComparison(metric.target, metric.unit)
        : strings.nutritionUnsetGoal(metric.unit);
  }

  TextStyle? _valueStyle(BuildContext context, _NutritionMetric metric) =>
      Theme.of(context).textTheme.titleLarge?.copyWith(
        color: metric.ink,
        fontSize: (metric.id == 'Calories' ? 40 : 24) * widget.scale,
        fontWeight: FontWeight.w800,
        height: 1.1,
      );

  TextStyle? _goalStyle(BuildContext context, _NutritionMetric metric) =>
      Theme.of(context).textTheme.bodySmall?.copyWith(
        color: metric.ink,
        fontSize: 12 * widget.scale,
        fontWeight: FontWeight.w600,
        height: 1.2,
      );

  TextStyle? _titleStyle(BuildContext context, _NutritionMetric metric) =>
      Theme.of(context).textTheme.titleSmall
          ?.copyWith(color: metric.ink, fontWeight: FontWeight.w800);

  double _textHeight(
    BuildContext context,
    String value,
    TextStyle? style,
    double width, {
    bool fitValue = false,
  }) {
    final painter = TextPainter(
      text: TextSpan(text: value, style: style),
      textDirection: Directionality.of(context),
      textScaler: MediaQuery.textScalerOf(context),
      locale: Localizations.maybeLocaleOf(context),
      maxLines: fitValue ? 1 : null,
    )..layout(maxWidth: fitValue ? double.infinity : math.max(1, width));
    final height =
        painter.height *
        (fitValue && painter.width > width ? width / painter.width : 1);
    painter.dispose();
    return height;
  }

  double _comparisonHeight(
    BuildContext context,
    _NutritionMetric metric,
    double width,
  ) =>
      _textHeight(
        context,
        '${metric.consumed}',
        _valueStyle(context, metric),
        width,
        fitValue: true,
      ) +
      4 * widget.scale +
      _textHeight(
        context,
        _goal(context, metric),
        _goalStyle(context, metric),
        width,
      );

  double _stroke(_NutritionMetric metric) =>
      (metric.id == 'Calories' ? 12 : 8) * widget.scale;

  bool _goalOutsideRing(
    BuildContext context,
    _NutritionMetric metric,
    double diameter,
  ) {
    final innerWidth = diameter - 2 * (_stroke(metric) + 4 * widget.scale);
    return _comparisonHeight(context, metric, innerWidth) > innerWidth;
  }

  double _ringHeight(
    BuildContext context,
    _NutritionMetric metric,
    double diameter,
  ) =>
      diameter +
      (_goalOutsideRing(context, metric, diameter)
          ? 6 * widget.scale +
                _textHeight(
                  context,
                  _goal(context, metric),
                  _goalStyle(context, metric),
                  diameter,
                )
          : 0);

  double _barContentHeight(
    BuildContext context,
    _NutritionMetric metric,
    double width,
  ) {
    if (metric.id != 'Calories') {
      return _comparisonHeight(context, metric, width) +
          8 * widget.scale +
          44 * widget.scale;
    }
    return _comparisonHeight(context, metric, width) +
        12 * widget.scale +
        44 * widget.scale;
  }

  Color _track(_NutritionMetric metric, {bool forBar = false}) =>
      Color.alphaBlend(
        metric.ink.withValues(
          alpha: metric.id == 'Calories'
              ? 0.22
              : forBar
              ? 0.18
              : 0.13,
        ),
        metric.surface,
      );

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: Listenable.merge([_nutritionMotion, _ringEntranceMotion]),
    builder: _buildSummary,
  );

  Widget _buildSummary(BuildContext context, Widget? child) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveDestinationTokens>()!;
    final dark = theme.brightness == Brightness.dark;
    final s = widget.scale;
    final strings = AppLocalizations.of(context);
    final metrics = <_NutritionMetric>[
      (
        id: 'Calories',
        label: strings.nutritionCaloriesLabel,
        consumed: _displayedValue(0),
        target: widget.calorieGoal,
        unit: strings.nutritionUnitCalories,
        surface: tokens.surfacePrimary,
        ink: tokens.onSurfacePrimary,
        accent: const Color(0xFFFFD5A6),
      ),
      (
        id: 'Protein',
        label: strings.nutritionProteinLabel,
        consumed: _displayedValue(1),
        target: widget.proteinTarget,
        unit: strings.nutritionUnitGrams,
        surface: tokens.surfaceSecondary,
        ink: tokens.onSurfaceSecondary,
        accent: dark ? const Color(0xFF80D9B8) : const Color(0xFF246953),
      ),
      (
        id: 'Carbs',
        label: strings.nutritionCarbsLabel,
        consumed: _displayedValue(2),
        target: widget.carbTarget,
        unit: strings.nutritionUnitGrams,
        surface: tokens.surfaceAccent,
        ink: tokens.onSurfaceAccent,
        accent: dark ? const Color(0xFF9BC7FF) : const Color(0xFF285B95),
      ),
      (
        id: 'Fat',
        label: strings.nutritionFatLabel,
        consumed: _displayedValue(3),
        target: widget.fatTarget,
        unit: strings.nutritionUnitGrams,
        surface: tokens.surfaceSelected,
        ink: tokens.onSurfaceSelected,
        accent: dark ? const Color(0xFFF0A8D0) : const Color(0xFF8D3B6B),
      ),
    ];

    return DecoratedBox(
      decoration: BoxDecoration(
        color: Color.alphaBlend(
          tokens.surfaceSelected.withValues(alpha: 0.24),
          tokens.pageCanvas,
        ),
        borderRadius: _outerShape,
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 12 * s, vertical: 8 * s),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final largeText = MediaQuery.textScalerOf(context).scale(14) > 19.6;
            final stacked = largeText || constraints.maxWidth < 280 * s;
            final rows = <List<_NutritionMetric>>[
              [metrics.first],
              if (stacked)
                ...metrics.skip(1).map((metric) => [metric])
              else
                metrics.skip(1).toList(),
            ];
            double panelInset(int view) => 8 * s;
            double contentWidth(int row, {required int view}) =>
                (constraints.maxWidth - (rows[row].length - 1) * 8 * s) /
                    rows[row].length -
                2 * panelInset(view);
            double diameter(int row) => math.min(
              (row == 0 ? 196 : 112) * s,
              contentWidth(row, view: 0),
            );

            double panelHeight(_NutritionMetric metric, int view, int row) {
              final width = contentWidth(row, view: view);
              final chartHeight = switch (view) {
                0 => _ringHeight(context, metric, diameter(row)),
                1 => _barContentHeight(context, metric, width),
                _ => _comparisonHeight(context, metric, width),
              };
              return 2 * panelInset(view) +
                  (view == 0 ? 6 : 5) * s +
                  (view == 0 ? 0 : 2) * s +
                  chartHeight +
                  _textHeight(
                    context,
                    metric.label,
                    _titleStyle(context, metric),
                    width,
                  );
            }

            final rowHeights = [
              for (var view = 0; view < 3; view++)
                [
                  for (var row = 0; row < rows.length; row++)
                    rows[row]
                        .map((metric) => panelHeight(metric, view, row))
                        .reduce(math.max),
                ],
            ];
            final pageHeights = [
              for (final rows in rowHeights)
                rows.reduce((a, b) => a + b) + (rows.length - 1) * 8 * s,
            ];
            final views = DecoratedBox(
              decoration: BoxDecoration(
                color: Color.alphaBlend(
                  tokens.surfaceSelected.withValues(alpha: dark ? 0.22 : 0.3),
                  tokens.pageCanvas,
                ),
                borderRadius: BorderRadius.circular(18 * s),
                border: Border.all(
                  color: tokens.outlineAccent.withValues(
                    alpha: dark ? 0.28 : 0.2,
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (final (index, label, icon) in [
                    (0, strings.nutritionRingView, Icons.donut_large_rounded),
                    (1, strings.nutritionBarView, Icons.bar_chart_rounded),
                    (
                      2,
                      strings.nutritionSummaryView,
                      Icons.format_list_bulleted_rounded,
                    ),
                  ])
                    MergeSemantics(
                      child: Semantics(
                        selected: _view == index,
                        child: IconButton(
                          key: ValueKey('nutrition-display-mode-$index'),
                          tooltip: label,
                          style: IconButton.styleFrom(
                            backgroundColor: _view == index
                                ? tokens.actionPrimary
                                : Colors.transparent,
                            foregroundColor: _view == index
                                ? tokens.onActionPrimary
                                : tokens.supportingForeground,
                            minimumSize: Size(48 * s, 48 * s),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14 * s),
                            ),
                          ),
                          onPressed: () => _pages.animateToPage(
                            index,
                            duration: MediaQuery.disableAnimationsOf(context)
                                ? Duration.zero
                                : const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                          ),
                          icon: Icon(icon, size: 22 * s),
                        ),
                      ),
                    ),
                ],
              ),
            );
            final title = Text(
              strings.nutritionSummaryTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                color: tokens.supportingForeground,
                fontWeight: FontWeight.w800,
              ),
            );

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (stacked) ...[
                  title,
                  const SizedBox(height: 4),
                  Align(
                    alignment: AlignmentDirectional.centerEnd,
                    child: views,
                  ),
                ] else
                  Row(
                    children: [
                      Expanded(child: title),
                      views,
                    ],
                  ),
                SizedBox(height: 6 * s),
                AnimatedSize(
                  alignment: Alignment.topCenter,
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 180),
                  child: SizedBox(
                    height: pageHeights[_view],
                    child: PageView(
                      controller: _pages,
                      onPageChanged: (value) => setState(() => _view = value),
                      children: [
                        for (var view = 0; view < 3; view++)
                          OverflowBox(
                            alignment: Alignment.topCenter,
                            minHeight: 0,
                            maxHeight: double.infinity,
                            child: SizedBox(
                              height: pageHeights[view],
                              child: Column(
                                children: [
                                  for (
                                    var row = 0;
                                    row < rowHeights[view].length;
                                    row++
                                  ) ...[
                                    if (row > 0) SizedBox(height: 8 * s),
                                    SizedBox(
                                      height: rowHeights[view][row],
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          for (
                                            var column = 0;
                                            column < rows[row].length;
                                            column++
                                          ) ...[
                                            if (column > 0)
                                              SizedBox(width: 8 * s),
                                            Expanded(
                                              child: _panel(
                                                context,
                                                rows[row][column],
                                                view,
                                                diameter(row),
                                              ),
                                            ),
                                          ],
                                        ],
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                MealPlanAddBar(scale: s),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _comparison(
    BuildContext context,
    _NutritionMetric metric, {
    bool showGoal = true,
    CrossAxisAlignment alignment = CrossAxisAlignment.center,
    TextAlign goalAlignment = TextAlign.center,
    AlignmentGeometry valueAlignment = Alignment.center,
  }) => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: alignment,
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        alignment: valueAlignment,
        child: Text(
          '${metric.consumed}',
          maxLines: 1,
          softWrap: false,
          style: _valueStyle(context, metric),
        ),
      ),
      if (showGoal) ...[
        SizedBox(height: 4 * widget.scale),
        Text(
          _goal(context, metric),
          textAlign: goalAlignment,
          style: _goalStyle(context, metric),
        ),
      ],
    ],
  );

  Widget _ring(BuildContext context, _NutritionMetric metric, double diameter) {
    final outsideGoal = _goalOutsideRing(context, metric, diameter);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox.square(
          dimension: diameter,
          child: Stack(
            alignment: Alignment.center,
            children: [
              RoundedProgressIndicator(
                progress:
                    _progress(metric) *
                    Curves.easeOutCubic.transform(_ringEntranceMotion.value),
                size: diameter,
                strokeWidth: _stroke(metric),
                progressColor: metric.accent,
                backgroundColor: _track(metric),
              ),
              Positioned.fill(
                child: Padding(
                  padding: EdgeInsets.all(_stroke(metric) + 4 * widget.scale),
                  child: Center(
                    child: _comparison(context, metric, showGoal: !outsideGoal),
                  ),
                ),
              ),
            ],
          ),
        ),
        if (outsideGoal) ...[
          SizedBox(height: 6 * widget.scale),
          SizedBox(
            width: diameter,
            child: Text(
              _goal(context, metric),
              textAlign: TextAlign.center,
              style: _goalStyle(context, metric),
            ),
          ),
        ],
      ],
    );
  }

  Widget _panel(
    BuildContext context,
    _NutritionMetric metric,
    int view,
    double diameter,
  ) {
    final s = widget.scale;
    final strings = AppLocalizations.of(context);
    final tokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>()!;
    final dark = Theme.of(context).brightness == Brightness.dark;
    final shape = metric.id == 'Calories' ? _calorieShape : _panelShape;
    final compact = view == 2;
    return Semantics(
      container: true,
      label: metric.target > 0
          ? strings.nutritionGoalSemantics(
              metric.label,
              _targetValues[_metricIndex(metric.id)].round(),
              metric.target,
              metric.unit,
            )
          : strings.nutritionUnsetGoalSemantics(
              metric.label,
              _targetValues[_metricIndex(metric.id)].round(),
              metric.unit,
            ),
      child: ExcludeSemantics(
        child: Container(
          key: ValueKey('nutrition-panel-${metric.id}'),
          clipBehavior: Clip.antiAlias,
          padding: EdgeInsets.all(8 * s),
          decoration: BoxDecoration(
            color: metric.surface,
            borderRadius: shape,
            border: view == 0
                ? null
                : Border.all(
                    color: tokens.outlineAccent.withValues(
                      alpha: dark ? 0.26 : 0.18,
                    ),
                  ),
          ),
          child: view == 0
              ? Column(
                  children: [
                    Text(
                      metric.label,
                      textAlign: TextAlign.center,
                      style: _titleStyle(context, metric),
                    ),
                    SizedBox(height: 6 * s),
                    Expanded(
                      child: Center(child: _ring(context, metric, diameter)),
                    ),
                  ],
                )
              : Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      metric.label,
                      textAlign: TextAlign.center,
                      style: _titleStyle(context, metric),
                    ),
                    SizedBox(height: (compact ? 5 : 4) * s),
                    Expanded(
                      child: compact
                          ? Align(
                              alignment: Alignment.topCenter,
                              child: SizedBox(
                                width: double.infinity,
                                child: _comparison(context, metric),
                              ),
                            )
                          : metric.id == 'Calories'
                          ? _calorieBarContent(context, metric)
                          : _macroBarContent(context, metric),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _calorieBarContent(BuildContext context, _NutritionMetric metric) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(width: double.infinity, child: _comparison(context, metric)),
          SizedBox(height: 12 * widget.scale),
          _meter(metric),
        ],
      );

  Widget _macroBarContent(BuildContext context, _NutritionMetric metric) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(
            width: double.infinity,
            child: _comparison(
              context,
              metric,
              alignment: CrossAxisAlignment.center,
              goalAlignment: TextAlign.center,
              valueAlignment: Alignment.center,
            ),
          ),
          SizedBox(height: 8 * widget.scale),
          _meter(metric),
        ],
      );

  Widget _meter(_NutritionMetric metric) => Padding(
    padding: EdgeInsets.symmetric(
      horizontal: metric.id == 'Calories' ? 16 * widget.scale : 0,
    ),
    child: SizedBox(
      key: ValueKey('nutrition-meter-${metric.id}'),
      height: 44 * widget.scale,
      width: double.infinity,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22 * widget.scale),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final progress = _progress(metric);
            final fillWidth = constraints.maxWidth * progress;
            final compactMarker = progress > 0 && fillWidth < 5 * widget.scale;
            return Stack(
              fit: StackFit.expand,
              children: [
                ColoredBox(
                  key: ValueKey('nutrition-meter-track-${metric.id}'),
                  color: _track(metric, forBar: true),
                ),
                if (progress > 0)
                  Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: compactMarker
                        ? Container(
                            key: ValueKey('nutrition-meter-fill-${metric.id}'),
                            width: 5 * widget.scale,
                            height: 5 * widget.scale,
                            decoration: BoxDecoration(
                              color: metric.accent,
                              shape: BoxShape.circle,
                            ),
                          )
                        : SizedBox(
                            key: ValueKey('nutrition-meter-fill-${metric.id}'),
                            width: fillWidth,
                            height: constraints.maxHeight,
                            child: ColoredBox(color: metric.accent),
                          ),
                  ),
              ],
            );
          },
        ),
      ),
    ),
  );
}
