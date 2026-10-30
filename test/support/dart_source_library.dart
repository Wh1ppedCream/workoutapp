import 'dart:io';

import 'package:path/path.dart' as p;

/// Resolves physical parts back to the canonical library for debt accounting.
String canonicalDartLibraryPath(String path) {
  final source = File(path).readAsStringSync();
  final partOf = RegExp(
    r"^part of '([^']+)';",
    multiLine: true,
  ).firstMatch(source);
  if (partOf == null) return path.replaceAll('\\', '/');
  return p.posix.normalize(
    p.posix.join(p.posix.dirname(path.replaceAll('\\', '/')), partOf.group(1)!),
  );
}

/// Reads the actual library composition, keeping all source ownership checks.
/// Missing parts, wrong owners and duplicate/cyclic parts fail the test.
String readDartSourceLibrary(String path) {
  if (!path.endsWith('.dart')) return File(path).readAsStringSync();
  final canonical = canonicalDartLibraryPath(path);
  final visited = <String>{};
  String expand(String file) {
    if (!visited.add(file)) throw StateError('Duplicate source part: $file');
    final source = File(file).readAsStringSync();
    if (canonicalDartLibraryPath(file) != canonical) {
      throw StateError('Wrong library owner for $file');
    }
    return source.replaceAllMapped(
      RegExp(r"^part '([^']+)';", multiLine: true),
      (match) => expand(
        p.posix.normalize(p.posix.join(p.posix.dirname(file), match.group(1)!)),
      ),
    );
  }

  return expand(canonical);
}

String sourceLibraryPattern(String canonical) => switch (canonical) {
  'lib/screens/onboarding_flow.dart' => 'lib/screens/onboarding**.dart',
  'lib/screens/profile/settings/exercise_editor_screen.dart' =>
    'lib/screens/profile/settings/exercise_editor**.dart',
  'lib/widgets/health_trends_section.dart' =>
    'lib/widgets/health_trends**.dart',
  'lib/widgets/exercise_progress_section.dart' =>
    'lib/widgets/exercise_progress**.dart',
  'lib/widgets/workout_metric_chart_card.dart' =>
    'lib/widgets/workout_metric_chart**.dart',
  'lib/widgets/exercise_detail_sheet.dart' =>
    'lib/widgets/exercise_detail**.dart',
  _ => canonical,
};
