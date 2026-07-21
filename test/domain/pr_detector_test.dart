import 'package:flutter_test/flutter_test.dart';
import 'package:gym/domain/enums.dart';
import 'package:gym/domain/pr_detector.dart';
import 'package:gym/domain/strength_math.dart';

void main() {
  group('PR detection', () {
    test('the first ever set sets a baseline instead of firing PRs', () {
      final prs = PrDetector.detect(
        weightKg: 40,
        reps: 10,
        history: const [],
      );

      expect(prs, isEmpty);
    });

    test('a heavier set is a weight PR', () {
      final prs = PrDetector.detect(
        weightKg: 45,
        reps: 5,
        history: const [SetPerformance(weightKg: 40, reps: 10)],
      );

      expect(prs.map((p) => p.type), contains(PrType.weight));
      final weightPr = prs.firstWhere((p) => p.type == PrType.weight);
      expect(weightPr.value, 45);
      expect(weightPr.previousValue, 40);
    });

    test('more reps at a previously used weight is a rep PR', () {
      final prs = PrDetector.detect(
        weightKg: 40,
        reps: 12,
        history: const [
          SetPerformance(weightKg: 40, reps: 10),
          SetPerformance(weightKg: 40, reps: 11),
        ],
      );

      final repPr = prs.firstWhere((p) => p.type == PrType.reps);
      expect(repPr.value, 12);
      expect(repPr.previousValue, 11);
    });

    test('a lighter weight never counts as a rep PR against heavier history', () {
      final prs = PrDetector.detect(
        weightKg: 20,
        reps: 20,
        history: const [SetPerformance(weightKg: 40, reps: 10)],
      );

      expect(prs.where((p) => p.type == PrType.reps), isEmpty);
      expect(prs.where((p) => p.type == PrType.weight), isEmpty);
    });

    test('e1RM PR catches strength gains the other two miss', () {
      // 32.5×6 → 39.0 e1RM beats the best of 35×3 → 38.5 and 30×6 → 36.0,
      // while being neither the heaviest load nor a rep record at 32.5 kg
      // (which has never been used before).
      final prs = PrDetector.detect(
        weightKg: 32.5,
        reps: 6,
        history: const [
          SetPerformance(weightKg: 35, reps: 3),
          SetPerformance(weightKg: 30, reps: 6),
        ],
      );

      expect(prs.map((p) => p.type), contains(PrType.estimated1RM));
      expect(prs.map((p) => p.type), isNot(contains(PrType.weight)));
    });

    test('repeating a previous best is not a PR', () {
      final prs = PrDetector.detect(
        weightKg: 40,
        reps: 10,
        history: const [SetPerformance(weightKg: 40, reps: 10)],
      );

      expect(prs, isEmpty);
    });

    test('a set breaking several records leads with the weight PR', () {
      final prs = PrDetector.detect(
        weightKg: 50,
        reps: 12,
        history: const [SetPerformance(weightKg: 40, reps: 10)],
      );

      expect(prs.first.type, PrType.weight);
      expect(prs.length, greaterThanOrEqualTo(2));
    });

    test('zero reps can never be a PR', () {
      final prs = PrDetector.detect(
        weightKg: 100,
        reps: 0,
        history: const [SetPerformance(weightKg: 40, reps: 10)],
      );

      expect(prs, isEmpty);
    });
  });

  group('strength math', () {
    test('Epley leaves a single alone and scales with reps', () {
      expect(StrengthMath.epley(100, 1), 100);
      expect(StrengthMath.epley(100, 10), closeTo(133.33, 0.01));
      expect(StrengthMath.epley(100, 0), 0);
    });

    test('tonnage sums weight × reps', () {
      expect(
        StrengthMath.tonnage(const [
          SetPerformance(weightKg: 40, reps: 10),
          SetPerformance(weightKg: 50, reps: 5),
        ]),
        650,
      );
    });

    test('top set prefers weight, then reps', () {
      final top = StrengthMath.topSet(const [
        SetPerformance(weightKg: 40, reps: 12),
        SetPerformance(weightKg: 50, reps: 3),
        SetPerformance(weightKg: 50, reps: 5),
      ]);

      expect(top!.weightKg, 50);
      expect(top.reps, 5);
    });

    test('moving average is trailing and defined from the first point', () {
      final ma = StrengthMath.movingAverage([1, 2, 3, 4, 5], 3);

      expect(ma[0], 1);
      expect(ma[1], 1.5);
      expect(ma[2], 2);
      expect(ma[4], 4);
    });

    test('rounding snaps to the plate increment', () {
      expect(StrengthMath.roundToIncrement(41.2, 2.5), 40);
      expect(StrengthMath.roundToIncrement(43.9, 2.5), 45);
      expect(StrengthMath.roundToIncrement(62, 5), 60);
    });
  });
}
