// file: lib/screens/profile/settings/profile_page.dart

import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../../l10n/generated/app_localizations.dart';
import '../../../services/tutorial_state_store.dart';
import '../../../theme/theme_extensions.dart';
import '../../../theme/widgets/tonos_surface.dart';
import '../../../widgets/guided_tutorial_overlay.dart';
import '../../../widgets/settings_tiles.dart';
import '../../../utils/app_test_keys.dart';
import 'database_settings_page.dart';
import 'diagnostics_settings_page.dart';
import 'gym_exercise_settings_page.dart';
import 'measurements_trends_settings_page.dart';
import 'tutorials_settings_page.dart';
import 'ui_appearance_settings_page.dart';
import 'user_information_settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _accountSettingsTutorialKey = GlobalKey(
    debugLabel: 'profile_account_settings_tutorial',
  );
  final _trainingSettingsTutorialKey = GlobalKey(
    debugLabel: 'profile_training_settings_tutorial',
  );
  final _dataSettingsTutorialKey = GlobalKey(
    debugLabel: 'profile_data_settings_tutorial',
  );
  final _tutorialStore = const TutorialStateStore();

  bool _profileTutorialQueued = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _queueProfileTutorial();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (TickerMode.of(context)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _queueProfileTutorial();
      });
    }
  }

  void _queueProfileTutorial() {
    if (!mounted || _profileTutorialQueued || !TickerMode.of(context)) return;
    _profileTutorialQueued = true;
    unawaited(_showProfileTutorialIfNeeded());
  }

  Future<void> _showProfileTutorialIfNeeded() async {
    try {
      await Future<void>.delayed(const Duration(milliseconds: 550));
      if (!mounted || !TickerMode.of(context)) return;

      final completed = await _tutorialStore.isCompleted(
        TutorialIds.profileHome,
      );
      if (completed || !mounted) return;
      final strings = AppLocalizations.of(context);

      await GuidedTutorialOverlay.show(
        context,
        steps: [
          GuidedTutorialStep(
            targetKey: _accountSettingsTutorialKey,
            icon: Icons.person_outline,
            title: strings.profileAccountTutorialTitle,
            body: strings.profileAccountTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _trainingSettingsTutorialKey,
            icon: Icons.fitness_center,
            title: strings.profileTrainingTutorialTitle,
            body: strings.profileTrainingTutorialBody,
          ),
          GuidedTutorialStep(
            targetKey: _dataSettingsTutorialKey,
            icon: Icons.storage_outlined,
            title: strings.profileDataTutorialTitle,
            body: strings.profileDataTutorialBody,
          ),
        ],
      );
      await _tutorialStore.markCompleted(TutorialIds.profileHome);
    } finally {
      _profileTutorialQueued = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final strings = AppLocalizations.of(context);
    if (context.usesExpressivePresentation) {
      return _buildExpressiveProfile(context, strings);
    }

    return SettingsPageScaffold(
      title: strings.profileTitle,
      subtitle: strings.profileSubtitle,
      icon: Icons.person,
      heroAccentColor: SettingsAccent.account,
      showBackButton: false,
      children: [
        KeyedSubtree(
          key: _accountSettingsTutorialKey,
          child: SettingsSection(
            title: strings.profileAccountSectionTitle,
            subtitle: strings.profileAccountSectionSubtitle,
            accentColor: SettingsAccent.account,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                key: AppTestKeys.profileUserInformation,
                icon: Icons.badge_outlined,
                iconColor: SettingsAccent.account,
                title: strings.profileUserInformationTitle,
                subtitle: strings.profileUserInformationSubtitle,
                onTap: () =>
                    _open(context, const UserInformationSettingsPage()),
              ),
              KeyedSubtree(
                key: AppTestKeys.profileUiAppearance,
                child: SettingsActionTile(
                  icon: Icons.palette_outlined,
                  iconColor: SettingsAccent.appearance,
                  title: strings.profileUiAppearanceTitle,
                  subtitle: strings.profileUiAppearanceSubtitle,
                  onTap: () => _open(context, const UIAppearanceSettingsPage()),
                ),
              ),
              SettingsActionTile(
                icon: Icons.school_outlined,
                iconColor: SettingsAccent.appearance,
                title: strings.profileGuidedTutorialsTitle,
                subtitle: strings.profileGuidedTutorialsSubtitle,
                onTap: () => _open(context, const TutorialsSettingsPage()),
              ),
            ]),
          ),
        ),
        KeyedSubtree(
          key: _trainingSettingsTutorialKey,
          child: SettingsSection(
            title: strings.profileTrainingSectionTitle,
            subtitle: strings.profileTrainingSectionSubtitle,
            accentColor: SettingsAccent.training,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                icon: Icons.fitness_center,
                iconColor: SettingsAccent.training,
                title: strings.profileGymWorkoutSettingsTitle,
                subtitle: strings.profileGymWorkoutSettingsSubtitle,
                onTap: () => _open(context, const GymExerciseSettingsPage()),
              ),
              KeyedSubtree(
                key: AppTestKeys.profileProgressSettings,
                child: SettingsActionTile(
                  icon: Icons.monitor_outlined,
                  iconColor: SettingsAccent.progress,
                  title: strings.profileProgressSettingsTitle,
                  subtitle: strings.profileProgressSettingsSubtitle,
                  onTap: () =>
                      _open(context, const MeasurementsTrendsSettingsPage()),
                ),
              ),
            ]),
          ),
        ),
        KeyedSubtree(
          key: _dataSettingsTutorialKey,
          child: SettingsSection(
            title: strings.profileDataSectionTitle,
            subtitle: strings.profileDataSectionSubtitle,
            accentColor: SettingsAccent.data,
            children: settingsTilesWithDividers(context, [
              SettingsActionTile(
                key: AppTestKeys.profileDatabaseSettings,
                icon: Icons.storage_outlined,
                iconColor: SettingsAccent.data,
                title: strings.profileDatabaseSettingsTitle,
                subtitle: strings.profileDatabaseSettingsSubtitle,
                onTap: () => _open(context, const DatabaseSettingsPage()),
              ),
              SettingsActionTile(
                icon: Icons.shield_outlined,
                iconColor: SettingsAccent.progress,
                title: strings.profileDiagnosticsTitle,
                subtitle: strings.profileDiagnosticsSubtitle,
                onTap: () => _open(context, const DiagnosticsSettingsPage()),
              ),
            ]),
          ),
        ),
        SettingsSection(
          title: strings.profileNutritionSectionTitle,
          subtitle: strings.profileNutritionSectionSubtitle,
          accentColor: SettingsAccent.muted,
          children: settingsTilesWithDividers(context, [
            _disabledNutritionTile(context),
          ]),
        ),
      ],
    );
  }

  Widget _buildExpressiveProfile(
    BuildContext context,
    AppLocalizations strings,
  ) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 24),
          children: [
            _ExpressiveProfileHero(
              title: strings.profileTitle,
              subtitle: strings.profileSubtitle,
            ),
            const SizedBox(height: 20),
            KeyedSubtree(
              key: _accountSettingsTutorialKey,
              child: _ExpressiveProfileSection(
                title: strings.profileAccountSectionTitle,
                subtitle: strings.profileAccountSectionSubtitle,
                accentColor: SettingsAccent.account,
                backgroundColor: _profileGroupSurface(
                  context,
                  SettingsAccent.account,
                ),
                children: settingsTilesWithDividers(context, [
                  _ExpressiveProfileFeatureTile(
                    key: AppTestKeys.profileUserInformation,
                    icon: Icons.badge_outlined,
                    accentColor: SettingsAccent.account,
                    title: strings.profileUserInformationTitle,
                    subtitle: strings.profileUserInformationSubtitle,
                    onTap: () =>
                        _open(context, const UserInformationSettingsPage()),
                  ),
                  KeyedSubtree(
                    key: AppTestKeys.profileUiAppearance,
                    child: SettingsActionTile(
                      icon: Icons.palette_outlined,
                      iconColor: SettingsAccent.appearance,
                      title: strings.profileUiAppearanceTitle,
                      subtitle: strings.profileUiAppearanceSubtitle,
                      onTap: () =>
                          _open(context, const UIAppearanceSettingsPage()),
                    ),
                  ),
                  SettingsActionTile(
                    icon: Icons.school_outlined,
                    iconColor: SettingsAccent.appearance,
                    title: strings.profileGuidedTutorialsTitle,
                    subtitle: strings.profileGuidedTutorialsSubtitle,
                    onTap: () => _open(context, const TutorialsSettingsPage()),
                  ),
                ]),
              ),
            ),
            KeyedSubtree(
              key: _trainingSettingsTutorialKey,
              child: _ExpressiveProfileSection(
                title: strings.profileTrainingSectionTitle,
                subtitle: strings.profileTrainingSectionSubtitle,
                accentColor: SettingsAccent.training,
                backgroundColor: _profileGroupSurface(
                  context,
                  SettingsAccent.training,
                ),
                children: settingsTilesWithDividers(context, [
                  SettingsActionTile(
                    icon: Icons.fitness_center,
                    iconColor: SettingsAccent.training,
                    title: strings.profileGymWorkoutSettingsTitle,
                    subtitle: strings.profileGymWorkoutSettingsSubtitle,
                    onTap: () =>
                        _open(context, const GymExerciseSettingsPage()),
                  ),
                  KeyedSubtree(
                    key: AppTestKeys.profileProgressSettings,
                    child: SettingsActionTile(
                      icon: Icons.monitor_outlined,
                      iconColor: SettingsAccent.progress,
                      title: strings.profileProgressSettingsTitle,
                      subtitle: strings.profileProgressSettingsSubtitle,
                      onTap: () => _open(
                        context,
                        const MeasurementsTrendsSettingsPage(),
                      ),
                    ),
                  ),
                ]),
              ),
            ),
            KeyedSubtree(
              key: _dataSettingsTutorialKey,
              child: _ExpressiveProfileSection(
                title: strings.profileDataSectionTitle,
                subtitle: strings.profileDataSectionSubtitle,
                accentColor: SettingsAccent.data,
                backgroundColor: _profileGroupSurface(
                  context,
                  SettingsAccent.data,
                ),
                children: settingsTilesWithDividers(context, [
                  SettingsActionTile(
                    key: AppTestKeys.profileDatabaseSettings,
                    icon: Icons.storage_outlined,
                    iconColor: SettingsAccent.data,
                    title: strings.profileDatabaseSettingsTitle,
                    subtitle: strings.profileDatabaseSettingsSubtitle,
                    onTap: () => _open(context, const DatabaseSettingsPage()),
                  ),
                  SettingsActionTile(
                    icon: Icons.shield_outlined,
                    iconColor: SettingsAccent.progress,
                    title: strings.profileDiagnosticsTitle,
                    subtitle: strings.profileDiagnosticsSubtitle,
                    onTap: () =>
                        _open(context, const DiagnosticsSettingsPage()),
                  ),
                ]),
              ),
            ),
            _ExpressiveProfileSection(
              title: strings.profileNutritionSectionTitle,
              subtitle: strings.profileNutritionSectionSubtitle,
              accentColor: SettingsAccent.muted,
              backgroundColor: context.surfaceTokens.dashboardSection,
              children: [_disabledNutritionTile(context)],
            ),
          ],
        ),
      ),
    );
  }

  void _open(BuildContext context, Widget page) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  Widget _disabledNutritionTile(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final strings = AppLocalizations.of(context);

    return Opacity(
      opacity: 0.48,
      child: SettingsActionTile(
        icon: Icons.restaurant_menu,
        iconColor: scheme.onSurfaceVariant,
        title: strings.profileDietNutritionSettingsTitle,
        subtitle: strings.profileDietNutritionSettingsSubtitle,
        trailing: SettingsStatusBadge(
          label: strings.profileLater,
          foregroundColor: scheme.onSurfaceVariant,
        ),
      ),
    );
  }
}

/// A Profile-specific identity anchor: it uses only the existing Profile copy
/// and icon, because this route does not load personal details for display.
class _ExpressiveProfileHero extends StatelessWidget {
  const _ExpressiveProfileHero({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;

    return TonosSurface(
      variant: TonosSurfaceVariant.panelRaised,
      color: scheme.primary,
      padding: const EdgeInsets.all(20),
      borderRadius: shapes.exerciseProgressHero,
      outlined: false,
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          PositionedDirectional(
            end: -48,
            top: -60,
            child: ExcludeSemantics(
              child: Container(
                width: 176,
                height: 176,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: scheme.onPrimary.withValues(alpha: 0.09),
                    width: 30,
                  ),
                ),
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final scale = MediaQuery.textScalerOf(context).scale(1);
              final stacked = scale > 1.15 || constraints.maxWidth < 330;
              final icon = Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: scheme.onPrimary.withValues(alpha: 0.14),
                  borderRadius: shapes.settingsIcon,
                ),
                child: Icon(
                  Icons.person_outline,
                  color: scheme.onPrimary,
                  size: 28,
                ),
              );
              final copy = Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        color: scheme.onPrimary,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: scheme.onPrimary.withValues(alpha: 0.88),
                    ),
                  ),
                ],
              );

              if (stacked) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [icon, const SizedBox(height: 12), copy],
                );
              }
              return Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  icon,
                  const SizedBox(width: 16),
                  Expanded(child: copy),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

/// A locally styled Profile category shell; action and state behavior stay in
/// the existing settings tiles and destination pages.
class _ExpressiveProfileSection extends StatelessWidget {
  const _ExpressiveProfileSection({
    required this.title,
    required this.subtitle,
    required this.accentColor,
    required this.backgroundColor,
    required this.children,
  });

  final String title;
  final String subtitle;
  final Color accentColor;
  final Color backgroundColor;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final shapes = context.shapeTokens;

    return Padding(
      padding: const EdgeInsets.only(bottom: 18),
      child: TonosSurface(
        variant: TonosSurfaceVariant.panelRaised,
        color: backgroundColor,
        borderRadius: shapes.workoutMetricDetails,
        outlined: true,
        clipBehavior: Clip.antiAlias,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 15, 16, 7),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 7,
                    height: 34,
                    margin: const EdgeInsetsDirectional.only(end: 11, top: 1),
                    decoration: BoxDecoration(
                      color: accentColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(2),
                        topRight: Radius.circular(9),
                        bottomRight: Radius.circular(2),
                        bottomLeft: Radius.circular(9),
                      ),
                    ),
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Semantics(
                          header: true,
                          child: Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: children),
            const SizedBox(height: 6),
          ],
        ),
      ),
    );
  }
}

Color _profileGroupSurface(BuildContext context, Color accent) =>
    Color.lerp(context.surfaceTokens.dashboardSection, accent, 0.18)!;

/// A featured route inside Profile's personal setup cluster.
class _ExpressiveProfileFeatureTile extends StatelessWidget {
  const _ExpressiveProfileFeatureTile({
    super.key,
    required this.icon,
    required this.accentColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final Color accentColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final shapes = context.shapeTokens;
    final foreground = scheme.onPrimaryContainer;

    return TonosSurface(
      variant: TonosSurfaceVariant.card,
      color: scheme.primaryContainer,
      borderRadius: shapes.exerciseProgressStat,
      outlined: false,
      padding: EdgeInsets.zero,
      margin: const EdgeInsets.all(9),
      child: ListTile(
        minVerticalPadding: 10,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14),
        leading: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.18),
            borderRadius: shapes.settingsAction,
          ),
          child: Icon(icon, color: foreground),
        ),
        title: Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleSmall?.copyWith(
            color: foreground,
            fontWeight: FontWeight.w900,
          ),
        ),
        subtitle: Text(
          subtitle,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.bodySmall?.copyWith(
            color: foreground.withValues(alpha: 0.82),
          ),
        ),
        trailing: Icon(Icons.chevron_right, color: foreground),
        onTap: onTap,
      ),
    );
  }
}
