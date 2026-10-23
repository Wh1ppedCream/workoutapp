import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../tools/theme_style_inventory.dart';

/// Pins existing technical debt without treating it as qualified styling.
/// Both counts and exact snippets must be reviewed when this baseline changes.
void expectPendingStyleBacklog(
  ThemeStyleInventoryReport report, {
  String? file,
}) {
  final baseline = jsonDecode(
    File('docs/theme-style-pending-baseline.json').readAsStringSync(),
  ) as Map<String, dynamic>;
  final files = baseline['files'] as Map<String, dynamic>;
  final expected = <String, dynamic>{
    for (final entry in files.entries)
      if (file == null || entry.key == file) entry.key: entry.value,
  };
  final groups = <String, List<ThemeStyleFinding>>{};
  for (final finding in report.findings) {
    if (finding.status != 'pending' || (file != null && finding.file != file)) {
      continue;
    }
    groups.putIfAbsent(finding.file, () => []).add(finding);
  }
  final actual = <String, dynamic>{};
  for (final entry in groups.entries) {
    final counts = <String, int>{};
    final snippets = <String>[];
    for (final finding in entry.value) {
      counts.update(finding.kind, (count) => count + 1, ifAbsent: () => 1);
      snippets.add('${finding.kind}|${finding.snippet.trim()}');
    }
    snippets.sort();
    actual[entry.key] = {
      'countsByKind': counts,
      'snippetDigest': sha256
          .convert(utf8.encode(snippets.join('\n')))
          .toString(),
    };
  }
  expect(
    actual,
    expected,
    reason:
        'Pending style debt must stay explicit; review changes instead of '
        'silently expanding an allowlist or claiming zero pending findings.',
  );
  if (file == null) {
    expect(
      groups.values.fold<int>(0, (sum, group) => sum + group.length),
      baseline['candidateCount'],
    );
  }
}
