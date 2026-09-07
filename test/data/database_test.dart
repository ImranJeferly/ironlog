import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/db/seed_data.dart';
import 'package:gym/domain/enums.dart';

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUpAll(quietDrift);

  setUp(() async {
    db = await createTestDatabase();
  });

  tearDown(() => db.close());

  group('seeding', () {
    test('loads every exercise from the plan on first run', () async {
      final exercises = await db.allExercises();

      expect(exercises, hasLength(SeedData.exercises.length));
      expect(
        exercises.map((e) => e.name),
        containsAll([
          'Incline DB Press',
          'Weighted Pull-ups',
          'Bulgarian Split Squat',
          'Box Jump / Jump Squat',
        ]),
      );
    });

    test('loads the legacy days, then the PPL 6-Day v2 days, in order', () async {
      final templates = await db.watchTemplates().first;

      expect(templates.map((t) => t.name), [
        'Push',
        'Pull',
        'Legs',
        'Arms',
        'Push A',
        'Pull A',
        'Legs A',
        'Push B',
        'Pull B',
        'Legs B',
      ]);
      // Program days rotate; they are never pinned to a weekday.
      for (final t in templates.skip(4)) {
        expect(t.weekday, isNull, reason: t.name);
      }
      expect(templates[0].weekday, DateTime.monday);
      expect(templates[1].weekday, DateTime.wednesday);
      expect(templates[2].weekday, DateTime.friday);
      // Arms is a full training day — 4 gym days out of 7, not an extra.
      expect(templates[3].weekday, DateTime.saturday);
    });

    test('carries the cardio prescription for each day', () async {
      final templates = await db.watchTemplates().first;

      expect(templates[0].cardioLabel, 'Rope 5 min');
      expect(templates[1].cardioLabel, 'HIIT bike 15 min');
      expect(templates[2].cardioLabel, 'Rope 10 min');
    });

    test('Push day is ordered exactly as the plan lists it', () async {
      final rows = await db.templateExerciseRows('push');

      expect(rows.map((r) => r.$2.name), [
        'Incline DB Press',
        'Seated Shoulder Press',
        'Weighted Dips',
        'Cable Chest Fly',
        'Overhead Tricep Ext',
        'Tricep Pulldown',
      ]);
    });

    test('Legs day leads with the explosive movement', () async {
      final rows = await db.templateExerciseRows('legs');

      expect(rows.first.$2.name, 'Box Jump / Jump Squat');
      expect(rows.first.$2.role, ExerciseRole.explosive);
      expect(rows[1].$2.name, 'Bulgarian Split Squat');
      expect(rows[1].$2.role, ExerciseRole.primary);
    });

    test('schemes match the role table', () async {
      final byId = {for (final e in await db.allExercises()) e.id: e};

      final primary = byId['incline-db-press']!;
      expect(primary.role, ExerciseRole.primary);
      expect(primary.targetSets, 4);
      expect(primary.repRangeMin, 5);
      expect(primary.repRangeMax, 6);

      final secondary = byId['cable-row']!;
      expect(secondary.targetSets, 3);
      expect(secondary.repRangeMin, 8);
      expect(secondary.repRangeMax, 10);

      final isolation = byId['cable-chest-fly']!;
      expect(isolation.targetSets, 3);
      expect(isolation.repRangeMin, 12);
      expect(isolation.repRangeMax, 15);

      final explosive = byId['box-jump']!;
      expect(explosive.targetSets, 4);
      expect(explosive.repRangeMin, 3);
      expect(explosive.repRangeMax, 3);
    });

    test('increments are +2.5 upper / +5 lower', () async {
      final byId = {for (final e in await db.allExercises()) e.id: e};

      expect(byId['incline-db-press']!.incrementKg, 2.5);
      expect(byId['seated-shoulder-press']!.incrementKg, 2.5);
      expect(byId['romanian-deadlift']!.incrementKg, 5.0);
      expect(byId['leg-press']!.incrementKg, 5.0);
    });

    test('re-seeding is idempotent', () async {
      final before = (await db.allExercises()).length;
      await db.seedIfNeeded();
      await db.seedIfNeeded();

      expect((await db.allExercises()).length, before);
    });

    test('the Extra template reuses existing arm exercises', () async {
      final rows = await db.templateExerciseRows('extra');

      expect(rows.map((r) => r.$2.name), [
        'EZ Bar Curl',
        'Incline Curl',
        'Tricep Pulldown',
        'Overhead Tricep Ext',
      ]);
    });
  });

  group('settings store', () {
    test('round-trips values', () async {
      await db.setSetting('unit', 'lb');
      expect(await db.getSetting('unit'), 'lb');

      await db.setSetting('unit', 'kg');
      expect(await db.getSetting('unit'), 'kg');
      expect(await db.getSetting('missing'), isNull);
    });
  });
}
