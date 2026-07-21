import 'enums.dart';
import 'strength_math.dart';

/// The subset of an exercise definition the engine needs. Keeping this separate
/// from the Drift row makes the engine trivially unit-testable.
class ProgressionSpec {
  const ProgressionSpec({
    required this.role,
    required this.targetSets,
    required this.repRangeMin,
    required this.repRangeMax,
    required this.incrementKg,
  });

  final ExerciseRole role;
  final int targetSets;
  final int repRangeMin;
  final int repRangeMax;
  final double incrementKg;

  /// "4×5–6", "3×8–10", "4×3".
  String get schemeLabel => repRangeMin == repRangeMax
      ? '$targetSets×$repRangeMin'
      : '$targetSets×$repRangeMin–$repRangeMax';
}

/// What the app tells you to do for an exercise before you start a set.
class ProgressionSuggestion {
  const ProgressionSuggestion({
    required this.suggestedWeightKg,
    required this.increaseFlagged,
    required this.targetReps,
    required this.ghostSets,
    required this.rationale,
    required this.previousWeightKg,
  });

  /// Null only when there is no history at all for the exercise.
  final double? suggestedWeightKg;

  /// True when double progression has been earned — the UI shows "↑ WEIGHT".
  final bool increaseFlagged;

  /// Reps to aim for on every set this session.
  final int targetReps;

  /// Last session's sets, shown as ghost values for one-tap repeat.
  final List<SetPerformance> ghostSets;

  final String rationale;

  /// The weight worked last session, before any increase was applied.
  final double? previousWeightKg;

  bool get hasHistory => ghostSets.isNotEmpty;
}

/// Double progression, exactly as specced in the plan:
///
/// > Work in a rep range (e.g. 3×8 means 8–10). Hit the top of the range on ALL
/// > sets → app flags ↑ WEIGHT next session (+2.5 kg upper / +5 kg lower).
abstract final class ProgressionEngine {
  /// [lastSets] must be the working sets of the most recent *completed* session
  /// containing this exercise, in set order. Warm-ups are excluded upstream.
  static ProgressionSuggestion suggest({
    required ProgressionSpec spec,
    required List<SetPerformance> lastSets,
  }) {
    if (lastSets.isEmpty) {
      return ProgressionSuggestion(
        suggestedWeightKg: null,
        increaseFlagged: false,
        targetReps: spec.repRangeMin,
        ghostSets: const [],
        previousWeightKg: null,
        rationale: 'First time — find a working weight for '
            '${spec.repRangeMin}–${spec.repRangeMax} reps.',
      );
    }

    // The working weight is the heaviest load carried last session; lighter
    // back-off sets don't hold progression back.
    final workingWeight = lastSets
        .map((s) => s.weightKg)
        .reduce((a, b) => a > b ? a : b);
    final setsAtWorkingWeight =
        lastSets.where((s) => s.weightKg == workingWeight).toList();

    // Explosive work is driven by bar speed and is deliberately never taken to
    // failure, so it never auto-progresses.
    if (!spec.role.autoProgresses) {
      return ProgressionSuggestion(
        suggestedWeightKg: workingWeight,
        increaseFlagged: false,
        targetReps: spec.repRangeMin,
        ghostSets: lastSets,
        previousWeightKg: workingWeight,
        rationale: 'Max intent, not to failure — add load only when it moves '
            'fast.',
      );
    }

    final loggedEnoughSets = setsAtWorkingWeight.length >= spec.targetSets;
    final allHitTop =
        setsAtWorkingWeight.every((s) => s.reps >= spec.repRangeMax);
    final earned = loggedEnoughSets && allHitTop;

    if (earned) {
      // Guard against a stored increment of 0 leaving the weight unchanged and
      // the flag stuck on forever.
      final increment = spec.incrementKg > 0 ? spec.incrementKg : 2.5;
      final next = StrengthMath.roundToIncrement(
        workingWeight + increment,
        increment,
      );
      return ProgressionSuggestion(
        suggestedWeightKg: next,
        increaseFlagged: true,
        targetReps: spec.repRangeMin,
        ghostSets: lastSets,
        previousWeightKg: workingWeight,
        rationale: 'All ${spec.targetSets} sets hit ${spec.repRangeMax} — '
            'add ${_fmt(increment)} kg.',
      );
    }

    // Not earned: repeat the weight and aim one rep higher than the weakest set
    // (never below the bottom of the range, never above the top).
    final weakest = setsAtWorkingWeight
        .map((s) => s.reps)
        .reduce((a, b) => a < b ? a : b);
    final nextTarget = (weakest + 1).clamp(spec.repRangeMin, spec.repRangeMax);

    final reason = !loggedEnoughSets
        ? 'Log all ${spec.targetSets} sets at ${_fmt(workingWeight)} kg to '
              'earn the jump.'
        : 'Hit ${spec.repRangeMax} on all ${spec.targetSets} sets to earn '
              '+${_fmt(spec.incrementKg)} kg.';

    return ProgressionSuggestion(
      suggestedWeightKg: workingWeight,
      increaseFlagged: false,
      targetReps: nextTarget,
      ghostSets: lastSets,
      previousWeightKg: workingWeight,
      rationale: reason,
    );
  }

  static String _fmt(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);
}
