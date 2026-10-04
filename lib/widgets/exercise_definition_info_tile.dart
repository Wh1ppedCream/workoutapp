import 'package:material_ui/material_ui.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/models.dart';
import '../theme/theme_extensions.dart';
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
    return TonosThemeReadyCard(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: expressive
          ? Theme.of(context).colorScheme.surfaceContainerLow
          : null,
      elevation: expressive ? 0 : null,
      shape: expressive
          ? RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))
          : null,
      child: ListTile(
        isThreeLine: true,
        title: LocalizedExerciseName(
          definition: definition,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
        subtitle: subtitle,
        trailing: expressive
            ? IconButton.filledTonal(
                tooltip: strings.catalogOpenExerciseInfo,
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showDetails(context, expressive: expressive),
              )
            : IconButton(
                tooltip: strings.catalogOpenExerciseInfo,
                icon: const Icon(Icons.info_outline),
                onPressed: () => _showDetails(context, expressive: expressive),
              ),
        onTap: () => _showDetails(context, expressive: expressive),
      ),
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
