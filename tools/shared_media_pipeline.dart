import 'dart:convert';
import 'dart:io';

import 'package:crypto/crypto.dart';

/// Release tooling for optional equipment, bodypart, and muscle illustrations.
///
/// Exercise media keeps using content_pipeline.dart. This independent tool keeps
/// shared catalog media on the same R2/manifest discipline without coupling its
/// release cycle to the much larger exercise catalog.
Future<void> main(List<String> args) async {
  final command = args.isEmpty ? 'help' : args.first;
  final options = _CliOptions.parse(args.skip(1));

  try {
    switch (command) {
      case 'validate-shared-media':
        await _validate(options);
        break;
      case 'build-shared-media':
        await _build(options);
        break;
      case 'release-check-shared-media':
        await _releaseCheck(options);
        break;
      case 'coverage-shared-media':
        await _coverage(options);
        break;
      case 'merge-shared-media-source':
        await _mergeSharedMediaSource(options);
        break;
      case 'help':
      case '--help':
      case '-h':
        _printHelp();
        break;
      default:
        throw _PipelineFailure('Unknown command "$command". Run help.');
    }
  } on _PipelineFailure catch (error) {
    stderr.writeln('[ERROR] ${error.message}');
    exitCode = 1;
  }
}

Future<void> _validate(_CliOptions options) async {
  final result = await _buildResult(options);
  _printMessages(result.messages);
  if (result.hasErrors || (options.flag('strict') && result.hasWarnings)) {
    throw _PipelineFailure('Validation failed.');
  }
  stdout.writeln(
    'Validated ${result.assetCount} assets for ${result.entityCount} shared entities.',
  );
}

Future<void> _build(_CliOptions options) async {
  final result = await _buildResult(options);
  _printMessages(result.messages);
  if (result.hasErrors || (options.flag('strict') && result.hasWarnings)) {
    throw _PipelineFailure('Build failed.');
  }

  final outputPath = options.requiredValue('output');
  await _writeJson(outputPath, result.manifest);
  await _writeUploadScriptIfRequested(options, result);
  stdout.writeln(
    'Wrote ${result.assetCount} assets for ${result.entityCount} shared entities to $outputPath.',
  );
}

Future<void> _releaseCheck(_CliOptions options) async {
  final result = await _buildResult(
    options.withForcedFlags({
      'check-remote',
      'strict',
      'require-hashes',
      'require-licenses',
    }),
  );
  _printMessages(result.messages);
  if (result.hasErrors || result.hasWarnings) {
    throw _PipelineFailure(
      'Release check failed. Fix all errors and warnings before publishing.',
    );
  }

  final outputPath = options.value('output');
  if (outputPath != null) {
    await _writeJson(outputPath, result.manifest);
    stdout.writeln('Wrote release-ready manifest to $outputPath.');
  }
  final reportPath = options.value('report');
  if (reportPath != null) {
    await _writeJson(reportPath, result.coverage);
    stdout.writeln('Wrote coverage report to $reportPath.');
  }
  await _writeUploadScriptIfRequested(options, result);

  stdout.writeln(
    'Release check passed for ${result.assetCount} assets across '
    '${result.entityCount} entities (${result.coverageLabel}).',
  );
}

Future<void> _coverage(_CliOptions options) async {
  final result = await _buildResult(options);
  _printMessages(result.messages);
  if (result.hasErrors) throw _PipelineFailure('Coverage build failed.');

  final outputPath = options.value('output');
  if (outputPath != null) {
    await _writeJson(outputPath, result.coverage);
    stdout.writeln('Wrote coverage report to $outputPath.');
  }
  stdout.writeln('Shared media coverage: ${result.coverageLabel}.');
}

Future<void> _mergeSharedMediaSource(_CliOptions options) async {
  final base = await _loadJsonMap(options.requiredValue('base'));
  final batch = await _loadJsonMap(options.requiredValue('batch'));
  final metadataManifestPath = options.value('metadata-manifest');
  final batchWithMetadata =
      metadataManifestPath == null
          ? batch
          : _enrichSourceWithManifestMetadata(
            source: batch,
            metadataManifest: await _loadJsonMap(metadataManifestPath),
          );
  final outputPath = options.requiredValue('output');
  final namespace =
      base.stringValue('namespace') ??
      batchWithMetadata.stringValue('namespace') ??
      'shared_media';
  final baseUrl =
      options.value('base-url') ??
      base.stringValue('baseUrl') ??
      batchWithMetadata.stringValue('baseUrl');
  final version =
      options.intValue('version') ??
      (options.flag('bump-version')
          ? (base.intValue('version') ?? 1) + 1
          : _maxInt(
                base.intValue('version'),
                batchWithMetadata.intValue('version'),
              ) ??
              1);

  if (namespace != 'shared_media') {
    throw _PipelineFailure(
      'Merged shared media source namespace must be shared_media.',
    );
  }
  if (baseUrl == null || baseUrl.trim().isEmpty) {
    throw _PipelineFailure(
      'Merged shared media source needs baseUrl or --base-url.',
    );
  }
  if (version < 1) {
    throw _PipelineFailure(
      'Merged shared media source version must be 1 or greater.',
    );
  }

  final merged = <String, Map<String, dynamic>>{};
  final replaceEntityAssets = options.flag('replace-entity-assets');
  final stripLocalFiles = options.flag('strip-local-files');
  _mergeSourceEntities(
    target: merged,
    source: base,
    label: 'base',
    replaceEntityAssets: replaceEntityAssets,
    stripLocalFiles: stripLocalFiles,
  );
  _mergeSourceEntities(
    target: merged,
    source: batchWithMetadata,
    label: 'batch',
    replaceEntityAssets: replaceEntityAssets,
    stripLocalFiles: stripLocalFiles,
  );

  final outputEntities =
      merged.values.toList()..sort((a, b) {
        final typeOrder = (a.stringValue('entityType') ?? '').compareTo(
          b.stringValue('entityType') ?? '',
        );
        if (typeOrder != 0) return typeOrder;
        return (a.intValue('entityId') ?? 0).compareTo(
          b.intValue('entityId') ?? 0,
        );
      });

  await _writeJson(outputPath, {
    'namespace': namespace,
    'version': version,
    'baseUrl': baseUrl,
    'entities': outputEntities,
  });
  stdout.writeln(
    'Merged ${batchWithMetadata.listValue('entities').length} batch shared '
    'entities into '
    '${base.listValue('entities').length} base entries.',
  );
  stdout.writeln(
    'Wrote ${outputEntities.length} shared media entities to $outputPath.',
  );
}

Map<String, dynamic> _enrichSourceWithManifestMetadata({
  required Map<String, dynamic> source,
  required Map<String, dynamic> metadataManifest,
}) {
  if (metadataManifest.stringValue('namespace') != 'shared_media') {
    throw _PipelineFailure(
      'The metadata manifest namespace must be shared_media.',
    );
  }

  final metadataByAsset = <String, Map<String, dynamic>>{};
  for (final rawEntity in metadataManifest.listValue('entities')) {
    if (rawEntity is! Map) {
      throw _PipelineFailure(
        'Every metadata manifest entity must be an object.',
      );
    }
    final entity = Map<String, dynamic>.from(rawEntity);
    final entityType = entity.stringValue('entityType');
    final entityId = entity.intValue('entityId');
    if (_SharedEntityType.fromValue(entityType) == null || entityId == null) {
      throw _PipelineFailure(
        'Every metadata manifest entity needs entityType and entityId.',
      );
    }
    for (final rawAsset in entity.listValue('assets')) {
      if (rawAsset is! Map) {
        throw _PipelineFailure(
          'Every metadata manifest asset must be an object.',
        );
      }
      final asset = Map<String, dynamic>.from(rawAsset);
      final assetId = asset.stringValue('assetId');
      if (assetId == null) {
        throw _PipelineFailure('A metadata manifest asset is missing assetId.');
      }
      final key = '$entityType:$entityId:$assetId';
      if (metadataByAsset.containsKey(key)) {
        throw _PipelineFailure(
          'The metadata manifest has duplicate asset "$key".',
        );
      }
      metadataByAsset[key] = asset;
    }
  }

  final enrichedEntities = <Map<String, dynamic>>[];
  for (final rawEntity in source.listValue('entities')) {
    if (rawEntity is! Map) {
      throw _PipelineFailure(
        'Every batch shared entity entry must be an object.',
      );
    }
    final entity = Map<String, dynamic>.from(rawEntity);
    final entityType = entity.stringValue('entityType');
    final entityId = entity.intValue('entityId');
    if (_SharedEntityType.fromValue(entityType) == null || entityId == null) {
      throw _PipelineFailure(
        'Every batch shared entity needs entityType and entityId.',
      );
    }
    final enrichedAssets = <Map<String, dynamic>>[];
    for (final rawAsset in entity.listValue('assets')) {
      if (rawAsset is! Map) {
        throw _PipelineFailure('Every batch shared asset must be an object.');
      }
      final asset = Map<String, dynamic>.from(rawAsset);
      final assetId = asset.stringValue('assetId');
      if (assetId == null) {
        throw _PipelineFailure('A batch shared asset is missing assetId.');
      }
      final key = '$entityType:$entityId:$assetId';
      final metadata = metadataByAsset[key];
      if (metadata == null) {
        throw _PipelineFailure(
          'No generated metadata was found for batch asset "$key".',
        );
      }
      for (final field in const ['bytes', 'sha256', 'width', 'height']) {
        final value = metadata[field];
        if (value == null) {
          throw _PipelineFailure(
            'Generated metadata for batch asset "$key" is missing $field.',
          );
        }
        asset[field] = value;
      }
      enrichedAssets.add(asset);
    }
    entity['assets'] = enrichedAssets;
    enrichedEntities.add(entity);
  }

  return {...source, 'entities': enrichedEntities};
}

void _mergeSourceEntities({
  required Map<String, Map<String, dynamic>> target,
  required Map<String, dynamic> source,
  required String label,
  required bool replaceEntityAssets,
  required bool stripLocalFiles,
}) {
  for (final rawEntry in source.listValue('entities')) {
    if (rawEntry is! Map) {
      throw _PipelineFailure(
        'Every $label shared entity entry must be an object.',
      );
    }
    final incoming = Map<String, dynamic>.from(rawEntry);
    final type = incoming.stringValue('entityType');
    final entityId = incoming.intValue('entityId');
    if (_SharedEntityType.fromValue(type) == null ||
        entityId == null ||
        entityId < 1) {
      throw _PipelineFailure(
        '$label shared entity needs a valid entityType and entityId.',
      );
    }
    final key = '$type:$entityId';
    final copiedIncoming = _copySourceEntity(
      incoming,
      '$label $key',
      stripLocalFiles: stripLocalFiles,
    );
    final existing = target[key];
    if (existing == null) {
      target[key] = copiedIncoming;
      continue;
    }

    final existingName = existing.stringValue('entityName');
    final incomingName = copiedIncoming.stringValue('entityName');
    if (existingName != null &&
        incomingName != null &&
        existingName != incomingName) {
      throw _PipelineFailure(
        'Cannot merge $key because names differ: '
        '"$existingName" vs "$incomingName".',
      );
    }
    if (existingName == null && incomingName != null) {
      existing['entityName'] = incomingName;
    }
    if (existing.stringValue('slug') == null &&
        copiedIncoming.stringValue('slug') != null) {
      existing['slug'] = copiedIncoming.stringValue('slug');
    }

    if (replaceEntityAssets) {
      existing['assets'] = copiedIncoming['assets'];
      continue;
    }

    final existingAssets =
        (existing['assets'] as List).cast<Map<String, dynamic>>();
    final assetIds = <String>{
      for (final asset in existingAssets)
        if (asset.stringValue('assetId') != null) asset.stringValue('assetId')!,
    };
    final incomingAssets =
        (copiedIncoming['assets'] as List).cast<Map<String, dynamic>>();
    for (final asset in incomingAssets) {
      final assetId = asset.stringValue('assetId');
      if (assetId == null) {
        throw _PipelineFailure('$label $key has an asset without assetId.');
      }
      if (!assetIds.add(assetId)) {
        throw _PipelineFailure(
          'Duplicate assetId "$assetId" while merging $label $key. '
          'Use --replace-entity-assets to replace the entity media.',
        );
      }
      existingAssets.add(asset);
    }
  }
}

Map<String, dynamic> _copySourceEntity(
  Map<String, dynamic> entity,
  String label, {
  required bool stripLocalFiles,
}) {
  final type = entity.stringValue('entityType');
  final entityId = entity.intValue('entityId');
  if (type == null || entityId == null) {
    throw _PipelineFailure('$label needs entityType and entityId.');
  }
  return {
    'entityType': type,
    'entityId': entityId,
    if (entity.stringValue('entityName') != null)
      'entityName': entity.stringValue('entityName'),
    if (entity.stringValue('slug') != null) 'slug': entity.stringValue('slug'),
    'assets': _copySourceAssets(
      entity,
      label,
      stripLocalFiles: stripLocalFiles,
    ),
  };
}

List<Map<String, dynamic>> _copySourceAssets(
  Map<String, dynamic> entity,
  String label, {
  required bool stripLocalFiles,
}) {
  final assets = <Map<String, dynamic>>[];
  for (final rawAsset in entity.listValue('assets')) {
    if (rawAsset is! Map) {
      throw _PipelineFailure('$label has an asset that is not an object.');
    }
    final asset = Map<String, dynamic>.from(rawAsset);
    if (asset.stringValue('assetId') == null) {
      throw _PipelineFailure('$label has an asset without assetId.');
    }
    if (stripLocalFiles) asset.remove('localFile');
    assets.add(asset);
  }
  if (assets.isEmpty) {
    throw _PipelineFailure('$label has no assets.');
  }
  return assets;
}

Future<_BuildResult> _buildResult(_CliOptions options) async {
  final source = await _loadJsonMap(options.requiredValue('source'));
  final index = await _SharedEntityIndex.load(
    equipmentPath: options.value('equipment') ?? 'assets/equipment.json',
    bodypartsPath: options.value('bodyparts') ?? 'assets/bodyparts.json',
    musclesPath: options.value('muscles') ?? 'assets/muscles.json',
  );
  final builder = _SharedMediaBuilder(
    source: source,
    index: index,
    baseUrl: options.value('base-url') ?? source.stringValue('baseUrl'),
    version: options.intValue('version') ?? source.intValue('version') ?? 1,
    checkRemote: options.flag('check-remote'),
    requireHashes: options.flag('require-hashes'),
    requireLicenses: options.flag('require-licenses'),
    requireDimensions: options.flag('require-dimensions'),
    quality: _SharedMediaQuality.fromOptions(options),
  );
  return builder.build();
}

class _SharedMediaBuilder {
  _SharedMediaBuilder({
    required this.source,
    required this.index,
    required this.baseUrl,
    required this.version,
    required this.checkRemote,
    required this.requireHashes,
    required this.requireLicenses,
    required this.requireDimensions,
    required this.quality,
  });

  final Map<String, dynamic> source;
  final _SharedEntityIndex index;
  final String? baseUrl;
  final int version;
  final bool checkRemote;
  final bool requireHashes;
  final bool requireLicenses;
  final bool requireDimensions;
  final _SharedMediaQuality quality;
  final List<_Message> _messages = [];
  final Set<String> _assetIds = {};
  final Set<String> _urls = {};
  final Set<String> _entityKeys = {};
  final List<_UploadFile> _uploadFiles = [];

  Future<_BuildResult> build() async {
    if (version < 1) _error('Manifest version must be 1 or greater.');
    final outputEntities = <Map<String, dynamic>>[];
    var assetCount = 0;

    for (final rawEntry in source.listValue('entities')) {
      if (rawEntry is! Map) {
        _error('Skipping a shared entity because it is not an object.');
        continue;
      }
      final entry = Map<String, dynamic>.from(rawEntry);
      final type = _SharedEntityType.fromValue(entry.stringValue('entityType'));
      final entityId = entry.intValue('entityId');
      if (type == null || entityId == null) {
        _error('Every entity requires a valid entityType and entityId.');
        continue;
      }
      final entity = index.lookup(type, entityId);
      if (entity == null) {
        _error('${type.value} ID $entityId is not in the local catalog.');
        continue;
      }
      final sourceName = entry.stringValue('entityName');
      if (sourceName != null &&
          _normalize(sourceName) != _normalize(entity.name)) {
        _error(
          '${type.value} ID $entityId is ${entity.name}, not "$sourceName".',
        );
        continue;
      }
      final entityKey = '${type.value}:$entityId';
      if (!_entityKeys.add(entityKey)) {
        _error('Duplicate entity $entityKey (${entity.name}).');
        continue;
      }

      final assets = <Map<String, dynamic>>[];
      var assetIndex = 0;
      for (final rawAsset in entry.listValue('assets')) {
        if (rawAsset is! Map) {
          _error('Skipping an asset for ${entity.name}; it is not an object.');
          continue;
        }
        final asset = await _buildAsset(
          type: type,
          entity: entity,
          source: Map<String, dynamic>.from(rawAsset),
          sortOrder: assetIndex,
        );
        assetIndex += 1;
        if (asset != null) assets.add(asset);
      }
      if (assets.isEmpty) {
        _warning('No valid assets found for ${entity.name}.');
        continue;
      }
      assetCount += assets.length;
      outputEntities.add({
        'entityType': type.value,
        'entityId': entity.id,
        'slug': entry.stringValue('slug') ?? _slugify(entity.name),
        'assets': assets,
      });
    }

    final manifest = <String, dynamic>{
      'namespace': source.stringValue('namespace') ?? 'shared_media',
      'version': version,
      'generatedAt': DateTime.now().toUtc().toIso8601String(),
      'entities': outputEntities,
    };
    final coverage = index.coverageFor(outputEntities);
    return _BuildResult(
      manifest: manifest,
      messages: _messages,
      entityCount: outputEntities.length,
      assetCount: assetCount,
      coverage: coverage,
      uploadFiles: _uploadFiles,
    );
  }

  Future<Map<String, dynamic>?> _buildAsset({
    required _SharedEntityType type,
    required _CatalogEntity entity,
    required Map<String, dynamic> source,
    required int sortOrder,
  }) async {
    final assetId = source.stringValue('assetId');
    final path = source.stringValue('path');
    if (assetId == null || assetId.isEmpty) {
      _error('${type.value} ${entity.name} has an asset without assetId.');
      return null;
    }
    if (!_assetIds.add(assetId)) {
      _error('Duplicate assetId "$assetId".');
      return null;
    }
    if (path == null || path.isEmpty) {
      _error('Asset "$assetId" is missing path.');
      return null;
    }
    final url = _resolveUrl(path);
    if (url == null) {
      _error('Asset "$assetId" needs an absolute URL or baseUrl.');
      return null;
    }
    if (!_urls.add(url)) _error('Duplicate media URL "$url".');

    final localFilePath = source.stringValue('localFile');
    File? localFile;
    var bytes = source.intValue('bytes');
    var hash = source.stringValue('sha256');
    if (localFilePath != null && localFilePath.isNotEmpty) {
      localFile = File(localFilePath);
      if (!await localFile.exists()) {
        _error('Asset "$assetId" localFile does not exist: $localFilePath');
      } else {
        final content = await localFile.readAsBytes();
        bytes = content.length;
        hash = sha256.convert(content).toString();
        _uploadFiles.add(
          _UploadFile(localPath: localFilePath, objectPath: path),
        );
      }
    }

    if (checkRemote) {
      await _checkRemote(assetId, url);
    }

    final width = source.intValue('width');
    final height = source.intValue('height');
    final licenseId = source.stringValue('licenseId');
    if (requireHashes && (hash == null || hash.isEmpty)) {
      _error('Asset "$assetId" is missing sha256.');
    }
    if (requireLicenses && (licenseId == null || licenseId.isEmpty)) {
      _error('Asset "$assetId" is missing licenseId.');
    }
    if (requireDimensions && (width == null || height == null)) {
      _error('Asset "$assetId" is missing width or height.');
    }
    if (bytes != null && bytes > quality.maxBytes) {
      _warning('Asset "$assetId" is $bytes bytes, above ${quality.maxBytes}.');
    }
    if (width != null && width < quality.minWidth) {
      _warning('Asset "$assetId" width $width is below ${quality.minWidth}.');
    }
    if (height != null && height < quality.minHeight) {
      _warning(
        'Asset "$assetId" height $height is below ${quality.minHeight}.',
      );
    }

    return _withoutNulls({
      'assetId': assetId,
      'type': source.stringValue('type') ?? 'thumbnail',
      'url': url,
      'thumbnailUrl': source.stringValue('thumbnailUrl'),
      'title': source.stringValue('title') ?? '${entity.name} thumbnail',
      'sortOrder': sortOrder,
      'version': source.intValue('version') ?? 1,
      'bytes': bytes,
      'width': width,
      'height': height,
      'sha256': hash,
      'licenseId': licenseId,
    });
  }

  String? _resolveUrl(String path) {
    final uri = Uri.tryParse(path);
    if (uri != null && uri.hasScheme) return uri.toString();
    final base = baseUrl?.trim();
    if (base == null || base.isEmpty) return null;
    return '${base.replaceFirst(RegExp(r'/+$'), '')}/${path.replaceFirst(RegExp(r'^/+'), '')}';
  }

  Future<void> _checkRemote(String assetId, String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) {
      _error('Asset "$assetId" has an invalid URL "$url".');
      return;
    }
    final client =
        HttpClient()..connectionTimeout = const Duration(seconds: 15);
    try {
      final request = await client.headUrl(uri);
      final response = await request.close();
      if (response.statusCode < 200 || response.statusCode >= 300) {
        _error(
          'URL check failed for "$assetId": HTTP ${response.statusCode} $url',
        );
      }
    } catch (error) {
      _error('URL check failed for "$assetId": $error');
    } finally {
      client.close(force: true);
    }
  }

  void _error(String text) => _messages.add(_Message.error(text));
  void _warning(String text) => _messages.add(_Message.warning(text));
}

class _SharedEntityIndex {
  final Map<_SharedEntityType, Map<int, _CatalogEntity>> _entities;

  const _SharedEntityIndex(this._entities);

  static Future<_SharedEntityIndex> load({
    required String equipmentPath,
    required String bodypartsPath,
    required String musclesPath,
  }) async {
    return _SharedEntityIndex({
      _SharedEntityType.equipment: await _loadCatalog(equipmentPath),
      _SharedEntityType.bodypart: await _loadCatalog(bodypartsPath),
      _SharedEntityType.muscle: await _loadCatalog(musclesPath),
    });
  }

  _CatalogEntity? lookup(_SharedEntityType type, int id) =>
      _entities[type]?[id];

  Map<String, dynamic> coverageFor(List<Map<String, dynamic>> entries) {
    final coveredByType = <_SharedEntityType, Set<int>>{
      for (final type in _SharedEntityType.values) type: <int>{},
    };
    for (final entry in entries) {
      final type = _SharedEntityType.fromValue(entry.stringValue('entityType'));
      final id = entry.intValue('entityId');
      if (type != null && id != null) coveredByType[type]!.add(id);
    }
    final types = <String, dynamic>{};
    for (final type in _SharedEntityType.values) {
      final total = _entities[type]!.length;
      final covered = coveredByType[type]!.length;
      types[type.value] = {
        'total': total,
        'covered': covered,
        'missing': total - covered,
        'coveragePercent': double.parse(
          (total == 0 ? 0 : covered * 100 / total).toStringAsFixed(1),
        ),
      };
    }
    return {'types': types};
  }
}

Future<Map<int, _CatalogEntity>> _loadCatalog(String path) async {
  final decoded = jsonDecode(await File(path).readAsString());
  if (decoded is! List) {
    throw _PipelineFailure('Expected a JSON list in $path.');
  }
  final result = <int, _CatalogEntity>{};
  for (var index = 0; index < decoded.length; index++) {
    final value = decoded[index];
    if (value is! Map) continue;
    final name = Map<String, dynamic>.from(value).stringValue('name');
    if (name == null || name.isEmpty) continue;
    result[index + 1] = _CatalogEntity(id: index + 1, name: name);
  }
  return result;
}

class _CatalogEntity {
  final int id;
  final String name;

  const _CatalogEntity({required this.id, required this.name});
}

enum _SharedEntityType {
  equipment('equipment'),
  bodypart('bodypart'),
  muscle('muscle');

  final String value;

  const _SharedEntityType(this.value);

  static _SharedEntityType? fromValue(String? value) {
    switch ((value ?? '').trim().toLowerCase()) {
      case 'equipment':
        return equipment;
      case 'bodypart':
      case 'bodyparts':
      case 'body_part':
        return bodypart;
      case 'muscle':
      case 'muscles':
        return muscle;
      default:
        return null;
    }
  }
}

class _SharedMediaQuality {
  final int minWidth;
  final int minHeight;
  final int maxBytes;

  const _SharedMediaQuality({
    required this.minWidth,
    required this.minHeight,
    required this.maxBytes,
  });

  factory _SharedMediaQuality.fromOptions(_CliOptions options) {
    final preset = options.value('quality-preset');
    if (preset != null && preset != 'shared-thumbnail') {
      throw _PipelineFailure(
        'Unknown --quality-preset "$preset". Use shared-thumbnail.',
      );
    }
    return _SharedMediaQuality(
      minWidth: options.intValue('min-width') ?? 128,
      minHeight: options.intValue('min-height') ?? 128,
      maxBytes: options.intValue('max-bytes') ?? 100000,
    );
  }
}

class _BuildResult {
  final Map<String, dynamic> manifest;
  final List<_Message> messages;
  final int entityCount;
  final int assetCount;
  final Map<String, dynamic> coverage;
  final List<_UploadFile> uploadFiles;

  const _BuildResult({
    required this.manifest,
    required this.messages,
    required this.entityCount,
    required this.assetCount,
    required this.coverage,
    required this.uploadFiles,
  });

  bool get hasErrors => messages.any((message) => message.isError);
  bool get hasWarnings => messages.any((message) => message.isWarning);

  String get coverageLabel {
    final types = coverage['types'] as Map<String, dynamic>;
    return types.entries
        .map((entry) {
          final value = entry.value as Map<String, dynamic>;
          return '${entry.key} ${value['covered']}/${value['total']}';
        })
        .join(', ');
  }
}

class _UploadFile {
  final String localPath;
  final String objectPath;

  const _UploadFile({required this.localPath, required this.objectPath});
}

class _Message {
  final bool isError;
  final String text;

  const _Message._({required this.isError, required this.text});

  factory _Message.error(String text) => _Message._(isError: true, text: text);
  factory _Message.warning(String text) =>
      _Message._(isError: false, text: text);

  bool get isWarning => !isError;
}

class _CliOptions {
  final Map<String, String> _values;
  final Set<String> _flags;

  const _CliOptions(this._values, this._flags);

  factory _CliOptions.parse(Iterable<String> values) {
    final parsedValues = <String, String>{};
    final flags = <String>{};
    final list = values.toList();
    for (var index = 0; index < list.length; index++) {
      final current = list[index];
      if (!current.startsWith('--')) continue;
      final key = current.substring(2);
      final next = index + 1 < list.length ? list[index + 1] : null;
      if (next == null || next.startsWith('--')) {
        flags.add(key);
      } else {
        parsedValues[key] = next;
        index += 1;
      }
    }
    return _CliOptions(parsedValues, flags);
  }

  String? value(String key) => _values[key];

  String requiredValue(String key) {
    final value = _values[key];
    if (value == null || value.isEmpty) {
      throw _PipelineFailure('Missing required --$key option.');
    }
    return value;
  }

  int? intValue(String key) => int.tryParse(_values[key] ?? '');
  bool flag(String key) => _flags.contains(key);

  _CliOptions withForcedFlags(Set<String> flags) {
    return _CliOptions(_values, {..._flags, ...flags});
  }
}

extension on Map<String, dynamic> {
  String? stringValue(String key) {
    final value = this[key];
    if (value is! String) return null;
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  int? intValue(String key) {
    final value = this[key];
    return value is num ? value.toInt() : null;
  }

  List<dynamic> listValue(String key) {
    final value = this[key];
    return value is List ? value : const [];
  }
}

Map<String, dynamic> _withoutNulls(Map<String, dynamic> value) {
  value.removeWhere((_, item) => item == null);
  return value;
}

Future<Map<String, dynamic>> _loadJsonMap(String path) async {
  final decoded = jsonDecode(await File(path).readAsString());
  if (decoded is! Map) {
    throw _PipelineFailure('Expected a JSON object in $path.');
  }
  return Map<String, dynamic>.from(decoded);
}

Future<void> _writeJson(String path, Map<String, dynamic> value) async {
  final file = File(path);
  await file.parent.create(recursive: true);
  await file.writeAsString(
    '${const JsonEncoder.withIndent('  ').convert(value)}\n',
  );
}

Future<void> _writeUploadScriptIfRequested(
  _CliOptions options,
  _BuildResult result,
) async {
  final scriptPath = options.value('upload-script');
  if (scriptPath == null) return;
  final bucket = options.requiredValue('bucket');
  final outputPath = options.requiredValue('output');
  final manifestObject =
      options.value('manifest-object') ??
      'manifests/shared_media_manifest.json';
  final lines = <String>[
    "\$ErrorActionPreference = 'Stop'",
    '',
    for (final file in result.uploadFiles)
      "wrangler r2 object put '$bucket/${file.objectPath}' "
          "--file '${file.localPath}' "
          "--content-type '${_contentTypeFor(file.objectPath)}' "
          '--remote',
    '',
    "wrangler r2 object put '$bucket/$manifestObject' "
        "--file '$outputPath' "
        "--content-type 'application/json' "
        '--remote',
    '',
  ];
  final file = File(scriptPath);
  await file.parent.create(recursive: true);
  await file.writeAsString(lines.join('\n'));
  stdout.writeln('Wrote upload script to $scriptPath.');
}

void _printMessages(List<_Message> messages) {
  for (final message in messages) {
    stdout.writeln(
      '[${message.isError ? 'ERROR' : 'WARNING'}] ${message.text}',
    );
  }
}

String _normalize(String value) => value.trim().toLowerCase();

String _slugify(String value) {
  return value
      .toLowerCase()
      .replaceAll(RegExp(r'[^a-z0-9]+'), '_')
      .replaceAll(RegExp(r'^_+|_+$'), '');
}

String _contentTypeFor(String path) {
  final lower = path.toLowerCase();
  if (lower.endsWith('.png')) return 'image/png';
  if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
  if (lower.endsWith('.webp')) return 'image/webp';
  if (lower.endsWith('.json')) return 'application/json';
  return 'application/octet-stream';
}

int? _maxInt(int? first, int? second) {
  if (first == null) return second;
  if (second == null) return first;
  return first > second ? first : second;
}

void _printHelp() {
  stdout.writeln('''
Tonos shared media pipeline

Commands:
  validate-shared-media       Validate equipment, bodypart, and muscle source JSON.
  build-shared-media          Build an app-ready shared media manifest.
  release-check-shared-media  Remote-check and gate a manifest before publishing.
  coverage-shared-media       Report coverage across all three entity types.
  merge-shared-media-source   Merge a validated batch source into a base source.

Common options:
  --source <path>             Source JSON describing shared media.
  --base-url <url>            CDN/R2 public base URL.
  --version <number>          Manifest version.
  --equipment <path>          Equipment JSON, defaults to assets/equipment.json.
  --bodyparts <path>          Bodyparts JSON, defaults to assets/bodyparts.json.
  --muscles <path>            Muscles JSON, defaults to assets/muscles.json.
  --check-remote              HEAD-check generated URLs.
  --strict                    Treat warnings as failures.
  --require-hashes            Require sha256 for every asset.
  --require-licenses          Require licenseId for every asset.
  --require-dimensions        Require width and height metadata.
  --quality-preset shared-thumbnail
                              Apply shared-thumbnail quality defaults.
  --min-width <pixels>        Default 128.
  --min-height <pixels>       Default 128.
  --max-bytes <bytes>         Default 100000.

Build/release options:
  --output <path>             Generated manifest path.
  --upload-script <path>      Optional PowerShell upload script path.
  --bucket <name>             R2 bucket for the upload script.
  --manifest-object <key>     Defaults to manifests/shared_media_manifest.json.
  --report <path>             Optional release coverage report path.

Merge options:
  --base <path>               Existing source JSON.
  --batch <path>              Batch source JSON to merge.
  --metadata-manifest <path>  Generated batch manifest to preserve hashes and
                              dimensions when stripping local files.
  --output <path>             Merged source JSON path.
  --bump-version              Increase the base source version by 1.
  --replace-entity-assets     Replace media on matching shared entities.
  --strip-local-files         Remove localFile paths from merged output.
''');
}

class _PipelineFailure implements Exception {
  final String message;

  const _PipelineFailure(this.message);
}
