import 'package:material_ui/material_ui.dart';
import 'package:flutter/foundation.dart' show ValueListenable;

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import 'expressive_train_focus_progress.dart';
import '../theme/theme_extensions.dart';
import '../utils/localized_body_part_name.dart';
import '../utils/localized_formatters.dart';

class FocusedSetHit {
  final BodyPart bodyPart;
  final double units;

  const FocusedSetHit({required this.bodyPart, required this.units});
}

class FocusedSetsList extends StatelessWidget {
  final List<FocusedSetHit> hits;
  final int maxVisible;
  final String? title;
  final String? emptyMessage;
  final FontWeight titleWeight;
  final ValueListenable<double>? expressiveProgressPhase;
  final bool compact;

  const FocusedSetsList({
    super.key,
    required this.hits,
    this.maxVisible = 6,
    this.title,
    this.emptyMessage,
    this.titleWeight = FontWeight.w700,
    this.expressiveProgressPhase,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final maxUnits = hits.fold<double>(
      0.0,
      (max, hit) => hit.units > max ? hit.units : max,
    );
    final visibleHits = hits.take(maxVisible).toList();
    final strings = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title ?? strings.focusedSetsTitle,
          style: theme.textTheme.titleSmall?.copyWith(fontWeight: titleWeight),
        ),
        SizedBox(
          height: compact
              ? 4
              : expressiveProgressPhase == null
              ? 8
              : 6,
        ),
        if (visibleHits.isEmpty && emptyMessage != null)
          Text(emptyMessage!, style: theme.textTheme.bodySmall)
        else
          for (final hit in visibleHits)
            Padding(
              padding: EdgeInsets.only(
                bottom:
                    (compact
                        ? 4
                        : expressiveProgressPhase == null
                        ? 10
                        : 8) -
                    (hit.units == 0.0 ? 2 : 0),
              ),
              child: _FocusedSetRow(
                hit: hit,
                maxUnits: maxUnits,
                expressiveProgressPhase: expressiveProgressPhase,
                compact: compact,
                zeroCount: hit.units == 0.0,
              ),
            ),
      ],
    );
  }
}

class _FocusedSetRow extends StatelessWidget {
  final FocusedSetHit hit;
  final double maxUnits;
  final ValueListenable<double>? expressiveProgressPhase;
  final bool compact;
  final bool zeroCount;

  const _FocusedSetRow({
    required this.hit,
    required this.maxUnits,
    required this.expressiveProgressPhase,
    required this.compact,
    required this.zeroCount,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    final value = maxUnits == 0.0 ? 0.0 : hit.units / maxUnits;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                localizedBodyPartName(context, hit.bodyPart.name),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              LocalizedFormatters.number(
                hit.units.floor(),
                Localizations.localeOf(context),
                maximumFractionDigits: 0,
              ),
              style: theme.textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        SizedBox(height: (compact ? 2 : 4) - (zeroCount ? 1 : 0)),
        if (expressiveProgressPhase case final phase?)
          ExpressiveTrainFocusProgress(
            value: value,
            phase: phase,
            borderRadius: shapes.pill,
          )
        else
          ClipRRect(
            borderRadius: shapes.pill,
            child: LinearProgressIndicator(
              minHeight: compact ? 4 : 6,
              value: value.clamp(0.0, 1.0).toDouble(),
            ),
          ),
      ],
    );
  }
}
