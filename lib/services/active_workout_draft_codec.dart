import 'dart:convert';

import '../models/workout_models.dart';

/// Detached data read from one persisted workout draft. Exercise instances are
/// freshly decoded and can subsequently become the live session's models.
class ActiveWorkoutDraft {
  ActiveWorkoutDraft({
    required List<WorkoutExercise> exercises,
    required List<CardType> cardTypes,
    required this.autoPresetId,
    required this.startedAt,
  }) : exercises = List.unmodifiable(exercises),
       cardTypes = List.unmodifiable(cardTypes);

  final List<WorkoutExercise> exercises;
  final List<CardType> cardTypes;
  final int? autoPresetId;
  final DateTime startedAt;
}

/// Owns the existing version-1 JSON format; no schema or data migration.
/// Invalid/future formats fail before any live state or stored draft changes.
class ActiveWorkoutDraftCodec {
  const ActiveWorkoutDraftCodec();

  ActiveWorkoutDraft decodeRow(Map<String, dynamic> row) {
    final payloadText = row['payload_json'];
    final startedText = row['started_at'];
    if (payloadText is! String || startedText is! String) {
      throw const FormatException('Invalid workout draft metadata.');
    }
    final payload = _map(jsonDecode(payloadText));
    final version = payload['version'];
    // Early drafts without a version use the same field layout as version 1.
    if (version != null && version != 1) {
      throw const FormatException('Unsupported workout draft version.');
    }
    final exercises = <WorkoutExercise>[];
    final types = <CardType>[];
    for (final raw in _list(payload['exercises'])) {
      final map = _map(raw);
      final typeName = _string(map['type']) ?? 'weight';
      final type = CardType.values.firstWhere(
        (value) => value.name == typeName,
        orElse: () =>
            throw const FormatException('Unsupported workout exercise type.'),
      );
      exercises.add(_exerciseFromJson(map, type));
      types.add(type);
    }
    return ActiveWorkoutDraft(
      exercises: exercises,
      cardTypes: types,
      autoPresetId: _integer(row['auto_preset_id']),
      startedAt: DateTime.parse(startedText).toLocal(),
    );
  }

  String encode({
    required List<WorkoutExercise> exercises,
    required List<CardType> cardTypes,
  }) {
    if (exercises.length != cardTypes.length) {
      throw ArgumentError('Exercise and card-type counts must match.');
    }
    return jsonEncode({
      'version': 1,
      'exercises': [
        for (var index = 0; index < exercises.length; index++)
          _exerciseToJson(exercises[index], cardTypes[index]),
      ],
    });
  }

  Map<String, dynamic> _exerciseToJson(
    WorkoutExercise exercise,
    CardType type,
  ) {
    final matches = switch (type) {
      CardType.weight => exercise is WeightExercise,
      CardType.cardio => exercise is CardioExercise,
      CardType.stretch => exercise is StretchExercise,
    };
    if (!matches) {
      throw ArgumentError('Workout exercise/card types must match.');
    }
    final map = <String, dynamic>{
      'type': type.name,
      'name': exercise.name,
      'equipment': exercise.equipment,
    };
    if (exercise is WeightExercise) {
      map.addAll({
        'sourcePresetExerciseId': exercise.sourcePresetExerciseId,
        'sets': exercise.sets.map(_setToJson).toList(),
        'changeSets': {
          for (final entry in exercise.changeSets.entries)
            entry.key.toString(): entry.value.map(_setToJson).toList(),
        },
        'completedParents': exercise.completedParents.toList(),
        'completedChildren': {
          for (final entry in exercise.completedChildren.entries)
            entry.key.toString(): entry.value.toList(),
        },
      });
    } else if (exercise is CardioExercise) {
      map.addAll({
        'cardioName': exercise.cardioName,
        'cardioNote': exercise.cardioNote,
        'plannedMinutes': exercise.plannedMinutes,
        'elapsedSeconds': exercise.elapsedSeconds,
      });
    } else if (exercise is StretchExercise) {
      map.addAll({
        'stretchInstances': exercise.stretchInstances
            .map((item) => item.toMap())
            .toList(),
        'completedStretchIndices': exercise.completedStretchIndices.toList(),
      });
    }
    return map;
  }

  WorkoutExercise _exerciseFromJson(Map<String, dynamic> map, CardType type) {
    final name = _string(map['name']) ?? '';
    final equipment = _string(map['equipment']) ?? '';
    return switch (type) {
      CardType.weight => WeightExercise(
        name: name,
        equipment: equipment,
        sourcePresetExerciseId: _integer(map['sourcePresetExerciseId']),
        sets: _list(map['sets']).map((raw) => _setFromJson(_map(raw))).toList(),
        changeSets: _indexed(
          map['changeSets'],
          (raw) => _list(raw).map((item) => _setFromJson(_map(item))).toList(),
        ),
        completedParents: _integers(map['completedParents']),
        completedChildren: _indexed(map['completedChildren'], _integers),
      ),
      CardType.cardio => CardioExercise(
        name: name,
        equipment: equipment,
        cardioName: _string(map['cardioName']),
        cardioNote: _string(map['cardioNote']),
        plannedMinutes: _integer(map['plannedMinutes']),
        elapsedSeconds: _integer(map['elapsedSeconds']),
      ),
      CardType.stretch => StretchExercise(
        name: name,
        equipment: equipment,
        stretchInstances: _list(map['stretchInstances']).map((raw) {
          final item = _map(raw);
          return StretchInstance(
            stretchId: _integer(item['stretch_id']),
            isCustom: _integer(item['is_custom']) == 1,
            customName: _string(item['custom_name']),
            customDesc: _string(item['custom_desc']),
            isChecked: _integer(item['is_checked']) == 1,
            orderIndex: _integer(item['order_index']) ?? 0,
          );
        }).toList(),
        completedStretchIndices: _integers(map['completedStretchIndices']),
      ),
    };
  }

  Map<String, dynamic> _setToJson(ExerciseSet set) => {
    'sourcePresetSetId': set.sourcePresetSetId,
    'weight': set.weight,
    'reps': set.reps,
  };

  ExerciseSet _setFromJson(Map<String, dynamic> map) => ExerciseSet(
    sourcePresetSetId: _integer(map['sourcePresetSetId']),
    weight: _number(map['weight']) ?? 0,
    reps: _integer(map['reps']) ?? 10,
  );

  Map<int, T> _indexed<T>(Object? raw, T Function(Object?) read) {
    final map = _map(raw ?? const <String, dynamic>{});
    return {
      for (final entry in map.entries)
        (int.tryParse(entry.key) ??
            (throw const FormatException('Invalid workout set index.'))): read(
          entry.value,
        ),
    };
  }

  Set<int> _integers(Object? raw) => _list(raw).map((value) {
    final integer = _integer(value);
    if (integer == null) {
      throw const FormatException('Missing workout set index.');
    }
    return integer;
  }).toSet();

  Map<String, dynamic> _map(Object? raw) {
    if (raw is! Map || raw.keys.any((key) => key is! String)) {
      throw const FormatException('Invalid workout draft object.');
    }
    return Map<String, dynamic>.from(raw);
  }

  List<dynamic> _list(Object? raw) {
    if (raw == null) return const [];
    if (raw is! List) {
      throw const FormatException('Invalid workout draft list.');
    }
    return raw;
  }

  String? _string(Object? raw) {
    if (raw == null || raw is String) return raw as String?;
    throw const FormatException('Invalid workout draft text.');
  }

  int? _integer(Object? raw) {
    if (raw == null || raw is int) return raw as int?;
    if (raw is double && raw.isFinite && raw == raw.truncateToDouble()) {
      return raw.toInt();
    }
    throw const FormatException('Invalid workout draft integer.');
  }

  double? _number(Object? raw) {
    if (raw == null) return null;
    if (raw is num && raw.isFinite) return raw.toDouble();
    throw const FormatException('Invalid workout draft number.');
  }
}
