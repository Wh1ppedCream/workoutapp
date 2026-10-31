import 'preset_models.dart';
import 'workout_models.dart';

/// Immutable read projections. Fields are decoded when consumed so partial
/// legacy projections and ignored unknown/orphan rows retain their behavior.
/// SQL/JSON keys stay here; consumers use named, typed properties.
abstract class _PresetReadRow {
  _PresetReadRow(Map<String, Object?> row)
    : _row = Map<String, Object?>.unmodifiable(row);

  final Map<String, Object?> _row;
}

final class PresetExerciseRow extends _PresetReadRow {
  PresetExerciseRow(super.row);

  int get id => _row['id'] as int;
  String? get type => _row['type'] as String?;
  int? get definitionId => _row['exercise_def_id'] as int?;
}

final class ExerciseDefinitionInfo {
  const ExerciseDefinitionInfo({this.name, this.equipmentName});

  factory ExerciseDefinitionInfo.fromRow(Map<String, Object?> row) =>
      ExerciseDefinitionInfo(
        name: row['name'] as String?,
        equipmentName: row['equipmentName'] as String?,
      );

  final String? name;
  final String? equipmentName;
}

final class PresetSetRow extends _PresetReadRow {
  PresetSetRow(super.row);

  int get id => _row['id'] as int;
  int? get parentSetId => _row['parent_set_id'] as int?;
  double get weight => (_row['weight'] as num).toDouble();
  int get reps => _row['reps'] as int;
}

final class PresetCardioRow extends _PresetReadRow {
  PresetCardioRow(super.row);

  String get name => _row['cardio_name'] as String;
  String? get note => _row['note'] as String?;
  int get plannedMinutes => (_row['planned_minutes'] as num).toInt();
  int get elapsedSeconds => (_row['elapsed_seconds'] as num).toInt();
}

final class PresetStretchRow extends _PresetReadRow {
  PresetStretchRow(super.row);

  StretchInstance toInstance() => StretchInstance(
    stretchId: _row['stretch_id'] as int?,
    isCustom: (_row['is_custom'] as int) == 1,
    customName: _row['custom_name'] as String?,
    customDesc: _row['custom_desc'] as String?,
    isChecked: false,
    orderIndex: (_row['order_index'] as num).toInt(),
  );
}

/// Defaults reflect the preset editor's read policy. Progression's raw API
/// retains its distinct validation/flag policy during this staged migration.
final class PresetAutoSettingsRow extends _PresetReadRow {
  PresetAutoSettingsRow(super.row);

  bool get isAutomatic => (_row['is_automatic'] as int? ?? 0) == 1;
  double get globalIncrement => (_row['global_increment'] as num).toDouble();
  bool get skipFirstSet => (_row['skip_first_set'] as int? ?? 1) == 1;
  bool get weightCheck => (_row['weight_check'] as int? ?? 1) == 1;
  bool get repCheck => (_row['rep_check'] as int? ?? 1) == 1;
  bool get volumeCheck => (_row['volume_check'] as int? ?? 0) == 1;
  bool get adjustAllSets => (_row['adjust_all_sets'] as int? ?? 0) != 0;
  bool get manualSelect => (_row['use_manual_select'] as int? ?? 0) == 1;
  String? get manualSelectionJson => _row['manual_selection_json'] as String?;
  ProgressionSuccessScope get successScope =>
      ProgressionSuccessScopeX.fromStorage(_row['success_count_mode']);
}

final class PresetExerciseAutoRow extends _PresetReadRow {
  PresetExerciseAutoRow(super.row);

  double? get incrementAmount => (_row['increment_amount'] as num?)?.toDouble();
  int? get lastSetIndex => _row['last_set_index'] as int?;
  String? get lastNode => _row['last_node'] as String?;
}

final class PresetSetAutoRow extends _PresetReadRow {
  PresetSetAutoRow(super.row);

  double? get incrementAmount => (_row['increment_amount'] as num?)?.toDouble();
}

/// Detached, immutable result of one database snapshot. Row projections preserve
/// ignored-field behavior; maps use persisted owner IDs, never UI positions.
final class PresetReadSnapshot {
  PresetReadSnapshot({
    required this.preset,
    required List<PresetExerciseRow> exercises,
    required Map<int, ExerciseDefinitionInfo> definitions,
    required Map<int, List<PresetSetRow>> sets,
    required Map<int, PresetCardioRow> cardio,
    required Map<int, List<PresetStretchRow>> stretches,
    required Map<int, String> stretchNames,
    required this.autoSettings,
    required Map<int, PresetExerciseAutoRow> exerciseAuto,
    required Map<int, PresetSetAutoRow> setAuto,
  }) : exercises = List.unmodifiable(exercises),
       definitions = Map.unmodifiable(definitions),
       sets = Map.unmodifiable({
         for (final entry in sets.entries)
           entry.key: List<PresetSetRow>.unmodifiable(entry.value),
       }),
       cardio = Map.unmodifiable(cardio),
       stretches = Map.unmodifiable({
         for (final entry in stretches.entries)
           entry.key: List<PresetStretchRow>.unmodifiable(entry.value),
       }),
       stretchNames = Map.unmodifiable(stretchNames),
       exerciseAuto = Map.unmodifiable(exerciseAuto),
       setAuto = Map.unmodifiable(setAuto);

  final PresetDefinition? preset;
  final List<PresetExerciseRow> exercises;
  final Map<int, ExerciseDefinitionInfo> definitions;
  final Map<int, List<PresetSetRow>> sets;
  final Map<int, PresetCardioRow> cardio;
  final Map<int, List<PresetStretchRow>> stretches;
  final Map<int, String> stretchNames;
  final PresetAutoSettingsRow? autoSettings;
  final Map<int, PresetExerciseAutoRow> exerciseAuto;
  final Map<int, PresetSetAutoRow> setAuto;
}
