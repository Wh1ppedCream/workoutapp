import 'package:flutter/foundation.dart' show debugPrint;

import '../db/database_maintenance.dart';
import '../providers/durable_active_session.dart';
import '../providers/nutrition_profile.dart';
import '../providers/selected_profile.dart';
import '../repositories/app_repository.dart';

/// Keeps both import entry points consistent when an import commits before a
/// maintenance failure. Only a genuinely uncommitted failure may resume the old
/// live draft; committed data always requires reconciliation first.
Future<void> importDatabaseWithLiveState({
  required AppRepository repository,
  required String json,
  ActiveSession? activeSession,
  SelectedProfile? selectedProfile,
  NutritionProfile? nutritionProfile,
}) async {
  await activeSession?.prepareForDatabaseReplace();
  DatabaseImportCommittedException? maintenanceFailure;
  StackTrace? maintenanceStack;
  try {
    await repository.importDatabase(json, clearFirst: true);
  } on DatabaseImportCommittedException catch (error, stack) {
    maintenanceFailure = error;
    maintenanceStack = stack;
  } catch (_) {
    activeSession?.abortDatabaseReplace();
    rethrow;
  }

  Future<void> reconcile(String owner, Future<void> Function()? reload) async {
    if (reload == null) return;
    try {
      await reload();
    } catch (error, stack) {
      if (maintenanceFailure == null) {
        maintenanceFailure = DatabaseImportCommittedException(error);
        maintenanceStack = stack;
      } else {
        // Preserve the primary failure and avoid logging paths, SQL or data.
        debugPrint(
          'Additional import recovery failure ($owner: ${error.runtimeType}).',
        );
      }
    }
  }

  await reconcile('workout', activeSession?.reloadFromDatabase);
  await reconcile('profiles', selectedProfile?.loadProfiles);
  await reconcile('nutrition', nutritionProfile?.reloadFromDatabase);
  final failure = maintenanceFailure;
  if (failure != null) {
    Error.throwWithStackTrace(failure, maintenanceStack!);
  }
}
