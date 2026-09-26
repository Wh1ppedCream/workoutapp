import 'dart:convert';
import 'dart:io';

import 'package:path/path.dart' as p;

const _defaultManifestPath = 'docs/theme-style-inventory.json';
const _defaultRootPath = 'lib';
const _validStatuses = <String>{
  'migrated',
  'excluded',
  'allowlisted',
  'pending',
  'review',
};

final _candidatePatterns = <_CandidatePattern>[
  _CandidatePattern('color', RegExp(r'\bColors\.[A-Za-z_][A-Za-z0-9_]*')),
  _CandidatePattern(
    'color_literal',
    RegExp(r'\bColor(?:\s*\(|\.(?:fromARGB|fromRGBO)\s*\()'),
  ),
  _CandidatePattern(
    'color_literal_candidate',
    RegExp(r'\b0x[0-9A-Fa-f]{6,8}\b'),
  ),
  _CandidatePattern(
    'color_transform',
    RegExp(r'\.(?:withOpacity|withValues)\s*\('),
  ),
  _CandidatePattern(
    'geometry',
    RegExp(
      r'\b(?:BorderRadius|BorderSide|RoundedRectangleBorder|'
      r'ContinuousRectangleBorder|StadiumBorder)\b|\bBorder\.all\s*\(',
    ),
  ),
  _CandidatePattern(
    'decoration',
    RegExp(r'\b(?:BoxDecoration|InputDecoration|ShapeDecoration)\s*\('),
  ),
  _CandidatePattern(
    'gradient',
    RegExp(r'\b(?:LinearGradient|RadialGradient|SweepGradient|Gradient)\s*\('),
  ),
  _CandidatePattern('shadow', RegExp(r'\b(?:BoxShadow|Shadow)\s*\(')),
  _CandidatePattern('local_theme', RegExp(r'\bTheme\s*\(')),
  _CandidatePattern('text_style', RegExp(r'\bTextStyle\s*\(')),
  _CandidatePattern(
    'component_style',
    RegExp(
      r'\b(?:ButtonStyle|WidgetStateProperty|MaterialStateProperty)'
      r'\s*(?:\.|\()',
    ),
  ),
];

const _candidateKinds = <String>{
  'color',
  'color_literal',
  'color_literal_candidate',
  'color_transform',
  'geometry',
  'decoration',
  'gradient',
  'shadow',
  'local_theme',
  'text_style',
  'component_style',
};

class ThemeStyleClassification {
  ThemeStyleClassification({
    required this.id,
    required this.label,
    required this.target,
    required this.status,
  });

  final String id;
  final String label;
  final String target;
  final String status;

  factory ThemeStyleClassification.fromJson(Map<String, dynamic> json) {
    return ThemeStyleClassification(
      id: _requiredString(json, 'id', context: 'classification'),
      label: _requiredString(json, 'label', context: 'classification'),
      target: _requiredString(json, 'target', context: 'classification'),
      status: _requiredString(json, 'status', context: 'classification'),
    );
  }
}

class ThemeStyleInventoryRule {
  ThemeStyleInventoryRule({
    required this.id,
    required this.pattern,
    required this.classification,
    required this.status,
    required this.target,
    required this.rationale,
    this.kinds = const <String>[],
  }) : _pathExpression = _globToRegExp(pattern);

  final String id;
  final String pattern;
  final List<String> kinds;
  final String classification;
  final String status;
  final String target;
  final String rationale;
  final RegExp _pathExpression;

  factory ThemeStyleInventoryRule.fromJson(Map<String, dynamic> json) {
    final rawKinds = json['kinds'];
    final kinds = <String>[];
    if (rawKinds != null) {
      if (rawKinds is! List) {
        throw const FormatException('Rule kinds must be a JSON array.');
      }
      for (final rawKind in rawKinds) {
        if (rawKind is! String || rawKind.trim().isEmpty) {
          throw const FormatException(
            'Rule kinds must contain non-empty strings.',
          );
        }
        kinds.add(rawKind.trim());
      }
    }

    return ThemeStyleInventoryRule(
      id: _requiredString(json, 'id', context: 'path rule'),
      pattern: _requiredString(json, 'pattern', context: 'path rule'),
      kinds: List<String>.unmodifiable(kinds),
      classification: _requiredString(
        json,
        'classification',
        context: 'path rule',
      ),
      status: _requiredString(json, 'status', context: 'path rule'),
      target: _requiredString(json, 'target', context: 'path rule'),
      rationale: _requiredString(json, 'rationale', context: 'path rule'),
    );
  }

  bool matches(String path, [String? kind]) {
    final normalizedPath = _normalizePath(path);
    if (!_pathExpression.hasMatch(normalizedPath)) {
      return false;
    }
    return kinds.isEmpty || (kind != null && kinds.contains(kind));
  }
}

class ThemeStyleReviewItem {
  ThemeStyleReviewItem({
    required this.id,
    required this.title,
    required List<String> patterns,
    required this.target,
    required this.rationale,
  }) : patterns = List<String>.unmodifiable(patterns),
       _pathExpressions = patterns.map(_globToRegExp).toList(growable: false);

  final String id;
  final String title;
  final List<String> patterns;
  final String target;
  final String rationale;
  final List<RegExp> _pathExpressions;

  bool matches(String path) {
    final normalizedPath = _normalizePath(path);
    return _pathExpressions.any(
      (expression) => expression.hasMatch(normalizedPath),
    );
  }

  factory ThemeStyleReviewItem.fromJson(Map<String, dynamic> json) {
    final rawPatterns = json['patterns'];
    if (rawPatterns is! List || rawPatterns.isEmpty) {
      throw const FormatException(
        'Every theme-style review item needs at least one pattern.',
      );
    }
    final patterns = <String>[];
    for (final rawPattern in rawPatterns) {
      if (rawPattern is! String || rawPattern.trim().isEmpty) {
        throw const FormatException(
          'Theme-style review patterns must be non-empty strings.',
        );
      }
      patterns.add(rawPattern.trim());
    }

    return ThemeStyleReviewItem(
      id: _requiredString(json, 'id', context: 'review item'),
      title: _requiredString(json, 'title', context: 'review item'),
      patterns: patterns,
      target: _requiredString(json, 'target', context: 'review item'),
      rationale: _requiredString(json, 'rationale', context: 'review item'),
    );
  }
}

class ThemeStyleInventory {
  ThemeStyleInventory({
    required this.schemaVersion,
    required this.mode,
    required List<ThemeStyleClassification> classifications,
    required List<ThemeStyleInventoryRule> pathRules,
    required List<ThemeStyleReviewItem> reviewQueue,
  }) : classifications = List<ThemeStyleClassification>.unmodifiable(
         classifications,
       ),
       pathRules = List<ThemeStyleInventoryRule>.unmodifiable(pathRules),
       reviewQueue = List<ThemeStyleReviewItem>.unmodifiable(reviewQueue);

  final int schemaVersion;
  final String mode;
  final List<ThemeStyleClassification> classifications;
  final List<ThemeStyleInventoryRule> pathRules;
  final List<ThemeStyleReviewItem> reviewQueue;

  Set<String> get classificationIds =>
      classifications.map((classification) => classification.id).toSet();

  factory ThemeStyleInventory.fromJson(Object? value) {
    if (value is! Map) {
      throw const FormatException(
        'Theme-style inventory must be a JSON object.',
      );
    }
    final json = Map<String, dynamic>.from(value);
    final rawClassifications = _requiredList(
      json,
      'classifications',
      context: 'inventory',
    );
    final rawRules = _requiredList(json, 'pathRules', context: 'inventory');
    final rawReviewQueue = _requiredList(
      json,
      'reviewQueue',
      context: 'inventory',
    );

    final inventory = ThemeStyleInventory(
      schemaVersion: _requiredInt(json, 'schemaVersion', context: 'inventory'),
      mode: _requiredString(json, 'mode', context: 'inventory'),
      classifications: rawClassifications
          .map((entry) {
            if (entry is! Map) {
              throw const FormatException(
                'Every theme-style classification must be a JSON object.',
              );
            }
            return ThemeStyleClassification.fromJson(
              Map<String, dynamic>.from(entry),
            );
          })
          .toList(growable: false),
      pathRules: rawRules
          .map((entry) {
            if (entry is! Map) {
              throw const FormatException(
                'Every theme-style path rule must be a JSON object.',
              );
            }
            return ThemeStyleInventoryRule.fromJson(
              Map<String, dynamic>.from(entry),
            );
          })
          .toList(growable: false),
      reviewQueue: rawReviewQueue
          .map((entry) {
            if (entry is! Map) {
              throw const FormatException(
                'Every theme-style review item must be a JSON object.',
              );
            }
            return ThemeStyleReviewItem.fromJson(
              Map<String, dynamic>.from(entry),
            );
          })
          .toList(growable: false),
    );
    inventory.validate();
    return inventory;
  }

  void validate() {
    if (schemaVersion != 1) {
      throw FormatException(
        'Unsupported theme-style inventory schema: $schemaVersion.',
      );
    }
    if (mode != 'report-only') {
      throw const FormatException(
        'Theme-style inventory mode must remain report-only.',
      );
    }
    if (classifications.isEmpty) {
      throw const FormatException(
        'Theme-style inventory needs at least one classification.',
      );
    }

    final classificationIds = <String>{};
    for (final classification in classifications) {
      if (!classificationIds.add(classification.id)) {
        throw FormatException(
          'Duplicate theme-style classification ID: ${classification.id}.',
        );
      }
      _validateStatus(
        classification.status,
        'classification ${classification.id}',
      );
    }

    final ruleIds = <String>{};
    for (final rule in pathRules) {
      if (!ruleIds.add(rule.id)) {
        throw FormatException(
          'Duplicate theme-style path rule ID: ${rule.id}.',
        );
      }
      if (!classificationIds.contains(rule.classification)) {
        throw FormatException(
          'Path rule ${rule.id} references unknown classification '
          '${rule.classification}.',
        );
      }
      _validateStatus(rule.status, 'path rule ${rule.id}');
      for (final kind in rule.kinds) {
        if (!_candidateKinds.contains(kind)) {
          throw FormatException(
            'Path rule ${rule.id} references unknown candidate kind $kind.',
          );
        }
      }
    }
    if (pathRules.isEmpty) {
      throw const FormatException(
        'Theme-style inventory needs at least one path rule.',
      );
    }

    final reviewIds = <String>{};
    for (final item in reviewQueue) {
      if (!reviewIds.add(item.id)) {
        throw FormatException(
          'Duplicate theme-style review item ID: ${item.id}.',
        );
      }
    }
  }

  ThemeStyleInventoryRule? ruleFor(String path, String kind) {
    for (final rule in pathRules) {
      if (rule.matches(path, kind)) {
        return rule;
      }
    }
    return null;
  }
}

class ThemeStyleFinding {
  const ThemeStyleFinding({
    required this.file,
    required this.line,
    required this.kind,
    required this.snippet,
    required this.ruleId,
    required this.classification,
    required this.status,
    required this.target,
  });

  final String file;
  final int line;
  final String kind;
  final String snippet;
  final String ruleId;
  final String classification;
  final String status;
  final String target;

  Map<String, dynamic> toJson() => <String, dynamic>{
    'file': file,
    'line': line,
    'kind': kind,
    'snippet': snippet,
    'ruleId': ruleId,
    'classification': classification,
    'status': status,
    'target': target,
  };
}

class ThemeStyleInventoryReport {
  ThemeStyleInventoryReport({
    required this.scannedRoot,
    required List<String> scannedFiles,
    required List<ThemeStyleFinding> findings,
    required List<ThemeStyleReviewItem> reviewQueue,
  }) : scannedFiles = List<String>.unmodifiable(scannedFiles),
       findings = List<ThemeStyleFinding>.unmodifiable(findings),
       reviewQueue = List<ThemeStyleReviewItem>.unmodifiable(reviewQueue);

  final String scannedRoot;
  final List<String> scannedFiles;
  final List<ThemeStyleFinding> findings;
  final List<ThemeStyleReviewItem> reviewQueue;

  bool get hasUnassignedFindings =>
      findings.any((finding) => finding.ruleId == 'unassigned');

  Map<String, int> get countsByKind =>
      _counts(findings.map((finding) => finding.kind));

  Map<String, int> get countsByClassification =>
      _counts(findings.map((finding) => finding.classification));

  Map<String, int> get countsByStatus =>
      _counts(findings.map((finding) => finding.status));

  Map<String, dynamic> get reviewQueueCoverage {
    var uniquelyAssignedCandidateCount = 0;
    var outsideQueueCandidateCount = 0;
    var pendingOutsideQueueCandidateCount = 0;
    var overlappingCandidateCount = 0;

    for (final finding in findings) {
      final matchingQueueCount =
          reviewQueue.where((item) => item.matches(finding.file)).length;
      if (matchingQueueCount == 1) {
        uniquelyAssignedCandidateCount++;
      } else if (matchingQueueCount == 0) {
        outsideQueueCandidateCount++;
        if (finding.status == 'pending') {
          pendingOutsideQueueCandidateCount++;
        }
      } else {
        overlappingCandidateCount++;
      }
    }

    final queues = reviewQueue
        .map((item) {
          final queueFindings = findings.where(
            (finding) => item.matches(finding.file),
          );
          return <String, dynamic>{
            'id': item.id,
            'title': item.title,
            'target': item.target,
            'candidateCount': queueFindings.length,
            'countsByStatus': _counts(
              queueFindings.map((finding) => finding.status),
            ),
          };
        })
        .toList(growable: false);

    return <String, dynamic>{
      'candidateCount': findings.length,
      'uniquelyAssignedCandidateCount': uniquelyAssignedCandidateCount,
      'outsideQueueCandidateCount': outsideQueueCandidateCount,
      'pendingOutsideQueueCandidateCount': pendingOutsideQueueCandidateCount,
      'overlappingCandidateCount': overlappingCandidateCount,
      'queues': queues,
    };
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
    'mode': 'report-only',
    'scannedRoot': scannedRoot,
    'scannedFileCount': scannedFiles.length,
    'candidateCount': findings.length,
    'countsByKind': countsByKind,
    'countsByClassification': countsByClassification,
    'countsByStatus': countsByStatus,
    'reviewQueueCoverage': reviewQueueCoverage,
    'scannedFiles': scannedFiles,
    'findings': findings.map((finding) => finding.toJson()).toList(),
    'reviewQueue':
        reviewQueue
            .map(
              (item) => <String, dynamic>{
                'id': item.id,
                'title': item.title,
                'patterns': item.patterns,
                'target': item.target,
                'rationale': item.rationale,
              },
            )
            .toList(),
  };

  String toText() {
    final lines = <String>[
      'Theme style inventory (report-only)',
      'Scanned root: $scannedRoot',
      'Dart files: ${scannedFiles.length}',
      'Style candidates: ${findings.length}',
      '',
      'Candidates by kind:',
    ];
    _appendCounts(lines, countsByKind);
    lines.add('Candidates by classification:');
    _appendCounts(lines, countsByClassification);
    lines.add('Candidates by status:');
    _appendCounts(lines, countsByStatus);
    lines.add('');
    final queueCoverage = reviewQueueCoverage;
    final pendingOutsideQueueCount =
        queueCoverage['pendingOutsideQueueCandidateCount'];
    lines.add(
      'Pending candidates without a review queue: $pendingOutsideQueueCount',
    );
    lines.add('Review queue coverage:');
    lines.add(
      '- ${queueCoverage['uniquelyAssignedCandidateCount']} candidates in exactly one queue',
    );
    lines.add(
      '- ${queueCoverage['outsideQueueCandidateCount']} candidates outside configured queues',
    );
    lines.add(
      '- ${queueCoverage['overlappingCandidateCount']} candidates in multiple queues',
    );
    for (final queue in queueCoverage['queues'] as List<Map<String, dynamic>>) {
      final statusCounts = queue['countsByStatus'] as Map<String, int>;
      final statusSummary = statusCounts.entries
          .map((entry) => '${entry.key}=${entry.value}')
          .join(', ');
      lines.add(
        '- ${queue['id']}: ${queue['candidateCount']} candidates'
        '${statusSummary.isEmpty ? '' : ' ($statusSummary)'}',
      );
    }
    lines.add('');
    if (hasUnassignedFindings) {
      lines.add('Unassigned candidates: configuration error');
    } else {
      lines.add('Unassigned candidates: 0');
    }
    lines.add('');
    lines.add('Pending review queue (${reviewQueue.length}):');
    for (final item in reviewQueue) {
      lines.add('- ${item.title} [${item.id}] -> ${item.target}');
    }
    if (findings.isNotEmpty) {
      lines.add('');
      lines.add('Sample findings (first 20):');
      for (final finding in findings.take(20)) {
        lines.add(
          '- ${finding.file}:${finding.line} ${finding.kind} '
          '[${finding.classification}/${finding.status}] ${finding.snippet}',
        );
      }
      if (findings.length > 20) {
        lines.add(
          '- ... ${findings.length - 20} more; use --format json for all.',
        );
      }
    }
    return lines.join('\n');
  }
}

ThemeStyleInventory loadThemeStyleInventory(String path) {
  final source = File(path);
  if (!source.existsSync()) {
    throw FormatException('Theme-style inventory was not found: $path.');
  }
  final decoded = jsonDecode(source.readAsStringSync());
  return ThemeStyleInventory.fromJson(decoded);
}

ThemeStyleInventoryReport scanThemeStyleInventory({
  required Directory root,
  required ThemeStyleInventory inventory,
}) {
  inventory.validate();
  if (!root.existsSync()) {
    throw FormatException('Theme-style scan root was not found: ${root.path}.');
  }

  final repositoryRoot = p.normalize(p.absolute('.'));
  final scannedRoot = _repositoryRelativePath(root.path, repositoryRoot);
  final files =
      root
          .listSync(recursive: true, followLinks: false)
          .whereType<File>()
          .where((file) => p.extension(file.path).toLowerCase() == '.dart')
          .toList()
        ..sort((left, right) => left.path.compareTo(right.path));

  final scannedFiles = <String>[];
  final findings = <ThemeStyleFinding>[];
  for (final file in files) {
    final relativePath = _repositoryRelativePath(file.path, repositoryRoot);
    scannedFiles.add(relativePath);
    final source = file.readAsStringSync();
    final searchableSource = _maskNonCode(source);
    for (final candidate in _candidatePatterns) {
      for (final match in candidate.expression.allMatches(searchableSource)) {
        final rule = inventory.ruleFor(relativePath, candidate.kind);
        findings.add(
          ThemeStyleFinding(
            file: relativePath,
            line: _lineNumberAt(source, match.start),
            kind: candidate.kind,
            snippet: _sourceLineAt(source, match.start),
            ruleId: rule?.id ?? 'unassigned',
            classification: rule?.classification ?? 'unassigned',
            status: rule?.status ?? 'unassigned',
            target: rule?.target ?? 'Add a matching path rule.',
          ),
        );
      }
    }
  }

  findings.sort((left, right) {
    final fileOrder = left.file.compareTo(right.file);
    if (fileOrder != 0) {
      return fileOrder;
    }
    final lineOrder = left.line.compareTo(right.line);
    if (lineOrder != 0) {
      return lineOrder;
    }
    return left.kind.compareTo(right.kind);
  });

  return ThemeStyleInventoryReport(
    scannedRoot: scannedRoot,
    scannedFiles: scannedFiles,
    findings: findings,
    reviewQueue: inventory.reviewQueue,
  );
}

void main(List<String> arguments) {
  try {
    final options = _Options.parse(arguments);
    final inventory = loadThemeStyleInventory(options.manifestPath);
    final report = scanThemeStyleInventory(
      root: Directory(options.rootPath),
      inventory: inventory,
    );
    if (options.check && report.hasUnassignedFindings) {
      throw const FormatException(
        'The theme-style inventory produced unassigned candidates.',
      );
    }

    final output =
        options.format == 'json'
            ? JsonEncoder.withIndent('  ').convert(report.toJson())
            : report.toText();
    final outputPath = options.outputPath;
    if (outputPath == null) {
      stdout.writeln(output);
      return;
    }

    final outputFile = File(outputPath);
    outputFile.parent.createSync(recursive: true);
    outputFile.writeAsStringSync('$output\n');
    stdout.writeln('Wrote theme-style inventory report to $outputPath.');
  } on FormatException catch (error) {
    stderr.writeln('Theme-style inventory failed: ${error.message}');
    exitCode = 64;
  } on FileSystemException catch (error) {
    stderr.writeln(
      'Theme-style inventory could not read or write a file: ${error.message}',
    );
    exitCode = 66;
  }
}

class _Options {
  const _Options({
    required this.rootPath,
    required this.manifestPath,
    required this.format,
    required this.outputPath,
    required this.check,
  });

  final String rootPath;
  final String manifestPath;
  final String format;
  final String? outputPath;
  final bool check;

  static _Options parse(List<String> arguments) {
    var rootPath = _defaultRootPath;
    var manifestPath = _defaultManifestPath;
    var format = 'text';
    String? outputPath;
    var check = false;

    for (var index = 0; index < arguments.length; index++) {
      switch (arguments[index]) {
        case '--root':
          rootPath = _nextValue(arguments, ++index, '--root');
          break;
        case '--manifest':
          manifestPath = _nextValue(arguments, ++index, '--manifest');
          break;
        case '--format':
          format = _nextValue(arguments, ++index, '--format');
          if (format != 'text' && format != 'json') {
            throw FormatException('Unsupported output format: $format.');
          }
          break;
        case '--output':
          outputPath = _nextValue(arguments, ++index, '--output');
          break;
        case '--check':
          check = true;
          break;
        default:
          throw FormatException('Unknown option: ${arguments[index]}');
      }
    }

    return _Options(
      rootPath: rootPath.trim(),
      manifestPath: manifestPath.trim(),
      format: format,
      outputPath: outputPath?.trim(),
      check: check,
    );
  }

  static String _nextValue(List<String> arguments, int index, String option) {
    if (index >= arguments.length || arguments[index].startsWith('--')) {
      throw FormatException('Missing value for $option.');
    }
    return arguments[index];
  }
}

class _CandidatePattern {
  const _CandidatePattern(this.kind, this.expression);

  final String kind;
  final RegExp expression;
}

String _requiredString(
  Map<String, dynamic> json,
  String key, {
  required String context,
}) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('$context requires a non-empty $key.');
  }
  return value.trim();
}

int _requiredInt(
  Map<String, dynamic> json,
  String key, {
  required String context,
}) {
  final value = json[key];
  if (value is! int) {
    throw FormatException('$context requires an integer $key.');
  }
  return value;
}

List<Object?> _requiredList(
  Map<String, dynamic> json,
  String key, {
  required String context,
}) {
  final value = json[key];
  if (value is! List || value.isEmpty) {
    throw FormatException('$context requires a non-empty $key array.');
  }
  return List<Object?>.from(value);
}

void _validateStatus(String status, String context) {
  if (!_validStatuses.contains(status)) {
    throw FormatException('Unknown theme-style status "$status" in $context.');
  }
}

Map<String, int> _counts(Iterable<String> values) {
  final counts = <String, int>{};
  for (final value in values) {
    counts[value] = (counts[value] ?? 0) + 1;
  }
  final keys = counts.keys.toList()..sort();
  return <String, int>{for (final key in keys) key: counts[key]!};
}

void _appendCounts(List<String> lines, Map<String, int> counts) {
  if (counts.isEmpty) {
    lines.add('- none');
    return;
  }
  for (final entry in counts.entries) {
    lines.add('- ${entry.key}: ${entry.value}');
  }
}

String _normalizePath(String path) => path.replaceAll('\\', '/');

String _repositoryRelativePath(String path, String repositoryRoot) {
  final absolutePath = p.normalize(p.absolute(path));
  return _normalizePath(p.relative(absolutePath, from: repositoryRoot));
}

RegExp _globToRegExp(String pattern) {
  final normalizedPattern = _normalizePath(pattern.trim());
  final expression = StringBuffer('^');
  for (var index = 0; index < normalizedPattern.length;) {
    final character = normalizedPattern[index];
    if (character == '*') {
      if (index + 1 < normalizedPattern.length &&
          normalizedPattern[index + 1] == '*') {
        expression.write('.*');
        index += 2;
      } else {
        expression.write('[^/]*');
        index++;
      }
      continue;
    }
    if (character == '?') {
      expression.write('[^/]');
      index++;
      continue;
    }
    if (r'\.^$+()[]{}|'.contains(character)) {
      expression.write('\\');
    }
    expression.write(character);
    index++;
  }
  expression.write(r'$');
  return RegExp(expression.toString());
}

String _maskNonCode(String source) {
  final codeUnits = source.codeUnits;
  final masked = List<int>.from(codeUnits);

  void maskAt(int index) {
    final code = masked[index];
    if (code != 10 && code != 13) {
      masked[index] = 32;
    }
  }

  bool startsWithAt(String value, int index) {
    if (index + value.length > codeUnits.length) {
      return false;
    }
    for (var offset = 0; offset < value.length; offset++) {
      if (codeUnits[index + offset] != value.codeUnitAt(offset)) {
        return false;
      }
    }
    return true;
  }

  for (var index = 0; index < codeUnits.length;) {
    if (startsWithAt('//', index)) {
      while (index < codeUnits.length && codeUnits[index] != 10) {
        maskAt(index++);
      }
      continue;
    }
    if (startsWithAt('/*', index)) {
      maskAt(index++);
      maskAt(index++);
      while (index < codeUnits.length) {
        if (startsWithAt('*/', index)) {
          maskAt(index++);
          maskAt(index++);
          break;
        }
        maskAt(index++);
      }
      continue;
    }

    final quote = codeUnits[index];
    if (quote != 39 && quote != 34) {
      index++;
      continue;
    }

    final triple =
        index + 2 < codeUnits.length &&
        codeUnits[index + 1] == quote &&
        codeUnits[index + 2] == quote;
    final delimiterLength = triple ? 3 : 1;
    for (var offset = 0; offset < delimiterLength; offset++) {
      maskAt(index++);
    }
    while (index < codeUnits.length) {
      if (triple &&
          index + 2 < codeUnits.length &&
          codeUnits[index] == quote &&
          codeUnits[index + 1] == quote &&
          codeUnits[index + 2] == quote) {
        for (var offset = 0; offset < 3; offset++) {
          maskAt(index++);
        }
        break;
      }
      if (!triple && codeUnits[index] == quote) {
        maskAt(index++);
        break;
      }
      if (codeUnits[index] == 92 && index + 1 < codeUnits.length) {
        maskAt(index++);
        maskAt(index++);
        continue;
      }
      maskAt(index++);
    }
  }

  return String.fromCharCodes(masked);
}

int _lineNumberAt(String source, int offset) {
  var line = 1;
  for (var index = 0; index < offset; index++) {
    if (source.codeUnitAt(index) == 10) {
      line++;
    }
  }
  return line;
}

String _sourceLineAt(String source, int offset) {
  final previousBreak = offset == 0 ? -1 : source.lastIndexOf('\n', offset - 1);
  final nextBreak = source.indexOf('\n', offset);
  final line = source
      .substring(previousBreak + 1, nextBreak < 0 ? source.length : nextBreak)
      .trim()
      .replaceAll(RegExp(r'\s+'), ' ');
  if (line.length <= 180) {
    return line;
  }
  return '${line.substring(0, 177)}...';
}
