import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test(
    'bundled content environments have explicit allowlisted HTTPS hosts',
    () {
      final root =
          jsonDecode(
                File(
                  'assets/content/content_environments.json',
                ).readAsStringSync(),
              )
              as Map<String, dynamic>;
      final environments = root['environments'] as List<dynamic>;

      expect(environments, isNotEmpty);
      final productionEnvironments = environments.where(
        (entry) => (entry as Map<String, dynamic>)['isProduction'] == true,
      );
      expect(productionEnvironments, hasLength(1));
      expect(
        (productionEnvironments.single as Map<String, dynamic>)['id'],
        'production',
      );

      final productionHosts = <String>{};
      final nonProductionHosts = <String>{};
      for (final rawEnvironment in environments) {
        final environment = rawEnvironment as Map<String, dynamic>;
        final hostList =
            (environment['allowedManifestHosts'] as List<dynamic>)
                .cast<String>();
        final hosts = hostList.toSet();
        expect(hosts, isNotEmpty);
        expect(hosts, hasLength(hostList.length));
        for (final host in hosts) {
          expect(host, host.trim().toLowerCase());
        }
        (environment['isProduction'] == true
                ? productionHosts
                : nonProductionHosts)
            .addAll(hosts);
        for (final key in [
          'exerciseMediaManifestUrl',
          'sharedMediaManifestUrl',
        ]) {
          final uri = Uri.parse(environment[key] as String);
          expect(uri.scheme, 'https');
          expect(uri.hasPort, isFalse);
          expect(uri.userInfo, isEmpty);
          expect(hosts, contains(uri.host.toLowerCase()));
        }
      }
      expect(productionHosts.intersection(nonProductionHosts), isEmpty);
    },
  );

  test('release workflows use explicit locked content targets', () {
    final ci = File('.github/workflows/ci.yml').readAsStringSync();
    final production =
        File('.github/workflows/production-release.yml').readAsStringSync();

    expect(ci, contains('tools/content_environment_check.dart'));
    expect(ci, contains('--target development'));
    expect(ci, contains('TONOS_CONTENT_ENVIRONMENT=development'));
    expect(ci, contains('TONOS_CONTENT_ALLOW_OVERRIDES=false'));

    expect(production, contains('tools/content_environment_check.dart'));
    expect(production, contains('--target production'));
    expect(production, contains('--locked'));
    expect(production, contains('TONOS_CONTENT_ENVIRONMENT=production'));
    expect(production, contains('TONOS_CONTENT_ALLOW_OVERRIDES=false'));
    expect(production, isNot(contains('TONOS_ENVIRONMENT=')));
  });

  test('runtime locks release overrides and scopes cloud metadata', () {
    final settings =
        File(
          'lib/screens/profile/settings/database_settings_page.dart',
        ).readAsStringSync();
    final repository =
        File('lib/repositories/content_repository.dart').readAsStringSync();
    final dao = File('lib/db/content_dao.dart').readAsStringSync();
    final preflight =
        File('tools/content_environment_check.dart').readAsStringSync();

    expect(settings, contains('allowsRuntimeOverrides'));
    expect(settings, contains('Icons.lock_outline'));
    expect(repository, contains('ContentEnvironmentScopeAction.reset'));
    expect(repository, contains('clearEnvironmentScopedContent'));
    expect(repository, contains('requireSelectedManifestUri'));
    expect(dao, contains("await txn.delete('exercise_media')"));
    expect(dao, contains("await txn.delete('shared_media')"));
    expect(
      preflight,
      contains('A production content target requires --locked'),
    );
    expect(preflight, contains('allowedManifestHosts'));
  });
}
