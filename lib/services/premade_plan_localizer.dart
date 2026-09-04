import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import '../data/premade_training_plans.dart';

typedef PremadeOneHourDescriptionBuilder =
    String Function(String duration, String planName);

/// Locale-specific presentation for a built-in plan. Stored plan data remains
/// canonical; copied or user-created plans never pass through this resolver.
class LocalizedPremadePlan {
  const LocalizedPremadePlan({
    required this.sourceName,
    required this.groupName,
    required this.name,
    required this.description,
  });

  final String sourceName;
  final String groupName;
  final String name;
  final String description;

  factory LocalizedPremadePlan.fromPlan(PremadeTrainingPlan plan) {
    return LocalizedPremadePlan(
      sourceName: plan.sourceName,
      groupName: plan.planGroupName,
      name: plan.name,
      description: plan.description,
    );
  }
}

/// Resolves bundled built-in plan copy by immutable plan ID.
class PremadePlanLocalizer {
  PremadePlanLocalizer({Future<String> Function()? loader})
    : _loader = loader ?? (() => rootBundle.loadString(_assetPath));

  static const _assetPath = 'assets/premade_plan_localizations.json';
  static final instance = PremadePlanLocalizer();

  final Future<String> Function() _loader;
  Future<Map<String, Map<String, LocalizedPremadePlan>>>? _bundle;

  Future<LocalizedPremadePlan> resolve(
    PremadeTrainingPlan plan,
    Locale locale, {
    PremadeOneHourDescriptionBuilder? oneHourDescriptionBuilder,
    String? oneHourDurationLabel,
  }) async {
    final fallback = LocalizedPremadePlan.fromPlan(plan);
    const suffix = '_one_hour';
    if (locale.languageCode == 'en') {
      if (plan.id.endsWith(suffix) && oneHourDescriptionBuilder != null) {
        return LocalizedPremadePlan(
          sourceName: plan.sourceName,
          groupName: plan.planGroupName,
          name: plan.name,
          description: oneHourDescriptionBuilder(
            oneHourDurationLabel ?? '1',
            plan.name,
          ),
        );
      }
      return fallback;
    }
    final bundle = await (_bundle ??= _load());
    final localized = bundle[locale.languageCode];
    final direct = localized?[plan.catalogId];
    if (direct != null) return direct;
    if (plan.id.endsWith(suffix)) {
      final baseId = plan.id.substring(0, plan.id.length - suffix.length);
      final base = localized?['tonos.plan.$baseId'];
      if (base != null) {
        return LocalizedPremadePlan(
          sourceName: base.sourceName,
          groupName: base.groupName,
          name: base.name,
          description:
              oneHourDescriptionBuilder?.call(
                oneHourDurationLabel ?? '1',
                base.name,
              ) ??
              '1-hour version of ${base.name} using the main movements from the full template.',
        );
      }
    }
    return fallback;
  }

  Future<Map<String, Map<String, LocalizedPremadePlan>>> _load() async {
    final decoded = jsonDecode(await _loader());
    if (decoded is! Map ||
        decoded['version'] != 1 ||
        decoded['plans'] is! Map) {
      throw const FormatException('Invalid premade-plan localization bundle.');
    }
    final result = <String, Map<String, LocalizedPremadePlan>>{};
    for (final localeEntry in (decoded['plans'] as Map).entries) {
      final locale = localeEntry.key.toString();
      if (!_localePattern.hasMatch(locale)) {
        throw FormatException('Invalid premade-plan locale "$locale".');
      }
      if (localeEntry.value is! Map) continue;
      final plans = <String, LocalizedPremadePlan>{};
      for (final planEntry in (localeEntry.value as Map).entries) {
        if (planEntry.value is! Map) continue;
        final value = planEntry.value as Map;
        final source = value['sourceName']?.toString().trim();
        final group = value['groupName']?.toString().trim();
        final name = value['name']?.toString().trim();
        final description = value['description']?.toString().trim();
        if (source == null ||
            group == null ||
            name == null ||
            description == null ||
            source.isEmpty ||
            group.isEmpty ||
            name.isEmpty ||
            description.isEmpty) {
          throw FormatException(
            'Incomplete localized plan "${planEntry.key}".',
          );
        }
        plans[planEntry.key.toString()] = LocalizedPremadePlan(
          sourceName: source,
          groupName: group,
          name: name,
          description: description,
        );
      }
      result[locale] = plans;
    }
    return result;
  }

  static final _localePattern = RegExp(r'^[a-z]{2,3}(?:_[A-Z]{2})?$');
}
