import 'package:env_test/models/content_models.dart';
import 'package:env_test/services/content_environment_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const config = ContentEnvironmentConfig(
    defaultEnvironmentId: 'development',
    environments: [
      ContentEnvironment(
        id: 'development',
        label: 'Development',
        exerciseMediaManifestUrl: 'https://dev.example/exercise.json',
        sharedMediaManifestUrl: 'https://dev.example/shared.json',
        allowedManifestHosts: ['dev.example'],
      ),
      ContentEnvironment(
        id: 'production',
        label: 'Production',
        exerciseMediaManifestUrl: 'https://prod.example/exercise.json',
        sharedMediaManifestUrl: 'https://prod.example/shared.json',
        allowedManifestHosts: ['prod.example'],
        isProduction: true,
      ),
    ],
  );

  ContentEnvironmentPolicy policy({
    required String target,
    required bool explicit,
    required bool allowOverrides,
    bool releaseMode = false,
  }) {
    return ContentEnvironmentPolicy(
      buildPolicy: ContentBuildPolicy(
        targetEnvironmentId: target,
        environmentWasExplicit: explicit,
        allowRuntimeOverrides: allowOverrides,
        isReleaseMode: releaseMode,
      ),
    );
  }

  test('locked builds ignore saved and custom runtime overrides', () {
    final selection = policy(
      target: 'production',
      explicit: true,
      allowOverrides: false,
      releaseMode: true,
    ).resolve(
      config: config,
      savedEnvironmentId: 'development',
      customExerciseMediaManifestUrl: 'https://preview.example/exercise.json',
    );

    expect(selection.environment.id, 'production');
    expect(
      selection.exerciseMediaManifestUrl,
      'https://prod.example/exercise.json',
    );
    expect(
      selection.sharedMediaManifestUrl,
      'https://prod.example/shared.json',
    );
    expect(selection.source, ContentEnvironmentSelectionSource.build);
    expect(selection.isLocked, isTrue);
  });

  test('unlocked builds preserve selected and custom developer behavior', () {
    final buildPolicy = policy(
      target: 'development',
      explicit: true,
      allowOverrides: true,
    );
    final selected = buildPolicy.resolve(
      config: config,
      savedEnvironmentId: 'production',
    );
    expect(selected.environment.id, 'production');
    expect(selected.source, ContentEnvironmentSelectionSource.savedPreference);

    final custom = buildPolicy.resolve(
      config: config,
      savedEnvironmentId: 'production',
      customExerciseMediaManifestUrl: 'https://preview.example/exercise.json',
    );
    expect(custom.environment.id, 'production');
    expect(
      custom.exerciseMediaManifestUrl,
      'https://preview.example/exercise.json',
    );
    expect(
      custom.source,
      ContentEnvironmentSelectionSource.customExerciseManifest,
    );
    expect(custom.isLocked, isFalse);
  });

  test('unknown and incorrectly marked production targets fail closed', () {
    expect(
      () => policy(
        target: 'missing',
        explicit: true,
        allowOverrides: false,
      ).resolve(config: config),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );

    const invalidProduction = ContentEnvironmentConfig(
      defaultEnvironmentId: 'production',
      environments: [
        ContentEnvironment(
          id: 'production',
          label: 'Production',
          exerciseMediaManifestUrl: 'https://prod.example/exercise.json',
          sharedMediaManifestUrl: 'https://prod.example/shared.json',
          allowedManifestHosts: ['prod.example'],
        ),
      ],
    );
    expect(
      () => policy(
        target: 'production',
        explicit: true,
        allowOverrides: false,
      ).resolve(config: invalidProduction),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });

  test('implicit builds cannot silently select production content', () {
    expect(
      () => policy(
        target: 'production',
        explicit: false,
        allowOverrides: false,
      ).resolve(config: config),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });

  test('the production marker cannot be assigned to another ID', () {
    const invalidProductionId = ContentEnvironmentConfig(
      defaultEnvironmentId: 'development',
      environments: [
        ContentEnvironment(
          id: 'development',
          label: 'Development',
          exerciseMediaManifestUrl: 'https://dev.example/exercise.json',
          sharedMediaManifestUrl: 'https://dev.example/shared.json',
          allowedManifestHosts: ['dev.example'],
        ),
        ContentEnvironment(
          id: 'release',
          label: 'Production',
          exerciseMediaManifestUrl: 'https://prod.example/exercise.json',
          sharedMediaManifestUrl: 'https://prod.example/shared.json',
          allowedManifestHosts: ['prod.example'],
          isProduction: true,
        ),
      ],
    );

    expect(
      () => policy(
        target: 'development',
        explicit: true,
        allowOverrides: false,
      ).resolve(config: invalidProductionId),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });

  test('an implicit release policy is locked to development', () {
    final buildPolicy = ContentBuildPolicy.fromCompileTime(releaseMode: true);

    expect(buildPolicy.targetEnvironmentId, 'development');
    expect(buildPolicy.environmentWasExplicit, isFalse);
    expect(buildPolicy.allowRuntimeOverrides, isFalse);
    expect(
      ContentEnvironmentPolicy(buildPolicy: buildPolicy)
          .resolve(
            config: config,
            savedEnvironmentId: 'production',
            customExerciseMediaManifestUrl:
                'https://preview.example/exercise.json',
          )
          .environment
          .id,
      'development',
    );
  });

  test('release builds cannot enable runtime overrides', () {
    expect(
      () => policy(
        target: 'development',
        explicit: true,
        allowOverrides: true,
        releaseMode: true,
      ).resolve(config: config),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });

  test('remote sync URIs must match the resolved environment', () {
    final lockedPolicy = policy(
      target: 'production',
      explicit: true,
      allowOverrides: false,
      releaseMode: true,
    );
    final selection = lockedPolicy.resolve(config: config);

    expect(
      () => lockedPolicy.requireSelectedManifestUri(
        selection,
        Uri.parse('https://prod.example/exercise.json'),
        sharedMedia: false,
      ),
      returnsNormally,
    );
    expect(
      () => lockedPolicy.requireSelectedManifestUri(
        selection,
        Uri.parse('https://other.example/exercise.json'),
        sharedMedia: false,
      ),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });

  test('manifest URLs require HTTPS and an environment allowlist', () {
    const invalid = ContentEnvironmentConfig(
      defaultEnvironmentId: 'development',
      environments: [
        ContentEnvironment(
          id: 'development',
          label: 'Development',
          exerciseMediaManifestUrl: 'https://other.example/exercise.json',
          sharedMediaManifestUrl: 'https://dev.example/shared.json',
          allowedManifestHosts: ['dev.example'],
        ),
        ContentEnvironment(
          id: 'production',
          label: 'Production',
          exerciseMediaManifestUrl: 'https://prod.example/exercise.json',
          sharedMediaManifestUrl: 'https://prod.example/shared.json',
          allowedManifestHosts: ['prod.example'],
          isProduction: true,
        ),
      ],
    );

    expect(
      () => policy(
        target: 'development',
        explicit: true,
        allowOverrides: false,
      ).resolve(config: invalid),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });

  test('manifest hosts remain exact and use standard HTTPS', () {
    for (final hosts in <List<String>>[
      ['DEV.EXAMPLE'],
      [' dev.example'],
      ['dev.example', 'dev.example'],
    ]) {
      final invalidHosts = ContentEnvironmentConfig(
        defaultEnvironmentId: 'development',
        environments: [
          ContentEnvironment(
            id: 'development',
            label: 'Development',
            exerciseMediaManifestUrl: 'https://dev.example/exercise.json',
            sharedMediaManifestUrl: 'https://dev.example/shared.json',
            allowedManifestHosts: hosts,
          ),
          const ContentEnvironment(
            id: 'production',
            label: 'Production',
            exerciseMediaManifestUrl: 'https://prod.example/exercise.json',
            sharedMediaManifestUrl: 'https://prod.example/shared.json',
            allowedManifestHosts: ['prod.example'],
            isProduction: true,
          ),
        ],
      );
      expect(
        () => policy(
          target: 'development',
          explicit: true,
          allowOverrides: false,
        ).resolve(config: invalidHosts),
        throwsA(isA<ContentEnvironmentPolicyException>()),
      );
    }

    const nonStandardPort = ContentEnvironmentConfig(
      defaultEnvironmentId: 'development',
      environments: [
        ContentEnvironment(
          id: 'development',
          label: 'Development',
          exerciseMediaManifestUrl: 'https://dev.example:444/exercise.json',
          sharedMediaManifestUrl: 'https://dev.example/shared.json',
          allowedManifestHosts: ['dev.example'],
        ),
        ContentEnvironment(
          id: 'production',
          label: 'Production',
          exerciseMediaManifestUrl: 'https://prod.example/exercise.json',
          sharedMediaManifestUrl: 'https://prod.example/shared.json',
          allowedManifestHosts: ['prod.example'],
          isProduction: true,
        ),
      ],
    );
    expect(
      () => policy(
        target: 'development',
        explicit: true,
        allowOverrides: false,
      ).resolve(config: nonStandardPort),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });

  test('all environments and host boundaries are validated at runtime', () {
    const invalidUnselectedEnvironment = ContentEnvironmentConfig(
      defaultEnvironmentId: 'development',
      environments: [
        ContentEnvironment(
          id: 'development',
          label: 'Development',
          exerciseMediaManifestUrl: 'https://dev.example/exercise.json',
          sharedMediaManifestUrl: 'https://dev.example/shared.json',
          allowedManifestHosts: ['dev.example'],
        ),
        ContentEnvironment(
          id: 'production',
          label: 'Production',
          exerciseMediaManifestUrl: 'http://prod.example/exercise.json',
          sharedMediaManifestUrl: 'https://prod.example/shared.json',
          allowedManifestHosts: ['prod.example'],
          isProduction: true,
        ),
      ],
    );
    expect(
      () => policy(
        target: 'development',
        explicit: true,
        allowOverrides: false,
      ).resolve(config: invalidUnselectedEnvironment),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );

    const overlappingHosts = ContentEnvironmentConfig(
      defaultEnvironmentId: 'development',
      environments: [
        ContentEnvironment(
          id: 'development',
          label: 'Development',
          exerciseMediaManifestUrl: 'https://shared.example/dev-exercise.json',
          sharedMediaManifestUrl: 'https://shared.example/dev-shared.json',
          allowedManifestHosts: ['shared.example'],
        ),
        ContentEnvironment(
          id: 'production',
          label: 'Production',
          exerciseMediaManifestUrl: 'https://shared.example/prod-exercise.json',
          sharedMediaManifestUrl: 'https://shared.example/prod-shared.json',
          allowedManifestHosts: ['shared.example'],
          isProduction: true,
        ),
      ],
    );
    expect(
      () => policy(
        target: 'development',
        explicit: true,
        allowOverrides: false,
      ).resolve(config: overlappingHosts),
      throwsA(isA<ContentEnvironmentPolicyException>()),
    );
  });

  test(
    'scope changes are explicit and locked first use resets old metadata',
    () {
      final unlockedSelection = policy(
        target: 'development',
        explicit: true,
        allowOverrides: true,
      ).resolve(config: config);
      final unlockedPolicy = policy(
        target: 'development',
        explicit: true,
        allowOverrides: true,
      );
      expect(
        unlockedPolicy.scopeAction(
          activeScope: null,
          selection: unlockedSelection,
        ),
        ContentEnvironmentScopeAction.adopt,
      );
      expect(
        unlockedPolicy.scopeAction(
          activeScope: unlockedSelection.cacheScope,
          selection: unlockedSelection,
        ),
        ContentEnvironmentScopeAction.none,
      );
      expect(
        unlockedPolicy.scopeAction(
          activeScope: 'content-v1:production:old',
          selection: unlockedSelection,
        ),
        ContentEnvironmentScopeAction.reset,
      );

      final lockedPolicy = policy(
        target: 'development',
        explicit: true,
        allowOverrides: false,
        releaseMode: true,
      );
      final lockedSelection = lockedPolicy.resolve(config: config);
      expect(
        lockedPolicy.scopeAction(activeScope: null, selection: lockedSelection),
        ContentEnvironmentScopeAction.reset,
      );
    },
  );
}
