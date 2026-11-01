import 'dart:convert';

import 'package:env_test/models/flow_method_draft.dart';
import 'package:env_test/models/preset_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'weight rules preserve the operation, numeric factor and trimmed name',
    () {
      final draft = FlowMethodDraft.fromEditor(
        name: '  Reduce weight  ',
        type: MethodType.weight,
        sign: '-',
        factorText: '1.25',
      );
      expect(draft, isA<WeightMethodDraft>());
      expect(draft.name, 'Reduce weight');
      expect(draft.type, MethodType.weight);
      expect(jsonEncode(draft.toParameters()), '{"sign":"-","factor":1.25}');
    },
  );

  test('rep rules retain integer amounts and exclude unrelated fields', () {
    final draft = FlowMethodDraft.fromEditor(
      name: 'Reps',
      type: MethodType.rep,
      sign: '+',
      amountText: '2',
      factorText: '9',
      weightText: '80',
      copyExistingSet: true,
    );
    expect(draft, isA<RepMethodDraft>());
    expect(draft.toParameters(), {'sign': '+', 'amount': 2});
    expect(draft.toParameters()['amount'], isA<int>());
  });

  test('explicit sets retain decimal weight and integer reps', () {
    final draft = FlowMethodDraft.fromEditor(
      name: 'Extra set',
      type: MethodType.addSet,
      weightText: '7.5',
      repsText: '8',
      copyIndexOverride: 3,
    );
    expect(draft, isA<ExplicitSetMethodDraft>());
    expect(draft.toParameters(), {'weight': 7.5, 'reps': 8});
  });

  for (final index in [-2, -1, 0, 5]) {
    test(
      'legacy copied-set index $index is preserved without reinterpretation',
      () {
        final draft = FlowMethodDraft.fromEditor(
          name: 'Copy',
          type: MethodType.addSet,
          copyExistingSet: true,
          copyIndexText: '$index',
          weightText: '90',
          repsText: '10',
        );
        expect(draft, isA<CopiedSetMethodDraft>());
        expect(draft.toParameters(), {'copyFromSetIndex': index});
      },
    );
  }

  test('the Expressive copy choice overrides the legacy text field', () {
    final draft = FlowMethodDraft.fromEditor(
      name: 'Copy set 3',
      type: MethodType.addSet,
      copyExistingSet: true,
      copyIndexText: '-1',
      copyIndexOverride: 2,
    );
    expect(draft.toParameters(), {'copyFromSetIndex': 2});
  });

  for (final invalid in ['', 'invalid']) {
    test('existing numeric fallbacks remain for "$invalid"', () {
      FlowMethodDraft parse(MethodType type, {bool copy = false}) =>
          FlowMethodDraft.fromEditor(
            name: 'Defaults',
            type: type,
            factorText: invalid,
            amountText: invalid,
            weightText: invalid,
            repsText: invalid,
            copyExistingSet: copy,
            copyIndexText: invalid,
          );
      expect(parse(MethodType.weight).toParameters(), {
        'sign': '+',
        'factor': 1.0,
      });
      expect(parse(MethodType.rep).toParameters(), {'sign': '+', 'amount': 0});
      expect(parse(MethodType.addSet).toParameters(), {
        'weight': 0.0,
        'reps': 0,
      });
      expect(parse(MethodType.addSet, copy: true).toParameters(), {
        'copyFromSetIndex': -1,
      });
    });
  }

  test('fractional integer fields keep their previous fallback', () {
    final draft = FlowMethodDraft.fromEditor(
      name: 'Reps',
      type: MethodType.rep,
      amountText: '2.5',
    );
    expect(draft.toParameters()['amount'], 0);
  });

  test('delete-set parameters remain an empty JSON object', () {
    final draft = FlowMethodDraft.fromEditor(
      name: 'Delete',
      type: MethodType.delSet,
      sign: '-',
      factorText: '2',
      amountText: '3',
      copyExistingSet: true,
      copyIndexOverride: 2,
    );
    expect(draft, isA<DeleteSetMethodDraft>());
    expect(draft.type, MethodType.delSet);
    expect(jsonEncode(draft.toParameters()), '{}');
  });

  test('parsing leaves name validation to the existing dialogs', () {
    expect(
      FlowMethodDraft.fromEditor(name: '   ', type: MethodType.delSet).name,
      isEmpty,
    );
  });

  test('parsing retains non-finite values for existing caller validation', () {
    final draft = FlowMethodDraft.fromEditor(
      name: 'Factor',
      type: MethodType.weight,
      factorText: 'NaN',
    ) as WeightMethodDraft;
    expect(draft.factor.isNaN, isTrue);
  });

  test('parameter maps are detached from immutable draft values', () {
    const draft = ExplicitSetMethodDraft(name: 'Extra', weight: 10, reps: 8);
    final map = draft.toParameters();
    map['reps'] = 999;
    expect(draft.reps, 8);
    expect(draft.toParameters(), {'weight': 10.0, 'reps': 8});
  });
}
