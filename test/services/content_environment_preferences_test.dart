import 'package:env_test/models/content_models.dart';
import 'package:env_test/services/content_environment_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const config = ContentEnvironmentConfig(
    defaultEnvironmentId: 'production',
    environments: [
      ContentEnvironment(
        id: 'development',
        label: 'Development',
        exerciseMediaManifestUrl: 'https://dev.example/manifest.json',
      ),
      ContentEnvironment(
        id: 'production',
        label: 'Production',
        exerciseMediaManifestUrl: 'https://prod.example/manifest.json',
        isProduction: true,
      ),
    ],
  );

  test(
    'uses the selected environment unless a custom manifest overrides it',
    () async {
      SharedPreferences.setMockInitialValues({});
      const preferences = ContentEnvironmentPreferences();

      expect(
        await preferences.loadExerciseMediaManifestUrl(config),
        'https://prod.example/manifest.json',
      );

      await preferences.saveSelectedEnvironment('development');
      expect(
        await preferences.loadExerciseMediaManifestUrl(config),
        'https://dev.example/manifest.json',
      );

      await preferences.saveCustomExerciseMediaManifestUrl(
        ' https://preview.example/manifest.json ',
      );
      expect(
        await preferences.loadExerciseMediaManifestUrl(config),
        'https://preview.example/manifest.json',
      );

      await preferences.saveCustomExerciseMediaManifestUrl('');
      expect(
        await preferences.loadExerciseMediaManifestUrl(config),
        'https://dev.example/manifest.json',
      );
    },
  );
}
