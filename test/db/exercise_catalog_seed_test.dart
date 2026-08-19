import 'package:env_test/db/schema.dart';
import 'package:env_test/db/seed.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  test(
    'fresh seeding assigns stable catalog identity independent of row order',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      await Schema.createTables(db);

      await Seed.seedLookupsAndExercises(db);

      final benchCable =
          (await db.query(
            'exercise_definitions',
            where: 'catalog_id = ?',
            whereArgs: ['tonos.exercise.0011'],
          )).single;
      expect(benchCable['name'], 'Bench Press - Cable Machine');
      expect(benchCable['legacy_media_id'], 11);
      expect(benchCable['catalog_status'], 'active');
      expect(
        benchCable['id'],
        isNot(11),
        reason:
            'Alphabetical display order must not become the durable media ID.',
      );
      expect((await db.query('exercise_catalog_state')).single['revision'], 1);
    },
  );
}
