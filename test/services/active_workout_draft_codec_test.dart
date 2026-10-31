import 'dart:convert';

import 'package:env_test/models/models.dart';
import 'package:env_test/services/active_workout_draft_codec.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const codec = ActiveWorkoutDraftCodec();
  test('the existing v1 weight/cardio/stretch payload round-trips with all IDs and completion state', () {
    final draft = codec.decodeRow(_row(_legacyPayload()));
    expect(draft.startedAt.toUtc(), DateTime.utc(2026, 10, 31, 10, 30));
    expect(draft.autoPresetId, 7);
    expect(draft.cardTypes, [
      CardType.weight,
      CardType.cardio,
      CardType.stretch,
    ]);
    final weight = draft.exercises[0] as WeightExercise;
    expect(weight.sourcePresetExerciseId, 12);
    expect(weight.sets.single.sourcePresetSetId, 101);
    expect(weight.sets.single.weight, 100);
    expect(weight.changeSets[0]!.single.sourcePresetSetId, 102);
    expect(weight.completedParents, {0});
    expect(weight.completedChildren, {
      0: {0},
    });
    final cardio = draft.exercises[1] as CardioExercise;
    expect(cardio.plannedMinutes, 20);
    expect(cardio.elapsedSeconds, 35);
    expect(cardio.cardioNote, 'Easy pace');
    final stretch = draft.exercises[2] as StretchExercise;
    expect(stretch.stretchInstances.single.isCustom, isTrue);
    expect(stretch.stretchInstances.single.orderIndex, 3);
    expect(stretch.completedStretchIndices, {0});
    expect(
      jsonDecode(
        codec.encode(exercises: draft.exercises, cardTypes: draft.cardTypes),
      ),
      _legacyPayload(),
    );
    expect(() => draft.cardTypes.clear(), throwsUnsupportedError);
    expect(() => draft.exercises.clear(), throwsUnsupportedError);
  });

  test('unversioned legacy drafts retain optional-field defaults', () {
    final draft = codec.decodeRow(
      _row({
        'exercises': [
          {
            'sets': [{}],
          },
        ],
      }),
    );
    final exercise = draft.exercises.single as WeightExercise;
    expect(exercise.name, '');
    expect(exercise.equipment, '');
    expect(exercise.sets.single.weight, 0);
    expect(exercise.sets.single.reps, 10);
    expect(exercise.sourcePresetExerciseId, isNull);
  });

  test('empty workouts and unknown additive fields remain supported', () {
    final draft = codec.decodeRow(
      _row({'version': 1, 'futureMetadata': 'ignored', 'exercises': []}),
    );
    expect(draft.exercises, isEmpty);
    expect(draft.cardTypes, isEmpty);
  });

  final malformed = <String, Object>{
    'future version': {'version': 2, 'exercises': []},
    'string version': {'version': '1', 'exercises': []},
    'wrong root shape': [],
    'wrong exercise list': {'version': 1, 'exercises': {}},
    'non-object exercise': {
      'version': 1,
      'exercises': [7],
    },
    'unknown exercise type': {
      'version': 1,
      'exercises': [
        {'type': 'future-type'},
      ],
    },
    'non-object set': {
      'version': 1,
      'exercises': [
        {
          'sets': [null],
        },
      ],
    },
    'invalid completion index': {
      'version': 1,
      'exercises': [
        {
          'completedParents': ['bad'],
        },
      ],
    },
    'invalid child-set index': {
      'version': 1,
      'exercises': [
        {
          'changeSets': {'bad': []},
        },
      ],
    },
    'fractional reps': {
      'version': 1,
      'exercises': [
        {
          'sets': [
            {'reps': 2.5},
          ],
        },
      ],
    },
  };
  for (final entry in malformed.entries) {
    test('${entry.key} is rejected without silently dropping workout data', () {
      expect(() => codec.decodeRow(_row(entry.value)), throwsFormatException);
    });
  }

  test('truncated JSON and invalid metadata are rejected', () {
    expect(
      () => codec.decodeRow({..._row({}), 'payload_json': '{"version":'}),
      throwsFormatException,
    );
    expect(
      () => codec.decodeRow({..._row({}), 'started_at': 'invalid'}),
      throwsFormatException,
    );
    expect(
      () => codec.decodeRow({..._row({}), 'auto_preset_id': 2.5}),
      throwsFormatException,
    );
  });

  test('encoding rejects mismatched exercise/card lists instead of corrupting a draft', () {
    final exercise = WeightExercise(name: 'Squat', equipment: '', sets: []);
    expect(
      () => codec.encode(exercises: [exercise], cardTypes: []),
      throwsArgumentError,
    );
    expect(
      () => codec.encode(exercises: [exercise], cardTypes: [CardType.cardio]),
      throwsArgumentError,
    );
  });
}

Map<String, dynamic> _row(Object payload) => {
  'started_at': '2026-10-31T10:30:00Z',
  'auto_preset_id': 7,
  'payload_json': jsonEncode(payload),
};

Map<String, dynamic> _legacyPayload() => {
  'version': 1,
  'exercises': [
    {
      'type': 'weight',
      'name': 'Squat',
      'equipment': 'Barbell',
      'sourcePresetExerciseId': 12,
      'sets': [
        {'sourcePresetSetId': 101, 'weight': 100.0, 'reps': 5},
      ],
      'changeSets': {
        '0': [
          {'sourcePresetSetId': 102, 'weight': 80.0, 'reps': 10},
        ],
      },
      'completedParents': [0],
      'completedChildren': {
        '0': [0],
      },
    },
    {
      'type': 'cardio',
      'name': 'Row',
      'equipment': 'Erg',
      'cardioName': 'Rowing',
      'cardioNote': 'Easy pace',
      'plannedMinutes': 20,
      'elapsedSeconds': 35,
    },
    {
      'type': 'stretch',
      'name': 'Stretch',
      'equipment': '',
      'stretchInstances': [
        {
          'stretch_id': null,
          'is_custom': 1,
          'custom_name': 'Custom stretch',
          'custom_desc': 'Hold',
          'is_checked': 1,
          'order_index': 3,
        },
      ],
      'completedStretchIndices': [0],
    },
  ],
};
