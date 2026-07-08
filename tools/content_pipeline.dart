import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

Future<void> main(List<String> args) async {
  final command = args.isEmpty ? 'help' : args.first;
  final options = _CliOptions.parse(args.skip(1).toList());

  try {
    switch (command) {
      case 'build-exercise-media':
        await _buildExerciseMediaManifest(options);
        break;
      case 'validate-exercise-media':
        await _validateExerciseMediaManifest(options);
        break;
      case 'release-check-exercise-media':
        await _releaseCheckExerciseMedia(options);
        break;
      case 'diff-exercise-media':
        await _diffExerciseMediaManifests(options);
        break;
      case 'coverage-exercise-media':
        await _reportExerciseMediaCoverage(options);
        break;
      case 'scaffold-exercise-media':
        await _scaffoldExerciseMediaSource(options);
        break;
      case 'merge-exercise-media-source':
        await _mergeExerciseMediaSource(options);
        break;
      case 'help':
      case '--help':
      case '-h':
        _printHelp();
        break;
      default:
        _fail('Unknown command "$command". Run with "help" for usage.');
    }
  } on _PipelineFailure catch (e) {
    stderr.writeln(e.message);
    exitCode = 1;
  }
}

Future<void> _buildExerciseMediaManifest(_CliOptions options) async {
  final sourcePath = options.requiredValue('source');
  final outputPath = options.requiredValue('output');
  final exerciseDefsPath =
      options.value('exercise-defs') ?? 'assets/exercises.json';
  final source = await _loadJsonMap(sourcePath);
  final exerciseIndex = await _ExerciseIndex.load(exerciseDefsPath);
  final baseUrl = options.value('base-url') ?? source.stringValue('baseUrl');
  final version =
      options.intValue('version') ?? source.intValue('version') ?? 1;
  final namespace = source.stringValue('namespace') ?? 'exercise_media';
  final checkRemote = options.flag('check-remote');
  final strict = options.flag('strict');
  final requireHashes = options.flag('require-hashes');
  final requireLicenses = options.flag('require-licenses');

  final result =
      await _ExerciseMediaManifestBuilder(
        source: source,
        exerciseIndex: exerciseIndex,
        baseUrl: baseUrl,
        namespace: namespace,
        version: version,
        checkRemote: checkRemote,
        requireHashes: requireHashes,
        requireLicenses: requireLicenses,
      ).build();

  _printMessages(result.messages);
  if (result.hasErrors) {
    _fail('Build failed because errors were found.');
  }
  if (strict && result.hasWarnings) {
    _fail('Strict mode failed because warnings were found.');
  }

  final outputFile = File(outputPath);
  await outputFile.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await outputFile.writeAsString('${encoder.convert(result.manifest)}\n');

  final uploadScriptPath = options.value('upload-script');
  if (uploadScriptPath != null) {
    final bucket = options.requiredValue('bucket');
    final manifestObject =
        options.value('manifest-object') ??
        'manifests/exercise_media_manifest.json';
    await _writeUploadScript(
      source: source,
      outputPath: outputPath,
      uploadScriptPath: uploadScriptPath,
      bucket: bucket,
      manifestObject: manifestObject,
    );
  }

  stdout.writeln(
    'Wrote ${result.assetCount} assets for ${result.exerciseCount} exercises '
    'to $outputPath.',
  );
}

Future<void> _validateExerciseMediaManifest(_CliOptions options) async {
  final sourcePath = options.requiredValue('source');
  final exerciseDefsPath =
      options.value('exercise-defs') ?? 'assets/exercises.json';
  final source = await _loadJsonMap(sourcePath);
  final exerciseIndex = await _ExerciseIndex.load(exerciseDefsPath);
  final baseUrl = options.value('base-url') ?? source.stringValue('baseUrl');
  final checkRemote = options.flag('check-remote');
  final strict = options.flag('strict');
  final requireHashes = options.flag('require-hashes');
  final requireLicenses = options.flag('require-licenses');

  final result =
      await _ExerciseMediaManifestBuilder(
        source: source,
        exerciseIndex: exerciseIndex,
        baseUrl: baseUrl,
        namespace: source.stringValue('namespace') ?? 'exercise_media',
        version: options.intValue('version') ?? source.intValue('version') ?? 1,
        checkRemote: checkRemote,
        requireHashes: requireHashes,
        requireLicenses: requireLicenses,
      ).build();

  _printMessages(result.messages);
  if (result.hasErrors || (strict && result.hasWarnings)) {
    _fail('Validation failed.');
  }
  stdout.writeln(
    'Validated ${result.assetCount} assets for ${result.exerciseCount} exercises.',
  );
}

Future<void> _releaseCheckExerciseMedia(_CliOptions options) async {
  final sourcePath = options.requiredValue('source');
  final exerciseDefsPath =
      options.value('exercise-defs') ?? 'assets/exercises.json';
  final source = await _loadJsonMap(sourcePath);
  final exerciseIndex = await _ExerciseIndex.load(exerciseDefsPath);
  final baseUrl = options.value('base-url') ?? source.stringValue('baseUrl');
  final version =
      options.intValue('version') ?? source.intValue('version') ?? 1;
  final minCoverage = options.doubleValue('min-coverage');

  if (minCoverage != null && (minCoverage < 0 || minCoverage > 100)) {
    _fail('--min-coverage must be between 0 and 100.');
  }

  final result =
      await _ExerciseMediaManifestBuilder(
        source: source,
        exerciseIndex: exerciseIndex,
        baseUrl: baseUrl,
        namespace: source.stringValue('namespace') ?? 'exercise_media',
        version: version,
        checkRemote: true,
        requireHashes: options.flag('require-hashes'),
        requireLicenses: options.flag('require-licenses'),
      ).build();

  _printMessages(result.messages);
  if (result.hasErrors || result.hasWarnings) {
    _fail(
      'Release check failed. Fix all errors/warnings before publishing this '
      'manifest.',
    );
  }

  final coverage =
      _ExerciseMediaCoverage(
        exerciseIndex: exerciseIndex,
        manifest: result.manifest,
      ).buildReport();
  final coveragePercent = coverage['coveragePercent'] as double;
  if (minCoverage != null && coveragePercent < minCoverage) {
    _fail(
      'Release check failed. Coverage is $coveragePercent%, below '
      '--min-coverage $minCoverage%.',
    );
  }

  final outputPath = options.value('output');
  if (outputPath != null) {
    await _writeJsonFile(outputPath, result.manifest);
    stdout.writeln('Wrote release-ready manifest to $outputPath.');
  }

  final coverageOutputPath = options.value('coverage-output');
  if (coverageOutputPath != null) {
    await _writeJsonFile(coverageOutputPath, coverage);
    stdout.writeln('Wrote release coverage report to $coverageOutputPath.');
  }

  stdout.writeln(
    'Release check passed for ${result.assetCount} assets across '
    '${result.exerciseCount} exercises '
    '(${coverage['coveredExerciseCount']}/${coverage['totalExerciseCount']} '
    'covered, $coveragePercent%).',
  );
}

Future<void> _diffExerciseMediaManifests(_CliOptions options) async {
  final oldManifest = await _loadJsonMapFromPathOrUrl(
    options.requiredValue('old'),
  );
  final newManifest = await _loadJsonMapFromPathOrUrl(
    options.requiredValue('new'),
  );

  final report =
      _ManifestDiff(
        oldManifest: oldManifest,
        newManifest: newManifest,
      ).buildReport();

  stdout.writeln(
    'Exercise media manifest diff: '
    '+${report['addedCount']} '
    '-${report['removedCount']} '
    '~${report['changedCount']} '
    '=${report['unchangedCount']}',
  );

  final changed = report['changed'] as List;
  if (changed.isNotEmpty) {
    stdout.writeln('Changed assets:');
    for (final asset in changed.take(12)) {
      stdout.writeln('  - ${(asset as Map)['assetId']}');
    }
    if (changed.length > 12) {
      stdout.writeln('  ... ${changed.length - 12} more');
    }
  }

  final reportPath = options.value('report');
  if (reportPath != null) {
    final file = File(reportPath);
    await file.parent.create(recursive: true);
    const encoder = JsonEncoder.withIndent('  ');
    await file.writeAsString('${encoder.convert(report)}\n');
    stdout.writeln('Wrote diff report to $reportPath.');
  }
}

Future<void> _reportExerciseMediaCoverage(_CliOptions options) async {
  final exerciseDefsPath =
      options.value('exercise-defs') ?? 'assets/exercises.json';
  final exerciseIndex = await _ExerciseIndex.load(exerciseDefsPath);
  final input = (await _loadCoverageInput(options))!;
  final mediaType = options.value('media-type')?.trim().toLowerCase();
  final report =
      _ExerciseMediaCoverage(
        exerciseIndex: exerciseIndex,
        manifest: input,
        mediaType: mediaType,
      ).buildReport();

  stdout.writeln(
    'Exercise media coverage: '
    '${report['coveredExerciseCount']}/${report['totalExerciseCount']} '
    'covered (${report['coveragePercent']}%).',
  );
  stdout.writeln('Missing exercises: ${report['missingExerciseCount']}');

  final outputPath = options.value('output');
  if (outputPath != null) {
    await _writeJsonFile(outputPath, report);
    stdout.writeln('Wrote coverage report to $outputPath.');
  }

  final missingOutputPath = options.value('missing-output');
  if (missingOutputPath != null) {
    await _writeJsonFile(missingOutputPath, report['missingExercises']);
    stdout.writeln('Wrote missing exercise list to $missingOutputPath.');
  }
}

Future<void> _scaffoldExerciseMediaSource(_CliOptions options) async {
  final exerciseDefsPath =
      options.value('exercise-defs') ?? 'assets/exercises.json';
  final exerciseIndex = await _ExerciseIndex.load(exerciseDefsPath);
  final existing = await _loadCoverageInput(options, allowEmpty: true);
  final coveredIds =
      existing == null
          ? <int>{}
          : _ExerciseMediaCoverage(
            exerciseIndex: exerciseIndex,
            manifest: existing,
          ).coveredExerciseIds();
  final outputPath = options.requiredValue('output');
  final version = options.intValue('version') ?? 1;
  final assetVersion = options.intValue('asset-version') ?? 1;
  final limit = options.intValue('limit');
  final mediaType = (options.value('media-type') ?? 'thumbnail').trim();
  final fileName = (options.value('file-name') ?? 'thumb.png').trim();
  final licenseId = options.value('license-id');
  final baseUrl = options.value('base-url') ?? 'https://content.example.com';

  if (version < 1) {
    _fail('--version must be 1 or greater.');
  }
  if (assetVersion < 1) {
    _fail('--asset-version must be 1 or greater.');
  }
  if (limit != null && limit < 1) {
    _fail('--limit must be 1 or greater.');
  }
  if (mediaType.isEmpty) {
    _fail('--media-type cannot be empty.');
  }
  if (fileName.isEmpty) {
    _fail('--file-name cannot be empty.');
  }

  final missing =
      exerciseIndex.all
          .where((exercise) => !coveredIds.contains(exercise.id))
          .take(limit ?? exerciseIndex.all.length)
          .toList();

  final source = {
    'namespace': 'exercise_media',
    'version': version,
    'baseUrl': baseUrl,
    'exercises':
        missing.map((exercise) {
          final slug = _slugify(exercise.name);
          final asset = <String, dynamic>{
            'assetId': '${slug}_${mediaType}_v$assetVersion',
            'type': mediaType,
            'path': 'exercises/$slug/v$assetVersion/$fileName',
            'title': '${exercise.name} ${_mediaTypeTitle(mediaType)}',
            'sortOrder': 0,
            'version': assetVersion,
          };
          if (licenseId != null && licenseId.trim().isNotEmpty) {
            asset['licenseId'] = licenseId.trim();
          }

          return {
            'exerciseId': exercise.id,
            'exerciseName': exercise.name,
            'slug': slug,
            'assets': [asset],
          };
        }).toList(),
  };

  await _writeJsonFile(outputPath, source);
  stdout.writeln(
    'Scaffolded ${missing.length} missing exercise media entries to $outputPath.',
  );
}

Future<void> _mergeExerciseMediaSource(_CliOptions options) async {
  final base = await _loadJsonMap(options.requiredValue('base'));
  final batch = await _loadJsonMap(options.requiredValue('batch'));
  final outputPath = options.requiredValue('output');
  final replaceAssets = options.flag('replace-assets');
  final bumpVersion = options.flag('bump-version');
  final namespace =
      base.stringValue('namespace') ??
      batch.stringValue('namespace') ??
      'exercise_media';
  final baseUrl =
      options.value('base-url') ??
      base.stringValue('baseUrl') ??
      batch.stringValue('baseUrl');
  final version =
      options.intValue('version') ??
      (bumpVersion
          ? (base.intValue('version') ?? 1) + 1
          : _maxInt(base.intValue('version'), batch.intValue('version')) ?? 1);

  if (namespace != 'exercise_media') {
    _fail('Merged exercise media source namespace must be exercise_media.');
  }
  if (baseUrl == null || baseUrl.trim().isEmpty) {
    _fail('Merged exercise media source needs baseUrl or --base-url.');
  }
  if (version < 1) {
    _fail('Merged exercise media source version must be 1 or greater.');
  }

  final merged = <int, Map<String, dynamic>>{};
  _mergeSourceExercises(
    target: merged,
    source: base,
    label: 'base',
    replaceAssets: replaceAssets,
  );
  _mergeSourceExercises(
    target: merged,
    source: batch,
    label: 'batch',
    replaceAssets: replaceAssets,
  );

  final outputExercises = (merged.keys.toList()..sort())
      .map((id) => merged[id]!)
      .toList(growable: false);
  await _writeJsonFile(outputPath, {
    'namespace': namespace,
    'version': version,
    'baseUrl': baseUrl,
    'exercises': outputExercises,
  });

  stdout.writeln(
    'Merged ${batch.listValue('exercises').length} batch exercise entries into '
    '${base.listValue('exercises').length} base entries.',
  );
  stdout.writeln(
    'Wrote ${outputExercises.length} exercise media entries to $outputPath.',
  );
}

Future<Map<String, dynamic>> _loadJsonMap(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    _fail('File not found: $path');
  }
  final decoded = jsonDecode(await file.readAsString());
  if (decoded is! Map) {
    _fail('Expected a JSON object in $path.');
  }
  return Map<String, dynamic>.from(decoded);
}

Future<Map<String, dynamic>> _loadJsonMapFromPathOrUrl(String value) async {
  final uri = Uri.tryParse(value);
  if (uri != null &&
      (uri.scheme == 'https' || uri.scheme == 'http') &&
      uri.host.isNotEmpty) {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _fail('Failed to load $value: HTTP ${response.statusCode}.');
      }
      final raw = await response.transform(utf8.decoder).join();
      final decoded = jsonDecode(raw);
      if (decoded is! Map) {
        _fail('Expected a JSON object from $value.');
      }
      return Map<String, dynamic>.from(decoded);
    } finally {
      client.close(force: true);
    }
  }

  return _loadJsonMap(value);
}

Future<Map<String, dynamic>?> _loadCoverageInput(
  _CliOptions options, {
  bool allowEmpty = false,
}) async {
  final manifest = options.value('manifest');
  final source = options.value('source');

  if (manifest != null && source != null) {
    _fail('Use either --manifest or --source, not both.');
  }
  if (manifest != null) return _loadJsonMapFromPathOrUrl(manifest);
  if (source != null) return _loadJsonMap(source);
  if (allowEmpty) return null;

  _fail('Missing --manifest or --source.');
}

Future<void> _writeJsonFile(String path, Object data) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  const encoder = JsonEncoder.withIndent('  ');
  await file.writeAsString('${encoder.convert(data)}\n');
}

void _mergeSourceExercises({
  required Map<int, Map<String, dynamic>> target,
  required Map<String, dynamic> source,
  required String label,
  required bool replaceAssets,
}) {
  for (final rawExercise in source.listValue('exercises')) {
    if (rawExercise is! Map) {
      _fail('Skipping $label exercise entry because it is not an object.');
    }

    final incoming = Map<String, dynamic>.from(rawExercise);
    final id = incoming.intValue('exerciseId');
    if (id == null) {
      _fail('$label exercise entry is missing exerciseId.');
    }

    final existing = target[id];
    if (existing == null) {
      target[id] = _copySourceExercise(incoming, '$label exerciseId $id');
      continue;
    }

    final incomingName = incoming.stringValue('exerciseName');
    final existingName = existing.stringValue('exerciseName');
    if (incomingName != null &&
        existingName != null &&
        incomingName != existingName) {
      _fail(
        'Cannot merge $label exerciseId $id because names differ: '
        '"$existingName" vs "$incomingName".',
      );
    }
    if (existingName == null && incomingName != null) {
      existing['exerciseName'] = incomingName;
    }

    final incomingSlug = incoming.stringValue('slug');
    if (existing.stringValue('slug') == null && incomingSlug != null) {
      existing['slug'] = incomingSlug;
    }

    final existingAssets =
        (existing['assets'] as List).cast<Map<String, dynamic>>();
    final existingAssetIds = <String, int>{};
    for (var i = 0; i < existingAssets.length; i++) {
      final assetId = existingAssets[i].stringValue('assetId');
      if (assetId == null) {
        _fail('Existing exerciseId $id has an asset without assetId.');
      }
      existingAssetIds[assetId] = i;
    }

    final incomingAssets = _copySourceAssets(incoming, '$label exerciseId $id');
    for (final asset in incomingAssets) {
      final assetId = asset.stringValue('assetId');
      if (assetId == null) {
        _fail('$label exerciseId $id has an asset without assetId.');
      }
      final existingIndex = existingAssetIds[assetId];
      if (existingIndex == null) {
        existingAssetIds[assetId] = existingAssets.length;
        existingAssets.add(asset);
      } else if (replaceAssets) {
        existingAssets[existingIndex] = asset;
      } else {
        _fail(
          'Duplicate assetId "$assetId" while merging $label exerciseId $id. '
          'Use --replace-assets to replace existing assets.',
        );
      }
    }
  }
}

Map<String, dynamic> _copySourceExercise(
  Map<String, dynamic> exercise,
  String label,
) {
  final output = <String, dynamic>{
    'exerciseId': exercise.intValue('exerciseId'),
    if (exercise.stringValue('exerciseName') != null)
      'exerciseName': exercise.stringValue('exerciseName'),
    if (exercise.stringValue('slug') != null)
      'slug': exercise.stringValue('slug'),
    'assets': _copySourceAssets(exercise, label),
  };
  return output;
}

List<Map<String, dynamic>> _copySourceAssets(
  Map<String, dynamic> exercise,
  String label,
) {
  final assets = <Map<String, dynamic>>[];
  for (final rawAsset in exercise.listValue('assets')) {
    if (rawAsset is! Map) {
      _fail('$label has an asset entry that is not an object.');
    }
    final asset = Map<String, dynamic>.from(rawAsset);
    if (asset.stringValue('assetId') == null) {
      _fail('$label has an asset without assetId.');
    }
    assets.add(asset);
  }
  if (assets.isEmpty) {
    _fail('$label has no assets.');
  }
  assets.sort((a, b) {
    final order = (a.intValue('sortOrder') ?? 0).compareTo(
      b.intValue('sortOrder') ?? 0,
    );
    if (order != 0) return order;
    return (a.stringValue('assetId') ?? '').compareTo(
      b.stringValue('assetId') ?? '',
    );
  });
  return assets;
}

void _printMessages(List<_PipelineMessage> messages) {
  for (final message in messages) {
    final label = message.severity.name.toUpperCase();
    stdout.writeln('[$label] ${message.text}');
  }
}

Future<void> _writeUploadScript({
  required Map<String, dynamic> source,
  required String outputPath,
  required String uploadScriptPath,
  required String bucket,
  required String manifestObject,
}) async {
  final lines = <String>[
    '# Generated by tools/content_pipeline.dart.',
    '# Requires Wrangler auth: https://developers.cloudflare.com/workers/wrangler/',
    r'$ErrorActionPreference = "Stop"',
    '',
  ];

  final sourceExercises = source.listValue('exercises');
  for (final exercise in sourceExercises.whereType<Map>()) {
    final assets = Map<String, dynamic>.from(exercise).listValue('assets');
    for (final rawAsset in assets.whereType<Map>()) {
      final asset = Map<String, dynamic>.from(rawAsset);
      final localFile = asset.stringValue('localFile');
      final remotePath =
          asset.stringValue('path') ?? asset.stringValue('remotePath');
      if (localFile == null || remotePath == null) continue;
      lines.add(
        'wrangler r2 object put ${_psQuote('$bucket/$remotePath')} '
        '--file ${_psQuote(localFile)} '
        '--content-type ${_psQuote(_contentTypeFor(remotePath))}',
      );
    }
  }

  lines
    ..add(
      'wrangler r2 object put ${_psQuote('$bucket/$manifestObject')} '
      '--file ${_psQuote(outputPath)} '
      '--content-type ${_psQuote('application/json')}',
    )
    ..add('');

  final file = File(uploadScriptPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(lines.join('\n'));
  stdout.writeln('Wrote upload script to $uploadScriptPath.');
}

String _psQuote(String value) => "'${value.replaceAll("'", "''")}'";

String _contentTypeFor(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.gif')) return 'image/gif';
  if (lower.endsWith('.mp4')) return 'video/mp4';
  if (lower.endsWith('.json')) return 'application/json';
  return 'application/octet-stream';
}

void _printHelp() {
  stdout.writeln('''
Tonos content pipeline

Commands:
  build-exercise-media      Build an app-ready exercise media manifest.
  validate-exercise-media   Validate a source file without writing output.
  release-check-exercise-media
                            Remote-check and gate a manifest before publishing.
  diff-exercise-media       Compare two generated exercise media manifests.
  coverage-exercise-media   Report exercise media coverage.
  scaffold-exercise-media   Scaffold source JSON entries for missing exercises.
  merge-exercise-media-source
                            Merge a validated batch source into a base source.

Common options:
  --source <path>           Source JSON describing exercise media.
  --exercise-defs <path>    Exercise definitions JSON. Defaults to assets/exercises.json.
  --base-url <url>          CDN/R2 base URL. Overrides source baseUrl.
  --version <number>        Manifest version. Overrides source version.
  --check-remote            HEAD-check generated URLs.
  --strict                  Treat warnings as failures.
  --require-hashes          Require each asset to include or generate sha256.
  --require-licenses        Require each asset to include licenseId.

Build-only options:
  --output <path>           Generated manifest path.
  --upload-script <path>    Optional PowerShell upload script path.
  --bucket <name>           R2 bucket name for upload script generation.
  --manifest-object <key>   Manifest object key. Defaults to manifests/exercise_media_manifest.json.

Diff-only options:
  --old <path-or-url>       Previous app-ready manifest.
  --new <path-or-url>       New app-ready manifest.
  --report <path>           Optional JSON diff report path.

Release-check options:
  --source <path>           Source JSON to build and remote-check.
  --output <path>           Optional release-ready manifest path.
  --coverage-output <path>  Optional coverage report path.
  --min-coverage <number>   Optional minimum coverage percent, 0-100.
  --require-hashes          Require each asset to include or generate sha256.
  --require-licenses        Require each asset to include licenseId.

Coverage options:
  --manifest <path-or-url>  App-ready manifest to inspect.
  --source <path>           Source JSON to inspect.
  --output <path>           Optional coverage report path.
  --missing-output <path>   Optional missing exercise list path.
  --media-type <type>       Optional coverage filter, such as thumbnail or video.

Scaffold options:
  --output <path>           New source JSON path.
  --limit <number>          Optional number of missing exercises to scaffold.
  --base-url <url>          Base URL placeholder for generated paths.
  --asset-version <number>  Asset version for generated paths. Defaults to 1.
  --file-name <name>        File name for generated paths. Defaults to thumb.png.
  --license-id <id>         Optional licenseId to apply to scaffolded assets.

Merge options:
  --base <path>             Existing source JSON.
  --batch <path>            Batch source JSON to merge.
  --output <path>           Merged source JSON path.
  --bump-version            Increase the base source version by 1.
  --replace-assets          Replace duplicate assetIds instead of failing.

Example:
  dart run tools/content_pipeline.dart build-exercise-media --source tools/content_pipeline/exercise_media_source.example.json --output build/content/exercise_media_manifest.json --check-remote
''');
}

Never _fail(String message) => throw _PipelineFailure(message);

class _PipelineFailure implements Exception {
  final String message;

  const _PipelineFailure(this.message);
}

class _CliOptions {
  final Map<String, String> _values;
  final Set<String> _flags;

  const _CliOptions(this._values, this._flags);

  factory _CliOptions.parse(List<String> args) {
    final values = <String, String>{};
    final flags = <String>{};

    for (var i = 0; i < args.length; i++) {
      final arg = args[i];
      if (!arg.startsWith('--')) {
        _fail('Unexpected argument: $arg');
      }
      final key = arg.substring(2);
      if (key.isEmpty) _fail('Empty option name.');

      final hasValue = i + 1 < args.length && !args[i + 1].startsWith('--');
      if (hasValue) {
        values[key] = args[++i];
      } else {
        flags.add(key);
      }
    }

    return _CliOptions(values, flags);
  }

  String? value(String key) => _values[key];

  String requiredValue(String key) {
    final result = value(key);
    if (result == null || result.trim().isEmpty) {
      _fail('Missing required option --$key.');
    }
    return result;
  }

  int? intValue(String key) {
    final raw = value(key);
    if (raw == null) return null;
    final parsed = int.tryParse(raw);
    if (parsed == null) _fail('Expected --$key to be an integer.');
    return parsed;
  }

  double? doubleValue(String key) {
    final raw = value(key);
    if (raw == null) return null;
    final parsed = double.tryParse(raw);
    if (parsed == null) _fail('Expected --$key to be a number.');
    return parsed;
  }

  bool flag(String key) => _flags.contains(key);
}

class _ExerciseMediaManifestBuilder {
  _ExerciseMediaManifestBuilder({
    required this.source,
    required this.exerciseIndex,
    required this.baseUrl,
    required this.namespace,
    required this.version,
    required this.checkRemote,
    required this.requireHashes,
    required this.requireLicenses,
  });

  final Map<String, dynamic> source;
  final _ExerciseIndex exerciseIndex;
  final String? baseUrl;
  final String namespace;
  final int version;
  final bool checkRemote;
  final bool requireHashes;
  final bool requireLicenses;

  final List<_PipelineMessage> _messages = [];
  final Set<int> _seenExerciseIds = {};
  final Set<String> _seenAssetIds = {};
  final Set<String> _seenUrls = {};

  Future<_BuildResult> build() async {
    final outputExercises = <Map<String, dynamic>>[];
    var assetCount = 0;
    final sourceExercises = source.listValue('exercises');

    if (version < 1) {
      _error('Manifest version must be 1 or greater.');
    }
    if (sourceExercises.isEmpty) {
      _warning('Source has no exercise media entries.');
    }

    for (final rawExercise in sourceExercises) {
      if (rawExercise is! Map) {
        _error('Skipping exercise entry because it is not an object.');
        continue;
      }
      final exercise = Map<String, dynamic>.from(rawExercise);
      final resolved = _resolveExercise(exercise);
      if (resolved == null) continue;

      if (!_seenExerciseIds.add(resolved.id)) {
        _error('Duplicate exerciseId ${resolved.id} (${resolved.name}).');
        continue;
      }

      final assets = <Map<String, dynamic>>[];
      var assetIndex = 0;
      for (final rawAsset in exercise.listValue('assets')) {
        if (rawAsset is! Map) {
          _error(
            'Skipping asset for ${resolved.name}; asset is not an object.',
          );
          continue;
        }
        final builtAsset = await _buildAsset(
          Map<String, dynamic>.from(rawAsset),
          exercise: resolved,
          assetIndex: assetIndex,
        );
        assetIndex += 1;
        if (builtAsset == null) continue;
        assets.add(builtAsset);
      }

      if (assets.isEmpty) {
        _warning('No valid assets found for ${resolved.name}.');
        continue;
      }

      assetCount += assets.length;
      outputExercises.add({
        'exerciseId': resolved.id,
        'slug': exercise.stringValue('slug') ?? _slugify(resolved.name),
        'assets': assets,
      });
    }

    outputExercises.sort(
      (a, b) => (a['exerciseId'] as int).compareTo(b['exerciseId'] as int),
    );

    return _BuildResult(
      manifest: {
        'namespace': namespace,
        'version': version,
        'generatedAt': DateTime.now().toUtc().toIso8601String(),
        'exercises': outputExercises,
      },
      messages: List.unmodifiable(_messages),
      exerciseCount: outputExercises.length,
      assetCount: assetCount,
    );
  }

  _ResolvedExercise? _resolveExercise(Map<String, dynamic> exercise) {
    final id = exercise.intValue('exerciseId');
    final name =
        exercise.stringValue('exerciseName') ?? exercise.stringValue('name');

    if (id == null && name == null) {
      _error('Exercise entry needs exerciseId or exerciseName.');
      return null;
    }

    final byId = id == null ? null : exerciseIndex.byId(id);
    final byName = name == null ? null : exerciseIndex.byName(name);

    if (id != null && byId == null) {
      _error('Unknown exerciseId $id.');
      return null;
    }
    if (name != null && byName == null) {
      _error('Unknown exerciseName "$name".');
      return null;
    }
    if (byId != null && byName != null && byId.id != byName.id) {
      _error(
        'Exercise mismatch: id ${byId.id} is "${byId.name}" but name "$name" '
        'resolves to id ${byName.id}.',
      );
      return null;
    }

    final resolved = byId ?? byName;
    if (resolved == null) return null;
    if (name != null && resolved.name != name) {
      _warning(
        'Exercise name casing differs for id ${resolved.id}: source "$name", '
        'definitions "${resolved.name}".',
      );
    }
    return resolved;
  }

  Future<Map<String, dynamic>?> _buildAsset(
    Map<String, dynamic> asset, {
    required _ResolvedExercise exercise,
    required int assetIndex,
  }) async {
    final slug = _slugify(exercise.name);
    final mediaType = (asset.stringValue('type') ?? 'image').toLowerCase();
    final assetVersion = asset.intValue('version') ?? 1;
    final assetId =
        asset.stringValue('assetId') ??
        '${slug}_${mediaType}_v${assetVersion}_$assetIndex';

    if (!_seenAssetIds.add(assetId)) {
      _error('Duplicate assetId "$assetId".');
      return null;
    }
    if (assetVersion < 1) {
      _error('Asset "$assetId" version must be 1 or greater.');
      return null;
    }
    if (!_knownMediaTypes.contains(mediaType)) {
      _warning(
        'Asset "$assetId" uses unknown media type "$mediaType". '
        'The app may still accept it, but display support may be limited.',
      );
    }

    final url = _assetUrl(asset, key: 'url');
    if (url == null) {
      _error('Asset "$assetId" needs url, path, or remotePath.');
      return null;
    }
    final thumbnailUrl = _assetUrl(asset, key: 'thumbnailUrl');
    if (!_seenUrls.add(url)) {
      _warning('Remote URL is reused by more than one asset: $url');
    }

    final output = <String, dynamic>{
      'assetId': assetId,
      'type': mediaType,
      'url': url,
      'title': asset.stringValue('title') ?? exercise.name,
      'sortOrder': asset.intValue('sortOrder') ?? assetIndex,
      'version': assetVersion,
    };
    if (thumbnailUrl != null) {
      output['thumbnailUrl'] = thumbnailUrl;
    }

    final localFile = asset.stringValue('localFile');
    if (localFile != null) {
      await _addLocalFileMetadata(output, localFile, assetId);
    }

    _copyOptionalInt(asset, output, 'bytes');
    _copyOptionalInt(asset, output, 'width');
    _copyOptionalInt(asset, output, 'height');
    _copyOptionalString(asset, output, 'sha256');
    _copyOptionalString(asset, output, 'licenseId');

    _validateMetadata(output, assetId);

    if (checkRemote) {
      await _checkRemoteUrl(
        url,
        assetId,
        expectedBytes: output['bytes'] as int?,
      );
      if (thumbnailUrl != null && thumbnailUrl != url) {
        await _checkRemoteUrl(thumbnailUrl, '$assetId thumbnail');
      }
    }

    return output;
  }

  void _validateMetadata(Map<String, dynamic> output, String assetId) {
    final bytes = output['bytes'] as int?;
    if (bytes != null && bytes <= 0) {
      _error('Asset "$assetId" bytes must be greater than 0.');
    }

    final width = output['width'] as int?;
    final height = output['height'] as int?;
    if (width != null && width <= 0) {
      _warning('Asset "$assetId" width should be greater than 0.');
    }
    if (height != null && height <= 0) {
      _warning('Asset "$assetId" height should be greater than 0.');
    }

    final hash = output['sha256'] as String?;
    if (requireHashes && (hash == null || hash.isEmpty)) {
      _error('Asset "$assetId" is missing sha256.');
    }
    if (hash != null && !_sha256Pattern.hasMatch(hash)) {
      _error('Asset "$assetId" has an invalid sha256 value.');
    }

    final licenseId = output['licenseId'] as String?;
    if (requireLicenses && (licenseId == null || licenseId.isEmpty)) {
      _error('Asset "$assetId" is missing licenseId.');
    }
  }

  Future<void> _addLocalFileMetadata(
    Map<String, dynamic> output,
    String localFile,
    String assetId,
  ) async {
    final file = File(localFile);
    if (!await file.exists()) {
      _error('Local file for "$assetId" does not exist: $localFile');
      return;
    }

    final bytes = await file.readAsBytes();
    output['bytes'] = bytes.length;
    output['sha256'] = sha256.convert(bytes).toString();
  }

  String? _assetUrl(Map<String, dynamic> asset, {required String key}) {
    final explicit = asset.stringValue(key);
    if (explicit != null) return explicit;

    final pathKeys =
        key == 'thumbnailUrl'
            ? const ['thumbnailPath']
            : const ['path', 'remotePath'];
    for (final pathKey in pathKeys) {
      final path = asset.stringValue(pathKey);
      if (path != null) {
        if (baseUrl == null || baseUrl!.trim().isEmpty) {
          _error('Asset path "$path" needs baseUrl.');
          return null;
        }
        return _joinUrl(baseUrl!, path);
      }
    }
    return null;
  }

  Future<void> _checkRemoteUrl(
    String url,
    String label, {
    int? expectedBytes,
  }) async {
    final uri = Uri.tryParse(url);
    if (uri == null || !uri.hasScheme || uri.host.isEmpty) {
      _error('Invalid URL for "$label": $url');
      return;
    }

    final client = HttpClient();
    try {
      final response = await _openHeadOrGet(client, uri);
      final status = response.statusCode;
      final length = response.contentLength;
      await response.drain<void>();
      if (status < 200 || status >= 400) {
        _error('URL check failed for "$label": HTTP $status $url');
      } else if (expectedBytes != null &&
          length > 0 &&
          length != expectedBytes) {
        _warning(
          'Remote byte count for "$label" is $length, expected $expectedBytes.',
        );
      }
    } catch (e) {
      _error('URL check failed for "$label": $e');
    } finally {
      client.close(force: true);
    }
  }

  Future<HttpClientResponse> _openHeadOrGet(HttpClient client, Uri uri) async {
    final head = await client.headUrl(uri);
    final headResponse = await head.close();
    if (headResponse.statusCode != 405) return headResponse;
    await headResponse.drain<void>();

    final get = await client.getUrl(uri);
    return get.close();
  }

  void _copyOptionalInt(
    Map<String, dynamic> source,
    Map<String, dynamic> output,
    String key,
  ) {
    final value = source.intValue(key);
    if (value != null) output[key] = value;
  }

  void _copyOptionalString(
    Map<String, dynamic> source,
    Map<String, dynamic> output,
    String key,
  ) {
    final value = source.stringValue(key);
    if (value != null) output[key] = value;
  }

  void _error(String text) => _messages.add(_PipelineMessage.error(text));

  void _warning(String text) => _messages.add(_PipelineMessage.warning(text));
}

class _ManifestDiff {
  final Map<String, dynamic> oldManifest;
  final Map<String, dynamic> newManifest;

  const _ManifestDiff({required this.oldManifest, required this.newManifest});

  Map<String, dynamic> buildReport() {
    final oldAssets = _indexAssets(oldManifest);
    final newAssets = _indexAssets(newManifest);
    final oldKeys = oldAssets.keys.toSet();
    final newKeys = newAssets.keys.toSet();
    final added = (newKeys.difference(oldKeys).toList()..sort());
    final removed = (oldKeys.difference(newKeys).toList()..sort());
    final shared = (oldKeys.intersection(newKeys).toList()..sort());
    final changed = <Map<String, dynamic>>[];
    var unchanged = 0;

    for (final key in shared) {
      final oldFingerprint = _assetFingerprint(oldAssets[key]!);
      final newFingerprint = _assetFingerprint(newAssets[key]!);
      if (jsonEncode(oldFingerprint) == jsonEncode(newFingerprint)) {
        unchanged += 1;
      } else {
        changed.add({
          'assetId': key,
          'old': oldFingerprint,
          'new': newFingerprint,
        });
      }
    }

    return {
      'oldVersion': oldManifest['version'],
      'newVersion': newManifest['version'],
      'oldGeneratedAt': oldManifest['generatedAt'],
      'newGeneratedAt': newManifest['generatedAt'],
      'addedCount': added.length,
      'removedCount': removed.length,
      'changedCount': changed.length,
      'unchangedCount': unchanged,
      'added': added,
      'removed': removed,
      'changed': changed,
    };
  }

  Map<String, Map<String, dynamic>> _indexAssets(
    Map<String, dynamic> manifest,
  ) {
    final assets = <String, Map<String, dynamic>>{};
    for (final rawExercise in manifest.listValue('exercises')) {
      if (rawExercise is! Map) continue;
      final exercise = Map<String, dynamic>.from(rawExercise);
      final exerciseId = exercise.intValue('exerciseId');
      for (final rawAsset in exercise.listValue('assets')) {
        if (rawAsset is! Map) continue;
        final asset = Map<String, dynamic>.from(rawAsset);
        final assetId =
            asset.stringValue('assetId') ??
            '${exerciseId ?? 'unknown'}:${asset.stringValue('url') ?? ''}';
        assets[assetId] = {
          ...asset,
          'exerciseId': exerciseId,
          'exerciseSlug': exercise.stringValue('slug'),
        };
      }
    }
    return assets;
  }

  Map<String, dynamic> _assetFingerprint(Map<String, dynamic> asset) {
    return {
      'exerciseId': asset['exerciseId'],
      'exerciseSlug': asset['exerciseSlug'],
      'type': asset['type'],
      'url': asset['url'],
      'thumbnailUrl': asset['thumbnailUrl'],
      'title': asset['title'],
      'sortOrder': asset['sortOrder'],
      'version': asset['version'],
      'bytes': asset['bytes'],
      'width': asset['width'],
      'height': asset['height'],
      'sha256': asset['sha256'],
      'licenseId': asset['licenseId'],
    };
  }
}

class _ExerciseMediaCoverage {
  final _ExerciseIndex exerciseIndex;
  final Map<String, dynamic> manifest;
  final String? mediaType;

  const _ExerciseMediaCoverage({
    required this.exerciseIndex,
    required this.manifest,
    this.mediaType,
  });

  Map<String, dynamic> buildReport() {
    final knownIds = exerciseIndex.all.map((exercise) => exercise.id).toSet();
    final coveredIds = coveredExerciseIds().intersection(knownIds);
    final total = exerciseIndex.all.length;
    final missing =
        exerciseIndex.all
            .where((exercise) => !coveredIds.contains(exercise.id))
            .map(_exerciseReportRow)
            .toList();
    final covered =
        exerciseIndex.all
            .where((exercise) => coveredIds.contains(exercise.id))
            .map(_exerciseReportRow)
            .toList();
    final mediaTypeCounts = _mediaTypeCounts();
    final percent = total == 0 ? 0.0 : coveredIds.length * 100 / total;

    return {
      'totalExerciseCount': total,
      'coveredExerciseCount': coveredIds.length,
      'missingExerciseCount': missing.length,
      'coveragePercent': double.parse(percent.toStringAsFixed(1)),
      'mediaType': mediaType,
      'mediaTypeCounts': mediaTypeCounts,
      'coveredExercises': covered,
      'missingExercises': missing,
    };
  }

  Set<int> coveredExerciseIds() {
    final ids = <int>{};
    for (final rawExercise in manifest.listValue('exercises')) {
      if (rawExercise is! Map) continue;
      final exercise = Map<String, dynamic>.from(rawExercise);
      final exerciseId = exercise.intValue('exerciseId');
      if (exerciseId == null) continue;

      final assets =
          exercise
              .listValue('assets')
              .whereType<Map>()
              .map((asset) => Map<String, dynamic>.from(asset))
              .where(_assetMatches)
              .toList();
      if (assets.isNotEmpty) {
        ids.add(exerciseId);
      }
    }
    return ids;
  }

  bool _assetMatches(Map<String, dynamic> asset) {
    if (mediaType == null || mediaType!.isEmpty) return true;
    return asset.stringValue('type')?.toLowerCase() == mediaType;
  }

  Map<String, int> _mediaTypeCounts() {
    final counts = <String, int>{};
    for (final rawExercise in manifest.listValue('exercises')) {
      if (rawExercise is! Map) continue;
      final exercise = Map<String, dynamic>.from(rawExercise);
      for (final rawAsset in exercise.listValue('assets')) {
        if (rawAsset is! Map) continue;
        final asset = Map<String, dynamic>.from(rawAsset);
        final type = asset.stringValue('type')?.toLowerCase() ?? 'unknown';
        counts[type] = (counts[type] ?? 0) + 1;
      }
    }
    return counts;
  }

  Map<String, dynamic> _exerciseReportRow(_ResolvedExercise exercise) {
    return {
      'exerciseId': exercise.id,
      'exerciseName': exercise.name,
      'slug': _slugify(exercise.name),
    };
  }
}

class _ExerciseIndex {
  final Map<int, _ResolvedExercise> _byId;
  final Map<String, _ResolvedExercise> _byName;

  const _ExerciseIndex(this._byId, this._byName);

  static Future<_ExerciseIndex> load(String path) async {
    final raw = await File(path).readAsString();
    final decoded = jsonDecode(raw);
    if (decoded is! List) {
      _fail('Expected a JSON list in $path.');
    }

    final byId = <int, _ResolvedExercise>{};
    final byName = <String, _ResolvedExercise>{};

    for (var i = 0; i < decoded.length; i++) {
      final item = decoded[i];
      if (item is! Map) continue;
      final name = Map<String, dynamic>.from(item).stringValue('name');
      if (name == null) continue;
      final exercise = _ResolvedExercise(id: i + 1, name: name);
      byId[exercise.id] = exercise;
      byName[_normalizeName(name)] = exercise;
    }

    return _ExerciseIndex(byId, byName);
  }

  List<_ResolvedExercise> get all =>
      (_byId.keys.toList()..sort()).map((id) => _byId[id]!).toList();

  _ResolvedExercise? byId(int id) => _byId[id];

  _ResolvedExercise? byName(String name) => _byName[_normalizeName(name)];
}

class _ResolvedExercise {
  final int id;
  final String name;

  const _ResolvedExercise({required this.id, required this.name});
}

class _BuildResult {
  final Map<String, dynamic> manifest;
  final List<_PipelineMessage> messages;
  final int exerciseCount;
  final int assetCount;

  const _BuildResult({
    required this.manifest,
    required this.messages,
    required this.exerciseCount,
    required this.assetCount,
  });

  bool get hasErrors =>
      messages.any((message) => message.severity == _Severity.error);

  bool get hasWarnings =>
      messages.any((message) => message.severity == _Severity.warning);
}

class _PipelineMessage {
  final _Severity severity;
  final String text;

  const _PipelineMessage(this.severity, this.text);

  factory _PipelineMessage.error(String text) {
    return _PipelineMessage(_Severity.error, text);
  }

  factory _PipelineMessage.warning(String text) {
    return _PipelineMessage(_Severity.warning, text);
  }
}

enum _Severity { error, warning }

const Set<String> _knownMediaTypes = {
  'image',
  'thumbnail',
  'still',
  'animation',
  'video',
};

final RegExp _sha256Pattern = RegExp(r'^[a-fA-F0-9]{64}$');

extension _JsonMapTools on Map<String, dynamic> {
  String? stringValue(String key) {
    final value = this[key];
    if (value == null) return null;
    final text = value.toString().trim();
    return text.isEmpty ? null : text;
  }

  int? intValue(String key) {
    final value = this[key];
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value.trim());
    return null;
  }

  List<dynamic> listValue(String key) {
    final value = this[key];
    if (value is List) return value;
    return const [];
  }
}

String _joinUrl(String baseUrl, String path) {
  final cleanBase =
      baseUrl.endsWith('/')
          ? baseUrl.substring(0, baseUrl.length - 1)
          : baseUrl;
  final cleanPath = path.startsWith('/') ? path.substring(1) : path;
  return '$cleanBase/$cleanPath';
}

String _slugify(String value) {
  final lower = value.toLowerCase();
  final buffer = StringBuffer();
  var previousWasSeparator = false;

  for (final codeUnit in lower.codeUnits) {
    final isLetterOrNumber =
        (codeUnit >= 97 && codeUnit <= 122) ||
        (codeUnit >= 48 && codeUnit <= 57);
    if (isLetterOrNumber) {
      buffer.writeCharCode(codeUnit);
      previousWasSeparator = false;
    } else if (!previousWasSeparator) {
      buffer.write('_');
      previousWasSeparator = true;
    }
  }

  return buffer.toString().replaceAll(RegExp(r'^_+|_+$'), '');
}

String _mediaTypeTitle(String mediaType) {
  switch (mediaType.toLowerCase()) {
    case 'thumbnail':
      return 'thumbnail';
    case 'video':
      return 'video';
    case 'animation':
      return 'animation';
    default:
      return 'media';
  }
}

int? _maxInt(int? a, int? b) {
  if (a == null) return b;
  if (b == null) return a;
  return a > b ? a : b;
}

String _normalizeName(String value) => value.trim().toLowerCase();
