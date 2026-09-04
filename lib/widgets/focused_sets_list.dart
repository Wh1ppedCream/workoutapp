import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
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

  const FocusedSetsList({
    super.key,
    required this.hits,
    this.maxVisible = 6,
    this.title,
    this.emptyMessage,
    this.titleWeight = FontWeight.w700,
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
        const SizedBox(height: 8),
        if (visibleHits.isEmpty && emptyMessage != null)
          Text(emptyMessage!, style: theme.textTheme.bodySmall)
        else
          for (final hit in visibleHits)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FocusedSetRow(hit: hit, maxUnits: maxUnits),
            ),
      ],
    );
  }
}

class _FocusedSetRow extends StatelessWidget {
  final FocusedSetHit hit;
  final double maxUnits;

  const _FocusedSetRow({required this.hit, required this.maxUnits});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(999),
          child: LinearProgressIndicator(
            minHeight: 6,
            value: value.clamp(0.0, 1.0).toDouble(),
          ),
        ),
      ],
    );
  }
}
