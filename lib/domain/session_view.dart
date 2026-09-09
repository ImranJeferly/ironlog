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

  /// Non-null when this exercise is part of a superset; every member of the
  /// same superset shares the number.
  int? get supersetGroup => link.supersetGroup;

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

  /// The last moment the lifter did something: the newest logged set, or the
  /// session start if nothing has been logged yet. Drives the idle watchdog
  /// and is the honest end time for an auto-ended session.
  DateTime get lastActivityAt {
    var latest = session.startedAt;
    for (final e in exercises) {
      for (final s in e.sets) {
        if (s.completedAt.isAfter(latest)) latest = s.completedAt;
      }
    }
    return latest;
  }

  /// The other exercises supersetted with [view], in session order.
  List<SessionExerciseView> supersetPartners(SessionExerciseView view) {
    final group = view.supersetGroup;
    if (group == null) return const [];
    return [
      for (final e in exercises)
        if (e.supersetGroup == group && e.link.id != view.link.id) e,
    ];
  }

  /// The next exercise to move to inside a superset: the partner with the
  /// fewest sets logged that still has work left. Null when the round is done
  /// (or this isn't a superset), which is when the rest timer should start.
  SessionExerciseView? nextInSuperset(SessionExerciseView view) {
    final partners = supersetPartners(view);
    if (partners.isEmpty) return null;
    SessionExerciseView? best;
    for (final p in partners) {
      if (p.isComplete) continue;
      // Only move on to a partner that is behind this one — otherwise the
      // round is finished and it's time to rest.
      if (p.completedSets >= view.completedSets) continue;
      if (best == null || p.completedSets < best.completedSets) best = p;
    }
    return best;
  }

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
