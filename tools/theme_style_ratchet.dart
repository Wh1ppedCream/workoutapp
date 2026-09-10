import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Conservative lexical ratchet, separate from the report-only inventory.
/// Refactors require review. Unsupported interpolation fails closed.
Map<String, int> styleFingerprints(String source) {
  final tokens = <String>[];
  final whitespace = RegExp(r'\s');
  final token = RegExp(
    r'[A-Za-z_$][A-Za-z0-9_$]*|0[xX][0-9a-fA-F]+|[0-9]+(?:\.[0-9]+)?',
  );
  var i = 0;
  while (i < source.length) {
    if (whitespace.hasMatch(source[i])) {
      i++;
      continue;
    }
    if (source.startsWith('//', i)) {
      final end = source.indexOf('\n', i);
      i = end < 0 ? source.length : end;
      continue;
    }
    if (source.startsWith('/*', i)) {
      var depth = 1;
      i += 2;
      while (i < source.length && depth > 0) {
        if (source.startsWith('/*', i)) {
          depth++;
          i += 2;
        } else if (source.startsWith('*/', i)) {
          depth--;
          i += 2;
        } else {
          i++;
        }
      }
      if (depth != 0) {
        throw const FormatException('Unclosed comment.');
      }
      continue;
    }
    final raw =
        source[i] == 'r' &&
        i + 1 < source.length &&
        (source[i + 1] == "'" || source[i + 1] == '"');
    final start = i;
    if (raw) {
      i++;
    }
    if (source[i] == "'" || source[i] == '"') {
      final quote = source[i];
      final delimiter = source.startsWith(quote * 3, i) ? quote * 3 : quote;
      i += delimiter.length;
      var closed = false;
      while (i < source.length) {
        if (source.startsWith(delimiter, i)) {
          i += delimiter.length;
          closed = true;
          break;
        }
        if (!raw && source[i] == r'$') {
          throw const FormatException(
            'Interpolated strings require parser support before this file can be protected.',
          );
        }
        if (!raw && source[i] == r'\') {
          i += 2;
        } else {
          i++;
        }
      }
      if (!closed) {
        throw const FormatException('Unclosed string.');
      }
      // Keep literal content distinct, but never scan it for style names.
      tokens.add('string:${source.substring(start, i)}');
      continue;
    }
    final match = token.matchAsPrefix(source, i);
    if (match != null) {
      tokens.add(match.group(0)!);
      i = match.end;
    } else {
      tokens.add(source[i++]);
    }
  }
  // Trailing commas do not affect identity; all other token values are retained.
  for (var j = tokens.length - 2; j >= 0; j--) {
    if (tokens[j] == ',' && [')', ']', '}'].contains(tokens[j + 1])) {
      tokens.removeAt(j);
    }
  }
  const candidates = {
    'Colors',
    'Color',
    'BorderRadius',
    'BorderSide',
    'Border',
    'BoxDecoration',
    'InputDecoration',
    'ShapeDecoration',
    'RoundedRectangleBorder',
    'ContinuousRectangleBorder',
    'StadiumBorder',
    'LinearGradient',
    'RadialGradient',
    'SweepGradient',
    'BoxShadow',
    'Shadow',
    'Theme',
    'TextStyle',
    'ButtonStyle',
    'WidgetStateProperty',
    'MaterialStateProperty',
    'withOpacity',
    'withValues',
  };
  final result = <String, int>{};
  for (var j = 0; j < tokens.length; j++) {
    if (!candidates.contains(tokens[j])) {
      continue;
    }
    var start = j;
    while (start > 0 && ![';', '{', '}'].contains(tokens[start - 1])) {
      start--;
    }
    var end = j + 1;
    while (end < tokens.length && ![';', '{', '}'].contains(tokens[end])) {
      end++;
    }
    // The lexical scope prefix disambiguates declarations without using lines.
    final scopes = <String>[];
    for (var k = 0; k < start; k++) {
      if (tokens[k] == '{') {
        var a = k;
        while (a > 0 && ![';', '{', '}'].contains(tokens[a - 1])) {
          a--;
        }
        scopes.add(jsonEncode(tokens.sublist(a, k)));
      } else if (tokens[k] == '}' && scopes.isNotEmpty) {
        scopes.removeLast();
      }
    }
    final identity = jsonEncode([
      scopes,
      tokens[j],
      tokens.sublist(start, end),
    ]);
    final hash = sha256.convert(utf8.encode(identity)).toString();
    result.update(hash, (count) => count + 1, ifAbsent: () => 1);
  }
  return Map.fromEntries(
    result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

Map<String, Map<String, int>> checkStyleRatchet(
  Map<String, dynamic> manifest, {
  required Directory root,
  bool reportOnly = false,
}) {
  if (manifest['schemaVersion'] != 1 || manifest['files'] is! List) {
    throw const FormatException('Expected schemaVersion 1 and files array.');
  }
  final results = <String, Map<String, int>>{};
  final canonicalPaths = <String>{};
  final failures = <String>[];
  for (final raw in manifest['files'] as List) {
    if (raw is! Map) {
      throw const FormatException('Invalid file entry.');
    }
    final path = raw['path'];
    final owner = raw['owner'];
    final evidence = raw['evidence'];
    final approvals = raw['approvals'];
    if (path is! String ||
        owner is! String ||
        owner.trim().isEmpty ||
        evidence is! String ||
        evidence.trim().isEmpty ||
        approvals is! List) {
      throw const FormatException(
        'File needs path, owner, evidence and approvals.',
      );
    }
    final normalized = path.replaceAll(r'\', '/');
    if (!normalized.startsWith('lib/') ||
        p.posix.normalize(normalized) != normalized ||
        normalized.contains(':') ||
        normalized.contains('..') ||
        normalized.contains('*') ||
        !normalized.endsWith('.dart') ||
        !canonicalPaths.add(normalized.toLowerCase())) {
      throw FormatException('Invalid or duplicate exact file path: $path');
    }
    final file = File(p.join(root.path, normalized));
    if (!file.existsSync()) {
      throw FormatException('Protected file missing: $path');
    }
    final resolvedRoot = root.resolveSymbolicLinksSync();
    final resolvedFile = file.resolveSymbolicLinksSync();
    if (!p.isWithin(resolvedRoot, resolvedFile)) {
      throw FormatException('Protected file escapes repository: $path');
    }
    final expected = <String, int>{};
    for (final approval in approvals) {
      if (approval is! Map ||
          approval['fingerprint'] is! String ||
          !RegExp(
            r'^[0-9a-f]{64}$',
          ).hasMatch(approval['fingerprint'] as String) ||
          approval['count'] is! int ||
          (approval['count'] as int) < 1 ||
          approval['reason'] is! String ||
          (approval['reason'] as String).trim().isEmpty) {
        throw FormatException('Invalid approval in $path');
      }
      final hash = approval['fingerprint'] as String;
      if (expected.containsKey(hash)) {
        throw FormatException('Duplicate approval in $path: $hash');
      }
      expected[hash] = approval['count'] as int;
    }
    final actual = styleFingerprints(file.readAsStringSync());
    results[normalized] = actual;
    for (final hash in {...actual.keys, ...expected.keys}) {
      if (actual[hash] != expected[hash]) {
        failures.add(
          '$normalized: $hash expected ${expected[hash] ?? 0}, found ${actual[hash] ?? 0}',
        );
      }
    }
  }
  if (!reportOnly && failures.isNotEmpty) {
    throw FormatException(failures.join('\n'));
  }
  return Map.fromEntries(
    results.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

void main(List<String> args) {
  try {
    if (args.length != 1 && !(args.length == 2 && args[1] == '--report')) {
      throw const FormatException(
        'Usage: dart run tools/theme_style_ratchet.dart manifest.json [--report]',
      );
    }
    final decoded = jsonDecode(File(args.first).readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object.');
    }
    final result = checkStyleRatchet(
      decoded,
      root: Directory.current,
      reportOnly: args.length == 2,
    );
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'mode': args.length == 2 ? 'report' : 'enforce',
        'protectedFileCount': result.length,
        'files': result,
      }),
    );
  } on FormatException catch (e) {
    stderr.writeln('Theme ratchet: $e');
    exitCode = 64;
  } on FileSystemException catch (e) {
    stderr.writeln('Theme ratchet: $e');
    exitCode = 66;
  }
}
