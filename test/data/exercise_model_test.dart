import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/repositories/workout_repository.dart';
import 'package:gym/domain/enums.dart';
import 'package:gym/domain/exercise_x.dart';

import '../helpers/test_db.dart';

/// Spec §2 — primary/secondary muscle attribution and the explosive flag.
void main() {
  late AppDatabase db;
  late WorkoutRepository repo;

  setUpAll(quietDrift);

  setUp(() async {
    db = await createTestDatabase();
    repo = WorkoutRepository(db);
  });

  tearDown(() => db.close());

  group('seeded attribution', () {
    test('compound movements credit a secondary muscle', () async {
      final dips = (await db.exerciseById('weighted-dips'))!;
      expect(dips.primary, Muscle.chest);
      expect(dips.secondary, Muscle.triceps);
      expect(dips.isBodyweight, isTrue);

      final pullUps = (await db.exerciseById('weighted-pull-ups'))!;
      expect(pullUps.primary, Muscle.back);
      expect(pullUps.secondary, Muscle.biceps);

      final rdl = (await db.exerciseById('romanian-deadlift'))!;
      expect(rdl.primary, Muscle.hamstrings);
      expect(rdl.secondary, Muscle.glutes);
    });

    test('isolation movements have no secondary', () async {
      final fly = (await db.exerciseById('cable-chest-fly'))!;
      expect(fly.primary, Muscle.chest);
      expect(fly.secondary, isNull);

      final shrugs = (await db.exerciseById('shrugs'))!;
      expect(shrugs.primary, Muscle.traps);
    });

    test('box jumps are explosive quads work', () async {
      final jump = (await db.exerciseById('box-jump'))!;
      expect(jump.primary, Muscle.quads);
      expect(jump.isExplosive, isTrue);
      expect(jump.volumeCredits, isEmpty);
    });

    test('the program\'s new exercises are seeded', () async {
      for (final id in [
        'flat-db-press',
        'lateral-raise',
        'leg-extension',
        'lying-leg-curl',
        'seated-leg-curl',
        'chest-supported-row',
        'lat-pulldown',
        'machine-chest-press',
        'walking-lunge',
        'skull-crusher',
      ]) {
        expect(await db.exerciseById(id), isNotNull, reason: id);
      }
      final lateral = (await db.exerciseById('lateral-raise'))!;
      expect(lateral.primary, Muscle.sideDelts);
    });
  });

  group('volume credit', () {
    test('primary 1, secondary 0.5, others 0', () async {
      final dips = (await db.exerciseById('weighted-dips'))!;
      expect(dips.volumeCreditFor(Muscle.chest), 1.0);
      expect(dips.volumeCreditFor(Muscle.triceps), 0.5);
      expect(dips.volumeCreditFor(Muscle.back), 0.0);
      expect(dips.volumeCredits, {Muscle.chest: 1.0, Muscle.triceps: 0.5});
    });
  });

  group('custom exercises', () {
    test('legacy call with only a coarse group derives a primary', () async {
      final created = await repo.createExercise(
        name: 'Cable Lateral Raise',
        muscleGroup: MuscleGroup.shoulders,
        targetSets: 3,
        repRangeMin: 12,
        repRangeMax: 15,
      );
      expect(created!.muscleGroup, MuscleGroup.shoulders);
      expect(created.primary, Muscle.shoulders);
      expect(created.secondary, isNull);
      expect(created.isExplosive, isFalse);
    });

    test('full attribution is stored and the group is derived', () async {
      final created = await repo.createExercise(
        name: 'Hack Squat',
        primary: Muscle.quads,
        secondary: Muscle.glutes,
        targetSets: 3,
        repRangeMin: 8,
        repRangeMax: 12,
      );
      expect(created!.primary, Muscle.quads);
      expect(created.secondary, Muscle.glutes);
      expect(created.muscleGroup, MuscleGroup.legs);
      expect(created.incrementKg, 5.0, reason: 'lower body increment');
    });

    test('explosive flag sets the role and zero volume credit', () async {
      final created = await repo.createExercise(
        name: 'Broad Jump',
        primary: Muscle.quads,
        targetSets: 4,
        repRangeMin: 3,
        repRangeMax: 3,
        isExplosive: true,
      );
      expect(created!.isExplosive, isTrue);
      expect(created.role, ExerciseRole.explosive);
      expect(created.volumeCreditFor(Muscle.quads), 0.0);
    });

    test('a secondary equal to the primary is dropped', () async {
      final created = await repo.createExercise(
        name: 'Odd Curl',
        primary: Muscle.biceps,
        secondary: Muscle.biceps,
        targetSets: 3,
        repRangeMin: 10,
        repRangeMax: 12,
      );
      expect(created!.secondary, isNull);
    });
  });

  group('pre-taxonomy rows', () {
    test('resolve a primary from the coarse group', () async {
      await db.into(db.exercises).insert(
        ExercisesCompanion.insert(
          id: 'legacy-legs',
          name: 'Legacy Leg Thing',
          muscleGroup: MuscleGroup.legs,
          role: ExerciseRole.secondary,
          targetSets: 3,
          repRangeMin: 8,
          repRangeMax: 12,
          incrementKg: 5,
          isCustom: const Value(true),
        ),
      );
      final row = (await db.exerciseById('legacy-legs'))!;
      expect(row.primaryMuscle, isNull);
      expect(row.primary, Muscle.quads);
      expect(row.volumeCreditFor(Muscle.quads), 1.0);
    });
  });
}
