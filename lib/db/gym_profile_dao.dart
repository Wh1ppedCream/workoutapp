// File: lib/db/gym_profile_dao.dart

import 'package:sqflite/sqflite.dart';
import '../models/gym_models.dart';

/// DAO for CRUD operations on gym_profiles and its equipment join.
class GymProfileDao {
  /// Inserts a new profile and returns its generated id.
  static Future<int> insertProfile(Database db, GymProfile profile) {
    return db.insert('gym_profiles', profile.toMap());
  }

  /// Retrieves all profiles, newest first.
  static Future<List<GymProfile>> getAllProfiles(Database db) async {
    final maps = await db.query('gym_profiles', orderBy: 'created_at DESC');
    return maps.map((m) => GymProfile.fromMap(m)).toList();
  }

  /// Updates an existing profile by id.
  static Future<int> updateProfile(Database db, GymProfile profile) {
    return db.update(
      'gym_profiles',
      profile.toMap(),
      where: 'id = ?',
      whereArgs: [profile.id],
    );
  }

  /// Deletes a profile (cascades to profile_equipment).
  static Future<int> deleteProfile(Database db, int id) {
    return db.delete('gym_profiles', where: 'id = ?', whereArgs: [id]);
  }

  /// Adds an equipment relation to a profile.
  static Future<void> insertProfileEquipment(
    Database db,
    int profileId,
    int equipmentId,
  ) async {
    await db.insert('profile_equipment', {
      'profile_id': profileId,
      'equipment_id': equipmentId,
    }, conflictAlgorithm: ConflictAlgorithm.ignore);
  }

  /// Removes an equipment relation from a profile.
  static Future<void> deleteProfileEquipment(
    Database db,
    int profileId,
    int equipmentId,
  ) async {
    await db.delete(
      'profile_equipment',
      where: 'profile_id = ? AND equipment_id = ?',
      whereArgs: [profileId, equipmentId],
    );
  }

  /// Fetches equipment entries, including the stable catalog identity, for a profile.
  static Future<List<Map<String, dynamic>>> getEquipmentForProfile(
    Database db,
    int profileId,
  ) {
    return db.rawQuery(
      '''
      SELECT e.id, e.name, e.catalog_id
      FROM equipment e
      JOIN profile_equipment pe ON e.id = pe.equipment_id
      WHERE pe.profile_id = ?
      ''',
      [profileId],
    );
  }
}
