import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/db/seed_data.dart';
import 'package:gym/data/repositories/workout_repository.dart';
import 'package:gym/domain/program.dart';

import '../helpers/test_db.dart';

/// Spec §3 — the 6-day rotation, per-day prescriptions and deload.
void main() {
  late AppDatabase db;
  late WorkoutRepository repo;

  setUpAll(quietDrift);

  setUp(() async {
    db = await createTestDatabase();
    repo = WorkoutRepository(db);
  });

  tearDown(() => db.close());

  Future<String> logAndFinish(String templateId) async {
    final id = await repo.startSessionFromTemplate(templateId);
    final view = (await repo.loadSessionView(id))!;
    await repo.logSet(
      sessionId: id,
      exerciseId: view.exercises.first.exercise.id,
      weightKg: 40,
      reps: 8,
      rpe: 8,
    );
    await repo.finishSession(id);
    return id;
  }

  group('program activation', () {
    test('the 6-day program is active on a fresh install', () async {
      expect(await db.getSetting(ProgramKeys.id), SeedData.program.id);
      expect(await db.getSetting(ProgramKeys.cursor), '0');
      for (final id in SeedData.program.dayIds) {
        expect(await db.templateById(id), isNotNull, reason: id);
      }
    });

    test('program days carry their own prescriptions', () async {
      final rows = await db.templateExerciseRows('ppl6-legs-a');
      final legPress = rows.firstWhere((r) => r.$2.id == 'leg-press').$1;
      expect(legPress.setsOverride, 4);
      expect(legPress.repMinOverride, 8);
      expect(legPress.repMaxOverride, 12);

      final rowsB = await db.templateExerciseRows('ppl6-legs-b');
      final legPressB = rowsB.firstWhere((r) => r.$2.id == 'leg-press').$1;
      expect(legPressB.setsOverride, 3);
      expect(legPressB.repMinOverride, 12);
      expect(legPressB.repMaxOverride, 15);
    });

    test('a session freezes the day\'s prescription, not the default', () async {
      final id = await repo.startSessionFromTemplate('ppl6-legs-b');
      final view = (await repo.loadSessionView(id))!;
      final legPress = view.exercises.firstWhere(
        (e) => e.exercise.id == 'leg-press',
      );
      expect(legPress.targetSets, 3);
      expect(legPress.link.repRangeMin, 12);
      expect(legPress.link.repRangeMax, 15);
    });
  });

  group('rotation', () {
    test('finishing a day advances the cursor', () async {
      await logAndFinish('ppl6-push-a');
      expect(await db.getSetting(ProgramKeys.cursor), '1');
      await logAndFinish('ppl6-pull-a');
      expect(await db.getSetting(ProgramKeys.cursor), '2');
    });

    test('the cursor wraps after the last day', () async {
      await logAndFinish('ppl6-legs-b');
      expect(await db.getSetting(ProgramKeys.cursor), '0');
    });

    test('doing a day out of order re-anchors there', () async {
      await logAndFinish('ppl6-push-b');
      expect(await db.getSetting(ProgramKeys.cursor), '4');
    });

    test('a non-program template leaves the cursor alone', () async {
      await logAndFinish('push');
      expect(await db.getSetting(ProgramKeys.cursor), '0');
    });

    test('ProgramDefinition helpers', () {
      const p = SeedData.program;
      expect(p.dayAt(0), 'ppl6-push-a');
      expect(p.dayAt(6), 'ppl6-push-a');
      expect(p.cursorAfter('ppl6-legs-b'), 0);
      expect(p.cursorAfter('nope'), 0);
      expect(p.contains('ppl6-pull-b'), isTrue);
      expect(p.contains(null), isFalse);
    });
  });

  group('deload', () {
    test('runs the next N sessions at half sets and −10 % load', () async {
      // Establish a working weight first.
      await logAndFinish('ppl6-push-a');

      await repo.applyDeload(sessions: 2);
      expect(await db.getSetting(ProgramKeys.deloadRemaining), '2');

      final id = await repo.startSessionFromTemplate('ppl6-push-a');
      final view = (await repo.loadSessionView(id))!;
      expect(view.title, contains('Deload'));

      final flat = view.exercises.first; // Flat DB Press, 4 sets prescribed
      expect(flat.targetSets, 2);
      // 40 kg × 0.9 = 36 → nearest 2.5 kg step is 35.
      expect(flat.suggestedWeightKg, 35);
      expect(flat.increaseFlagged, isFalse);

      expect(await db.getSetting(ProgramKeys.deloadRemaining), '1');
    });

    test('a normal session is built once the counter hits zero', () async {
      await repo.applyDeload(sessions: 1);
      await repo.startSessionFromTemplate('ppl6-pull-a'); // consumes it
      final id = await repo.startSessionFromTemplate('ppl6-pull-a');
      final view = (await repo.loadSessionView(id))!;
      expect(view.title, isNot(contains('Deload')));
      expect(view.exercises.first.targetSets, 4);
    });

    test('dismiss and cancel', () async {
      await repo.applyDeload();
      await repo.cancelDeload();
      expect(await db.getSetting(ProgramKeys.deloadRemaining), '0');
      await repo.dismissDeload();
      expect(await db.getSetting(ProgramKeys.deloadDismissedAt), isNotNull);
    });
  });
}
