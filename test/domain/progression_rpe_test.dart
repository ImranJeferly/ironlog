import 'package:flutter_test/flutter_test.dart';
import 'package:gym/domain/enums.dart';
import 'package:gym/domain/progression.dart';
import 'package:gym/domain/strength_math.dart';

/// Spec §3 — double progression is only earned at the top of the range AND
/// at RPE ≤ 9; increments are +2.5 kg upper / +5 kg lower.
void main() {
  const upper = ProgressionSpec(
    role: ExerciseRole.secondary,
    targetSets: 3,
    repRangeMin: 8,
    repRangeMax: 12,
    incrementKg: 2.5,
  );
  const lower = ProgressionSpec(
    role: ExerciseRole.secondary,
    targetSets: 4,
    repRangeMin: 8,
    repRangeMax: 12,
    incrementKg: 5,
  );

  List<SetPerformance> sets(int n, double w, int reps, {int? rpe}) => [
    for (var i = 0; i < n; i++)
      SetPerformance(weightKg: w, reps: reps, rpe: rpe),
  ];

  group('RPE gate', () {
    test('top of range at RPE 8 earns +2.5 kg on an upper-body lift', () {
      final s = ProgressionEngine.suggest(
        spec: upper,
        lastSets: sets(3, 30, 12, rpe: 8),
      );
      expect(s.increaseFlagged, isTrue);
      expect(s.suggestedWeightKg, 32.5);
    });

    test('top of range at RPE 9 still earns the jump', () {
      final s = ProgressionEngine.suggest(
        spec: upper,
        lastSets: sets(3, 30, 12, rpe: 9),
      );
      expect(s.increaseFlagged, isTrue);
    });

    test('a single RPE 10 set blocks the jump and repeats the weight', () {
      final s = ProgressionEngine.suggest(
        spec: upper,
        lastSets: [
          ...sets(2, 30, 12, rpe: 8),
          const SetPerformance(weightKg: 30, reps: 12, rpe: 10),
        ],
      );
      expect(s.increaseFlagged, isFalse);
      expect(s.suggestedWeightKg, 30);
      expect(s.rationale, contains('RPE 10'));
    });

    test('unlogged RPE does not block the jump', () {
      final s = ProgressionEngine.suggest(
        spec: upper,
        lastSets: sets(3, 30, 12),
      );
      expect(s.increaseFlagged, isTrue);
    });

    test('lower-body lifts jump by 5 kg', () {
      final s = ProgressionEngine.suggest(
        spec: lower,
        lastSets: sets(4, 100, 12, rpe: 8),
      );
      expect(s.increaseFlagged, isTrue);
      expect(s.suggestedWeightKg, 105);
    });

    test('missing the top of the range never jumps, whatever the RPE', () {
      final s = ProgressionEngine.suggest(
        spec: upper,
        lastSets: sets(3, 30, 10, rpe: 7),
      );
      expect(s.increaseFlagged, isFalse);
      expect(s.targetReps, 11);
    });
  });
}
