import '../data/db/database.dart';
import 'enums.dart';
import 'strength_math.dart';

/// One exercise inside a session, with everything the UI needs to render it.
class SessionExerciseView {
  const SessionExerciseView({
    required this.link,
    required this.exercise,
    required this.sets,
    required this.ghostSets,
  });

  final SessionExerciseRow link;
  final ExerciseRow exercise;

  /// Sets logged so far this session, in set order.
  final List<WorkoutSetRow> sets;

  /// Last session's sets, shown as ghost values.
  final List<SetPerformance> ghostSets;

  String get name => exercise.name;

  ExerciseRole get role => exercise.role;

  MuscleGroup get muscleGroup => exercise.muscleGroup;

  int get targetSets => link.targetSets;

  int get completedSets => sets.where((s) => !s.isWarmup).length;

  bool get isComplete => completedSets >= targetSets;

  bool get isStarted => sets.isNotEmpty;

  bool get increaseFlagged => link.increaseFlagged;

  double? get suggestedWeightKg => link.suggestedWeightKg;

  String get schemeLabel => link.repRangeMin == link.repRangeMax
      ? '$targetSets×${link.repRangeMin}'
      : '$targetSets×${link.repRangeMin}–${link.repRangeMax}';

  double get tonnageKg =>
      sets.fold(0.0, (sum, s) => sum + s.weightKg * s.reps);

  bool get hasPr => sets.any((s) => s.isPr);

  /// Ghost values for the next set to log, if last session went that deep.
  SetPerformance? ghostForSet(int setNo) {
    final idx = setNo - 1;
    if (idx < 0 || idx >= ghostSets.length) {
      return ghostSets.isNotEmpty ? ghostSets.last : null;
    }
    return ghostSets[idx];
  }

  /// What the weight wheel should open on for the next set.
  double defaultWeightKg() {
    if (sets.isNotEmpty) return sets.last.weightKg;
    if (link.suggestedWeightKg != null) return link.suggestedWeightKg!;
    final ghost = ghostSets.isNotEmpty ? ghostSets.first.weightKg : null;
    return ghost ?? 20.0;
  }

  int defaultReps() {
    if (link.increaseFlagged) return link.repRangeMin;
    if (sets.isNotEmpty) return sets.last.reps;
    final ghost = ghostForSet(sets.length + 1);
    return ghost?.reps ?? link.repRangeMin;
  }
}

/// A whole session assembled for display.
class SessionView {
  const SessionView({required this.session, required this.exercises});

  final SessionRow session;
  final List<SessionExerciseView> exercises;

  String get title => session.templateName ?? 'Workout';

  bool get isComplete => session.isComplete;

  Duration get elapsed =>
      (session.endedAt ?? DateTime.now()).difference(session.startedAt);

  double get tonnageKg =>
      exercises.fold(0.0, (sum, e) => sum + e.tonnageKg);

  int get totalSets =>
      exercises.fold(0, (sum, e) => sum + e.completedSets);

  int get targetSetTotal =>
      exercises.fold(0, (sum, e) => sum + e.targetSets);

  int get prCount =>
      exercises.fold(0, (sum, e) => sum + e.sets.where((s) => s.isPr).length);

  /// 0–1 completion across all prescribed sets.
  double get progress {
    final target = targetSetTotal;
    if (target == 0) return 0;
    return (totalSets / target).clamp(0.0, 1.0);
  }

  /// The exercise the user is most likely working on right now.
  SessionExerciseView? get currentExercise {
    for (final e in exercises) {
      if (!e.isComplete) return e;
    }
    return exercises.isNotEmpty ? exercises.last : null;
  }

  double get best1RM => exercises.fold(0.0, (best, e) {
    final sets = e.sets
        .map((s) => SetPerformance(weightKg: s.weightKg, reps: s.reps))
        .toList();
    final b = StrengthMath.best1RM(sets);
    return b > best ? b : best;
  });
}

/// Per-set volume/muscle attribution used by the analytics screens.
class MuscleVolume {
  const MuscleVolume({
    required this.group,
    required this.sets,
    required this.tonnageKg,
  });

  final MuscleGroup group;
  final int sets;
  final double tonnageKg;
}
