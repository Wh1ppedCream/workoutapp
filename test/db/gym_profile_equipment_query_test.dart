import 'package:env_test/db/gym_profile_dao.dart';
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
        id INTEGER PRIMARY KEY,
        name TEXT NOT NULL,
        catalog_id TEXT
      )
    ''');
    await db.execute('''
      CREATE TABLE profile_equipment (
        profile_id INTEGER NOT NULL,
        equipment_id INTEGER NOT NULL,
        PRIMARY KEY(profile_id, equipment_id)
      )
    ''');
  });

  tearDown(() => db.close());

  test('profile equipment hydration keeps the stable catalog ID', () async {
    await db.insert('equipment', {
      'id': 5,
      'name': 'Barbell',
      'catalog_id': 'tonos.equipment.0005',
    });
    await db.insert('profile_equipment', {'profile_id': 1, 'equipment_id': 5});

    final rows = await GymProfileDao.getEquipmentForProfile(db, 1);

    expect(rows, hasLength(1));
    expect(rows.single['id'], 5);
    expect(rows.single['name'], 'Barbell');
    expect(rows.single['catalog_id'], 'tonos.equipment.0005');
  });
}
