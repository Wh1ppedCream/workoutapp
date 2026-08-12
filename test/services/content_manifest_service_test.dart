import 'package:env_test/services/content_manifest_service.dart';
import 'package:env_test/services/trusted_content_policy.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('bundled content configuration and manifests are usable', (
    tester,
  ) async {
    const service = ContentManifestService();

    final environments = await service.loadBundledContentEnvironments();
    final manifest = await service.loadBundledExerciseMediaManifest();
    final sharedManifest = await service.loadBundledSharedMediaManifest();

    expect(environments.environments, isNotEmpty);
    expect(environments.defaultEnvironment.hasExerciseMediaManifestUrl, isTrue);
    expect(manifest.namespace, 'exercise_media');
    expect(sharedManifest.namespace, 'shared_media');
    expect(manifest.version, greaterThan(0));
    expect(
      manifest.exerciseMedia.every(
        (entry) => entry.assets.every((asset) => asset.remoteUrl.isNotEmpty),
      ),
      isTrue,
    );
    for (final environment in environments.environments) {
      for (final value in [
        environment.exerciseMediaManifestUrl,
        environment.sharedMediaManifestUrl,
      ]) {
        if (value.isEmpty) continue;
        expect(
          () => TrustedContentPolicy.requireHttps(
            Uri.parse(value),
            description: 'Bundled content environment',
          ),
          returnsNormally,
        );
      }
    }
  });
}
