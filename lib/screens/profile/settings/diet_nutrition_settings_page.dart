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
    final theme = Theme.of(context);
    final tokens = theme.extension<AppExpressiveDestinationTokens>()!;
    final hasAdditionalTargets =
        goal != null &&
        [
          goal.fiberG,
          goal.sugarG,
          goal.satFatG,
          goal.sodiumMg,
        ].any((value) => value != null);

    String target(double? value, String unit) =>
        value == null ? '—' : '${value.round()} $unit';

    Widget tile(
      String label,
      double? value,
      String unit,
      Color color,
      Color ink,
    ) => _GoalTargetTile(
      label: label,
      value: value,
      unit: unit,
      color: color,
      foreground: ink,
    );

    return Scaffold(
      backgroundColor: tokens.pageCanvas,
      appBar: AppBar(
        title: Text(
          strings.nutritionGoalsMenu,
          style: theme.textTheme.titleMedium?.copyWith(
            color: tokens.onSurfacePrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        backgroundColor: tokens.surfacePrimary,
        foregroundColor: tokens.onSurfacePrimary,
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                _NutritionGoalSurface(
                  color: tokens.surfacePrimary,
                  foreground: tokens.onSurfacePrimary,
                  icon: Icons.flag_outlined,
                  title: strings.nutritionCurrentGoals,
                  body: goal == null
                      ? strings.nutritionNoGoalSet
                      : '${strings.nutritionGoalStarts} · ${MaterialLocalizations.of(context).formatMediumDate(goal.startDate)}',
                  child: Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: goal == null
                        ? Text(
                            strings.nutritionGoalsSubtitle,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: tokens.onSurfacePrimary,
                              height: 1.4,
                            ),
                          )
                        : Column(
                            children: [
                              _GoalTargetTile(
                                label: strings.nutritionCaloriesLabel,
                                value: goal.kcalTarget,
                                unit: 'kcal',
                                color: tokens.surfaceTertiary,
                                foreground: tokens.onSurfaceTertiary,
                                prominent: true,
                              ),
                              const SizedBox(height: 8),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  final columns =
                                      constraints.maxWidth < 290 ||
                                          MediaQuery.textScalerOf(context)
                                                  .scale(1) >
                                              1.25
                                      ? 1
                                      : 3;
                                  final width =
                                      (constraints.maxWidth -
                                          8 * (columns - 1)) /
                                      columns;
                                  return Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: [
                                      SizedBox(
                                        width: width,
                                        child: tile(
                                          strings.nutritionProteinLabel,
                                          goal.proteinG,
                                          'g',
                                          tokens.surfaceSecondary,
                                          tokens.onSurfaceSecondary,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width,
                                        child: tile(
                                          strings.nutritionCarbsLabel,
                                          goal.carbsG,
                                          'g',
                                          tokens.surfaceAccent,
                                          tokens.onSurfaceAccent,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width,
                                        child: tile(
                                          strings.nutritionFatLabel,
                                          goal.fatG,
                                          'g',
                                          tokens.surfaceSelected,
                                          tokens.onSurfaceSelected,
                                        ),
                                      ),
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                  ),
                ),
                if (goal != null) ...[
                  const SizedBox(height: 16),
                  _NutritionGoalSurface(
                    color: Color.lerp(
                      tokens.surfaceTertiary,
                      tokens.pageCanvas,
                      0.6,
                    )!,
                    foreground: tokens.onSurfaceTertiary,
                    icon: Icons.science_outlined,
                    title: strings.nutritionAdditionalNutrients,
                    secondary: true,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: !hasAdditionalTargets
                          ? Text(
                              strings.nutritionNoAdditionalTargets,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: tokens.onSurfaceTertiary.withValues(
                                  alpha: 0.82,
                                ),
                              ),
                            )
                          : Column(
                              children: [
                                _goalDetail(
                                  context,
                                  strings.nutritionFiber,
                                  target(goal.fiberG, 'g'),
                                  tokens.onSurfaceTertiary,
                                ),
                                _goalDetail(
                                  context,
                                  strings.nutritionSugar,
                                  target(goal.sugarG, 'g'),
                                  tokens.onSurfaceTertiary,
                                ),
                                _goalDetail(
                                  context,
                                  strings.nutritionSatFat,
                                  target(goal.satFatG, 'g'),
                                  tokens.onSurfaceTertiary,
                                ),
                                _goalDetail(
                                  context,
                                  strings.nutritionSodium,
                                  target(goal.sodiumMg, 'mg'),
                                  tokens.onSurfaceTertiary,
                                ),
                              ],
                            ),
                    ),
                  ),
                ],
                const SizedBox(height: 16),
                Material(
                  color: tokens.surfaceSecondary,
                  shape: RoundedRectangleBorder(
                    borderRadius: context.nutritionTokens.sectionShape,
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () => _openEditor(context, strings),
                    child: Padding(
                      padding: const EdgeInsets.all(18),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: tokens.onSurfaceSecondary.withValues(
                                alpha: 0.08,
                              ),
                              borderRadius:
                                  context.nutritionTokens.compactShape,
                            ),
                            child: Icon(
                              Icons.edit_note,
                              color: tokens.onSurfaceSecondary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  strings.nutritionEditGoals,
                                  style: theme.textTheme.titleSmall?.copyWith(
                                    color: tokens.onSurfaceSecondary,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  strings.nutritionManualGoalsSubtitle,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: tokens.onSurfaceSecondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
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
        ),
      ),
    );
  }

  Widget _goalDetail(
    BuildContext context,
    String label,
    String value,
    Color ink,
  ) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 6),
    child: Row(
      children: [
        Expanded(
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: ink),
          ),
        ),
        const SizedBox(width: 12),
        Flexible(
          fit: FlexFit.tight,
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.titleSmall
                ?.copyWith(color: ink, fontWeight: FontWeight.w700),
          ),
        ),
      ],
    ),
  );

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
    this.body,
    this.child,
    this.secondary = false,
  });

  final Color color;
  final Color foreground;
  final IconData icon;
  final String title;
  final String? body;
  final Widget? child;
  final bool secondary;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: color,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(24),
        topRight: Radius.circular(14),
        bottomRight: Radius.circular(24),
        bottomLeft: Radius.circular(14),
      ),
      border: Border.all(color: foreground.withValues(alpha: 0.12)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: foreground, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                title,
                style:
                    (secondary
                            ? Theme.of(context).textTheme.titleSmall
                            : Theme.of(context).textTheme.titleMedium)
                        ?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w800,
                        ),
              ),
            ),
          ],
        ),
        if (body != null) ...[
          const SizedBox(height: 8),
          Text(
            body!,
            style: Theme.of(context).textTheme.bodySmall
                ?.copyWith(color: foreground.withValues(alpha: 0.82)),
          ),
        ],
        if (child != null) child!,
      ],
    ),
  );
}

class _GoalTargetTile extends StatelessWidget {
  const _GoalTargetTile({
    required this.label,
    required this.value,
    required this.unit,
    required this.color,
    required this.foreground,
    this.prominent = false,
  });

  final String label;
  final double? value;
  final String unit;
  final Color color;
  final Color foreground;
  final bool prominent;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: EdgeInsets.symmetric(
      horizontal: 14,
      vertical: prominent ? 14 : 12,
    ),
    decoration: BoxDecoration(
      color: color,
      borderRadius: context.nutritionTokens.portionShape,
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium
              ?.copyWith(color: foreground, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Text.rich(
          TextSpan(
            children: [
              TextSpan(text: value?.round().toString() ?? '—'),
              if (value != null)
                TextSpan(
                  text: ' $unit',
                  style: TextStyle(
                    fontSize: prominent ? 16 : 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: foreground,
            fontSize: prominent ? 28 : 21,
            fontWeight: FontWeight.w800,
            height: 1.15,
          ),
        ),
      ],
    ),
  );
}
