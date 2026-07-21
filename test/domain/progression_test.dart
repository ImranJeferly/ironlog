import 'package:flutter_test/flutter_test.dart';
import 'package:gym/domain/enums.dart';
import 'package:gym/domain/progression.dart';
import 'package:gym/domain/strength_math.dart';

const secondary = ProgressionSpec(
  role: ExerciseRole.secondary,
  targetSets: 3,
  repRangeMin: 8,
  repRangeMax: 10,
  incrementKg: 2.5,
);

const primaryLower = ProgressionSpec(
  role: ExerciseRole.primary,
  targetSets: 4,
  repRangeMin: 5,
  repRangeMax: 6,
  incrementKg: 5,
);

const explosive = ProgressionSpec(
  role: ExerciseRole.explosive,
  targetSets: 4,
  repRangeMin: 3,
  repRangeMax: 3,
  incrementKg: 5,
);

List<SetPerformance> sets(double weight, List<int> reps) =>
    [for (final r in reps) SetPerformance(weightKg: weight, reps: r)];

void main() {
  group('double progression', () {
    test('flags ↑ WEIGHT when every set hits the top of the range', () {
      final s = ProgressionEngine.suggest(
        spec: secondary,
        lastSets: sets(40, [10, 10, 10]),
      );

      expect(s.increaseFlagged, isTrue);
      expect(s.suggestedWeightKg, 42.5);
      expect(s.targetReps, 8, reason: 'reps reset to the bottom of the range');
      expect(s.previousWeightKg, 40);
    });

    test('holds the weight when one set falls short of the top', () {
      final s = ProgressionEngine.suggest(
        spec: secondary,
        lastSets: sets(40, [10, 10, 9]),
      );

      expect(s.increaseFlagged, isFalse);
      expect(s.suggestedWeightKg, 40);
      expect(s.targetReps, 10, reason: 'chase one more rep on the weak set');
    });

    test('does not progress on too few sets even if all hit the top', () {
      final s = ProgressionEngine.suggest(
        spec: secondary,
        lastSets: sets(40, [10, 10]),
      );

      expect(s.increaseFlagged, isFalse);
      expect(s.suggestedWeightKg, 40);
      expect(s.rationale, contains('all 3 sets'));
    });

    test('reps above the top of the range still earn the jump', () {
      final s = ProgressionEngine.suggest(
        spec: secondary,
        lastSets: sets(40, [12, 11, 10]),
      );

      expect(s.increaseFlagged, isTrue);
      expect(s.suggestedWeightKg, 42.5);
    });

    test('uses +5 kg for lower-body primaries', () {
      final s = ProgressionEngine.suggest(
        spec: primaryLower,
        lastSets: sets(60, [6, 6, 6, 6]),
      );

      expect(s.increaseFlagged, isTrue);
      expect(s.suggestedWeightKg, 65);
    });

    test('back-off sets do not block progression', () {
      // Four working sets at 60 all hit the top; a lighter fifth set follows.
      final s = ProgressionEngine.suggest(
        spec: primaryLower,
        lastSets: [
          ...sets(60, [6, 6, 6, 6]),
          const SetPerformance(weightKg: 40, reps: 12),
        ],
      );

      expect(s.increaseFlagged, isTrue);
      expect(s.suggestedWeightKg, 65);
    });

    test('a heavier partial top set becomes the new working weight', () {
      final s = ProgressionEngine.suggest(
        spec: primaryLower,
        lastSets: [
          ...sets(60, [6, 6]),
          ...sets(65, [5, 4]),
        ],
      );

      expect(s.increaseFlagged, isFalse);
      expect(s.suggestedWeightKg, 65);
    });

    test('explosive work never auto-progresses', () {
      final s = ProgressionEngine.suggest(
        spec: explosive,
        lastSets: sets(20, [3, 3, 3, 3]),
      );

      expect(s.increaseFlagged, isFalse);
      expect(s.suggestedWeightKg, 20);
      expect(s.rationale, contains('not to failure'));
    });

    test('no history yields no weight and a first-time prompt', () {
      final s = ProgressionEngine.suggest(spec: secondary, lastSets: const []);

      expect(s.suggestedWeightKg, isNull);
      expect(s.increaseFlagged, isFalse);
      expect(s.hasHistory, isFalse);
      expect(s.targetReps, 8);
      expect(s.rationale, contains('First time'));
    });

    test('ghost sets carry the whole of last session for prefill', () {
      final last = sets(40, [10, 9, 8]);
      final s = ProgressionEngine.suggest(spec: secondary, lastSets: last);

      expect(s.ghostSets, hasLength(3));
      expect(s.ghostSets.map((e) => e.reps), [10, 9, 8]);
      expect(s.hasHistory, isTrue);
    });

    test('a zero increment falls back to 2.5 kg rather than standing still', () {
      const broken = ProgressionSpec(
        role: ExerciseRole.secondary,
        targetSets: 3,
        repRangeMin: 8,
        repRangeMax: 10,
        incrementKg: 0,
      );
      final s = ProgressionEngine.suggest(
        spec: broken,
        lastSets: sets(40, [10, 10, 10]),
      );

      expect(s.suggestedWeightKg, greaterThan(40));
    });

    test('scheme label renders ranges and fixed schemes differently', () {
      expect(secondary.schemeLabel, '3×8–10');
      expect(explosive.schemeLabel, '4×3');
    });
  });
}
