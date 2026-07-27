import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../l10n/generated/app_localizations.dart';
import '../repositories/app_repository.dart';
import '../theme/theme_extensions.dart';
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    return FutureBuilder<_SevenDayFocusData>(
      future: _dataFuture,
      builder: (context, snapshot) {
        final data = snapshot.data;
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.sevenDayFocusTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 16),
                if (snapshot.connectionState != ConnectionState.done &&
                    data == null)
                  const SizedBox(
                    height: 176,
                    child: Center(child: CircularProgressIndicator()),
                  )
                else if (snapshot.hasError && data == null)
                  SizedBox(
                    height: 176,
                    child: Center(child: Text(strings.sevenDayFocusLoadFailed)),
                  )
                else
                  _SevenDayFocusLayout(
                    data: data ?? _emptySevenDayFocusData,
                    onFocusedSetsTap: widget.onFocusedSetsTap,
                  ),
              ],
            ),
          ),
        );
      },
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
    final colors = context.colors;
    return LayoutBuilder(
      builder: (context, constraints) {
        final heatmapBox =
            (constraints.maxWidth * 0.43).clamp(118.0, 170.0).toDouble();
        final heatmapSize = (heatmapBox - 6).clamp(112.0, 164.0).toDouble();
        final gap = constraints.maxWidth < 330 ? 10.0 : 14.0;

        return SizedBox(
          height: 198,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: heatmapBox,
                height: 198,
                child: Center(
                  child: BodyHeatmap(
                    frequencyMap: data.heatmapFrequencyMap,
                    lowColor: colors.historySummaryHeatmapLow!,
                    highColor: colors.historySummaryHeatmapHigh!,
                    width: heatmapSize,
                    height: heatmapSize,
                  ),
                ),
              ),
              SizedBox(width: gap),
              Expanded(
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: onFocusedSetsTap,
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(6),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          FocusedSetsList(
                            hits: data.topBodyParts,
                            maxVisible: 3,
                            emptyMessage:
                                AppLocalizations.of(context).sevenDayFocusEmpty,
                            titleWeight: FontWeight.w800,
                          ),
                          if (data.topBodyParts.length > 3)
                            const _MoreFocusedSetsHint(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          Icon(Icons.more_horiz, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context).sevenDayFocusMore,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
