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
            'sharedMediaManifestUrl': 'https://dev.example/shared-media.json',
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
      expect(
        config.environmentById('development')?.hasSharedMediaManifestUrl,
        isTrue,
      );
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
                'sha256': List.filled(64, 'a').join(),
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

    test('parses shared media by type and source entity ID', () {
      final manifest = SharedMediaManifest.fromJson({
        'namespace': 'shared_media',
        'version': 3,
        'entities': [
          {
            'entityType': 'equipment',
            'entityId': 4,
            'slug': 'barbell',
            'assets': [
              {
                'assetId': 'barbell_thumb_v1',
                'type': 'thumbnail',
                'url': 'https://cdn.example/equipment/barbell.webp',
                'width': 256,
                'height': 256,
              },
            ],
          },
        ],
        'bodyparts': [
          {
            'entityId': 3,
            'slug': 'chest',
            'assets': [
              {
                'assetId': 'chest_thumb_v1',
                'type': 'thumbnail',
                'url': 'https://cdn.example/bodyparts/chest.webp',
              },
            ],
          },
        ],
      });

      expect(manifest.namespace, 'shared_media');
      expect(manifest.entities, hasLength(2));
      expect(
        manifest.entities.first.entityType,
        SharedMediaEntityType.equipment,
      );
      expect(manifest.entities.first.entityId, 4);
      expect(manifest.entities.last.entityType, SharedMediaEntityType.bodypart);
    });

    test('ignores shared media entries without a valid source entity ID', () {
      final manifest = SharedMediaManifest.fromJson({
        'namespace': 'shared_media',
        'version': 1,
        'entities': [
          {
            'entityType': 'equipment',
            'entityId': 0,
            'slug': 'invalid',
            'assets': const [],
          },
        ],
      });

      expect(manifest.entities, isEmpty);
    });
  });
}
