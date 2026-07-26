// File: lib/db/personal_info_dao.dart
import 'package:sqflite/sqflite.dart';
import '../models/personal_info.dart';

class PersonalInfoDao {
  final DatabaseExecutor db;
  PersonalInfoDao(this.db);

  Future<PersonalInfo?> get() async {
    final rows = await db.query('personal_info', limit: 1);
    if (rows.isEmpty) return null;
    return PersonalInfo.fromMap(rows.first);
  }

  Future<int> upsert(PersonalInfo info) async {
    // if there's already a row, update; otherwise insert
    final existing = await get();
    if (existing == null) {
      return db.insert('personal_info', info.toMap());
    } else {
      return db.update(
        'personal_info',
        info.toMap(),
        where: 'id = ?',
        whereArgs: [existing.id],
      );
    }
  }
}
