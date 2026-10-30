// File: lib/models/selected_profile.dart

import 'package:flutter/foundation.dart';

import '../models/gym_models.dart';
import '../repositories/app_repository.dart';
import '../utils/serial_async_queue.dart';

/// Manages the list of gym profiles and the currently selected profile.
class SelectedProfile extends ChangeNotifier {
  static const String _selectedProfileStateKey = 'selected_gym_profile_id';
  final AppRepository _repo;
  late final Future<void> ready;
  bool _disposed = false;
  int _selectionVersion = 0;
  final _selectionWrites = SerialAsyncQueue();
  final _equipmentWrites = SerialAsyncQueue();

  bool _isCurrent(int version) => !_disposed && version == _selectionVersion;

  List<GymProfile> profiles = [];
  GymProfile? currentProfile;
  List<Map<String, dynamic>> equipment = [];

  SelectedProfile({required AppRepository repository}) : _repo = repository {
    ready = _init();
  }

  Future<void> _init() async {
    await loadProfiles();
  }

  /// Loads profiles while preserving the current or persisted selection.
  Future<void> loadProfiles({int? preferredProfileId}) async {
    if (_disposed) return;
    final version = ++_selectionVersion;
    final previousProfileId = preferredProfileId ?? currentProfile?.id;
    final loadedProfiles = await _repo.fetchAllProfiles();
    if (!_isCurrent(version)) return;
    profiles = loadedProfiles;
    if (profiles.isEmpty) {
      final allEquip = await _repo.fetchAllEquipment();
      if (!_isCurrent(version)) return;
      final defaultId = await _repo.saveGymProfileAtomic(
        existingProfile: null,
        name: 'General',
        equipmentIds: allEquip.map((item) => item.id).toSet(),
      );
      if (!_isCurrent(version)) return;
      final refreshedProfiles = await _repo.fetchAllProfiles();
      if (!_isCurrent(version)) return;
      profiles = refreshedProfiles;
      preferredProfileId = defaultId;
    }

    final storedProfileId = int.tryParse(
      await _repo.getAppState(_selectedProfileStateKey) ?? '',
    );
    if (!_isCurrent(version)) return;
    final targetProfileId =
        preferredProfileId ?? previousProfileId ?? storedProfileId;
    currentProfile = profiles.firstWhere(
      (profile) => profile.id == targetProfileId,
      orElse: () => profiles.first,
    );
    await _loadEquipment();
    if (!_isCurrent(version)) return;
    await _persistSelection(version);
    if (!_isCurrent(version)) return;
    notifyListeners();
  }

  /// Selects a different profile.
  Future<void> selectProfile(GymProfile profile) async {
    if (_disposed) return;
    final version = ++_selectionVersion;
    currentProfile = profile;
    await _loadEquipment();
    if (!_isCurrent(version)) return;
    await _persistSelection(version);
    if (!_isCurrent(version)) return;
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
  Future<void> toggleEquipment(int equipmentId) {
    final version = _selectionVersion;
    final profileId = currentProfile?.id;
    return _equipmentWrites.run(() async {
      if (!_isCurrent(version) || profileId == null) return;
      final exists = equipment.any((e) => e['id'] == equipmentId);
      if (exists) {
        await _repo.removeEquipmentFromProfile(profileId, equipmentId);
      } else {
        await _repo.addEquipmentToProfile(profileId, equipmentId);
      }
      if (!_isCurrent(version) || currentProfile?.id != profileId) return;
      final loaded = await _repo.fetchEquipmentForProfile(profileId);
      if (!_isCurrent(version) || currentProfile?.id != profileId) return;
      equipment = loaded;
      notifyListeners();
    });
  }

  /// Loads the equipment list for the selected profile.
  Future<void> _loadEquipment() async {
    final version = _selectionVersion;
    final profileId = currentProfile?.id;
    final loaded = profileId == null
        ? <Map<String, dynamic>>[]
        : await _repo.fetchEquipmentForProfile(profileId);
    if (_isCurrent(version) && currentProfile?.id == profileId) {
      equipment = loaded;
    }
  }

  Future<void> _persistSelection(int version) {
    final profileId = currentProfile?.id;
    return _selectionWrites.run(() async {
      if (!_isCurrent(version)) return;
      await _repo.setAppState(_selectedProfileStateKey, profileId?.toString());
    });
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
