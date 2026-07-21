import 'enums.dart';
import 'strength_math.dart';

/// A record broken by a just-logged set.
class PrCandidate {
  const PrCandidate({
    required this.type,
    required this.value,
    required this.weightKg,
    required this.reps,
    this.previousValue,
  });

  final PrType type;

  /// kg for [PrType.weight] and [PrType.estimated1RM], reps for [PrType.reps].
  final double value;
  final double weightKg;
  final int reps;
  final double? previousValue;

  /// The one the celebration headline uses when a set breaks several at once.
  int get priority => switch (type) {
    PrType.weight => 3,
    PrType.estimated1RM => 2,
    PrType.reps => 1,
  };
}

abstract final class PrDetector {
  /// Compares a new set against every previous working set of the same
  /// exercise.
  ///
  /// The very first set of an exercise establishes baselines silently — nothing
  /// is a "record" when there is nothing to beat, and celebrating 18 PRs on the
  /// first Push day would make the feed meaningless.
  static List<PrCandidate> detect({
    required double weightKg,
    required int reps,
    required List<SetPerformance> history,
  }) {
    if (reps <= 0 || history.isEmpty) return const [];

    final prs = <PrCandidate>[];

    // Weight PR — heaviest load ever moved for at least one rep.
    final bestWeight = history
        .map((s) => s.weightKg)
        .reduce((a, b) => a > b ? a : b);
    if (weightKg > bestWeight) {
      prs.add(
        PrCandidate(
          type: PrType.weight,
          value: weightKg,
          weightKg: weightKg,
          reps: reps,
          previousValue: bestWeight,
        ),
      );
    }

    // Rep PR — most reps ever at this exact load. Only meaningful if the weight
    // has been used before; a brand-new load is a weight PR story, not a rep one.
    final atSameWeight = history.where((s) => s.weightKg == weightKg).toList();
    if (atSameWeight.isNotEmpty) {
      final bestReps = atSameWeight
          .map((s) => s.reps)
          .reduce((a, b) => a > b ? a : b);
      if (reps > bestReps) {
        prs.add(
          PrCandidate(
            type: PrType.reps,
            value: reps.toDouble(),
            weightKg: weightKg,
            reps: reps,
            previousValue: bestReps.toDouble(),
          ),
        );
      }
    }

    // Estimated 1RM PR — catches strength gains that neither of the above sees,
    // e.g. 32.5×5 beating a previous 30×6.
    final e1rm = StrengthMath.epley(weightKg, reps);
    final bestE1rm = StrengthMath.best1RM(history);
    if (e1rm > bestE1rm + 0.01) {
      prs.add(
        PrCandidate(
          type: PrType.estimated1RM,
          value: e1rm,
          weightKg: weightKg,
          reps: reps,
          previousValue: bestE1rm,
        ),
      );
    }

    prs.sort((a, b) => b.priority.compareTo(a.priority));
    return prs;
  }
}
