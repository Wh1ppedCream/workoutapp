// ignore_for_file: prefer_interpolation_to_compose_strings

import 'dart:convert';
import 'dart:io';

void main(List<String> arguments) {
  try {
    final options = _Options.parse(arguments);
    final source = File(options.sourcePath);
    if (!source.existsSync()) {
      throw FormatException(
        'Content environment configuration was not found: ' +
            options.sourcePath,
      );
    }

    final decoded = jsonDecode(source.readAsStringSync());
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException(
        'Content environment configuration must be a JSON object.',
      );
    }

    final result = _validateConfiguration(
      decoded,
      targetEnvironmentId: options.targetEnvironmentId,
      locked: options.locked,
    );
    stdout.writeln(
      'Validated content target "' +
          result.targetId +
          '" with ' +
          result.environmentCount.toString() +
          ' configured environment(s).',
    );
  } on FormatException catch (error) {
    stderr.writeln('Content environment preflight failed: ' + error.message);
    exitCode = 64;
  } on FileSystemException catch (error) {
    stderr.writeln(
      'Content environment preflight could not read its source: ' +
          error.message,
    );
    exitCode = 66;
  }
}

class _Options {
  const _Options({
    required this.sourcePath,
    required this.targetEnvironmentId,
    required this.locked,
  });

  final String sourcePath;
  final String targetEnvironmentId;
  final bool locked;

  static _Options parse(List<String> arguments) {
    String? sourcePath;
    String? targetEnvironmentId;
    var locked = false;

    for (var index = 0; index < arguments.length; index++) {
      final argument = arguments[index];
      switch (argument) {
        case '--source':
          sourcePath = _nextValue(arguments, ++index, argument);
          break;
        case '--target':
          targetEnvironmentId = _nextValue(arguments, ++index, argument);
          break;
        case '--locked':
          locked = true;
          break;
        default:
          throw FormatException('Unknown option: ' + argument);
      }
    }

    if (sourcePath == null || sourcePath.trim().isEmpty) {
      throw const FormatException('Missing required option --source.');
    }
    if (targetEnvironmentId == null || targetEnvironmentId.trim().isEmpty) {
      throw const FormatException('Missing required option --target.');
    }

    return _Options(
      sourcePath: sourcePath.trim(),
      targetEnvironmentId: targetEnvironmentId.trim(),
      locked: locked,
    );
  }

  static String _nextValue(List<String> arguments, int index, String option) {
    if (index >= arguments.length || arguments[index].startsWith('--')) {
      throw FormatException('Missing value for ' + option + '.');
    }
    return arguments[index];
  }
}

class _ValidationResult {
  const _ValidationResult({
    required this.targetId,
    required this.environmentCount,
  });

  final String targetId;
  final int environmentCount;
}

_ValidationResult _validateConfiguration(
  Map<String, dynamic> root, {
  required String targetEnvironmentId,
  required bool locked,
}) {
  final defaultEnvironmentId = _requiredString(
    root,
    'defaultEnvironment',
    context: 'configuration',
  );
  final rawEnvironments = root['environments'];
  if (rawEnvironments is! List || rawEnvironments.isEmpty) {
    throw const FormatException(
      'At least one content environment must be configured.',
    );
  }

  final environments = <String, _Environment>{};
  for (final rawEnvironment in rawEnvironments) {
    if (rawEnvironment is! Map) {
      throw const FormatException(
        'Every content environment must be a JSON object.',
      );
    }
    final environment = _Environment.fromJson(
      Map<String, dynamic>.from(rawEnvironment),
    );
    if (environments.containsKey(environment.id)) {
      throw FormatException(
        'Duplicate content environment ID: ' + environment.id,
      );
    }
    environments[environment.id] = environment;
  }

  if (!environments.containsKey(defaultEnvironmentId)) {
    throw FormatException(
      'Default content environment is not configured: ' + defaultEnvironmentId,
    );
  }

  final productionEnvironments = environments.values.where(
    (environment) => environment.isProduction,
  );
  if (productionEnvironments.length != 1) {
    throw const FormatException(
      'Exactly one content environment must be marked as production.',
    );
  }
  if (productionEnvironments.single.id != 'production') {
    throw const FormatException(
      'The production content environment must use the ID "production".',
    );
  }

  final target = environments[targetEnvironmentId];
  if (target == null) {
    throw FormatException(
      'Requested content target is not configured: ' + targetEnvironmentId,
    );
  }
  if (targetEnvironmentId == 'production' && !target.isProduction) {
    throw const FormatException(
      'The production target must be marked as production.',
    );
  }
  if (target.isProduction && !locked) {
    throw const FormatException(
      'A production content target requires --locked.',
    );
  }

  final productionHosts = <String>{};
  final nonProductionHosts = <String>{};
  for (final environment in environments.values) {
    final destination =
        environment.isProduction ? productionHosts : nonProductionHosts;
    destination.addAll(environment.allowedManifestHosts);
  }
  final sharedHosts = productionHosts.intersection(nonProductionHosts);
  if (sharedHosts.isNotEmpty) {
    throw FormatException(
      'Production and non-production manifest hosts must be distinct: ' +
          (sharedHosts.toList()..sort()).join(', '),
    );
  }

  return _ValidationResult(
    targetId: target.id,
    environmentCount: environments.length,
  );
}

class _Environment {
  const _Environment({
    required this.id,
    required this.isProduction,
    required this.allowedManifestHosts,
  });

  final String id;
  final bool isProduction;
  final Set<String> allowedManifestHosts;

  factory _Environment.fromJson(Map<String, dynamic> json) {
    final id = _requiredString(json, 'id', context: 'environment');
    final rawHosts = json['allowedManifestHosts'];
    if (rawHosts is! List || rawHosts.isEmpty) {
      throw FormatException(
        'Content environment "' + id + '" requires allowedManifestHosts.',
      );
    }

    final hosts = <String>{};
    for (final rawHost in rawHosts) {
      if (rawHost is! String || rawHost.trim().isEmpty) {
        throw FormatException(
          'Content environment "' + id + '" has an invalid allowed host.',
        );
      }
      final host = rawHost.trim();
      if (host != rawHost || host != host.toLowerCase()) {
        throw FormatException(
          'Allowed manifest hosts must be trimmed and lowercase: ' + rawHost,
        );
      }
      if (!hosts.add(host)) {
        throw FormatException(
          'Content environment "' + id + '" repeats allowed host ' + host + '.',
        );
      }
    }

    for (final key in ['exerciseMediaManifestUrl', 'sharedMediaManifestUrl']) {
      final value = _requiredString(
        json,
        key,
        context: 'environment "' + id + '"',
      );
      final uri = Uri.tryParse(value);
      if (uri == null ||
          uri.scheme != 'https' ||
          uri.host.isEmpty ||
          uri.hasPort ||
          uri.userInfo.isNotEmpty) {
        throw FormatException(
          'Content environment "' +
              id +
              '" has an invalid HTTPS manifest URL for ' +
              key +
              '.',
        );
      }
      if (!hosts.contains(uri.host.toLowerCase())) {
        throw FormatException(
          'Manifest host "' +
              uri.host +
              '" is not allowlisted for environment "' +
              id +
              '".',
        );
      }
    }

    return _Environment(
      id: id,
      isProduction: json['isProduction'] == true,
      allowedManifestHosts: hosts,
    );
  }
}

String _requiredString(
  Map<String, dynamic> json,
  String key, {
  required String context,
}) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException(context + ' requires a non-empty "' + key + '".');
  }
  return value.trim();
}
