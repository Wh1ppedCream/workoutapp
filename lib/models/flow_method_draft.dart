import 'preset_models.dart';

/// Typed values submitted by a rule editor, independent of its widgets/scope.
/// Parsing retains the existing defaults; dialogs still own their validation.
sealed class FlowMethodDraft {
  const FlowMethodDraft({required this.name});

  factory FlowMethodDraft.fromEditor({
    required String name,
    required MethodType type,
    String sign = '+',
    String factorText = '',
    String amountText = '',
    String weightText = '',
    String repsText = '',
    bool copyExistingSet = false,
    String copyIndexText = '',
    int? copyIndexOverride,
  }) {
    final trimmedName = name.trim();
    return switch (type) {
      MethodType.weight => WeightMethodDraft(
        name: trimmedName,
        sign: sign,
        factor: double.tryParse(factorText) ?? 1.0,
      ),
      MethodType.rep => RepMethodDraft(
        name: trimmedName,
        sign: sign,
        amount: int.tryParse(amountText) ?? 0,
      ),
      MethodType.addSet =>
        copyExistingSet
            ? CopiedSetMethodDraft(
                name: trimmedName,
                index: copyIndexOverride ?? int.tryParse(copyIndexText) ?? -1,
              )
            : ExplicitSetMethodDraft(
                name: trimmedName,
                weight: double.tryParse(weightText) ?? 0.0,
                reps: int.tryParse(repsText) ?? 0,
              ),
      MethodType.delSet => DeleteSetMethodDraft(name: trimmedName),
    };
  }

  final String name;
  MethodType get type;

  /// Encodes the existing persisted parameter keys without a data migration.
  Map<String, dynamic> toParameters();
}

final class WeightMethodDraft extends FlowMethodDraft {
  const WeightMethodDraft({
    required super.name,
    required this.sign,
    required this.factor,
  });

  final String sign;
  final double factor;

  @override
  MethodType get type => MethodType.weight;

  @override
  Map<String, dynamic> toParameters() => {'sign': sign, 'factor': factor};
}

final class RepMethodDraft extends FlowMethodDraft {
  const RepMethodDraft({
    required super.name,
    required this.sign,
    required this.amount,
  });

  final String sign;
  final int amount;

  @override
  MethodType get type => MethodType.rep;

  @override
  Map<String, dynamic> toParameters() => {'sign': sign, 'amount': amount};
}

final class ExplicitSetMethodDraft extends FlowMethodDraft {
  const ExplicitSetMethodDraft({
    required super.name,
    required this.weight,
    required this.reps,
  });

  final double weight;
  final int reps;

  @override
  MethodType get type => MethodType.addSet;

  @override
  Map<String, dynamic> toParameters() => {'weight': weight, 'reps': reps};
}

final class CopiedSetMethodDraft extends FlowMethodDraft {
  const CopiedSetMethodDraft({required super.name, required this.index});

  /// Persisted index: -1 means last; nonnegative indices are zero-based.
  /// Older negative values are retained for compatibility with existing rules.
  final int index;

  @override
  MethodType get type => MethodType.addSet;

  @override
  Map<String, dynamic> toParameters() => {'copyFromSetIndex': index};
}

final class DeleteSetMethodDraft extends FlowMethodDraft {
  const DeleteSetMethodDraft({required super.name});

  @override
  MethodType get type => MethodType.delSet;

  @override
  Map<String, dynamic> toParameters() => {};
}
