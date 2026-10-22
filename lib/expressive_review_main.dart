import 'dev/expressive_preview_safety.dart';
import 'main.dart' show runTonosApp;
import 'theme/tonos_preview_presentation.dart';

/// Starts the isolated Expressive review app using its existing data.
/// Identity is checked before preferences or SQLite are opened. Startup follows
/// the persisted onboarding setting and does not prepare or reset fixtures.
Future<void> main() => runTonosApp(
  previewPresentation: TonosPreviewPresentation(),
  beforeDataAccess: ExpressivePreviewSafety.verifyBeforeDataAccess,
);
