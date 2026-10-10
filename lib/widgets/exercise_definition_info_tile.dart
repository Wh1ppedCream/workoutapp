import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/tonos_theme_ready.dart';
import 'exercise_detail_sheet.dart';
import 'localized_exercise_name.dart';

class ExerciseDefinitionInfoTile extends StatelessWidget {
  final ExerciseDefinition definition;
  final Widget subtitle;
  final bool expressiveCatalogPresentation;

  const ExerciseDefinitionInfoTile({
    super.key,
    required this.definition,
    required this.subtitle,
    this.expressiveCatalogPresentation = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressive =
        expressiveCatalogPresentation && context.usesExpressivePresentation;
    final destinationTokens =
        Theme.of(context).extension<AppExpressiveDestinationTokens>();
    final card = TonosThemeReadyCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color:
          expressive
              ? destinationTokens?.surfaceSelected ??
                  Theme.of(context).colorScheme.surfaceContainerLow
              : null,
      elevation: expressive ? 0 : null,
      shape:
          expressive
              ? RoundedRectangleBorder(
                borderRadius: const BorderRadiusDirectional.only(
                  topStart: Radius.circular(22),
                  topEnd: Radius.circular(10),
                  bottomEnd: Radius.circular(22),
                  bottomStart: Radius.circular(10),
                ),
                side: BorderSide(
                  color:
                      destinationTokens?.outlineAccent.withValues(alpha: 0.4) ??
                      Theme.of(context).colorScheme.outlineVariant,
                ),
              )
              : null,
      child: ListTile(
        isThreeLine: true,
        title: LocalizedExerciseName(
          definition: definition,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            color: expressive ? destinationTokens?.onSurfaceSelected : null,
            fontWeight: FontWeight.w700,
          ),
        ),
        subtitle:
            expressive
                ? DefaultTextStyle.merge(
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: destinationTokens?.onSurfaceSelected,
                  ),
                  child: subtitle,
                )
                : subtitle,
        contentPadding:
            expressive
                ? const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12)
                : null,
        minVerticalPadding: expressive ? 12 : null,
        trailing:
            expressive
                ? IconButton.filledTonal(
                  tooltip: strings.catalogOpenExerciseInfo,
                  icon: const Icon(Icons.info_outline),
                  style: IconButton.styleFrom(
                    foregroundColor:
                        destinationTokens?.onSurfaceAccent ??
                        Theme.of(context).colorScheme.onSurface,
                    backgroundColor:
                        destinationTokens?.surfaceAccent ??
                        Theme.of(context).colorScheme.surfaceContainerHigh,
                    minimumSize: const Size(48, 48),
                    padding: EdgeInsets.zero,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadiusDirectional.only(
                        topStart: Radius.circular(8),
                        topEnd: Radius.circular(16),
                        bottomEnd: Radius.circular(8),
                        bottomStart: Radius.circular(16),
                      ),
                    ),
                  ),
                  onPressed:
                      () => _showDetails(context, expressive: expressive),
                )
                : IconButton(
                  tooltip: strings.catalogOpenExerciseInfo,
                  icon: const Icon(Icons.info_outline),
                  onPressed:
                      () => _showDetails(context, expressive: expressive),
                ),
        onTap: () => _showDetails(context, expressive: expressive),
      ),
    );
    if (!expressive) return card;
    return TonosExpressivePressResponse(
      enabled: true,
      pressedScale: TonosExpressiveMotionTiers.supportingScale,
      pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
      child: card,
    );
  }

  void _showDetails(BuildContext context, {required bool expressive}) {
    ExerciseDetailSheet.show(
      context: context,
      definition: definition,
      defId: definition.id,
      expressiveCatalogPresentation: expressive,
    );
  }
}
