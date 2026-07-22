import 'package:env_test/db/content_dao.dart';
import 'package:env_test/models/content_models.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE equipment (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE bodypart (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE muscles (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL UNIQUE
      )
    ''');
    await db.execute('''
      CREATE TABLE exercise_media (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        exercise_def_id INTEGER NOT NULL,
        media_type TEXT NOT NULL,
        remote_url TEXT NOT NULL,
        thumbnail_url TEXT,
        local_cache_path TEXT,
        local_thumbnail_path TEXT,
        title TEXT,
        sort_order INTEGER NOT NULL DEFAULT 0,
        created_at TEXT,
        updated_at TEXT
      )
    ''');
    await db.insert('equipment', {'id': 4, 'name': 'Barbell'});
    await ContentDao.ensureTables(db);
  });

  tearDown(() => db.close());

  ContentManifest manifest({
    required int version,
    required List<Map<String, Object?>> assets,
  }) {
    return ContentManifest.fromJson({
      'namespace': 'exercise_media',
      'version': version,
      'exercises': [
        {'exerciseId': 12, 'slug': 'bench_press', 'assets': assets},
      ],
    });
  }

  Map<String, Object?> asset(String id, String url) => {
    'assetId': id,
    'type': 'image',
    'url': url,
    'thumbnailUrl': '$url?thumb=1',
    'bytes': 12000,
    'width': 512,
    'height': 512,
  };

  test(
    'upserts a manifest, updates metadata, and removes stale assets',
    () async {
      await ContentDao.upsertExerciseMediaManifest(
        db,
        manifest(
          version: 1,
          assets: [
            asset('bench_v1', 'https://cdn.example/bench-v1.webp'),
            asset('bench_old', 'https://cdn.example/bench-old.webp'),
          ],
        ),
      );

      expect(await ContentDao.getManifestVersion(db, 'exercise_media'), 1);
      expect((await db.query('exercise_media')).length, 2);

      await ContentDao.upsertExerciseMediaManifest(
        db,
        manifest(
          version: 2,
          assets: [asset('bench_v1', 'https://cdn.example/bench-v2.webp')],
        ),
      );

      final rows = await db.query('exercise_media');
      expect(rows, hasLength(1));
      expect(rows.single['asset_id'], 'bench_v1');
      expect(rows.single['remote_url'], 'https://cdn.example/bench-v2.webp');
      expect(await ContentDao.getManifestVersion(db, 'exercise_media'), 2);
      expect(
        await ContentDao.getManifestStatus(db, 'exercise_media'),
        isNotNull,
      );
    },
  );

  test('tracks local cache paths and access timestamps for an asset', () async {
    await ContentDao.upsertExerciseMediaManifest(
      db,
      manifest(
        version: 1,
        assets: [asset('bench_v1', 'https://cdn.example/bench.webp')],
      ),
    );
    final row = (await db.query('exercise_media')).single;
    final item = ExerciseMediaManifestEntry.fromJson({
      'exerciseId': 12,
      'slug': 'bench_press',
      'assets': [asset('bench_v1', 'https://cdn.example/bench.webp')],
    }).assets.single.copyWith(id: row['id'] as int);

    await ContentDao.updateCachedMediaPath(
      db,
      item,
      thumbnail: true,
      localPath: '/cache/bench.webp',
    );
    await ContentDao.markMediaAccessed(db, item);

    final updated = (await db.query('exercise_media')).single;
    expect(updated['local_thumbnail_path'], '/cache/bench.webp');
    expect(updated['downloaded_at'], isNotNull);
    expect(updated['last_accessed_at'], isNotNull);
  });

  test(
    'upserts and caches shared media independently from exercise media',
    () async {
      SharedMediaManifest manifest({
        required int version,
        required List<Map<String, Object?>> assets,
      }) {
        return SharedMediaManifest.fromJson({
          'namespace': 'shared_media',
          'version': version,
          'entities': [
            {
              'entityType': 'equipment',
              'entityId': 4,
              'slug': 'barbell',
              'assets': assets,
            },
          ],
        });
      }

      Map<String, Object?> asset(String id, String url) => {
        'assetId': id,
        'type': 'thumbnail',
        'url': url,
        'width': 256,
        'height': 256,
      };

      await ContentDao.upsertSharedMediaManifest(
        db,
        manifest(
          version: 1,
          assets: [
            asset('barbell_v1', 'https://cdn.example/barbell-v1.webp'),
            asset('barbell_old', 'https://cdn.example/barbell-old.webp'),
          ],
        ),
      );

      var items = await ContentDao.getSharedMedia(
        db,
        SharedMediaEntityType.equipment,
        4,
      );
      expect(items, hasLength(2));

      await ContentDao.upsertSharedMediaManifest(
        db,
        manifest(
          version: 2,
          assets: [asset('barbell_v1', 'https://cdn.example/barbell-v2.webp')],
        ),
      );

      items = await ContentDao.getSharedMedia(
        db,
        SharedMediaEntityType.equipment,
        4,
      );
      expect(items, hasLength(1));
      expect(items.single.remoteUrl, 'https://cdn.example/barbell-v2.webp');

      await ContentDao.updateCachedSharedMediaPath(
        db,
        items.single,
        thumbnail: true,
        localPath: '/cache/barbell.webp',
      );
      await ContentDao.markSharedMediaAccessed(db, items.single);

      final row = (await db.query('shared_media')).single;
      expect(row['local_thumbnail_path'], '/cache/barbell.webp');
      expect(row['last_accessed_at'], isNotNull);
      expect(await ContentDao.getManifestVersion(db, 'shared_media'), 2);
    },
  );

  test(
    'resolves shared media by canonical slug instead of manifest source ID',
    () async {
      await db.delete('equipment');
      await db.insert('equipment', {'id': 91, 'name': 'Barbell'});
      await db.insert('shared_media', {
        'entity_type': 'equipment',
        'entity_id': 4,
        'asset_id': 'barbell_thumb_v1',
        'media_type': 'thumbnail',
        'remote_url': 'https://cdn.example/old-barbell.webp',
        'sort_order': 0,
      });

      final manifest = SharedMediaManifest.fromJson({
        'namespace': 'shared_media',
        'version': 2,
        'entities': [
          {
            // The source was created against another database's ID sequence.
            'entityType': 'equipment',
            'entityId': 4,
            'slug': 'barbell',
            'assets': [
              {
                'assetId': 'barbell_thumb_v1',
                'type': 'thumbnail',
                'url': 'https://cdn.example/barbell.webp',
              },
            ],
          },
        ],
      });

      await ContentDao.upsertSharedMediaManifest(db, manifest);

      final resolved = await ContentDao.getSharedMedia(
        db,
        SharedMediaEntityType.equipment,
        91,
      );
      expect(resolved, hasLength(1));
      expect(resolved.single.remoteUrl, 'https://cdn.example/barbell.webp');
      expect(
        await ContentDao.getSharedMedia(
          db,
          SharedMediaEntityType.equipment,
          4,
        ),
        isEmpty,
      );
      expect((await db.query('shared_media')), hasLength(1));
    },
  );
}
