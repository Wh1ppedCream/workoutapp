// lib/screens/profile/settings/gym_exercise_settings_page.dart

import 'package:material_ui/material_ui.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/workout_exit_preferences.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_train_tokens.dart';
import '../../../theme/widgets/tonos_dialog.dart';
import '../../../theme/widgets/tonos_surface.dart';
import '../../../widgets/settings_tiles.dart';
import 'analytics_setting_screen.dart';
import 'flow_methods_page.dart';
import 'workout_progress_flows_page.dart';

class GymExerciseSettingsPage extends StatefulWidget {
  const GymExerciseSettingsPage({super.key});

  @override
  State<GymExerciseSettingsPage> createState() =>
      _GymExerciseSettingsPageState();
}

class _GymExerciseSettingsPageState extends State<GymExerciseSettingsPage> {
  static const _exitPreferences = WorkoutExitPreferences();

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    final expressive = context.usesExpressivePresentation;
    final expressiveTokens = expressive
        ? Theme.of(context).extension<AppExpressiveTrainTokens>()!
        : null;
    final exitPreferenceTile = FutureBuilder<WorkoutExitBehavior>(
      future: _exitPreferences.load(),
      builder: (context, snapshot) {
        final behavior = snapshot.data ?? WorkoutExitBehavior.askEveryTime;
        return expressive
            ? _ExpressivePreferenceTile(
                icon: Icons.exit_to_app_outlined,
                iconColor: SettingsAccent.training,
                title: strings.gymSettingsExitTitle,
                subtitle: _exitBehaviorLabel(behavior, strings),
                onTap: () => _chooseExitBehavior(behavior),
              )
            : SettingsActionTile(
                icon: Icons.exit_to_app_outlined,
                iconColor: SettingsAccent.training,
                title: strings.gymSettingsExitTitle,
                subtitle: _exitBehaviorLabel(behavior, strings),
                onTap: () => _chooseExitBehavior(behavior),
              );
      },
    );
    return SettingsPageScaffold(
      title: strings.gymSettingsTitle,
      subtitle: strings.gymSettingsSubtitle,
      icon: Icons.fitness_center,
      heroAccentColor: SettingsAccent.training,
      children: [
        if (expressive) ...[
          _ExpressivePreferenceGroup(
            title: strings.gymSettingsLogicTitle,
            subtitle: strings.gymSettingsLogicSubtitle,
            surface: expressiveTokens!.activePlansSurface,
            children: [
              _ExpressivePreferenceTile(
                icon: Icons.bar_chart,
                iconColor: SettingsAccent.training,
                title: strings.gymSettingsWorkoutTitle,
                subtitle: strings.gymSettingsWorkoutSubtitle,
                onTap: () => _open(context, const AnalyticsSettingsScreen()),
              ),
              exitPreferenceTile,
            ],
          ),
          const SizedBox(height: 12),
          _ExpressivePreferenceGroup(
            title: strings.gymSettingsFlowToolsTitle,
            subtitle: strings.gymSettingsFlowToolsSubtitle,
            surface: expressiveTokens.archivedPlansSurface,
            children: [
              _ExpressivePreferenceTile(
                icon: Icons.schema_outlined,
                iconColor: SettingsAccent.advanced,
                title: strings.flowPageTitle,
                subtitle: strings.gymSettingsFlowsSubtitle,
                onTap: () => _open(context, const WorkoutProgressFlowsPage()),
              ),
              _ExpressivePreferenceTile(
                icon: Icons.route_outlined,
                iconColor: SettingsAccent.advanced,
                title: strings.rulesPageTitle,
                subtitle: strings.gymSettingsRulesSubtitle,
                onTap: () => _open(context, const FlowMethodsPage()),
              ),
            ],
          ),
        ] else ...[
          SettingsSection(
            title: strings.gymSettingsLogicTitle,
            subtitle: strings.gymSettingsLogicSubtitle,
            accentColor: SettingsAccent.training,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.bar_chart,
                iconColor: SettingsAccent.training,
                title: strings.gymSettingsWorkoutTitle,
                subtitle: strings.gymSettingsWorkoutSubtitle,
                onTap: () => _open(context, const AnalyticsSettingsScreen()),
              ),
              exitPreferenceTile,
            ]),
          ),
          SettingsSection(
            title: strings.gymSettingsFlowToolsTitle,
            subtitle: strings.gymSettingsFlowToolsSubtitle,
            accentColor: SettingsAccent.advanced,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.schema_outlined,
                iconColor: SettingsAccent.advanced,
                title: strings.flowPageTitle,
                subtitle: strings.gymSettingsFlowsSubtitle,
                onTap: () => _open(context, const WorkoutProgressFlowsPage()),
              ),
              SettingsActionTile(
                icon: Icons.route_outlined,
                iconColor: SettingsAccent.advanced,
                title: strings.rulesPageTitle,
                subtitle: strings.gymSettingsRulesSubtitle,
                onTap: () => _open(context, const FlowMethodsPage()),
              ),
            ]),
          ),
        ],
      ],
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  String _exitBehaviorLabel(
    WorkoutExitBehavior behavior,
    AppLocalizations strings,
  ) {
    return switch (behavior) {
      WorkoutExitBehavior.askEveryTime => strings.gymExitAskBody,
      WorkoutExitBehavior.discard => strings.gymExitDiscardBody,
      WorkoutExitBehavior.saveCompleted => strings.gymExitSaveBody,
    };
  }

  Future<void> _chooseExitBehavior(WorkoutExitBehavior current) async {
    final strings = AppLocalizations.of(context);
    final selected = await showDialog<WorkoutExitBehavior>(
      context: context,
      builder: (dialogContext) {
        final neo = context.usesNeoPresentation;
        final ink = context.cs.onPrimaryContainer;
        return TonosDialogFrame(
          child: SimpleDialog(
            title: Text(strings.gymSettingsExitTitle),
            children: [
              for (final behavior in WorkoutExitBehavior.values)
                RadioListTile<WorkoutExitBehavior>(
                  value: behavior,
                  groupValue: current,
                  title: Text(switch (behavior) {
                    WorkoutExitBehavior.askEveryTime => strings.gymExitAsk,
                    WorkoutExitBehavior.discard => strings.gymExitDiscard,
                    WorkoutExitBehavior.saveCompleted => strings.gymExitSave,
                  }, style: neo ? TextStyle(color: ink) : null),
                  subtitle: Text(
                    _exitBehaviorLabel(behavior, strings),
                    style: neo ? TextStyle(color: ink) : null,
                  ),
                  onChanged: (value) => Navigator.pop(dialogContext, value),
                ),
            ],
          ),
        );
      },
    );
    if (selected == null) return;
    await _exitPreferences.save(selected);
    if (mounted) setState(() {});
  }
}

class _ExpressivePreferenceGroup extends StatelessWidget {
  const _ExpressivePreferenceGroup({
    required this.title,
    required this.subtitle,
    required this.surface,
    required this.children,
  });

  final String title;
  final String subtitle;
  final Color surface;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return TonosSurface(
      color: surface,
      variant: TonosSurfaceVariant.card,
      borderRadius: ExpressiveTrainShapes.section,
      padding: const EdgeInsets.fromLTRB(14, 14, 10, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w900,
              color: theme.colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 3),
          Text(subtitle, style: theme.textTheme.bodySmall),
          const SizedBox(height: 8),
          ...children,
        ],
      ),
    );
  }
}

class _ExpressivePreferenceTile extends StatelessWidget {
  const _ExpressivePreferenceTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;
    return InkWell(
      onTap: onTap,
      borderRadius: ExpressiveTrainShapes.focusInset,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9, horizontal: 4),
        child: Row(
          children: [
            SizedBox(
              width: 42,
              height: 42,
              child: TonosSurface(
                variant: TonosSurfaceVariant.panelRaised,
                borderRadius: shapes.control,
                padding: const EdgeInsets.all(10),
                child: Icon(icon, color: iconColor, size: 22),
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
            const SizedBox(width: 4),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}
