import 'dart:convert';
import 'dart:io';
import 'package:crypto/crypto.dart';
import 'package:path/path.dart' as p;

/// Conservative lexical ratchet, separate from the report-only inventory.
/// Refactors require review. Interpolated expressions are tokenized as code;
/// literal portions remain opaque, exact string tokens.
Map<String, int> styleFingerprints(String source) {
  return {
    for (final entry in styleFingerprintDetails(source).entries)
      entry.key: entry.value['count'] as int,
  };
}

/// Returns the normalized statement context for each fingerprint.
///
/// This is report-only evidence to make manual approval review auditable; the
/// enforcement identity and accepted fingerprint counts remain unchanged.
Map<String, Map<String, Object>> styleFingerprintDetails(String source) {
  final tokens = _tokenizeStyleSource(source);
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
  final result = <String, Map<String, Object>>{};
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
    result.update(
      hash,
      (detail) => {...detail, 'count': (detail['count'] as int) + 1},
      ifAbsent:
          () => {
            'count': 1,
            'candidate': tokens[j],
            'scope': scopes.map(jsonDecode).toList(),
            'statementTokens': tokens.sublist(start, end),
          },
    );
  }
  return Map.fromEntries(
    result.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
  );
}

List<String> _tokenizeStyleSource(String source) {
  final tokens = <String>[];
  final whitespace = RegExp(r'\s');
  final token = RegExp(
    r'[A-Za-z_$][A-Za-z0-9_$]*|0[xX][0-9a-fA-F]+|[0-9]+(?:\.[0-9]+)?',
  );
  final identifierStart = RegExp(r'[A-Za-z_$]');
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
      var interpolated = false;
      var segmentStart = i;
      while (i < source.length) {
        if (source.startsWith(delimiter, i)) {
          final stringEnd = i + delimiter.length;
          i += delimiter.length;
          closed = true;
          if (interpolated) {
            _addStringSegment(
              tokens,
              source,
              segmentStart,
              stringEnd - delimiter.length,
            );
            tokens.add('string-end:$delimiter');
          } else {
            // Keep literal content distinct, but never scan it for style names.
            tokens.add('string:${source.substring(start, i)}');
          }
          break;
        }
        if (!raw && source[i] == r'\') {
          i += 2;
          continue;
        }
        if (!raw && source[i] == r'$') {
          final hasBracedExpression = source.startsWith(r'${', i);
          final identifier =
              !hasBracedExpression && i + 1 < source.length
                  ? token.matchAsPrefix(source, i + 1)
                  : null;
          if (hasBracedExpression ||
              (identifier != null && identifierStart.hasMatch(source[i + 1]))) {
            if (!interpolated) {
              tokens.add(
                'string-start:${source.substring(start, start + delimiter.length)}',
              );
              interpolated = true;
            }
            _addStringSegment(tokens, source, segmentStart, i);
            tokens.add('interpolation-start');
            if (hasBracedExpression) {
              final expressionStart = i + 2;
              final expressionEnd = _findInterpolationEnd(
                source,
                expressionStart,
              );
              tokens.addAll(
                _tokenizeStyleSource(
                  source.substring(expressionStart, expressionEnd),
                ),
              );
              i = expressionEnd + 1;
            } else {
              tokens.add(identifier!.group(0)!);
              i = identifier.end;
            }
            tokens.add('interpolation-end');
            segmentStart = i;
            continue;
          }
        } else {
          i++;
          continue;
        }
        i++;
      }
      if (!closed) {
        throw const FormatException('Unclosed string.');
      }
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
  return tokens;
}

void _addStringSegment(List<String> tokens, String source, int start, int end) {
  if (start < end) {
    tokens.add('string-segment:${source.substring(start, end)}');
  }
}

int _findInterpolationEnd(String source, int start) {
  var depth = 1;
  var i = start;
  while (i < source.length) {
    if (source.startsWith('//', i)) {
      final end = source.indexOf('\n', i);
      i = end < 0 ? source.length : end;
      continue;
    }
    if (source.startsWith('/*', i)) {
      i = _skipBlockComment(source, i);
      continue;
    }
    final raw =
        source[i] == 'r' &&
        i + 1 < source.length &&
        (source[i + 1] == "'" || source[i + 1] == '"');
    final quoteIndex = raw ? i + 1 : i;
    if (source[quoteIndex] == "'" || source[quoteIndex] == '"') {
      i = _skipQuotedString(source, quoteIndex, raw: raw);
      continue;
    }
    if (source[i] == '{') {
      depth++;
    } else if (source[i] == '}') {
      depth--;
      if (depth == 0) {
        return i;
      }
    }
    i++;
  }
  throw const FormatException('Unclosed string interpolation.');
}

int _skipQuotedString(String source, int quoteIndex, {required bool raw}) {
  final quote = source[quoteIndex];
  final delimiter =
      source.startsWith(quote * 3, quoteIndex) ? quote * 3 : quote;
  var i = quoteIndex + delimiter.length;
  while (i < source.length) {
    if (!raw && source[i] == r'\') {
      i += 2;
    } else if (!raw && source.startsWith(r'${', i)) {
      // Quotes and braces inside the nested expression are code, not string
      // delimiters for this containing string.
      i = _findInterpolationEnd(source, i + 2) + 1;
    } else if (source.startsWith(delimiter, i)) {
      return i + delimiter.length;
    } else {
      i++;
    }
  }
  throw const FormatException('Unclosed string.');
}

int _skipBlockComment(String source, int start) {
  var depth = 1;
  var i = start + 2;
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
  return i;
}

Map<String, Map<String, int>> checkStyleRatchet(
  Map<String, dynamic> manifest, {
  required Directory root,
  bool reportOnly = false,
  Map<String, Map<String, Map<String, Object>>>? fingerprintDetails,
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
    final details = styleFingerprintDetails(file.readAsStringSync());
    final actual = {
      for (final entry in details.entries)
        entry.key: entry.value['count'] as int,
    };
    results[normalized] = actual;
    if (reportOnly && fingerprintDetails != null) {
      fingerprintDetails[normalized] = details;
    }
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
    final reportOnly = args.length >= 2 && args[1] == '--report';
    final includeDetails = args.length == 3 && args[2] == '--details';
    if (args.length != 1 &&
        !(args.length == 2 && reportOnly) &&
        !(args.length == 3 && reportOnly && includeDetails)) {
      throw const FormatException(
        'Usage: dart run tools/theme_style_ratchet.dart manifest.json [--report [--details]]',
      );
    }
    final decoded = jsonDecode(File(args.first).readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Expected JSON object.');
    }
    final fingerprintDetails = <String, Map<String, Map<String, Object>>>{};
    final result = checkStyleRatchet(
      decoded,
      root: Directory.current,
      reportOnly: reportOnly,
      fingerprintDetails: includeDetails ? fingerprintDetails : null,
    );
    stdout.writeln(
      const JsonEncoder.withIndent('  ').convert({
        'mode': reportOnly ? 'report' : 'enforce',
        'protectedFileCount': result.length,
        'files': result,
        if (includeDetails) 'fingerprintDetails': fingerprintDetails,
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
