import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
import '../theme/widgets/tonos_surface.dart';
import 'body_heatmap.dart';
import 'focused_sets_list.dart';

/// Shared seven-day training summary used by Train and the customizable
/// Dashboard so both surfaces report the same recent focus data.
class SevenDayFocusCard extends StatefulWidget {
  final int refreshToken;
  final VoidCallback onFocusedSetsTap;

  const SevenDayFocusCard({
    super.key,
    required this.refreshToken,
    required this.onFocusedSetsTap,
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
    this.loading = false,
    this.failed = false,
  });

  final Map<String, double> heatmapFrequencyMap;
  final List<FocusedSetHit> hits;
  final VoidCallback onFocusedSetsTap;
  final bool loading;
  final bool failed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final surfaces = context.surfaceTokens;
    final usesInkRecipe = context.surfaceDecorationTokens.panelRaised.outlined;
    final surfaceInk = context.cs.onPrimaryContainer;
    final content = Theme(
      data:
          usesInkRecipe
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
              : theme,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            strings.sevenDayFocusTitle,
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.w800,
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
    return usesInkRecipe
        ? TonosSurface(
          variant: TonosSurfaceVariant.panelRaised,
          color: surfaces.dashboardHero,
          padding: const EdgeInsets.all(16),
          child: content,
        )
        : Card(
          child: Padding(padding: const EdgeInsets.all(16), child: content),
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
        final rowAnatomyWidth =
            (constraints.maxWidth * 0.43).clamp(118.0, 170.0).toDouble();
        final isStacked =
            supportsStackedLayout &&
            constraints.maxWidth < rowAnatomyWidth + gap + minimumDetailsWidth;
        final heatmapBox =
            (constraints.maxWidth * (isStacked ? 0.62 : 0.43))
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
                titleWeight: FontWeight.w800,
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
                child:
                    scrollable
                        ? SingleChildScrollView(
                          padding: const EdgeInsets.all(6),
                          child: content,
                        )
                        : Padding(
                          padding: const EdgeInsets.all(6),
                          child: content,
                        ),
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
  const _MoreFocusedSetsHint();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground =
        context.surfaceDecorationTokens.panelRaised.outlined
            ? theme.colorScheme.onPrimaryContainer
            : theme.colorScheme.primary;
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
