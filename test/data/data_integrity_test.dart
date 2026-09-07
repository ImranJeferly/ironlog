import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/repositories/workout_repository.dart';

import '../helpers/test_db.dart';

/// Spec §1 — data integrity rules enforced at the repository boundary.
void main() {
  late AppDatabase db;
  late WorkoutRepository repo;

  setUpAll(quietDrift);

  setUp(() async {
    db = await createTestDatabase();
    repo = WorkoutRepository(db);
  });

  tearDown(() => db.close());

  group('phantom sets', () {
    test('0 kg × 1 rep on a loaded exercise is rejected', () async {
      final id = await repo.startSessionFromTemplate('push');

      await expectLater(
        () => repo.logSet(
          sessionId: id,
          exerciseId: 'incline-db-press',
          weightKg: 0,
          reps: 1,
        ),
        throwsA(isA<PhantomSetException>()),
      );
      expect(await db.setsForSession(id), isEmpty);
    });

    test('0 kg is a real set on a bodyweight exercise', () async {
      final dips = await db.exerciseById('weighted-dips');
      // Guard: only meaningful if the seed marks dips as bodyweight.
      if (dips == null || !dips.isBodyweight) return;

      final id = await repo.startSessionFromTemplate('push');
      final result = await repo.logSet(
        sessionId: id,
        exerciseId: 'weighted-dips',
        weightKg: 0,
        reps: 1,
      );
      expect(result.setId, isNotEmpty);
    });

    test('a normal set still logs', () async {
      final id = await repo.startSessionFromTemplate('push');
      final result = await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 6,
      );
      expect(result.setId, isNotEmpty);
    });
  });

  group('finishing a session', () {
    test('refuses to save a session with no working sets', () async {
      final id = await repo.startSessionFromTemplate('push');
      // A warmup alone doesn't count.
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 20,
        reps: 8,
        isWarmup: true,
      );

      final finished = await repo.finishSession(id);

      expect(finished, isNull);
      expect((await db.activeSession())?.id, id, reason: 'still open');
    });

    test('caps implausible durations and flags them', () async {
      final id = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 6,
      );

      // Pretend the app sat open for five hours.
      final finished = await repo.finishSession(
        id,
        endedAt: DateTime.now().add(const Duration(hours: 5)),
      );

      expect(finished, isNotNull);
      expect(finished!.durationMin, AppDatabase.maxSessionMinutes);
      expect(finished.durationSuspect, isTrue);
      expect(finished.isComplete, isTrue);
    });

    test('a normal duration is stored as-is and not flagged', () async {
      final id = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 6,
      );

      final finished = await repo.finishSession(
        id,
        endedAt: DateTime.now().add(const Duration(minutes: 70)),
      );

      expect(finished!.durationMin, inInclusiveRange(69, 71));
      expect(finished.durationSuspect, isFalse);
    });

    test('an auto-ended session closes at the given time', () async {
      final id = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 6,
      );
      final lastSet = (await db.setsForSession(id)).single.completedAt;

      final finished = await repo.finishSession(id, endedAt: lastSet);

      expect(finished!.endedAt, lastSet);
    });
  });
}
