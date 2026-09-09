import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/export/csv_export.dart';
import 'package:gym/data/export/csv_import.dart';
import 'package:gym/data/repositories/metrics_repository.dart';
import 'package:gym/data/repositories/workout_repository.dart';
import 'package:gym/domain/enums.dart';

import '../helpers/test_db.dart';

void main() {
  group('parseLine', () {
    test('splits plain cells', () {
      expect(CsvImporter.parseLine('a,b,c'), ['a', 'b', 'c']);
    });

    test('honours quoted commas and doubled quotes', () {
      expect(
        CsvImporter.parseLine('a,"b,c","say ""hi""",d'),
        ['a', 'b,c', 'say "hi"', 'd'],
      );
    });

    test('keeps empty trailing cells', () {
      expect(CsvImporter.parseLine('a,,'), ['a', '', '']);
    });
  });

  group('round trip', () {
    late AppDatabase db;
    late Directory tmp;

    setUp(() async {
      db = await createTestDatabase();
      tmp = await Directory.systemTemp.createTemp('ironlog_csv');
    });

    tearDown(() async {
      await closeTestDatabase(db);
      if (await tmp.exists()) await tmp.delete(recursive: true);
    });

    Future<File> write(String name, String contents) async {
      final f = File('${tmp.path}/$name');
      await f.writeAsString(contents);
      return f;
    }

    test('metrics export can be read back into an empty database', () async {
      final metrics = MetricsRepository(db);
      final day = DateTime(2026, 3, 4);
      await metrics.setWeight(day, 82.5);
      await metrics.setProtein(day, 180);
      await metrics.setMeasurement(day, BodyMeasurement.arm, 41.5);

      final csv = await CsvExporter(db).buildMetricsCsv();

      // Wipe and restore.
      await db.delete(db.dailyMetrics).go();
      expect(await db.metricForDate(day), isNull);

      final report = await CsvImporter(
        db,
      ).importMetrics(await write('m.csv', csv));

      expect(report.metrics, 1);
      final row = await db.metricForDate(day);
      expect(row, isNotNull);
      expect(row!.weightKg, 82.5);
      expect(row.proteinG, 180);
      expect(row.armCm, 41.5);
    });

    test('a second import leaves existing days alone', () async {
      final metrics = MetricsRepository(db);
      final day = DateTime(2026, 3, 4);
      await metrics.setWeight(day, 82.5);
      final csv = await CsvExporter(db).buildMetricsCsv();

      // Change the value, then re-import the old export over it.
      await metrics.setWeight(day, 90);
      final report = await CsvImporter(
        db,
      ).importMetrics(await write('m.csv', csv));

      expect(report.metrics, 0);
      expect(report.skipped, 1);
      expect((await db.metricForDate(day))!.weightKg, 90);
    });

    test('sessions export rebuilds sessions and their sets', () async {
      final workouts = WorkoutRepository(db);
      final id = await workouts.startSessionFromTemplate('push');
      await workouts.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 8,
      );
      await workouts.finishSession(id);

      final csv = await CsvExporter(db).buildSessionsCsv();

      await db.delete(db.workoutSets).go();
      await db.delete(db.sessionExercises).go();
      await db.delete(db.sessions).go();

      final report = await CsvImporter(
        db,
      ).importSessions(await write('s.csv', csv));

      expect(report.sessions, 1);
      expect(report.sets, 1);
      final sets = await db.allSets();
      expect(sets, hasLength(1));
      expect(sets.first.weightKg, 30);
      expect(sets.first.reps, 8);
      expect(sets.first.exerciseId, 'incline-db-press');
    });

    test('a set naming an unknown exercise is skipped, not invented', () async {
      const csv =
          'date,session_id,workout,started_at,ended_at,duration_min,'
          'duration_suspect,session_tonnage_kg,cardio_done,sauna_done,'
          'session_notes,exercise,set_no,weight_kg,reps,completed_at\n'
          '2026-03-04,s1,Push,2026-03-04T10:00:00.000,2026-03-04T11:00:00.000,'
          '60,false,100,false,false,,Nonexistent Lift,1,50,5,'
          '2026-03-04T10:10:00.000\n';

      final report = await CsvImporter(
        db,
      ).importSessions(await write('s.csv', csv));

      expect(report.sets, 0);
      expect(report.skipped, 1);
      expect(await db.allSets(), isEmpty);
      // No phantom exercise was created.
      final names = (await db.allExercises()).map((e) => e.name);
      expect(names, isNot(contains('Nonexistent Lift')));
    });

    test('rejects a file that is not one of ours', () async {
      final report = await CsvImporter(
        db,
      ).importMetrics(await write('x.csv', 'foo,bar\n1,2\n'));
      expect(report.isEmpty, isTrue);
      expect(report.errors, isNotEmpty);
    });
  });
}
