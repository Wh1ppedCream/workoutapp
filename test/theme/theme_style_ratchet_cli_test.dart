import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import '../../tools/theme_style_ratchet.dart';

void main() {
  test('production manifest retains an exact qualified scope', () {
    final manifest =
        jsonDecode(File('docs/theme-style-ratchet.json').readAsStringSync())
            as Map<String, dynamic>;
    final files = manifest['files'] as List<dynamic>;
    expect(files, hasLength(1));
    expect(
      (files.single as Map<String, dynamic>)['path'],
      'lib/theme/widgets/tonos_surface.dart',
    );
    final result = checkStyleRatchet(manifest, root: Directory.current);
    expect(
      result,
      containsPair('lib/theme/widgets/tonos_surface.dart', isNotEmpty),
    );
  });

  test(
    'CLI enforces approvals in a nonempty scope',
    () async {
      final root = Directory.systemTemp.createTempSync('ratchet_enforcement_');
      final script = File('tools/theme_style_ratchet.dart').absolute.path;
      final packages = File('.dart_tool/package_config.json').absolute.path;
      try {
        Directory('${root.path}/lib').createSync();
        final source = File('${root.path}/lib/example.dart');
        source.writeAsStringSync('var color = Colors.red;');
        final manifest = File('${root.path}/manifest.json');
        manifest.writeAsStringSync(
          jsonEncode({
            'schemaVersion': 1,
            'files': [
              {
                'path': 'lib/example.dart',
                'owner': 'test',
                'evidence': 'CLI fixture only',
                'approvals': [
                  for (final e
                      in styleFingerprints(source.readAsStringSync()).entries)
                    {
                      'fingerprint': e.key,
                      'count': e.value,
                      'reason': 'fixture',
                    },
                ],
              },
            ],
          }),
        );
        Future<ProcessResult> run() => Process.run(
          'dart',
          ['--packages=$packages', script, manifest.path],
          workingDirectory: root.path,
          runInShell: Platform.isWindows,
        );
        final approved = await run();
        expect(approved.exitCode, 0, reason: '${approved.stderr}');
        expect(jsonDecode(approved.stdout as String)['protectedFileCount'], 1);
        source.writeAsStringSync('var color = Colors.blue;');
        final rejected = await run();
        expect(rejected.exitCode, 64);
        expect(rejected.stderr, contains('lib/example.dart'));
        expect(rejected.stderr, contains('expected'));
      } finally {
        root.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
  test(
    'CLI reports empty protection honestly and rejects invalid input',
    () async {
      final root = Directory.systemTemp.createTempSync('ratchet_cli_');
      try {
        final manifest = File('${root.path}/manifest.json');
        manifest.writeAsStringSync(
          jsonEncode({'schemaVersion': 1, 'files': []}),
        );
        Future<ProcessResult> run(List<String> args) => Process.run('dart', [
          'run',
          'tools/theme_style_ratchet.dart',
          ...args,
        ], runInShell: Platform.isWindows);
        final valid = await run([manifest.path]);
        expect(valid.exitCode, 0, reason: '${valid.stderr}');
        expect(jsonDecode(valid.stdout as String)['protectedFileCount'], 0);
        final report = await run([manifest.path, '--report']);
        expect(report.exitCode, 0, reason: '${report.stderr}');
        expect(jsonDecode(report.stdout as String)['mode'], 'report');
        final invalidArgs = await run([manifest.path, '--unknown']);
        expect(invalidArgs.exitCode, 64);
        manifest.writeAsStringSync('{invalid');
        expect((await run([manifest.path])).exitCode, 64);
        manifest.deleteSync();
        expect((await run([manifest.path])).exitCode, 66);
      } finally {
        root.deleteSync(recursive: true);
      }
    },
    timeout: const Timeout(Duration(minutes: 3)),
  );
}
