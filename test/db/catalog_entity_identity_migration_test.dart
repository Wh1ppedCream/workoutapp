import 'package:env_test/db/schema.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  sqfliteFfiInit();

  test(
    'v62 adds durable IDs to shipped lookup tables without changing names',
    () async {
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);

      await Schema.createV1(db);
      await Schema.migrateV3(db);
      await Schema.migrateV4(db);
      await db.insert('equipment', {'name': 'Barbell'});
      await db.insert('muscles', {'name': 'Biceps Brachii'});
      await db.insert('stretch_definitions', {
        'name': 'Arm Circles',
        'description': 'Canonical description.',
      });

      await Schema.migrateV62(db);
      await Schema.migrateV62(db);

      for (final table in const [
        'equipment',
        'muscles',
        'stretch_definitions',
      ]) {
        final columns = await db.rawQuery("PRAGMA table_info('$table')");
        expect(columns.map((row) => row['name']), contains('catalog_id'));
        final indexes = await db.rawQuery("PRAGMA index_list('$table')");
        expect(
          indexes.any((row) => row['name'] == 'idx_${table}_catalog_id'),
          isTrue,
        );
      }

      expect((await db.query('equipment')).single['name'], 'Barbell');
      expect((await db.query('muscles')).single['name'], 'Biceps Brachii');
      expect(
        (await db.query('stretch_definitions')).single['name'],
        'Arm Circles',
      );
    },
  );
}
