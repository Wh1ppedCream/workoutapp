import 'package:env_test/services/tutorial_state_store.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const store = TutorialStateStore();

  setUp(() {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  test('skipAll hides every registered tutorial', () async {
    await store.skipAll();

    for (final tutorialId in TutorialIds.all) {
      expect(await store.isCompleted(tutorialId), isTrue);
    }
  });

  test('reset restores tutorials after skipAll', () async {
    await store.skipAll();
    await store.reset(TutorialIds.trainHome);

    expect(await store.isCompleted(TutorialIds.trainHome), isFalse);
    expect(await store.isCompleted(TutorialIds.catalogHome), isTrue);

    await store.resetAll();
    for (final tutorialId in TutorialIds.all) {
      expect(await store.isCompleted(tutorialId), isFalse);
    }
  });
}
