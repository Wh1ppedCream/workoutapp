import 'package:env_test/models/content_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Content manifest models', () {
    test('uses the configured environment and safely handles missing IDs', () {
      final config = ContentEnvironmentConfig.fromJson({
        'defaultEnvironment': 'production',
        'environments': [
          {
            'id': 'development',
            'label': 'Development',
            'exerciseMediaManifestUrl': 'https://dev.example/manifest.json',
          },
          {
            'id': 'production',
            'label': 'Production',
            'exerciseMediaManifestUrl': 'https://prod.example/manifest.json',
            'isProduction': true,
          },
        ],
      });

      expect(config.defaultEnvironment.id, 'production');
      expect(config.environmentById('development')?.label, 'Development');
      expect(config.environmentById('missing'), isNull);
    });

    test('parses usable exercise assets and drops entries without URLs', () {
      final manifest = ContentManifest.fromJson({
        'namespace': 'exercise_media',
        'version': 7,
        'generatedAt': '2026-07-01T12:00:00.000Z',
        'exercises': [
          {
            'exerciseId': 42,
            'slug': 'barbell_squat',
            'assets': [
              {
                'assetId': 'barbell_squat_thumb_v1',
                'type': 'image',
                'url': 'https://cdn.example/squat.webp',
                'thumbnailUrl': 'https://cdn.example/squat-thumb.webp',
                'bytes': 12000,
                'width': 512,
                'height': 512,
              },
              {'assetId': 'invalid'},
            ],
          },
        ],
      });

      expect(manifest.version, 7);
      expect(manifest.generatedAt, DateTime.utc(2026, 7, 1, 12));
      expect(manifest.exerciseMedia, hasLength(1));
      expect(manifest.exerciseMedia.single.assets, hasLength(1));
      expect(manifest.exerciseMedia.single.assets.single.exerciseDefId, 42);
      expect(manifest.exerciseMedia.single.assets.single.width, 512);
    });
  });
}
