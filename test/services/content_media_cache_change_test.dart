import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/content_repository.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('exercise cache changes refresh only the matching thumbnail', () {
    const change = ContentMediaCacheChange.exercise(
      exerciseDefId: 42,
      thumbnail: true,
    );

    expect(change.matchesExercise(42, thumbnail: true), isTrue);
    expect(change.matchesExercise(42, thumbnail: false), isFalse);
    expect(change.matchesExercise(43, thumbnail: true), isFalse);
  });

  test('shared cache changes match their entity type, id, and role', () {
    const change = ContentMediaCacheChange.shared(
      entityType: SharedMediaEntityType.equipment,
      entityId: 9,
      thumbnail: true,
    );

    expect(
      change.matchesShared(SharedMediaEntityType.equipment, 9, thumbnail: true),
      isTrue,
    );
    expect(
      change.matchesShared(SharedMediaEntityType.bodypart, 9, thumbnail: true),
      isFalse,
    );
    expect(
      change.matchesShared(
        SharedMediaEntityType.equipment,
        9,
        thumbnail: false,
      ),
      isFalse,
    );
  });
}
