// File: lib/screens/profile/settings/analytics_setting_screen.dart
// Hub for exercise analytics and training recommendation settings.

import 'package:material_ui/material_ui.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../widgets/settings_tiles.dart';
import 'analytics_destination_surfaces.dart';
import 'bodypart_muscle_mapping_screen.dart';
import 'bodypart_ranking_screen.dart';
import 'exercise_analytics_screen.dart';
import 'exercise_editor_screen.dart';
import 'muscle_ranking_screen.dart';
import 'volume_boundaries_screen.dart';

class AnalyticsSettingsScreen extends StatelessWidget {
  const AnalyticsSettingsScreen({super.key});

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    if (analyticsDestinationTokens(context) != null) {
      return AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.analytics,
        child: Scaffold(
          backgroundColor: analyticsDestinationTokens(context)!.pageCanvas,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 28),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: strings.commonBack,
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back),
                  ),
                ),
                const SizedBox(height: 4),
                AnalyticsRouteHeader(
                  title: strings.settingsWorkoutTitle,
                  subtitle: strings.settingsWorkoutSubtitle,
                  icon: Icons.tune,
                ),
                const SizedBox(height: 20),
                _buildExpressiveGroup(
                  context,
                  title: strings.settingsTrainingBiasTitle,
                  subtitle: strings.settingsTrainingBiasSubtitle,
                  role: AnalyticsSurfaceRole.secondary,
                  routes: [
                    _HubRoute(
                      Icons.accessibility_new,
                      strings.settingsBodyPartRankings,
                      strings.settingsBodyPartRankingsSubtitle,
                      const BodyPartRankingScreen(),
                    ),
                    _HubRoute(
                      Icons.fitness_center,
                      strings.settingsMuscleRankings,
                      strings.settingsMuscleRankingsSubtitle,
                      const MuscleRankingScreen(),
                    ),
                    _HubRoute(
                      Icons.track_changes,
                      strings.settingsVolumeBoundaries,
                      strings.settingsVolumeBoundariesSubtitle,
                      const VolumeBoundariesScreen(),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                _buildExpressiveGroup(
                  context,
                  title: strings.settingsExerciseDefinitionsTitle,
                  subtitle: strings.settingsExerciseDefinitionsSubtitle,
                  role: AnalyticsSurfaceRole.tertiary,
                  routes: [
                    _HubRoute(
                      Icons.hub,
                      strings.settingsAnatomyMapping,
                      strings.settingsAnatomyMappingSubtitle,
                      const BodyPartMuscleMappingScreen(),
                    ),
                    _HubRoute(
                      Icons.analytics,
                      strings.settingsExerciseSetAllocation,
                      strings.settingsExerciseSetAllocationSubtitle,
                      const ExerciseAnalyticsScreen(),
                    ),
                    _HubRoute(
                      Icons.edit_note,
                      strings.settingsExerciseEditor,
                      strings.settingsExerciseEditorSubtitle,
                      const ExerciseEditorScreen(),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    }
    return SettingsPageScaffold(
      title: strings.settingsWorkoutTitle,
      subtitle: strings.settingsWorkoutSubtitle,
      icon: Icons.tune,
      heroAccentColor: SettingsAccent.training,
      children: [
        SettingsSection(
          title: strings.settingsTrainingBiasTitle,
          subtitle: strings.settingsTrainingBiasSubtitle,
          accentColor: SettingsAccent.training,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.accessibility_new,
              iconColor: SettingsAccent.training,
              title: strings.settingsBodyPartRankings,
              subtitle: strings.settingsBodyPartRankingsSubtitle,
              onTap: () => _open(context, const BodyPartRankingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.fitness_center,
              iconColor: SettingsAccent.training,
              title: strings.settingsMuscleRankings,
              subtitle: strings.settingsMuscleRankingsSubtitle,
              onTap: () => _open(context, const MuscleRankingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.track_changes,
              iconColor: SettingsAccent.training,
              title: strings.settingsVolumeBoundaries,
              subtitle: strings.settingsVolumeBoundariesSubtitle,
              onTap: () => _open(context, const VolumeBoundariesScreen()),
            ),
          ]),
        ),
        SettingsSection(
          title: strings.settingsExerciseDefinitionsTitle,
          subtitle: strings.settingsExerciseDefinitionsSubtitle,
          accentColor: SettingsAccent.advanced,
          children: settingsTilesWithDividers(context, [
            SettingsActionTile(
              icon: Icons.hub,
              iconColor: SettingsAccent.advanced,
              title: strings.settingsAnatomyMapping,
              subtitle: strings.settingsAnatomyMappingSubtitle,
              onTap: () => _open(context, const BodyPartMuscleMappingScreen()),
            ),
            SettingsActionTile(
              icon: Icons.analytics,
              iconColor: SettingsAccent.advanced,
              title: strings.settingsExerciseSetAllocation,
              subtitle: strings.settingsExerciseSetAllocationSubtitle,
              onTap: () => _open(context, const ExerciseAnalyticsScreen()),
            ),
            SettingsActionTile(
              icon: Icons.edit_note,
              iconColor: SettingsAccent.advanced,
              title: strings.settingsExerciseEditor,
              subtitle: strings.settingsExerciseEditorSubtitle,
              onTap: () => _open(context, const ExerciseEditorScreen()),
            ),
          ]),
        ),
      ],
    );
  }

  Widget _buildExpressiveGroup(
    BuildContext context, {
    required String title,
    required String subtitle,
    required AnalyticsSurfaceRole role,
    required List<_HubRoute> routes,
  }) {
    final tokens = analyticsDestinationTokens(context)!;
    final foreground = analyticsForegroundColor(tokens, role);
    return AnalyticsZone(
      role: role,
      padding: const EdgeInsets.fromLTRB(16, 18, 12, 12),
      borderRadius: 28,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleMedium
                ?.copyWith(color: foreground, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: foreground.withValues(alpha: 0.82)),
          ),
          const SizedBox(height: 12),
          for (var index = 0; index < routes.length; index++) ...[
            if (index > 0) const SizedBox(height: 8),
            _buildExpressiveRouteTile(context, routes[index], index),
          ],
        ],
      ),
    );
  }

  Widget _buildExpressiveRouteTile(
    BuildContext context,
    _HubRoute route,
    int index,
  ) {
    final tokens = analyticsDestinationTokens(context)!;
    return Material(
      color: tokens.pageCanvas.withValues(alpha: 0.78),
      borderRadius: BorderRadius.only(
        topLeft: const Radius.circular(20),
        topRight: const Radius.circular(20),
        bottomRight: const Radius.circular(20),
        bottomLeft: Radius.circular(index.isEven ? 6 : 20),
      ),
      child: InkWell(
        borderRadius: BorderRadius.only(
          topLeft: const Radius.circular(20),
          topRight: const Radius.circular(20),
          bottomRight: const Radius.circular(20),
          bottomLeft: Radius.circular(index.isEven ? 6 : 20),
        ),
        onTap: () => _open(context, route.page),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: tokens.surfacePrimary,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Icon(
                  route.icon,
                  color: tokens.onSurfacePrimary,
                  size: 21,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      route.title,
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: tokens.supportingForeground,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      route.subtitle,
                      style: Theme.of(context).textTheme.bodySmall
                          ?.copyWith(color: tokens.supportingForeground),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward, color: tokens.outlineAccent, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubRoute {
  const _HubRoute(this.icon, this.title, this.subtitle, this.page);

  final IconData icon;
  final String title;
  final String subtitle;
  final Widget page;
}
