import 'package:env_test/db/active_plan_dao.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  sqfliteFfiInit();

  late Database db;

  setUp(() async {
    db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
    await db.execute('''
      CREATE TABLE active_plans (
        profile_id INTEGER NOT NULL,
        preset_id INTEGER NOT NULL,
        activated_at TEXT NOT NULL,
        PRIMARY KEY(profile_id, preset_id)
      )
    ''');
  });

  tearDown(() => db.close());

  test('replace, add, and remove keep profiles isolated', () async {
    await ActivePlanDao.replace(db, 1, {10, 20});
    await ActivePlanDao.add(db, 2, 30);
    await ActivePlanDao.add(db, 1, 20);

    expect(await ActivePlanDao.load(db, 1), {10, 20});
    expect(await ActivePlanDao.load(db, 2), {30});

    await ActivePlanDao.remove(db, 1, 10);
    expect(await ActivePlanDao.load(db, 1), {20});
    expect(await ActivePlanDao.load(db, 2), {30});
  });
}
