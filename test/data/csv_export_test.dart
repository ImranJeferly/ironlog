import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/core/utils/date_x.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/export/csv_export.dart';
import 'package:gym/data/repositories/metrics_repository.dart';
import 'package:gym/data/repositories/workout_repository.dart';

import '../helpers/test_db.dart';

/// Spec §8 — export columns, weekly volume file, tombstones excluded.
void main() {
  late AppDatabase db;
  late WorkoutRepository repo;
  late CsvExporter exporter;

  setUpAll(quietDrift);

  setUp(() async {
    db = await createTestDatabase();
    repo = WorkoutRepository(db);
    exporter = CsvExporter(db);
  });

  tearDown(() => db.close());

  List<List<String>> parse(String csv) => csv
      .trim()
      .split('\n')
      .map((line) => line.split(','))
      .toList();

  Map<String, String> byColumn(List<String> header, List<String> row) => {
    for (var i = 0; i < header.length; i++) header[i]: row[i],
  };

  Future<String> finishPushA() async {
    final id = await repo.startSessionFromTemplate('ppl6-push-a');
    await repo.logSet(
      sessionId: id,
      exerciseId: 'weighted-dips',
      weightKg: 10,
      reps: 8,
      isWarmup: true,
    );
    await repo.logSet(
      sessionId: id,
      exerciseId: 'weighted-dips',
      weightKg: 20,
      reps: 8,
      rpe: 8,
    );
    await repo.logSet(
      sessionId: id,
      exerciseId: 'weighted-dips',
      weightKg: 20,
      reps: 8,
      rpe: 9,
    );
    await repo.finishSession(id);
    return id;
  }

  group('sessions.csv', () {
    test('carries the new exercise + session columns', () async {
      await finishPushA();
      final rows = parse(await exporter.buildSessionsCsv());
      final header = rows.first;

      for (final col in [
        'primary_muscle',
        'secondary_muscle',
        'is_explosive',
        'duration_suspect',
        'program_day',
      ]) {
        expect(header, contains(col), reason: col);
      }
      expect(header, CsvExporter.sessionColumns);

      final working = rows
          .skip(1)
          .map((r) => byColumn(header, r))
          .where((r) => r['is_warmup'] == 'false')
          .toList();
      expect(working, hasLength(2));
      final row = working.first;
      expect(row['program_day'], 'Push A');
      expect(row['workout'], 'Push A');
      expect(row['primary_muscle'], 'Chest');
      expect(row['secondary_muscle'], 'Triceps');
      expect(row['is_explosive'], 'false');
      expect(row['duration_suspect'], 'false');
      expect(row['rpe'], '8');
    });

    test('a session from an ad-hoc template has no program_day', () async {
      final id = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 8,
        rpe: 8,
      );
      await repo.finishSession(id);

      final rows = parse(await exporter.buildSessionsCsv());
      final row = byColumn(rows.first, rows[1]);
      expect(row['program_day'], '');
      expect(row['workout'], isNotEmpty);
    });

    test('soft-deleted sessions and their sets are excluded', () async {
      final keep = await finishPushA();
      final drop = await finishPushA();
      await repo.deleteSession(drop);

      final rows = parse(await exporter.buildSessionsCsv());
      final ids = rows.skip(1).map((r) => byColumn(rows.first, r)['session_id']);
      expect(ids, everyElement(keep));
      expect(ids, isNot(contains(drop)));
    });
  });

  group('metrics.csv', () {
    test('exports every column and skips tombstones', () async {
      final metrics = MetricsRepository(db);
      final today = DateTime.now().dayStart;
      final yesterday = today.subtract(const Duration(days: 1));
      await metrics.upsert(
        today,
        weightKg: const Value(80.5),
        kcal: const Value(2600),
        proteinG: const Value(180),
        sleepHours: const Value(7.5),
      );
      await metrics.upsert(yesterday, weightKg: const Value(80.0));
      await (db.update(db.dailyMetrics)
            ..where((t) => t.date.equals(yesterday)))
          .write(const DailyMetricsCompanion(deleted: Value(true)));

      final rows = parse(await exporter.buildMetricsCsv());
      expect(rows.first, CsvExporter.metricColumns);
      expect(rows, hasLength(2), reason: 'header + today only');
      final row = byColumn(rows.first, rows[1]);
      expect(row['weight_kg'], '80.5');
      expect(row['kcal'], '2600');
      expect(row['protein_g'], '180');
      expect(row['sleep_hours'], '7.5');
      expect(row['weight_from_health'], 'false');
      expect(row['updated_at'], isNotEmpty);
    });
  });

  group('weekly_volume.csv', () {
    test('one row per muscle for each trained week', () async {
      await finishPushA();
      final rows = parse(await exporter.buildWeeklyVolumeCsv());
      expect(rows.first, CsvExporter.volumeColumns);

      final data = rows.skip(1).map((r) => byColumn(rows.first, r)).toList();
      expect(data, isNotEmpty);
      final thisWeek = Dates.isoDay(DateTime.now().weekStart);
      expect(data.map((r) => r['week']).toSet(), {thisWeek});

      final chest = data.firstWhere((r) => r['muscle'] == 'Chest');
      final triceps = data.firstWhere((r) => r['muscle'] == 'Triceps');
      // Two working sets of dips: chest 1.0 each, triceps 0.5 each; the
      // warm-up counts for nothing.
      expect(chest['hard_sets'], '2');
      expect(chest['tonnage_kg'], '320.0');
      expect(triceps['hard_sets'], '1');
      expect(triceps['tonnage_kg'], '160.0');
    });

    test('is header-only with no completed sessions', () async {
      final rows = parse(await exporter.buildWeeklyVolumeCsv());
      expect(rows, hasLength(1));
    });

    test('ignores deleted sessions', () async {
      final id = await finishPushA();
      await repo.deleteSession(id);
      final rows = parse(await exporter.buildWeeklyVolumeCsv());
      expect(rows, hasLength(1));
    });
  });
}
