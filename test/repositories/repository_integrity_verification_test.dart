import 'package:env_test/db/database_helper.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite/sqflite.dart';

void main() {
  for (final entry in <String, List<Map<String, Object?>>>{
    'healthy': [
      {'quick_check': 'ok'},
    ],
    'corrupt': [
      {'quick_check': 'Page 7: invalid page type'},
    ],
    'mixed': [
      {'quick_check': 'ok'},
      {'quick_check': 'broken index'},
    ],
    'empty': [],
  }.entries) {
    test('verification inspects the $entry quick_check result', () async {
      final db = _IntegrityDatabase()..rows = entry.value;
      final repo = _IntegrityRepository(db);
      expect(await repo.warmUp(verify: true), entry.key == 'healthy');
      expect(db.checks, 1);
    });
  }

  test('verification reports a query failure without throwing', () async {
    final db = _IntegrityDatabase()..fail = true;
    expect(await _IntegrityRepository(db).warmUp(verify: true), isFalse);
  });

  test('ordinary warmup does not perform an integrity scan', () async {
    final db = _IntegrityDatabase()..fail = true;
    expect(await _IntegrityRepository(db).warmUp(), isTrue);
    expect(db.checks, 0);
  });
}

class _IntegrityRepository extends AppRepository {
  _IntegrityRepository(Database db) : super(db: _DatabaseHelper(db));
  @override
  Future<void> ensureExerciseMediaManifestReady() async {}
  @override
  Future<void> ensureSharedMediaManifestReady() async {}
  @override
  Future<void> reconcileMediaCache() async {}
}

class _DatabaseHelper implements DatabaseHelper {
  _DatabaseHelper(this.value);
  final Database value;
  @override
  Future<Database> get database async => value;
  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

class _IntegrityDatabase implements Database {
  List<Map<String, Object?>> rows = [];
  bool fail = false;
  int checks = 0;
  @override
  Future<List<Map<String, Object?>>> rawQuery(
    String sql, [
    List<Object?>? arguments,
  ]) async {
    expect(sql, 'PRAGMA quick_check');
    checks++;
    if (fail) throw StateError('Check failed');
    return rows;
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}
