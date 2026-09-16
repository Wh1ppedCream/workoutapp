import 'package:env_test/db/lookup_dao.dart';
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

  test('renaming a shipped lookup row turns it into a custom value', () async {
    final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    addTearDown(db.close);

    await Schema.createV1(db);
    await Schema.migrateV3(db);
    await Schema.migrateV62(db);
    final equipmentId = await db.insert('equipment', {
      'name': 'Barbell',
      'catalog_id': 'tonos.equipment.0005',
    });
    final muscleId = await db.insert('muscles', {
      'name': 'Biceps Brachii',
      'catalog_id': 'tonos.muscle.0006',
    });

    await LookupDao.updateEquipment(db, equipmentId, 'Barbell');
    expect(
      (await db.query(
        'equipment',
        where: 'id = ?',
        whereArgs: [equipmentId],
      )).single['catalog_id'],
      'tonos.equipment.0005',
    );
    await LookupDao.updateMuscle(db, muscleId, 'Biceps Brachii');
    expect(
      (await db.query(
        'muscles',
        where: 'id = ?',
        whereArgs: [muscleId],
      )).single['catalog_id'],
      'tonos.muscle.0006',
    );

    await LookupDao.updateEquipment(db, equipmentId, 'Custom Bar');
    await LookupDao.updateMuscle(db, muscleId, 'Custom Arm Muscle');

    expect(
      (await db.query(
        'equipment',
        where: 'id = ?',
        whereArgs: [equipmentId],
      )).single['catalog_id'],
      isNull,
    );
    expect(
      (await db.query(
        'muscles',
        where: 'id = ?',
        whereArgs: [muscleId],
      )).single['catalog_id'],
      isNull,
    );
  });
}
