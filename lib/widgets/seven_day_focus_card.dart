import 'dart:async';

import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../repositories/app_repository.dart';
import '../theme/tokens/app_expressive_train_tokens.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/tonos_surface.dart';
import 'body_heatmap.dart';
import 'focused_sets_list.dart';

/// Shared seven-day training summary used by Train and the customizable
/// Dashboard so both surfaces report the same recent focus data.
class SevenDayFocusCard extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onFocusedSetsTap;
  final bool ambientMotionEnabled;
  final bool motionEnabled;

  const SevenDayFocusCard({
    super.key,
    required this.refreshToken,
    required this.onFocusedSetsTap,
    this.ambientMotionEnabled = false,
    this.motionEnabled = true,
  });

  @override
  State<SevenDayFocusCard> createState() => _SevenDayFocusCardState();
}

class _SevenDayFocusData {
  final Map<String, double> heatmapFrequencyMap;
  final List<FocusedSetHit> topBodyParts;

  const _SevenDayFocusData({
    required this.heatmapFrequencyMap,
    required this.topBodyParts,
  });
}

const _emptySevenDayFocusData = _SevenDayFocusData(
  heatmapFrequencyMap: <String, double>{},
  topBodyParts: <FocusedSetHit>[],
);

class _SevenDayFocusCardState extends State<SevenDayFocusCard> {
  AppRepository get _repo => context.read<AppRepository>();
  late Future<_SevenDayFocusData> _dataFuture;

  @override
  void initState() {
    super.initState();
    unawaited(BodyHeatmap.preload());
    _dataFuture = _loadData();
  }

  @override
  void didUpdateWidget(covariant SevenDayFocusCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.refreshToken != widget.refreshToken) {
      _dataFuture = _loadData();
    }
  }

  Future<_SevenDayFocusData> _loadData() async {
    final now = DateTime.now();
    final weekAgo = now.subtract(const Duration(days: 7));
    final bodyPartSets = await _repo.fetchAllBodyPartSetsOverTimeRange(
      start: weekAgo,
      end: now,
    );
    final hits =
        bodyPartSets.entries
            .where((entry) => entry.value > 0)
            .map(
              (entry) => FocusedSetHit(bodyPart: entry.key, units: entry.value),
            )
            .toList()
          ..sort((a, b) => b.units.compareTo(a.units));

    return _SevenDayFocusData(
      heatmapFrequencyMap: bodyPartFrequencyMapFromNames({
        for (final hit in hits) hit.bodyPart.name: hit.units,
      }),
      topBodyParts: hits,
    );
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_SevenDayFocusData>(
    future: _dataFuture,
    builder: (context, snapshot) {
      final data = snapshot.data ?? _emptySevenDayFocusData;
      return SevenDayFocusPresentation(
        heatmapFrequencyMap: data.heatmapFrequencyMap,
        hits: data.topBodyParts,
        onFocusedSetsTap: widget.onFocusedSetsTap,
        ambientMotionEnabled: widget.ambientMotionEnabled,
        motionEnabled: widget.motionEnabled,
        loading:
            snapshot.connectionState != ConnectionState.done &&
            snapshot.data == null,
        failed: snapshot.hasError && snapshot.data == null,
      );
    },
  );
}

/// Shared visuals for live repository data and disposable Theme Lab fixtures.
class SevenDayFocusPresentation extends StatelessWidget {
  const SevenDayFocusPresentation({
    super.key,
    required this.heatmapFrequencyMap,
    required this.hits,
    required this.onFocusedSetsTap,
    this.ambientMotionEnabled = false,
    this.motionEnabled = true,
    this.loading = false,
    this.failed = false,
  });

  final Map<String, double> heatmapFrequencyMap;
  final List<FocusedSetHit> hits;
  final VoidCallback onFocusedSetsTap;
  final bool ambientMotionEnabled;
  final bool motionEnabled;
  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    if (context.usesExpressivePresentation) {
      return _ExpressiveSevenDayFocusPresentation(
        heatmapFrequencyMap: heatmapFrequencyMap,
        hits: hits,
        onFocusedSetsTap: onFocusedSetsTap,
        ambientMotionEnabled: ambientMotionEnabled,
        motionEnabled: motionEnabled,
        loading: loading,
        failed: failed,
      );
    }

    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.usesNeoPresentation;
    final usesExpressiveRecipe = context.usesExpressivePresentation;
    final surfaceInk = context.cs.onPrimaryContainer;
    final expressiveFocusTheme = usesExpressiveRecipe
        ? theme.copyWith(
            textTheme: theme.textTheme.copyWith(
              bodySmall: theme.textTheme.bodySmall?.copyWith(
                fontSize: 15,
                height: 1.25,
              ),
              titleSmall: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          )
        : theme;
    final content = Theme(
      data: usesInkRecipe
          ? theme.copyWith(
              colorScheme: theme.colorScheme.copyWith(
                onSurface: surfaceInk,
                onSurfaceVariant: surfaceInk,
              ),
              textTheme: theme.textTheme.apply(
                bodyColor: surfaceInk,
                displayColor: surfaceInk,
              ),
              progressIndicatorTheme: theme.progressIndicatorTheme.copyWith(
                color: surfaceInk,
                linearTrackColor: surfaceInk.withValues(alpha: 0.22),
              ),
            )
          : usesExpressiveRecipe
          ? expressiveFocusTheme
          : theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.sevenDayFocusTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: usesExpressiveRecipe
                  ? FontWeight.w600
                  : FontWeight.w800,
              color: usesInkRecipe ? surfaceInk : null,
            ),
          ),
          const SizedBox(height: 16),
          if (loading)
            const SizedBox(
              height: 176,
              child: Center(child: CircularProgressIndicator()),
            )
          else if (failed)
            SizedBox(
              height: 176,
              child: Center(child: Text(strings.sevenDayFocusLoadFailed)),
            )
          else
            _SevenDayFocusLayout(
              data: _SevenDayFocusData(
                heatmapFrequencyMap: heatmapFrequencyMap,
                topBodyParts: hits,
              ),
              onFocusedSetsTap: onFocusedSetsTap,
            ),
        ],
      ),
    );
    return usesInkRecipe || usesExpressiveRecipe
        ? TonosSurface(
            variant: usesExpressiveRecipe
                ? TonosSurfaceVariant.card
                : TonosSurfaceVariant.panelRaised,
            color: surfaces.dashboardHero,
            padding: const EdgeInsets.all(16),
            child: content,
          )
        : Card(
            child: Padding(padding: const EdgeInsets.all(16), child: content),
          );
  }
}

class _ExpressiveSevenDayFocusPresentation extends StatelessWidget {
  const _ExpressiveSevenDayFocusPresentation({
    required this.heatmapFrequencyMap,
    required this.hits,
    required this.onFocusedSetsTap,
    required this.ambientMotionEnabled,
    required this.motionEnabled,
    required this.loading,
    required this.failed,
  });

  final Map<String, double> heatmapFrequencyMap;
  final List<FocusedSetHit> hits;
  final VoidCallback onFocusedSetsTap;
  final bool ambientMotionEnabled;
  final bool motionEnabled;
  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveTrainTokens>()!;
    final surfaces = context.surfaceTokens;
    final focusTheme = theme.copyWith(
      colorScheme: theme.colorScheme.copyWith(
        onSurface: tokens.focusForeground,
        onSurfaceVariant: tokens.focusForeground,
      ),
      textTheme: theme.textTheme.apply(
        bodyColor: tokens.focusForeground,
        displayColor: tokens.focusForeground,
      ),
      progressIndicatorTheme: theme.progressIndicatorTheme.copyWith(
        color: tokens.focusWarm,
        linearTrackColor: tokens.focusForeground.withValues(alpha: 0.2),
      ),
    );
    final canAnimateContent =
        motionEnabled &&
        !(MediaQuery.maybeOf(context)?.disableAnimations ?? false) &&
        TickerMode.valuesOf(context).enabled;
    final focusState = loading
        ? SizedBox(
            key: const ValueKey('expressive-focus-loading'),
            height: 176,
            child: Center(
              child: CircularProgressIndicator(color: tokens.focusWarm),
            ),
          )
        : failed
        ? SizedBox(
            key: const ValueKey('expressive-focus-failed'),
            height: 176,
            child: Center(
              child: Text(
                AppLocalizations.of(context).sevenDayFocusLoadFailed,
                textAlign: TextAlign.center,
              ),
            ),
          )
        : _ExpressiveSevenDayFocusLayout(
            key: const ValueKey('expressive-focus-data'),
            heatmapFrequencyMap: heatmapFrequencyMap,
            hits: hits,
            onFocusedSetsTap: onFocusedSetsTap,
            heatmapSurface: surfaces.dashboardHero,
            tokens: tokens,
            motionEnabled: motionEnabled,
          );

    return TonosExpressiveAmbientMotion(
      enabled: ambientMotionEnabled,
      halfCycle: const Duration(seconds: 3),
      builder: (context, phase, child) => TonosSurface(
        variant: TonosSurfaceVariant.card,
        color: Color.lerp(
          tokens.focusSurface,
          tokens.focusInset,
          0.42 * phase,
        )!,
        borderRadius: ExpressiveTrainShapes.focusHero,
        padding: const EdgeInsets.all(18),
        child: child,
      ),
      child: Theme(
        data: focusTheme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    AppLocalizations.of(context).sevenDayFocusTitle,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      color: tokens.focusForeground,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.55,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                _ExpressiveFocusAccents(tokens: tokens),
              ],
            ),
            const SizedBox(height: 14),
            AnimatedSwitcher(
              duration: canAnimateContent
                  ? const Duration(milliseconds: 180)
                  : Duration.zero,
              switchInCurve: Curves.easeOutCubic,
              switchOutCurve: Curves.easeInCubic,
              transitionBuilder: (child, animation) => FadeTransition(
                opacity: animation,
                child: ScaleTransition(
                  scale: Tween<double>(begin: 0.985, end: 1).animate(animation),
                  child: child,
                ),
              ),
              child: focusState,
            ),
          ],
        ),
      ),
    );
  }
}

/// Small decorative marks share the hero surface's existing phase driver.
/// Their text/data siblings remain still and these marks are excluded from
/// touch and accessibility trees.
class _ExpressiveFocusAccents extends StatelessWidget {
  const _ExpressiveFocusAccents({required this.tokens});

  final AppExpressiveTrainTokens tokens;

  @override
  Widget build(BuildContext context) {
    final phase = TonosExpressiveAmbientPhaseScope.maybePhaseOf(context);
    if (phase == null) return _paintAt(0);

    return RepaintBoundary(
      child: IgnorePointer(
        child: ExcludeSemantics(
          child: AnimatedBuilder(
            animation: phase,
            builder: (context, _) => _paintAt(phase.value),
          ),
        ),
      ),
    );
  }

  Widget _paintAt(double phase) {
    final progress = phase.clamp(0.0, 1.0).toDouble();
    final warmWidth = 34 + 14 * progress;
    return SizedBox(
      width: 72,
      height: 6,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned(
            left: 0,
            top: 0,
            child: Transform.translate(
              offset: Offset(0, -1.5 * progress),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.focusWarm,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: SizedBox(width: warmWidth, height: 6),
              ),
            ),
          ),
          Positioned(
            left: warmWidth + 5,
            top: 0,
            child: Transform.translate(
              offset: Offset(0, 1.5 * progress),
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: tokens.focusCool,
                  borderRadius: BorderRadius.circular(99),
                ),
                child: const SizedBox(width: 13, height: 6),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExpressiveSevenDayFocusLayout extends StatelessWidget {
  const _ExpressiveSevenDayFocusLayout({
    super.key,
    required this.heatmapFrequencyMap,
    required this.hits,
    required this.onFocusedSetsTap,
    required this.heatmapSurface,
    required this.tokens,
    required this.motionEnabled,
  });

  final Map<String, double> heatmapFrequencyMap;
  final List<FocusedSetHit> hits;
  final VoidCallback onFocusedSetsTap;
  final Color heatmapSurface;
  final AppExpressiveTrainTokens tokens;
  final bool motionEnabled;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final isStacked = textScale >= 1.35 || constraints.maxWidth < 340;
        final heatmapSize = isStacked
            ? constraints.maxWidth.clamp(132.0, 164.0).toDouble()
            : (constraints.maxWidth * 0.38).clamp(118.0, 148.0).toDouble();
        final heatmap = Container(
          width: heatmapSize,
          height: heatmapSize,
          padding: const EdgeInsets.all(5),
          decoration: BoxDecoration(
            color: heatmapSurface,
            borderRadius: ExpressiveTrainShapes.focusInset,
          ),
          child: BodyHeatmap(
            frequencyMap: heatmapFrequencyMap,
            lowColor: tonosHeatmapLowForSurface(context, heatmapSurface),
            highColor: tonosHeatmapHighForSurface(context, heatmapSurface),
            width: heatmapSize - 10,
            height: heatmapSize - 10,
          ),
        );
        final details = _ExpressiveFocusDetails(
          hits: hits,
          onTap: onFocusedSetsTap,
          tokens: tokens,
          motionEnabled: motionEnabled,
        );

        if (isStacked) {
          return Column(
            key: const ValueKey('seven-day-focus-stacked'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(child: heatmap),
              const SizedBox(height: 12),
              details,
            ],
          );
        }

        return SizedBox(
          key: const ValueKey('seven-day-focus-side-by-side'),
          height: 198 + (textScale - 1).clamp(0.0, 0.35) * 150,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(flex: 4, child: Center(child: heatmap)),
              const SizedBox(width: 12),
              Expanded(flex: 6, child: details),
            ],
          ),
        );
      },
    );
  }
}

class _ExpressiveFocusDetails extends StatelessWidget {
  const _ExpressiveFocusDetails({
    required this.hits,
    required this.onTap,
    required this.tokens,
    required this.motionEnabled,
  });

  final List<FocusedSetHit> hits;
  final VoidCallback onTap;
  final AppExpressiveTrainTokens tokens;
  final bool motionEnabled;

  @override
  Widget build(BuildContext context) {
    final radius = ExpressiveTrainShapes.focusInset;
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        FocusedSetsList(
          hits: hits,
          maxVisible: 3,
          emptyMessage: AppLocalizations.of(context).sevenDayFocusEmpty,
          titleWeight: FontWeight.w700,
          expressiveProgressPhase:
              TonosExpressiveAmbientPhaseScope.maybePhaseOf(context),
        ),
        if (hits.length > 3) _MoreFocusedSetsHint(color: tokens.focusWarm),
      ],
    );

    return MergeSemantics(
      child: Semantics(
        button: true,
        onTap: onTap,
        child: TonosExpressivePressResponse(
          enabled: motionEnabled,
          borderRadius: radius,
          pressedBorderRadius: ExpressiveTrainShapes.focusInsetPressed,
          pressedScale: TonosExpressiveMotionTiers.supportingScale,
          pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
          child: Material(
            color: tokens.focusInset,
            shape: RoundedRectangleBorder(borderRadius: radius),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              customBorder: RoundedRectangleBorder(borderRadius: radius),
              onTap: onTap,
              child: Padding(padding: const EdgeInsets.all(12), child: content),
            ),
          ),
        ),
      ),
    );
  }
}

class _SevenDayFocusLayout extends StatelessWidget {
  final _SevenDayFocusData data;
  final VoidCallback onFocusedSetsTap;

  const _SevenDayFocusLayout({
    required this.data,
    required this.onFocusedSetsTap,
  });

  @override
  Widget build(BuildContext context) {
    final surfaces = context.surfaceTokens;
    return LayoutBuilder(
      builder: (context, constraints) {
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        // Keep the established side-by-side overview at ordinary font sizes.
        // Stacking is reserved for genuinely large accessibility text.
        final supportsStackedLayout = textScale >= 1.6;
        final minimumDetailsWidth =
            176.0 * (supportsStackedLayout ? textScale.clamp(1.0, 1.6) : 1.0);
        final gap = constraints.maxWidth < 330 ? 10.0 : 14.0;
        final rowAnatomyWidth = (constraints.maxWidth * 0.43)
            .clamp(118.0, 170.0)
            .toDouble();
        final isStacked =
            supportsStackedLayout &&
            constraints.maxWidth < rowAnatomyWidth + gap + minimumDetailsWidth;
        final heatmapBox = (constraints.maxWidth * (isStacked ? 0.62 : 0.43))
            .clamp(118.0, 170.0)
            .toDouble();
        final heatmapSize = (heatmapBox - 6).clamp(112.0, 164.0).toDouble();
        final heatmap = BodyHeatmap(
          frequencyMap: data.heatmapFrequencyMap,
          lowColor: tonosHeatmapLowForSurface(context, surfaces.dashboardHero),
          highColor: tonosHeatmapHighForSurface(
            context,
            surfaces.dashboardHero,
          ),
          width: heatmapSize,
          height: heatmapSize,
        );

        Widget details({required bool scrollable}) {
          final content = Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.min,
            children: [
              FocusedSetsList(
                hits: data.topBodyParts,
                maxVisible: 3,
                emptyMessage: AppLocalizations.of(context).sevenDayFocusEmpty,
                titleWeight: context.usesExpressivePresentation
                    ? FontWeight.w600
                    : FontWeight.w800,
              ),
              if (data.topBodyParts.length > 3) const _MoreFocusedSetsHint(),
            ],
          );
          return Semantics(
            button: true,
            onTap: onFocusedSetsTap,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: onFocusedSetsTap,
                child: scrollable
                    ? SingleChildScrollView(
                        padding: const EdgeInsets.all(6),
                        child: content,
                      )
                    : Padding(padding: const EdgeInsets.all(6), child: content),
              ),
            ),
          );
        }

        if (isStacked) {
          return Column(
            key: const ValueKey('seven-day-focus-stacked'),
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: SizedBox(
                  width: heatmapBox,
                  height: heatmapSize,
                  child: Center(child: heatmap),
                ),
              ),
              const SizedBox(height: 8),
              details(scrollable: false),
            ],
          );
        }

        return SizedBox(
          key: const ValueKey('seven-day-focus-side-by-side'),
          height: 198,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: heatmapBox,
                height: 198,
                child: Center(child: heatmap),
              ),
              SizedBox(width: gap),
              Expanded(child: details(scrollable: true)),
            ],
          ),
        );
      },
    );
  }
}

class _MoreFocusedSetsHint extends StatelessWidget {
  const _MoreFocusedSetsHint({this.color});

  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        color ??
        (context.usesNeoPresentation
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.primary);
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(Icons.more_horiz, size: 18, color: foreground),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).sevenDayFocusMore,
            style: theme.textTheme.bodySmall?.copyWith(
              color: foreground,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
