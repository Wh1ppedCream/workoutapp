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
}
