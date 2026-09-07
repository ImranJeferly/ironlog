import '../data/db/database.dart';
import 'enums.dart';

/// Resolved muscle attribution for an exercise row.
///
/// `primaryMuscle` is nullable in the schema so pre-taxonomy rows still load;
/// everything that reasons about volume or progression should go through
/// these getters instead of the raw columns.
extension ExerciseMuscles on ExerciseRow {
  /// Full-credit muscle. Falls back to the coarse group's best guess.
  Muscle get primary => primaryMuscle ?? Muscle.fromGroup(muscleGroup);

  /// Half-credit muscle, if the movement has one.
  Muscle? get secondary => secondaryMuscle;

  /// Volume credit this exercise gives [muscle] per hard set: 1 for the
  /// primary, 0.5 for the secondary, 0 otherwise. Explosive work never counts
  /// toward hypertrophy volume.
  double volumeCreditFor(Muscle muscle) {
    if (isExplosive) return 0;
    if (muscle == primary) return 1;
    if (muscle == secondary) return 0.5;
    return 0;
  }

  /// All muscles this exercise credits, with their weights.
  Map<Muscle, double> get volumeCredits => isExplosive
      ? const {}
      : {
          primary: 1.0,
          if (secondary != null && secondary != primary) secondary!: 0.5,
        };
}
