// File: lib/repositories/profile_repository.dart

import '../db/database_helper.dart';
import '../db/gym_profile_dao.dart';
import '../models/gym_models.dart';

/// Repository extension for managing Gym Profiles.
extension ProfileRepository on DatabaseHelper {
  /// Creates a new gym profile and returns its id.
  Future<int> createProfile(String name) async {
    final db = await database;
    final profile = GymProfile(id: null, name: name, createdAt: DateTime.now());
    return await GymProfileDao.insertProfile(db, profile);
  }

  /// Retrieves all gym profiles.
  Future<List<GymProfile>> fetchAllProfiles() async {
    final db = await database;
    return await GymProfileDao.getAllProfiles(db);
  }

  /// Updates an existing gym profile.
  Future<int> updateProfile(GymProfile profile) async {
    final db = await database;
    return await GymProfileDao.updateProfile(db, profile);
  }

  /// Deletes a gym profile by id.
  Future<int> deleteProfile(int profileId) async {
    final db = await database;
    return await GymProfileDao.deleteProfile(db, profileId);
  }

  /// Adds equipment to a gym profile.
  Future<void> addEquipmentToProfile(int profileId, int equipmentId) async {
    final db = await database;
    return await GymProfileDao.insertProfileEquipment(db, profileId, equipmentId);
  }

  /// Removes equipment from a gym profile.
  Future<void> removeEquipmentFromProfile(int profileId, int equipmentId) async {
    final db = await database;
    return await GymProfileDao.deleteProfileEquipment(db, profileId, equipmentId);
  }

  /// Fetches equipment for a specific gym profile.
  Future<List<Map<String, dynamic>>> fetchEquipmentForProfile(int profileId) async {
    final db = await database;
    return await GymProfileDao.getEquipmentForProfile(db, profileId);
  }
}
