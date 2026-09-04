// File: lib/models/selected_profile.dart

import 'package:flutter/foundation.dart';
import '../models/gym_models.dart';
import '../repositories/app_repository.dart';

/// Manages the list of gym profiles and the currently selected profile.
class SelectedProfile extends ChangeNotifier {
  static const String _selectedProfileStateKey = 'selected_gym_profile_id';
  final AppRepository _repo;
  bool _disposed = false;

  List<GymProfile> profiles = [];
  GymProfile? currentProfile;
  List<Map<String, dynamic>> equipment = [];

  SelectedProfile({required AppRepository repository}) : _repo = repository {
    _init();
  }

  Future<void> _init() async {
    await loadProfiles();
  }

  /// Loads profiles while preserving the current or persisted selection.
  Future<void> loadProfiles({int? preferredProfileId}) async {
    final previousProfileId = preferredProfileId ?? currentProfile?.id;
    profiles = await _repo.fetchAllProfiles();
    if (_disposed) return;
    if (profiles.isEmpty) {
      final allEquip = await _repo.fetchAllEquipment();
      if (_disposed) return;
      final defaultId = await _repo.saveGymProfileAtomic(
        existingProfile: null,
        name: 'General',
        equipmentIds: allEquip.map((item) => item.id).toSet(),
      );
      if (_disposed) return;
      profiles = await _repo.fetchAllProfiles();
      if (_disposed) return;
      preferredProfileId = defaultId;
    }

    final storedProfileId = int.tryParse(
      await _repo.getAppState(_selectedProfileStateKey) ?? '',
    );
    if (_disposed) return;
    final targetProfileId =
        preferredProfileId ?? previousProfileId ?? storedProfileId;
    currentProfile = profiles.firstWhere(
      (profile) => profile.id == targetProfileId,
      orElse: () => profiles.first,
    );
    await _loadEquipment();
    if (_disposed) return;
    await _persistSelection();
    if (_disposed) return;
    notifyListeners();
  }

  /// Selects a different profile.
  Future<void> selectProfile(GymProfile profile) async {
    currentProfile = profile;
    await _loadEquipment();
    if (_disposed) return;
    await _persistSelection();
    if (_disposed) return;
    notifyListeners();
  }

  /// Creates a new profile and selects it.
  Future<void> createProfile(String name) async {
    final id = await _repo.createProfile(name);
    await loadProfiles(preferredProfileId: id);
  }

  /// Updates an existing profile.
  Future<void> updateProfile(GymProfile profile) async {
    await _repo.updateProfile(profile);
    await loadProfiles(preferredProfileId: profile.id);
  }

  /// Deletes a profile and reverts selection if needed.
  Future<void> deleteProfile(int profileId) async {
    await _repo.deleteProfile(profileId);
    await loadProfiles();
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
    if (_disposed) return;
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

  Future<void> _persistSelection() async {
    await _repo.setAppState(
      _selectedProfileStateKey,
      currentProfile?.id?.toString(),
    );
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
