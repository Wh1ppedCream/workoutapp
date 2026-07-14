import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('database schema contract', () {
    test(
      'database helper version is wired into create and upgrade migrations',
      () {
        final helper = File('lib/db/database_helper.dart').readAsStringSync();
        final schema = File('lib/db/schema.dart').readAsStringSync();
        final versionMatch = RegExp(
          r'static const int _kDbVersion = (\d+);',
        ).firstMatch(helper);

        expect(versionMatch, isNotNull);
        final version = versionMatch!.group(1)!;

        expect(schema, contains('await migrateV$version(db);'));
        expect(
          schema,
          contains('if (oldVersion < $version) await migrateV$version(db);'),
        );
      },
    );

    test('latest food catalog schema includes local search essentials', () {
      final sql = File('lib/db/schema_latest.sql').readAsStringSync();

      expect(sql, contains('CREATE TABLE IF NOT EXISTS foods'));
      expect(sql, contains('CREATE TABLE IF NOT EXISTS food_portions'));
      expect(sql, contains('CREATE TABLE IF NOT EXISTS food_barcodes'));
      expect(sql, contains('CREATE TABLE IF NOT EXISTS food_nutrient_values'));
      expect(
        sql,
        contains('CREATE VIRTUAL TABLE IF NOT EXISTS food_search_fts'),
      );
      expect(sql, contains('trg_portion_single_default_ins'));
      expect(sql, contains('trg_portion_single_default_upd'));
    });

    test('latest migration includes durable workout state', () {
      final schema = File('lib/db/schema.dart').readAsStringSync();

      expect(schema, contains('CREATE TABLE IF NOT EXISTS active_workout_draft'));
      expect(schema, contains('CREATE TABLE IF NOT EXISTS active_plans'));
      expect(schema, contains('CHECK (id = 1)'));
      expect(schema, contains('PRIMARY KEY(profile_id, preset_id)'));
    });
  });
}
