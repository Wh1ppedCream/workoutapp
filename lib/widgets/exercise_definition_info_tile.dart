import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme_extensions.dart';
import '../theme/tokens/app_expressive_destination_tokens.dart';
import '../theme/widgets/tonos_expressive_motion.dart';
import '../theme/widgets/tonos_theme_ready.dart';
import 'exercise_detail_sheet.dart';
import 'exercise_media_thumbnail.dart';
import 'localized_exercise_name.dart';

class ExerciseDefinitionInfoTile extends StatelessWidget {
  final ExerciseDefinition definition;
  final Widget subtitle;
  final bool expressiveCatalogPresentation;
  final AppExpressiveDestinationFamily? expressiveDestinationFamily;
  final bool compactExpressivePresentation;
  final bool bodypartExercisePreview;
  final bool muscleExercisePreview;

  const ExerciseDefinitionInfoTile({
    super.key,
    required this.definition,
    required this.subtitle,
    this.expressiveCatalogPresentation = false,
    this.expressiveDestinationFamily,
    this.compactExpressivePresentation = false,
    this.bodypartExercisePreview = false,
    this.muscleExercisePreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final destinationTokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final expressiveFamily =
        expressiveDestinationFamily ??
        (expressiveCatalogPresentation
            ? AppExpressiveDestinationFamily.catalog
            : null);
    final expressive =
        expressiveFamily != null &&
        context.usesExpressivePresentation &&
        destinationTokens?.family == expressiveFamily;
    if (compactExpressivePresentation &&
        expressive &&
        expressiveFamily == AppExpressiveDestinationFamily.catalog) {
      return _compactCatalogTile(context, destinationTokens!);
    }
    final card = TonosThemeReadyCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: expressive
          ? destinationTokens?.surfaceSelected ??
                Theme.of(context).colorScheme.surfaceContainerLow
          : null,
      elevation: expressive ? 0 : null,
      shape: expressive
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
        subtitle: expressive
            ? DefaultTextStyle.merge(
                style: Theme.of(context).textTheme.bodyMedium
                    ?.copyWith(color: destinationTokens?.onSurfaceSelected),
                child: subtitle,
              )
            : subtitle,
        contentPadding: expressive
            ? const EdgeInsetsDirectional.fromSTEB(16, 12, 12, 12)
            : null,
        minVerticalPadding: expressive ? 12 : null,
        trailing: expressive
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
                onPressed: () => _showDetails(
                  context,
                  expressiveCatalog:
                      expressive &&
                      expressiveFamily ==
                          AppExpressiveDestinationFamily.catalog,
                ),
              )
            : IconButton(
                tooltip: strings.catalogOpenExerciseInfo,
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showDetails(
                  context,
                  expressiveCatalog:
                      expressive &&
                      expressiveFamily ==
                          AppExpressiveDestinationFamily.catalog,
                ),
              ),
        onTap: () => _showDetails(
          context,
          expressiveCatalog:
              expressive &&
              expressiveFamily == AppExpressiveDestinationFamily.catalog,
        ),
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

  Widget _compactCatalogTile(
    BuildContext context,
    AppExpressiveDestinationTokens tokens,
  ) {
    final theme = Theme.of(context);
    final strings = AppLocalizations.of(context);
    final surface = theme.brightness == Brightness.dark
        ? const Color(0xFF382A49)
        : const Color(0xFFDED3EE);
    final anatomyPreview = bodypartExercisePreview || muscleExercisePreview;
    const shape = RoundedRectangleBorder(
      borderRadius: BorderRadius.all(Radius.circular(16)),
    );
    void showDetails() => _showDetails(context, expressiveCatalog: true);

    return TonosExpressivePressResponse(
      enabled: true,
      pressedScale: TonosExpressiveMotionTiers.supportingScale,
      pressedOffset: TonosExpressiveMotionTiers.supportingOffset,
      child: TonosThemeReadyCard(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        color: surface,
        elevation: 0,
        shape: shape,
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          customBorder: shape,
          onTap: showDetails,
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: anatomyPreview ? 88 : 104),
            child: Padding(
              padding: anatomyPreview
                  ? const EdgeInsetsDirectional.fromSTEB(16, 10, 8, 10)
                  : const EdgeInsetsDirectional.fromSTEB(12, 10, 4, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        LocalizedExerciseName(
                          definition: definition,
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: tokens.onSurfaceSelected,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        SizedBox(height: anatomyPreview ? 4 : 3),
                        DefaultTextStyle.merge(
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: tokens.supportingForeground,
                          ),
                          child: subtitle,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 4),
                  if (anatomyPreview)
                    Tooltip(
                      message: strings.catalogOpenExerciseInfo,
                      excludeFromSemantics: true,
                      child: Semantics(
                        button: true,
                        label: strings.catalogOpenExerciseInfo,
                        child: Material(
                          color: context.surfaceTokens.mediaPlaceholder,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          clipBehavior: Clip.antiAlias,
                          child: ExerciseMediaThumbnail(
                            key: ValueKey(
                              'anatomy-exercise-thumbnail-${definition.id}',
                            ),
                            definition: definition,
                            size: 60,
                            borderRadius: BorderRadius.circular(12),
                            padding: EdgeInsets.zero,
                            framed: false,
                            onTap: showDetails,
                          ),
                        ),
                      ),
                    )
                  else
                    IconButton(
                      tooltip: strings.catalogOpenExerciseInfo,
                      icon: const Icon(Icons.info_outline, size: 21),
                      style: IconButton.styleFrom(
                        foregroundColor: tokens.actionPrimary,
                        minimumSize: const Size(48, 48),
                        tapTargetSize: MaterialTapTargetSize.padded,
                        padding: const EdgeInsets.all(12),
                      ),
                      onPressed: showDetails,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showDetails(BuildContext context, {required bool expressiveCatalog}) {
    ExerciseDetailSheet.show(
      context: context,
      definition: definition,
      defId: definition.id,
      expressiveCatalogPresentation: expressiveCatalog,
    );
  }
}
