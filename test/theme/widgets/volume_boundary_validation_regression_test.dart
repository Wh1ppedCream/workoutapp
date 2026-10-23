import 'package:env_test/db/analytics_dao.dart';
import 'package:env_test/l10n/generated/app_localizations.dart';
import 'package:env_test/l10n/tonos_localization_delegates.dart';
import 'package:env_test/models/models.dart';
import 'package:env_test/repositories/app_repository.dart';
import 'package:env_test/screens/profile/settings/volume_boundaries_screen.dart';
import 'package:env_test/theme/expressive_theme.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:provider/provider.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

VolumeBoundaries _bounds(List<double> values) => VolumeBoundaries(
  id: 1,
  maintenance: values[0],
  minEffective: values[1],
  maxAdaptive: values[2],
  maxRecoverable: values[3],
);

class _Repository extends AppRepository {
  final saved = <VolumeBoundaries>[];
  @override
  Future<List<BodyPart>> fetchAllBodyPartsFull() async => [
    BodyPart(1, 'Chest'),
  ];
  @override
  Future<List<Muscle>> fetchAllMusclesFull() async => [
    Muscle(id: 1, name: 'Pectorals'),
  ];
  @override
  Future<VolumeBoundaries?> fetchBodyPartVolumeBounds(int bodyPartId) async =>
      _bounds([4, 6, 12, 20]);
  @override
  Future<VolumeBoundaries?> fetchMuscleVolumeBounds(int muscleId) async =>
      _bounds([4, 6, 12, 20]);
  @override
  Future<int> setBodyPartVolumeBounds(
    int bodypartId,
    VolumeBoundaries bounds,
  ) async {
    saved.add(bounds);
    return 1;
  }
}

void main() {
  test(
    'volume DAO validates before writing and tolerates invalid legacy rows',
    () async {
      sqfliteFfiInit();
      final db = await databaseFactoryFfi.openDatabase(inMemoryDatabasePath);
      addTearDown(db.close);
      for (final entity in ['muscle', 'bodypart']) {
        await db.execute('''CREATE TABLE ${entity}_volume_boundaries (
        ${entity}_id INTEGER PRIMARY KEY, maintenance_volume REAL,
        min_effective_volume REAL, max_adaptive_volume REAL, max_recoverable_volume REAL
      )''');
      }
      await AnalyticsDao.setBodyPartVolumeBoundaries(
        db,
        1,
        _bounds([4, 6, 12, 20]),
      );
      for (final values in [
        [-1.0, 6.0, 12.0, 20.0],
        [4.0, 3.0, 12.0, 20.0],
        [4.0, 6.0, double.infinity, 20.0],
        [double.nan, 6.0, 12.0, 20.0],
      ]) {
        await expectLater(
          Future.sync(
            () => AnalyticsDao.setBodyPartVolumeBoundaries(
              db,
              1,
              _bounds(values),
            ),
          ),
          throwsArgumentError,
        );
        await expectLater(
          Future.sync(
            () =>
                AnalyticsDao.setMuscleVolumeBoundaries(db, 1, _bounds(values)),
          ),
          throwsArgumentError,
        );
      }
      final valid = await AnalyticsDao.getBodyPartVolumeBoundaries(db, 1);
      expect(valid!.maintenance, 4);
      await db.rawUpdate(
        'UPDATE bodypart_volume_boundaries SET max_adaptive_volume = ?',
        [double.infinity],
      );
      expect(await AnalyticsDao.getBodyPartVolumeBoundaries(db, 1), isNull);
    },
  );

  testWidgets(
    'volume editor rejects invalid bounds and preserves valid zero and decimals',
    (tester) async {
      await tester.binding.setSurfaceSize(const Size(430, 1200));
      addTearDown(() => tester.binding.setSurfaceSize(null));
      final repository = _Repository();
      await tester.pumpWidget(
        Provider<AppRepository>.value(
          value: repository,
          child: MaterialApp(
            theme: ExpressiveThemeDefinition.light(),
            localizationsDelegates: tonosLocalizationDelegates,
            supportedLocales: AppLocalizations.supportedLocales,
            home: const VolumeBoundariesScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final fields = tester
          .widgetList<TextFormField>(find.byType(TextFormField))
          .toList();
      final strings = AppLocalizations.of(
        tester.element(find.byType(VolumeBoundariesScreen)),
      );
      for (final values in [
        ['-1', '6', '12', '20'],
        ['NaN', '6', '12', '20'],
        ['4', '3', '12', '20'],
        ['4', '6', 'Infinity', '20'],
        ['4', '6', '12', '10'],
      ]) {
        for (var i = 0; i < 4; i++) {
          fields[i].controller!.text = values[i];
        }
        await tester.ensureVisible(
          find.text(strings.volumeSaveBoundaries).first,
        );
        await tester.pumpAndSettle();
        await tester.tap(find.text(strings.volumeSaveBoundaries).first);
        await tester.pump();
        expect(repository.saved, isEmpty);
        expect(find.text(strings.volumeInvalidNumbers), findsWidgets);
      }
      for (var i = 0; i < 4; i++) {
        fields[i].controller!.text = ['0', '0', '12.5', '20'][i];
      }
      await tester.tap(find.text(strings.volumeSaveBoundaries).first);
      await tester.pumpAndSettle();
      expect(repository.saved.single.maintenance, 0);
      expect(repository.saved.single.maxAdaptive, 12.5);
    },
  );
}
