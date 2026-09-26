import 'dart:io';
import 'package:flutter_test/flutter_test.dart';
import '../../tools/theme_style_ratchet.dart';

void main() {
  test('formatting, nested comments and trailing commas preserve identity', () {
    expect(
      styleFingerprints(
        'void f() { return BoxDecoration(color: Colors.red); }',
      ),
      styleFingerprints(
        'void f() { /* outer /* inner */ end */ return BoxDecoration(\n color: Colors.red,\n); }',
      ),
    );
  });
  test('values and duplicate occurrences cannot hide behind an approval', () {
    final base = styleFingerprints('void f() { return Color(0xFF123456); }');
    expect(
      styleFingerprints('void f() { return Color(0xFF123457); }'),
      isNot(base),
    );
    final twice = styleFingerprints(
      'void f() { return Color(0xFF123456); return Color(0xFF123456); }',
    );
    expect(twice.keys, base.keys);
    expect(twice.values.single, 2);
  });
  test('strings and comments do not produce style findings', () {
    expect(
      styleFingerprints('var x = "Colors.red"; // Color(1)\n/* BoxShadow() */'),
      isEmpty,
    );
    expect(styleFingerprints("var x = r'Colors.red';"), isEmpty);
    expect(styleFingerprints("var x = '''Colors.red''';"), isEmpty);
  });
  test('interpolation fails closed instead of concealing executable code', () {
    expect(
      () => styleFingerprints(r'var x = "${Colors.red}";'),
      throwsFormatException,
    );
    expect(() => styleFingerprints('/* unclosed'), throwsFormatException);
  });

  group('exact-scope enforcement', () {
    late Directory root;
    late File file;
    setUp(() {
      root = Directory.systemTemp.createTempSync('theme_ratchet_');
      Directory('${root.path}/lib').createSync();
      file = File('${root.path}/lib/example.dart');
      file.writeAsStringSync('void f() { return Colors.red; }');
    });
    tearDown(() => root.deleteSync(recursive: true));
    Map<String, dynamic> manifest() => {
      'schemaVersion': 1,
      'files': [
        {
          'path': r'lib\example.dart',
          'owner': 'fixture',
          'evidence': 'test-only scope',
          'approvals': [
            for (final entry
                in styleFingerprints(file.readAsStringSync()).entries)
              {
                'fingerprint': entry.key,
                'count': entry.value,
                'reason': 'fixture media contrast',
              },
          ],
        },
      ],
    };

    test('approved scope passes; changed or duplicated code fails', () {
      final m = manifest();
      expect(checkStyleRatchet(m, root: root), isNotEmpty);
      file.writeAsStringSync('void f() { return Colors.blue; }');
      expect(() => checkStyleRatchet(m, root: root), throwsFormatException);
      expect(checkStyleRatchet(m, root: root, reportOnly: true), isNotEmpty);
    });
    test('pending files do not block a protected file', () {
      final m = manifest();
      File('${root.path}/lib/pending.dart').writeAsStringSync('Color(7)');
      expect(checkStyleRatchet(m, root: root).length, 1);
    });
    test('noncanonical paths and case aliases fail', () {
      for (final path in [
        'lib/./example.dart',
        'lib//example.dart',
        'lib/../lib/example.dart',
      ]) {
        final m = manifest();
        final rows = m['files'] as List<Map<String, Object>>;
        rows.first['path'] = path;
        expect(() => checkStyleRatchet(m, root: root), throwsFormatException);
      }
      final m = manifest();
      final rows = m['files'] as List<Map<String, Object>>;
      final alias = Map<String, Object>.from(rows.first);
      alias['path'] = 'lib/EXAMPLE.dart';
      rows.add(alias);
      expect(() => checkStyleRatchet(m, root: root), throwsFormatException);
    });
    test('missing files, duplicate scopes and invalid approvals fail', () {
      final m = manifest();
      final rows = m['files'] as List<Map<String, Object>>;
      rows.add(rows.first);
      expect(() => checkStyleRatchet(m, root: root), throwsFormatException);
      rows.removeLast();
      rows.first['approvals'] = <Map<String, Object>>[
        {'fingerprint': 'bad', 'count': 0, 'reason': ''},
      ];
      expect(() => checkStyleRatchet(m, root: root), throwsFormatException);
      final valid = manifest();
      file.deleteSync();
      expect(() => checkStyleRatchet(valid, root: root), throwsFormatException);
    });
  });
}
