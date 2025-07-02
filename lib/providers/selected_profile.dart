// File: lib/models/selected_profile.dart

import 'package:flutter/foundation.dart';
import '../models/gym_models.dart';
import '../repositories/app_repository.dart';

/// Manages the list of gym profiles and the currently selected profile.
class SelectedProfile extends ChangeNotifier {
  final AppRepository _repo;

  List<GymProfile> profiles = [];
  GymProfile? currentProfile;
  List<Map<String, dynamic>> equipment = [];

  SelectedProfile({AppRepository? repository})
      : _repo = repository ?? AppRepository() {
    _init();
  }

  Future<void> _init() async {
    await loadProfiles();
  }

  /// Loads all profiles, seeds a default if none exist, and selects the first.
  Future<void> loadProfiles() async {
    profiles = await _repo.fetchAllProfiles();
    if (profiles.isEmpty) {
      final defaultId = await _repo.createProfile('General');
      final allEquip = await _repo.fetchAllEquipment();
      for (final eq in allEquip) {
        await _repo.addEquipmentToProfile(defaultId, eq.id);
      }
      profiles = await _repo.fetchAllProfiles();
    }
    currentProfile = profiles.first;
    await _loadEquipment();
    notifyListeners();
  }

  /// Selects a different profile.
  Future<void> selectProfile(GymProfile profile) async {
    currentProfile = profile;
    await _loadEquipment();
    notifyListeners();
  }

  /// Creates a new profile and selects it.
  Future<void> createProfile(String name) async {
    final id = await _repo.createProfile(name);
    await loadProfiles();
    currentProfile = profiles.firstWhere((p) => p.id == id);
    await _loadEquipment();
    notifyListeners();
  }

  /// Updates an existing profile.
  Future<void> updateProfile(GymProfile profile) async {
    await _repo.updateProfile(profile);
    await loadProfiles();
    currentProfile = profiles.firstWhere((p) => p.id == profile.id);
    await _loadEquipment();
    notifyListeners();
  }

  /// Deletes a profile and reverts selection if needed.
  Future<void> deleteProfile(int profileId) async {
    await _repo.deleteProfile(profileId);
    await loadProfiles();
    notifyListeners();
  }

  /// Toggles equipment assignment for the current profile.
  Future<void> toggleEquipment(int equipmentId) async {
    if (currentProfile == null) return;
    final exists = equipment.any((e) => e['id'] == equipmentId);
    if (exists) {
      await _repo.removeEquipmentFromProfile(currentProfile!.id!, equipmentId);
    } else {
      await _repo.addEquipmentToProfile(currentProfile!.id!, equipmentId);
    }
    await _loadEquipment();
    notifyListeners();
  }

  /// Loads the equipment list for the selected profile.
  Future<void> _loadEquipment() async {
    if (currentProfile == null) {
      equipment = [];
    } else {
      equipment = await _repo.fetchEquipmentForProfile(currentProfile!.id!);
    }
  }
}