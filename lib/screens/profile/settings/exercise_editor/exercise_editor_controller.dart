import 'package:flutter/foundation.dart';

import '../../../../models/models.dart';
import '../../../../repositories/app_repository.dart';
import '../../../../services/safe_failure.dart';

/// Loaded values used to seed the screen's editable fields. The screen owns
/// those field drafts; this controller owns requests and durable operations.
class ExerciseEditorDetails {
  ExerciseEditorDetails({
    required this.definition,
    required List<ExerciseMusclePercent> musclePercents,
    required this.useManualMuscles,
    required Map<BodyPart, double> automaticBodyparts,
    required List<ExerciseBodyPartPercent> manualBodyparts,
    required this.useManualBodyparts,
    required List<ExerciseMediaItem> media,
    required this.multiplyByRating,
  }) : musclePercents = List.unmodifiable(musclePercents),
       automaticBodyparts = Map.unmodifiable(automaticBodyparts),
       manualBodyparts = List.unmodifiable(manualBodyparts),
       media = List.unmodifiable(media);

  final ExerciseDefinition definition;
  final List<ExerciseMusclePercent> musclePercents;
  final bool useManualMuscles;
  final Map<BodyPart, double> automaticBodyparts;
  final List<ExerciseBodyPartPercent> manualBodyparts;
  final bool useManualBodyparts;
  final List<ExerciseMediaItem> media;
  final bool multiplyByRating;
}

/// Owns loading order, stale-result suppression and saves for one editor route.
/// It never retains BuildContext, field controllers or navigation callbacks.
class ExerciseEditorController extends ChangeNotifier {
  ExerciseEditorController(this._repository);

  final AppRepository _repository;
  bool _disposed = false;
  int _catalogRequest = 0;
  int _selectionRequest = 0;
  bool _loadingCatalog = true;
  bool _loadingDetails = false;
  bool _saving = false;
  SafeFailure? _catalogFailure;
  ExerciseDefinition? _definition;
  ExerciseDefinition? _loadedDefinition;
  List<Equipment> _equipment = const [];

  bool get loadingCatalog => _loadingCatalog;
  bool get loadingDetails => _loadingDetails;
  bool get saving => _saving;
  SafeFailure? get catalogFailure => _catalogFailure;
  ExerciseDefinition? get definition => _definition;
  List<Equipment> get equipment => _equipment;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  bool _isCurrent(int request) => !_disposed && request == _selectionRequest;

  Future<bool> loadCatalog() async {
    if (_disposed) return false;
    final request = ++_catalogRequest;
    final selectionRequest = ++_selectionRequest;
    _loadingDetails = false;
    _loadingCatalog = true;
    _catalogFailure = null;
    _notify();
    try {
      final results = await Future.wait<Object>([
        _repository.lookupDefsDetailed(),
        _repository.fetchAllEquipment(),
      ]);
      if (_disposed || request != _catalogRequest) return false;
      _equipment = List.unmodifiable(results[1] as List<Equipment>);
      if (!_isCurrent(selectionRequest)) return false;
      _definition = null;
      _loadedDefinition = null;
      return true;
    } catch (error) {
      if (!_disposed && request == _catalogRequest) {
        _catalogFailure = SafeFailure.classify(error);
      }
      return false;
    } finally {
      if (!_disposed && request == _catalogRequest) {
        _loadingCatalog = false;
        _notify();
      }
    }
  }

  Future<ExerciseEditorDetails?> loadDefinition(
    ExerciseDefinition definition,
  ) async {
    if (_disposed) return null;
    final request = ++_selectionRequest;
    _definition = definition;
    _loadingDetails = true;
    _notify();
    try {
      final details = await _readDetails(definition, request);
      if (_isCurrent(request)) _loadedDefinition = definition;
      return details;
    } catch (_) {
      if (_isCurrent(request)) {
        _definition = _loadedDefinition;
        rethrow;
      }
      return null;
    } finally {
      if (_isCurrent(request)) {
        _loadingDetails = false;
        _notify();
      }
    }
  }

  Future<ExerciseEditorDetails?> _readDetails(
    ExerciseDefinition definition,
    int request,
  ) async {
    final id = definition.id;
    final values = await Future.wait<Object>([
      _repository.computeMusclePercents(id),
      _repository.getUseManualMuscles(id),
      _repository.computeMuscleCalculatedBodyparts(id),
      _repository.fetchBodyPartPercentsManual(id),
      _repository.getUseManualBodyparts(id),
      _repository.fetchExerciseMedia(id),
      _repository.getMultiplyByRating(id),
    ]);
    if (!_isCurrent(request)) return null;
    return ExerciseEditorDetails(
      definition: definition,
      musclePercents: values[0] as List<ExerciseMusclePercent>,
      useManualMuscles: values[1] as bool,
      automaticBodyparts: values[2] as Map<BodyPart, double>,
      manualBodyparts: values[3] as List<ExerciseBodyPartPercent>,
      useManualBodyparts: values[4] as bool,
      media: values[5] as List<ExerciseMediaItem>,
      multiplyByRating: values[6] as bool,
    );
  }

  /// Reloads a saved definition for discard/save without allowing a late result
  /// to switch the user back from a more recently selected exercise.
  Future<ExerciseEditorDetails?> reloadSelection() async {
    final definition = _definition;
    if (_disposed || definition == null) return null;
    final request = ++_selectionRequest;
    _loadingDetails = true;
    _notify();
    try {
      final refreshed = await _repository.fetchDefinitionById(definition.id);
      if (!_isCurrent(request)) return null;
      if (refreshed == null) {
        throw StateError('Selected definition is unavailable.');
      }
      final details = await _readDetails(refreshed, request);
      if (_isCurrent(request)) {
        _definition = refreshed;
        _loadedDefinition = refreshed;
      }
      return details;
    } catch (_) {
      if (_isCurrent(request)) rethrow;
      return null;
    } finally {
      if (_isCurrent(request)) {
        _loadingDetails = false;
        _notify();
      }
    }
  }

  Future<ExerciseEditorDetails?> save(ExerciseDefinitionWrite write) async {
    if (_disposed || _saving || write.definition.id != _definition?.id) {
      return null;
    }
    final request = _selectionRequest;
    _saving = true;
    _notify();
    try {
      await _repository.saveExerciseDefinitionAtomic(write);
      if (!_isCurrent(request)) return null;
      return await reloadSelection();
    } finally {
      _saving = false;
      _notify();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    ++_catalogRequest;
    ++_selectionRequest;
    super.dispose();
  }
}
