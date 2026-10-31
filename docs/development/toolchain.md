# Windows Flutter/Dart commands

Use the same SDK as CI from the existing checkout:

```powershell
.\tools\tonos.ps1 check
.\tools\tonos.ps1 dart format lib/path/to/changed_file.dart
.\tools\tonos.ps1 dart analyze lib test integration_test test_driver tools
.\tools\tonos.ps1 flutter test --no-pub test/path/to/focused_test.dart
```

The wrapper reads `FLUTTER_VERSION` from `.github/workflows/ci.yml`, verifies
the selected Flutter version and its bundled Dart, and propagates the command's
exit code. It does not fetch packages or install/upgrade an SDK automatically.
PATH changes apply only to the command and are restored afterward.

The default Windows SDK root is
`E:\tools\flutter_sdks\<CI version>\flutter`. Set `TONOS_FLUTTER_SDK` to use
another installation of that exact version. VS Code's workspace SDK selection
is in `.vscode/settings.json`; update it when changing the CI pin. Ordinary
`dart` or `flutter` commands can still resolve another globally installed SDK.

For the existing isolated Android installation, continue using
`tools/run_expressive_preview.ps1`. It additionally verifies the package,
database and preview build flags. Do not substitute a normal app build for
that runner when updating the preview installation.
