import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../providers/nutrition_profile.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/tokens/app_expressive_destination_tokens.dart';
import '../../../theme/widgets/app_expressive_destination_theme.dart';
import '../../../widgets/settings_tiles.dart';
import 'goal_manual_entry_page.dart';

class DietNutritionSettingsPage extends StatelessWidget {
  const DietNutritionSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    if (context.usesExpressivePresentation) {
      return AppExpressiveDestinationTheme(
        family: AppExpressiveDestinationFamily.nutrition,
        child: Builder(builder: _buildExpressive),
      );
    }
    return _buildClassicAndNeo(context);
  }

  Widget _buildExpressive(BuildContext context) {
    final profile = context.watch<NutritionProfile>();
    final goal = profile.activeGoal;
    final strings = AppLocalizations.of(context);
    final tokens = Theme.of(context)
        .extension<AppExpressiveDestinationTokens>()!;

    return Scaffold(
      backgroundColor: tokens.pageCanvas,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                tooltip: strings.commonBack,
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back),
                color: tokens.supportingForeground,
              ),
            ),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: tokens.surfacePrimary,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(30),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(30),
                  bottomLeft: Radius.circular(18),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.restaurant_menu, color: tokens.onSurfacePrimary),
                  const SizedBox(height: 12),
                  Text(
                    strings.nutritionSettingsTitle,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: tokens.onSurfacePrimary,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    strings.nutritionSettingsSubtitle,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: tokens.onSurfacePrimary.withValues(alpha: 0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            if (goal != null) ...[
              _NutritionGoalSurface(
                color: tokens.surfaceTertiary,
                foreground: tokens.onSurfaceTertiary,
                icon: Icons.flag_outlined,
                title: strings.nutritionCurrentGoals,
                body: _formatGoalSummary(strings, goal),
              ),
              const SizedBox(height: 16),
            ],
            _NutritionGoalSurface(
              color: tokens.surfaceSecondary,
              foreground: tokens.onSurfaceSecondary,
              icon: Icons.tune,
              title: strings.nutritionGoals,
              body: strings.nutritionGoalsSubtitle,
              child: InkWell(
                borderRadius: BorderRadius.circular(18),
                onTap: () => _openEditor(context, strings),
                child: Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.edit_note, color: tokens.onSurfaceSecondary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              strings.nutritionManualGoals,
                              style: Theme.of(context).textTheme.titleSmall
                                  ?.copyWith(
                                    color: tokens.onSurfaceSecondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              strings.nutritionManualGoalsSubtitle,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(color: tokens.onSurfaceSecondary),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right,
                        color: tokens.onSurfaceSecondary,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildClassicAndNeo(BuildContext context) {
    final profile = context.watch<NutritionProfile>();
    final goal = profile.activeGoal;
    final strings = AppLocalizations.of(context);
    return SettingsPageScaffold(
      title: strings.nutritionSettingsTitle,
      subtitle: strings.nutritionSettingsSubtitle,
      icon: Icons.restaurant_menu,
      children: [
        if (goal != null) ...[
          SettingsInfoCard(
            icon: Icons.flag_outlined,
            title: strings.nutritionCurrentGoals,
            body: _formatGoalSummary(strings, goal),
          ),
          const SizedBox(height: 16),
        ],
        SettingsSection(
          title: strings.nutritionGoals,
          subtitle: strings.nutritionGoalsSubtitle,
          children: [
            SettingsActionTile(
              icon: Icons.edit_note,
              title: strings.nutritionManualGoals,
              subtitle: strings.nutritionManualGoalsSubtitle,
              onTap: () => _openEditor(context, strings),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    AppLocalizations strings,
  ) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => const GoalManualEntryPage()),
    );
    if (changed == true && context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(strings.nutritionGoalsSaved)));
    }
  }

  String _formatGoalSummary(AppLocalizations strings, dynamic goal) {
    String number(double? value, {String unit = ''}) {
      if (value == null) return '-';
      return '${value.toStringAsFixed(0)}$unit';
    }

    return strings.nutritionGoalSummary(
      number(goal.kcalTarget, unit: ' kcal'),
      number(goal.proteinG, unit: ' g'),
      number(goal.carbsG, unit: ' g'),
      number(goal.fatG, unit: ' g'),
      number(goal.fiberG, unit: ' g'),
      number(goal.sugarG, unit: ' g'),
      number(goal.satFatG, unit: ' g'),
      goal.sodiumMg == null ? '-' : '${goal.sodiumMg!.round()} mg',
    );
  }
}

class _NutritionGoalSurface extends StatelessWidget {
  const _NutritionGoalSurface({
    required this.color,
    required this.foreground,
    required this.icon,
    required this.title,
    required this.body,
    this.child,
  });

  final Color color;
  final Color foreground;
  final IconData icon;
  final String title;
  final String body;
  final Widget? child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(14),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(14),
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: foreground),
        const SizedBox(height: 10),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium
              ?.copyWith(color: foreground, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 5),
        Text(
          body,
          style: Theme.of(context).textTheme.bodyMedium
              ?.copyWith(color: foreground),
        ),
        if (child != null) child!,
      ],
    ),
  );
}
