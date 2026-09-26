import 'package:env_test/models/content_models.dart';
import 'package:env_test/services/content_environment_policy.dart';
import 'package:env_test/services/content_environment_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = ContentEnvironmentConfig(
    defaultEnvironmentId: 'development',
    environments: [
      ContentEnvironment(
        id: 'development',
        label: 'Development',
        exerciseMediaManifestUrl: 'https://dev.example/manifest.json',
        sharedMediaManifestUrl: 'https://dev.example/shared.json',
        allowedManifestHosts: ['dev.example'],
      ),
      ContentEnvironment(
        id: 'production',
        label: 'Production',
        exerciseMediaManifestUrl: 'https://prod.example/manifest.json',
        sharedMediaManifestUrl: 'https://prod.example/shared.json',
        allowedManifestHosts: ['prod.example'],
        isProduction: true,
      ),
    ],
  );

  ContentEnvironmentPreferences preferences({required bool allowOverrides}) {
    return ContentEnvironmentPreferences(
      policy: ContentEnvironmentPolicy(
        buildPolicy: ContentBuildPolicy(
          targetEnvironmentId: 'development',
          environmentWasExplicit: true,
          allowRuntimeOverrides: allowOverrides,
          isReleaseMode: !allowOverrides,
        ),
      ),
    );
  }

  test(
    'uses selected and custom environments only when overrides are enabled',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = preferences(allowOverrides: true);

      expect(
        await store.loadExerciseMediaManifestUrl(config),
        'https://dev.example/manifest.json',
      );

      await store.saveSelectedEnvironment('production');
      expect(
        await store.loadExerciseMediaManifestUrl(config),
        'https://prod.example/manifest.json',
      );
      expect(
        await store.loadSharedMediaManifestUrl(config),
        'https://prod.example/shared.json',
      );

      await store.saveCustomExerciseMediaManifestUrl(
        ' https://preview.example/manifest.json ',
      );
      expect(
        await store.loadExerciseMediaManifestUrl(config),
        'https://preview.example/manifest.json',
      );

      await store.saveCustomExerciseMediaManifestUrl('');
      expect(
        await store.loadExerciseMediaManifestUrl(config),
        'https://prod.example/manifest.json',
      );
    },
  );

  test(
    'locked builds ignore persisted overrides and reject new ones',
    () async {
      SharedPreferences.setMockInitialValues({
        ContentEnvironmentPreferences.exerciseMediaEnvironmentKey: 'production',
        ContentEnvironmentPreferences.exerciseMediaManifestUrlKey:
            'https://preview.example/manifest.json',
      });
      final store = preferences(allowOverrides: false);

      final selection = await store.loadEffectiveEnvironment(config);
      expect(selection.environment.id, 'development');
      expect(
        selection.exerciseMediaManifestUrl,
        'https://dev.example/manifest.json',
      );
      expect(selection.isLocked, isTrue);

      await expectLater(
        store.saveSelectedEnvironment('production'),
        throwsA(isA<ContentEnvironmentPolicyException>()),
      );
      await expectLater(
        store.saveCustomExerciseMediaManifestUrl(
          'https://preview.example/manifest.json',
        ),
        throwsA(isA<ContentEnvironmentPolicyException>()),
      );
    },
  );

  test(
    'persists the active content scope independently from overrides',
    () async {
      SharedPreferences.setMockInitialValues({});
      final store = preferences(allowOverrides: false);

      expect(await store.loadActiveContentScope(), isNull);
      await store.saveActiveContentScope('content-v1:development:test');
      expect(
        await store.loadActiveContentScope(),
        'content-v1:development:test',
      );
    },
  );

  test('custom manifest overrides require credential-free HTTPS', () async {
    SharedPreferences.setMockInitialValues({});
    final store = preferences(allowOverrides: true);

    await expectLater(
      store.saveCustomExerciseMediaManifestUrl('http://preview.example/a.json'),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
    await expectLater(
      store.saveCustomExerciseMediaManifestUrl(
        'https://user:secret@preview.example/a.json',
      ),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
    await expectLater(
      store.saveCustomExerciseMediaManifestUrl(
        'https://preview.example:444/a.json',
      ),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });
}
