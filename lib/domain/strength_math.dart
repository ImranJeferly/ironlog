import 'dart:math' as math;

/// A single performed set, reduced to what the maths cares about.
class SetPerformance {
  const SetPerformance({required this.weightKg, required this.reps, this.rpe});

  final double weightKg;
  final int reps;

  /// Rate of perceived exertion (6–10) if it was logged. Progression only
  /// awards a weight jump when the work was owned at RPE ≤ 9.
  final int? rpe;

  double get volumeKg => weightKg * reps;

  double get estimated1RM => StrengthMath.epley(weightKg, reps);

  @override
  String toString() => '${weightKg}kg × $reps';
}

abstract final class StrengthMath {
  /// Epley: 1RM = w × (1 + r/30). A single is its own max.
  static double epley(double weightKg, int reps) {
    if (reps <= 0) return 0;
    if (reps == 1) return weightKg;
    return weightKg * (1 + reps / 30.0);
  }

  /// Total kg moved. Bodyweight movements contribute their *added* load only,
  /// so a 0 kg pull-up set adds nothing to tonnage by design.
  static double tonnage(Iterable<SetPerformance> sets) =>
      sets.fold(0.0, (sum, s) => sum + s.volumeKg);

  /// The heaviest set, tie-broken by reps — what the "top set" chart plots.
  static SetPerformance? topSet(Iterable<SetPerformance> sets) {
    SetPerformance? best;
    for (final s in sets) {
      if (best == null ||
          s.weightKg > best.weightKg ||
          (s.weightKg == best.weightKg && s.reps > best.reps)) {
        best = s;
      }
    }
    return best;
  }

  /// Best estimated 1RM across the given sets.
  static double best1RM(Iterable<SetPerformance> sets) =>
      sets.fold(0.0, (best, s) => math.max(best, s.estimated1RM));

  /// Trailing moving average, used for the body-weight trend line. Emits a
  /// value for every input index, averaging over however many points are
  /// available up to [window].
  static List<double> movingAverage(List<double> values, int window) {
    if (values.isEmpty || window <= 1) return List.of(values);
    final out = <double>[];
    for (var i = 0; i < values.length; i++) {
      final start = math.max(0, i - window + 1);
      var sum = 0.0;
      for (var j = start; j <= i; j++) {
        sum += values[j];
      }
      out.add(sum / (i - start + 1));
    }
    return out;
  }

  /// Rounds to the nearest achievable plate step (2.5 kg pairs / 5 kg).
  static double roundToIncrement(double weightKg, double incrementKg) {
    if (incrementKg <= 0) return weightKg;
    return (weightKg / incrementKg).round() * incrementKg;
  }
}
