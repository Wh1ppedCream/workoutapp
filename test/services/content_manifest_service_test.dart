import 'package:env_test/services/content_manifest_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'bundled content configuration and exercise manifest are usable',
    (tester) async {
      const service = ContentManifestService();

      final environments = await service.loadBundledContentEnvironments();
      final manifest = await service.loadBundledExerciseMediaManifest();

      expect(environments.environments, isNotEmpty);
      expect(
        environments.defaultEnvironment.hasExerciseMediaManifestUrl,
        isTrue,
      );
      expect(manifest.namespace, 'exercise_media');
      expect(manifest.version, greaterThan(0));
      expect(
        manifest.exerciseMedia.every(
          (entry) => entry.assets.every((asset) => asset.remoteUrl.isNotEmpty),
        ),
        isTrue,
      );
    },
  );
}
