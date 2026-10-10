// lib/screens/profile/settings/measurements_trends_settings_page.dart

import 'package:material_ui/material_ui.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../theme/widgets/tonos_surface.dart';
import '../../../utils/app_test_keys.dart';
import '../../../widgets/settings_tiles.dart';
import '../../nutrition/measured_items_page.dart';

class MeasurementsTrendsSettingsPage extends StatelessWidget {
  const MeasurementsTrendsSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    final destination = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>();
    final expressiveTokens = expressive
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()!
        : null;
    return SettingsPageScaffold(
      title: strings.progressSettingsTitle,
      subtitle: strings.progressSettingsSubtitle,
      icon: Icons.monitor_outlined,
      heroAccentColor: SettingsAccent.progress,
      useExpressiveProfileHeroShape: true,
      children: [
        if (expressive)
          TonosSurface(
            color: destination?.family == AppExpressiveDestinationFamily.profile
                ? destination!.surfaceTertiary
                : expressiveTokens!.creationSurface,
            variant: TonosSurfaceVariant.card,
            borderRadius: ExpressiveTrainShapes.section,
            padding: const EdgeInsets.fromLTRB(14, 14, 10, 8),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  strings.progressMeasurements,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color:
                        destination?.family ==
                            AppExpressiveDestinationFamily.profile
                        ? destination!.onSurfaceTertiary
                        : null,
                    fontWeight: FontWeight.w900,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  strings.progressMeasurementsSubtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color:
                        destination?.family ==
                            AppExpressiveDestinationFamily.profile
                        ? destination!.onSurfaceTertiary.withValues(alpha: 0.78)
                        : null,
                  ),
                ),
                const SizedBox(height: 8),
                KeyedSubtree(
                  key: AppTestKeys.progressMeasurementLibrary,
                  child: _ExpressiveMeasurementLibraryTile(
                    title: strings.progressMeasurementLibrary,
                    subtitle: strings.progressMeasurementLibrarySubtitle,
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => AppExpressiveDestinationTheme(
                          family: AppExpressiveDestinationFamily.profile,
                          child: const MeasuredItemsPage(),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          )
        else
          SettingsSection(
            title: strings.progressMeasurements,
            subtitle: strings.progressMeasurementsSubtitle,
            accentColor: SettingsAccent.progress,
            children: [
              KeyedSubtree(
                key: AppTestKeys.progressMeasurementLibrary,
                child: SettingsActionTile(
                  icon: Icons.straighten,
                  iconColor: SettingsAccent.progress,
                  title: strings.progressMeasurementLibrary,
                  subtitle: strings.progressMeasurementLibrarySubtitle,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => AppExpressiveDestinationTheme(
                        family: AppExpressiveDestinationFamily.profile,
                        child: const MeasuredItemsPage(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

class _ExpressiveMeasurementLibraryTile extends StatelessWidget {
  const _ExpressiveMeasurementLibraryTile({
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final destination = theme.extension<AppExpressiveDestinationTokens>();
    return InkWell(
      onTap: onTap,
      borderRadius: ExpressiveTrainShapes.focusInset,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: TonosSurface(
                variant: TonosSurfaceVariant.panelRaised,
                color:
                    destination?.family ==
                        AppExpressiveDestinationFamily.profile
                    ? destination!.surfaceSelected
                    : null,
                borderRadius: context.shapeTokens.control,
                padding: const EdgeInsets.all(10),
                child: Icon(
                  Icons.straighten,
                  color:
                      destination?.family ==
                          AppExpressiveDestinationFamily.profile
                      ? destination!.onSurfaceSelected
                      : context.cs.primary,
                ),
              ),
            ),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(subtitle, style: theme.textTheme.bodySmall),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
