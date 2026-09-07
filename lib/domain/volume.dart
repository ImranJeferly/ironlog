import '../core/utils/date_x.dart';
import 'enums.dart';

/// One logged set, reduced to what volume accounting needs.
class VolumeSetInput {
  const VolumeSetInput({
    required this.exerciseId,
    required this.weightKg,
    required this.reps,
    required this.isWarmup,
    required this.date,
  });

  final String exerciseId;
  final double weightKg;
  final int reps;
  final bool isWarmup;

  /// The session's calendar day.
  final DateTime date;
}

/// A week of per-muscle volume.
class MuscleWeek {
  MuscleWeek(this.weekStart)
    : hardSets = {for (final m in Muscle.values) m: 0.0},
      tonnageKg = {for (final m in Muscle.values) m: 0.0},
      setsByExercise = {for (final m in Muscle.values) m: <String, double>{}};

  final DateTime weekStart;

  /// Hard (working) sets credited to each muscle: 1 per set for the primary,
  /// 0.5 for the secondary; explosive work contributes nothing.
  final Map<Muscle, double> hardSets;

  /// Tonnage credited the same way.
  final Map<Muscle, double> tonnageKg;

  /// Which exercises produced each muscle's sets — for the tap-through.
  final Map<Muscle, Map<String, double>> setsByExercise;

  double get totalHardSets => hardSets.values.fold(0.0, (a, b) => a + b);
}

/// Weekly hard-set target range for a muscle.
class VolumeTarget {
  const VolumeTarget(this.min, this.max);

  final int min;
  final int max;

  VolumeStatus statusFor(double sets) {
    if (sets < min) return VolumeStatus.under;
    if (sets > max) return VolumeStatus.over;
    return VolumeStatus.onTarget;
  }

  @override
  String toString() => '$min–$max';
}

enum VolumeStatus { under, onTarget, over }

/// Hypertrophy volume accounting (spec §4). Pure, so it's trivially testable.
abstract final class VolumeCalc {
  /// Spec defaults; Shoulders / Traps / Glutes weren't listed and get
  /// conservative bands.
  static const defaultTargets = <Muscle, VolumeTarget>{
    Muscle.chest: VolumeTarget(12, 16),
    Muscle.back: VolumeTarget(12, 16),
    Muscle.quads: VolumeTarget(10, 14),
    Muscle.hamstrings: VolumeTarget(8, 12),
    Muscle.sideDelts: VolumeTarget(8, 12),
    Muscle.rearDelts: VolumeTarget(6, 10),
    Muscle.biceps: VolumeTarget(8, 12),
    Muscle.triceps: VolumeTarget(8, 12),
    Muscle.calves: VolumeTarget(8, 12),
    Muscle.core: VolumeTarget(6, 10),
    Muscle.shoulders: VolumeTarget(6, 10),
    Muscle.traps: VolumeTarget(4, 8),
    Muscle.glutes: VolumeTarget(6, 12),
  };

  /// Buckets [sets] into the last [weeks] calendar weeks ending with the week
  /// containing [now]. [credits] maps exercise id → {muscle: weight}
  /// (see `ExerciseMuscles.volumeCredits`); exercises missing from it are
  /// ignored. Warm-ups never count.
  static List<MuscleWeek> weekly({
    required Iterable<VolumeSetInput> sets,
    required Map<String, Map<Muscle, double>> credits,
    required DateTime now,
    int weeks = 4,
  }) {
    final firstWeek = now.weekStart.subtract(Duration(days: 7 * (weeks - 1)));
    final buckets = <DateTime, MuscleWeek>{
      for (var i = 0; i < weeks; i++)
        firstWeek.add(Duration(days: 7 * i)): MuscleWeek(
          firstWeek.add(Duration(days: 7 * i)),
        ),
    };

    for (final s in sets) {
      if (s.isWarmup) continue;
      final credit = credits[s.exerciseId];
      if (credit == null || credit.isEmpty) continue;
      final week = buckets[s.date.weekStart];
      if (week == null) continue;
      final tonnage = s.weightKg * s.reps;
      credit.forEach((muscle, weight) {
        week.hardSets[muscle] = (week.hardSets[muscle] ?? 0) + weight;
        week.tonnageKg[muscle] = (week.tonnageKg[muscle] ?? 0) + tonnage * weight;
        final byEx = week.setsByExercise[muscle]!;
        byEx[s.exerciseId] = (byEx[s.exerciseId] ?? 0) + weight;
      });
    }

    final out = buckets.values.toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));
    return out;
  }
}
