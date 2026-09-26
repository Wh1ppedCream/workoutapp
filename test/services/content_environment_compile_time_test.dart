import 'package:env_test/models/content_models.dart';
import 'package:env_test/services/content_environment_policy.dart';
import 'package:flutter_test/flutter_test.dart';

const expectedEnvironment = String.fromEnvironment(
  'TONOS_EXPECTED_CONTENT_ENVIRONMENT',
  defaultValue: 'development',
);
const expectedOverrides = bool.fromEnvironment(
  'TONOS_EXPECTED_CONTENT_OVERRIDES',
  defaultValue: true,
);

void main() {
  test('compile-time content policy matches the requested build contract', () {
    final buildPolicy = ContentBuildPolicy.fromCompileTime();
    expect(buildPolicy.targetEnvironmentId, expectedEnvironment);
    expect(buildPolicy.allowRuntimeOverrides, expectedOverrides);

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

    final selection = ContentEnvironmentPolicy(
      buildPolicy: buildPolicy,
    ).resolve(
      config: config,
      savedEnvironmentId:
          expectedEnvironment == 'production' ? 'development' : 'production',
      customExerciseMediaManifestUrl: 'https://preview.example/exercise.json',
    );

    expect(
      selection.environment.id,
      expectedOverrides
          ? (expectedEnvironment == 'production' ? 'development' : 'production')
          : expectedEnvironment,
    );
    expect(selection.allowRuntimeOverrides, expectedOverrides);
  });
}
