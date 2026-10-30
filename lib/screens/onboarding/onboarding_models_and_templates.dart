part of '../onboarding_flow.dart';

enum _WorkoutPlanSetupOption { manual, premade, generate, skip }

class _OnboardingPlanItem {
  final int presetId;
  final String name;
  final bool isAutomatic;
  final int listIndex;
  final Map<String, double> focusFrequencyMap;

  const _OnboardingPlanItem({
    required this.presetId,
    required this.name,
    required this.isAutomatic,
    required this.listIndex,
    required this.focusFrequencyMap,
  });
}

class _GymSpaceTemplate {
  final String id;
  final IconData icon;
  final Set<String> equipmentNames;
  final bool includeAllEquipment;
  final bool skipSetup;
  final bool highlighted;

  const _GymSpaceTemplate({
    required this.id,
    required this.icon,
    this.equipmentNames = const {},
    this.includeAllEquipment = false,
    this.skipSetup = false,
    this.highlighted = false,
  });
}

const _gymSpaceTemplates = <_GymSpaceTemplate>[
  _GymSpaceTemplate(id: 'custom', icon: Icons.tune, highlighted: true),
  _GymSpaceTemplate(id: 'skip', icon: Icons.fast_forward, skipSetup: true),
  _GymSpaceTemplate(
    id: 'commercial',
    icon: Icons.apartment,
    includeAllEquipment: true,
  ),
  _GymSpaceTemplate(
    id: 'home_gym',
    icon: Icons.home_work_outlined,
    equipmentNames: {
      'None',
      'Bodyweight',
      'Dumbbell',
      'Kettlebell',
      'Adjustable Bench',
      'Resistance Band',
      'Ab Roller',
      'Weight Plates',
    },
  ),
  _GymSpaceTemplate(
    id: 'calisthenics',
    icon: Icons.accessibility_new,
    equipmentNames: {
      'None',
      'Bodyweight',
      'Adjustable Bench',
      'Dip Bars',
      'Ab Roller',
      'Resistance Band',
      'Weight Plates',
      'Pull-Up Bar',
      'Gymnastics Rings',
    },
  ),
  _GymSpaceTemplate(
    id: 'powerlifting',
    icon: Icons.fitness_center,
    equipmentNames: {
      'Barbell',
      'Weight Plates',
      'Power Rack',
      'Adjustable Bench',
    },
  ),
  _GymSpaceTemplate(
    id: 'free_weights',
    icon: Icons.sports_gymnastics,
    equipmentNames: {
      'Dumbbell',
      'Weight Plates',
      'Adjustable Bench',
      'Bodyweight',
      'Kettlebell',
    },
  ),
];

final _skipGymSpaceTemplate = _gymSpaceTemplates.firstWhere(
  (template) => template.skipSetup,
);

class _FieldGap {
  static const small = SizedBox(height: 14);
}

class _OnboardingPage {
  final String id;
  final String label;
  final Widget Function() builder;

  const _OnboardingPage({
    required this.id,
    required this.label,
    required this.builder,
  });
}
