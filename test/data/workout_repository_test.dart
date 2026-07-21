import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/repositories/workout_repository.dart';
import 'package:gym/domain/enums.dart';

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;
  late WorkoutRepository repo;

  setUpAll(quietDrift);

  setUp(() async {
    db = await createTestDatabase();
    repo = WorkoutRepository(db);
  });

  tearDown(() => db.close());

  /// Logs a full session of `incline-db-press` and finishes it.
  Future<String> logPushSession(List<(double, int)> sets) async {
    final id = await repo.startSessionFromTemplate('push');
    for (final (weight, reps) in sets) {
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: weight,
        reps: reps,
      );
    }
    await repo.finishSession(id);
    return id;
  }

  group('starting a session', () {
    test('builds the template exercises in order', () async {
      final id = await repo.startSessionFromTemplate('push');
      final view = await repo.loadSessionView(id);

      expect(view, isNotNull);
      expect(view!.title, 'Push');
      expect(view.exercises.map((e) => e.name), [
        'Incline DB Press',
        'Seated Shoulder Press',
        'Weighted Dips',
        'Cable Chest Fly',
        'Overhead Tricep Ext',
        'Tricep Pulldown',
      ]);
      expect(view.exercises.first.targetSets, 4);
      expect(view.targetSetTotal, 4 + 3 + 3 + 3 + 3 + 3);
    });

    test('freezes the prescription on the session, not a live join', () async {
      final id = await repo.startSessionFromTemplate('push');
      final view = await repo.loadSessionView(id);
      final link = view!.exercises.first.link;

      expect(link.repRangeMin, 5);
      expect(link.repRangeMax, 6);
      expect(link.targetSets, 4);
    });

    test('an empty session starts with no exercises', () async {
      final id = await repo.startEmptySession();
      final view = await repo.loadSessionView(id);

      expect(view!.exercises, isEmpty);
      expect(view.title, 'Freestyle');
    });

    test('shows up as the active session until finished', () async {
      final id = await repo.startSessionFromTemplate('push');
      expect((await db.activeSession())?.id, id);

      await repo.finishSession(id);
      expect(await db.activeSession(), isNull);
    });
  });

  group('logging sets', () {
    test('numbers sets sequentially per exercise', () async {
      final id = await repo.startSessionFromTemplate('push');
      for (var i = 0; i < 3; i++) {
        await repo.logSet(
          sessionId: id,
          exerciseId: 'incline-db-press',
          weightKg: 30,
          reps: 5,
        );
      }

      final view = await repo.loadSessionView(id);
      final sets = view!.exercises.first.sets;
      expect(sets.map((s) => s.setNo), [1, 2, 3]);
    });

    test('the first session of an exercise sets baselines, not PRs', () async {
      final id = await repo.startSessionFromTemplate('push');
      final result = await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 6,
      );

      expect(result.isPr, isFalse);
      expect(await db.personalRecordsForExercise('incline-db-press'), isEmpty);
    });

    test('a heavier set in a later session records a PR', () async {
      await logPushSession([(30, 6), (30, 6), (30, 6), (30, 6)]);

      final second = await repo.startSessionFromTemplate('push');
      final result = await repo.logSet(
        sessionId: second,
        exerciseId: 'incline-db-press',
        weightKg: 35,
        reps: 5,
      );

      expect(result.isPr, isTrue);
      expect(result.headline!.type, PrType.weight);

      final prs = await db.personalRecordsForExercise('incline-db-press');
      expect(prs, isNotEmpty);
      expect(prs.any((p) => p.type == PrType.weight), isTrue);
    });

    test('PRs also fire against earlier sets in the same session', () async {
      await logPushSession([(30, 6)]);

      final second = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: second,
        exerciseId: 'incline-db-press',
        weightKg: 32.5,
        reps: 5,
      );
      final result = await repo.logSet(
        sessionId: second,
        exerciseId: 'incline-db-press',
        weightKg: 35,
        reps: 5,
      );

      expect(result.isPr, isTrue);
    });

    test('warm-up sets never count as PRs', () async {
      await logPushSession([(30, 6)]);

      final second = await repo.startSessionFromTemplate('push');
      final result = await repo.logSet(
        sessionId: second,
        exerciseId: 'incline-db-press',
        weightKg: 60,
        reps: 10,
        isWarmup: true,
      );

      expect(result.isPr, isFalse);
    });

    test('deleting a set renumbers the rest and retracts its PR', () async {
      await logPushSession([(30, 6)]);

      final second = await repo.startSessionFromTemplate('push');
      final pr = await repo.logSet(
        sessionId: second,
        exerciseId: 'incline-db-press',
        weightKg: 40,
        reps: 6,
      );
      await repo.logSet(
        sessionId: second,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 6,
      );
      expect(pr.isPr, isTrue);

      await repo.deleteSet(pr.setId);

      final view = await repo.loadSessionView(second);
      final sets = view!.exercises.first.sets;
      expect(sets, hasLength(1));
      expect(sets.first.setNo, 1);

      final prs = await db.personalRecordsForExercise('incline-db-press');
      expect(prs.where((p) => !p.deleted), isEmpty);
    });

    test('updating a set changes its values', () async {
      final id = await repo.startSessionFromTemplate('push');
      final logged = await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 5,
      );

      await repo.updateSet(setId: logged.setId, weightKg: 32.5, reps: 6, rpe: 8);

      final view = await repo.loadSessionView(id);
      final set = view!.exercises.first.sets.single;
      expect(set.weightKg, 32.5);
      expect(set.reps, 6);
      expect(set.rpe, 8);
    });
  });

  group('finishing', () {
    test('denormalises duration, tonnage and set count', () async {
      final id = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 10,
      );
      await repo.logSet(
        sessionId: id,
        exerciseId: 'cable-row',
        weightKg: 50,
        reps: 8,
      );

      final finished = await repo.finishSession(id);

      expect(finished!.isComplete, isTrue);
      expect(finished.totalSets, 2);
      expect(finished.tonnageKg, 30 * 10 + 50 * 8);
      expect(finished.endedAt, isNotNull);
    });

    test('warm-ups are excluded from tonnage', () async {
      final id = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 20,
        reps: 10,
        isWarmup: true,
      );
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 5,
      );

      final finished = await repo.finishSession(id);
      expect(finished!.tonnageKg, 150);
      expect(finished.totalSets, 1);
    });

    test('discarding removes the session and its sets entirely', () async {
      final id = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 5,
      );

      await repo.discardSession(id);

      expect(await db.sessionById(id), isNull);
      expect(await db.setsForSession(id), isEmpty);
      expect(await db.sessionExerciseRows(id), isEmpty);
    });

    test('deleting a finished session leaves a tombstone to sync', () async {
      final id = await logPushSession([(30, 5)]);
      await repo.deleteSession(id);

      final row = await db.sessionById(id);
      expect(row, isNotNull);
      expect(row!.deleted, isTrue);
      expect(row.synced, isFalse);
    });
  });

  group('progression across sessions', () {
    test('hitting the top of the range flags ↑ WEIGHT next time', () async {
      await logPushSession([(30, 6), (30, 6), (30, 6), (30, 6)]);

      final second = await repo.startSessionFromTemplate('push');
      final view = await repo.loadSessionView(second);
      final press = view!.exercises.first;

      expect(press.increaseFlagged, isTrue);
      expect(press.suggestedWeightKg, 32.5);
    });

    test('falling short holds the weight', () async {
      await logPushSession([(30, 6), (30, 6), (30, 5), (30, 6)]);

      final second = await repo.startSessionFromTemplate('push');
      final view = await repo.loadSessionView(second);
      final press = view!.exercises.first;

      expect(press.increaseFlagged, isFalse);
      expect(press.suggestedWeightKg, 30);
    });

    test('ghost sets carry last session forward for prefill', () async {
      await logPushSession([(30, 6), (30, 5), (30, 5), (30, 4)]);

      final second = await repo.startSessionFromTemplate('push');
      final view = await repo.loadSessionView(second);
      final press = view!.exercises.first;

      expect(press.ghostSets.map((g) => g.reps), [6, 5, 5, 4]);
      expect(press.ghostForSet(2)!.reps, 5);
      expect(press.defaultWeightKg(), 30);
    });

    test('an unfinished session does not feed the engine', () async {
      final first = await repo.startSessionFromTemplate('push');
      for (var i = 0; i < 4; i++) {
        await repo.logSet(
          sessionId: first,
          exerciseId: 'incline-db-press',
          weightKg: 30,
          reps: 6,
        );
      }
      // Deliberately not finished.

      final second = await repo.startSessionFromTemplate('push');
      final view = await repo.loadSessionView(second);

      expect(view!.exercises.first.suggestedWeightKg, isNull);
      expect(view.exercises.first.ghostSets, isEmpty);
    });

    test('explosive work never gets flagged for a jump', () async {
      final first = await repo.startSessionFromTemplate('legs');
      for (var i = 0; i < 4; i++) {
        await repo.logSet(
          sessionId: first,
          exerciseId: 'box-jump',
          weightKg: 0,
          reps: 3,
        );
      }
      await repo.finishSession(first);

      final second = await repo.startSessionFromTemplate('legs');
      final view = await repo.loadSessionView(second);
      final jump = view!.exercises.firstWhere((e) => e.name.contains('Box'));

      expect(jump.increaseFlagged, isFalse);
    });

    test('lower-body primaries jump by 5 kg', () async {
      final first = await repo.startSessionFromTemplate('legs');
      for (var i = 0; i < 4; i++) {
        await repo.logSet(
          sessionId: first,
          exerciseId: 'bulgarian-split-squat',
          weightKg: 20,
          reps: 6,
        );
      }
      await repo.finishSession(first);

      final second = await repo.startSessionFromTemplate('legs');
      final view = await repo.loadSessionView(second);
      final bss = view!.exercises.firstWhere(
        (e) => e.name == 'Bulgarian Split Squat',
      );

      expect(bss.increaseFlagged, isTrue);
      expect(bss.suggestedWeightKg, 25);
    });
  });

  group('editing the session', () {
    test('adds and removes exercises', () async {
      final id = await repo.startEmptySession();
      await repo.addExercise(id, 'cable-row');
      await repo.addExercise(id, 'ez-bar-curl');

      var view = await repo.loadSessionView(id);
      expect(view!.exercises.map((e) => e.name), ['Cable Row', 'EZ Bar Curl']);

      await repo.removeExerciseFromSession(view.exercises.first.link.id);
      view = await repo.loadSessionView(id);
      expect(view!.exercises.map((e) => e.name), ['EZ Bar Curl']);
    });

    test('removing an exercise also drops its logged sets', () async {
      final id = await repo.startEmptySession();
      await repo.addExercise(id, 'cable-row');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'cable-row',
        weightKg: 40,
        reps: 8,
      );

      final view = await repo.loadSessionView(id);
      await repo.removeExerciseFromSession(view!.exercises.first.link.id);

      final after = await repo.loadSessionView(id);
      expect(after!.exercises, isEmpty);
      expect(after.totalSets, 0);
    });

    test('target sets can be bumped mid-session', () async {
      final id = await repo.startSessionFromTemplate('push');
      final view = await repo.loadSessionView(id);
      final link = view!.exercises.first.link;

      await repo.setTargetSets(link.id, 5);

      final after = await repo.loadSessionView(id);
      expect(after!.exercises.first.targetSets, 5);
    });

    test('cardio and sauna toggles persist', () async {
      final id = await repo.startSessionFromTemplate('push');
      await repo.setCardioDone(id, true);
      await repo.setSaunaDone(id, true);

      final session = await db.sessionById(id);
      expect(session!.cardioDone, isTrue);
      expect(session.saunaDone, isTrue);
    });
  });
}
