import '../../domain/enums.dart';

/// A seeded exercise definition. IDs are stable slugs so re-seeding is
/// idempotent and Firestore documents keep the same keys across installs.
class SeedExercise {
  const SeedExercise({
    required this.id,
    required this.name,
    required this.primary,
    required this.role,
    required this.sets,
    required this.repMin,
    required this.repMax,
    this.secondary,
    this.isExplosive = false,
    this.isUnilateral = false,
    this.isBodyweight = false,
    this.incrementKg,
    this.notes,
  });

  final String id;
  final String name;

  /// Muscle that gets full volume credit.
  final Muscle primary;

  /// Muscle that gets half credit (0.5 set per set), if any.
  final Muscle? secondary;

  /// Power work: excluded from hypertrophy volume and auto-progression.
  final bool isExplosive;
  final ExerciseRole role;
  final int sets;
  final int repMin;
  final int repMax;
  final bool isUnilateral;
  final bool isBodyweight;
  final double? incrementKg;
  final String? notes;

  /// Coarse group, derived — kept for legacy charts and colours.
  MuscleGroup get muscleGroup => primary.group;

  double get resolvedIncrementKg => incrementKg ?? primary.defaultIncrementKg;
}

class SeedTemplate {
  const SeedTemplate({
    required this.id,
    required this.name,
    required this.exerciseIds,
    required this.orderIndex,
    this.weekday,
    this.cardioLabel,
    this.accentHex,
  });

  final String id;
  final String name;
  final List<String> exerciseIds;
  final int orderIndex;
  final int? weekday;
  final String? cardioLabel;
  final String? accentHex;
}

/// The exercise library. Rep ranges follow the double-progression rule: the
/// listed scheme is the bottom of the range, and you earn the weight jump by
/// hitting the top of the range on every set.
///
/// Muscle attribution: `primary` gets a full set of volume, `secondary` half.
abstract final class SeedData {
  static const exercises = <SeedExercise>[
    // ---------------- CHEST / PUSH ----------------
    SeedExercise(
      id: 'flat-db-press',
      name: 'Flat DB Press',
      primary: Muscle.chest,
      secondary: Muscle.triceps,
      role: ExerciseRole.primary,
      sets: 4,
      repMin: 6,
      repMax: 8,
      notes: 'Primary press on Push A. 2–3 reps in reserve.',
    ),
    SeedExercise(
      id: 'incline-db-press',
      name: 'Incline DB Press',
      primary: Muscle.chest,
      secondary: Muscle.triceps,
      role: ExerciseRole.primary,
      sets: 4,
      repMin: 5,
      repMax: 6,
      notes: 'Primary press. 2–3 reps in reserve, 5th top set optional.',
    ),
    SeedExercise(
      id: 'machine-chest-press',
      name: 'Machine Chest Press',
      primary: Muscle.chest,
      secondary: Muscle.triceps,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 10,
      repMax: 12,
    ),
    SeedExercise(
      id: 'weighted-dips',
      name: 'Weighted Dips',
      primary: Muscle.chest,
      secondary: Muscle.triceps,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 8,
      repMax: 10,
      isBodyweight: true,
      notes: 'Log added load only — 0 kg is bodyweight.',
    ),
    SeedExercise(
      id: 'cable-chest-fly',
      name: 'Cable Chest Fly',
      primary: Muscle.chest,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
    ),

    // ---------------- SHOULDERS ----------------
    SeedExercise(
      id: 'seated-shoulder-press',
      name: 'Seated Shoulder Press',
      primary: Muscle.shoulders,
      secondary: Muscle.triceps,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 8,
      repMax: 10,
    ),
    SeedExercise(
      id: 'lateral-raise',
      name: 'Lateral Raise',
      primary: Muscle.sideDelts,
      role: ExerciseRole.isolation,
      sets: 4,
      repMin: 12,
      repMax: 15,
    ),
    SeedExercise(
      id: 'rear-delt-fly',
      name: 'Rear Delt Fly',
      primary: Muscle.rearDelts,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 15,
      repMax: 18,
    ),

    // ---------------- TRICEPS ----------------
    SeedExercise(
      id: 'overhead-tricep-ext',
      name: 'Overhead Tricep Ext',
      primary: Muscle.triceps,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
    ),
    SeedExercise(
      id: 'tricep-pulldown',
      name: 'Tricep Pulldown',
      primary: Muscle.triceps,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
    ),
    SeedExercise(
      id: 'skull-crusher',
      name: 'Skull Crusher',
      primary: Muscle.triceps,
      role: ExerciseRole.isolation,
      sets: 2,
      repMin: 10,
      repMax: 12,
    ),

    // ---------------- BACK / PULL ----------------
    SeedExercise(
      id: 'weighted-pull-ups',
      name: 'Weighted Pull-ups',
      primary: Muscle.back,
      secondary: Muscle.biceps,
      role: ExerciseRole.primary,
      sets: 4,
      repMin: 5,
      repMax: 6,
      isBodyweight: true,
      notes: 'Log added load only — 0 kg is bodyweight.',
    ),
    SeedExercise(
      id: 'chest-supported-row',
      name: 'Chest-Supported Row',
      primary: Muscle.back,
      role: ExerciseRole.primary,
      sets: 4,
      repMin: 8,
      repMax: 10,
    ),
    SeedExercise(
      id: 'cable-row',
      name: 'Cable Row',
      primary: Muscle.back,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 8,
      repMax: 10,
    ),
    SeedExercise(
      id: 'lat-pulldown',
      name: 'Lat Pulldown',
      primary: Muscle.back,
      secondary: Muscle.biceps,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 10,
      repMax: 12,
    ),
    SeedExercise(
      id: 'single-arm-db-row',
      name: 'Single-Arm DB Row',
      primary: Muscle.back,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 10,
      repMax: 12,
      isUnilateral: true,
    ),
    SeedExercise(
      id: 'shrugs',
      name: 'Shrugs',
      primary: Muscle.traps,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 10,
      repMax: 12,
    ),

    // ---------------- BICEPS ----------------
    SeedExercise(
      id: 'ez-bar-curl',
      name: 'EZ Bar Curl',
      primary: Muscle.biceps,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 10,
      repMax: 12,
    ),
    SeedExercise(
      id: 'cross-body-hammer-curl',
      name: 'Cross-Body Hammer Curl',
      primary: Muscle.biceps,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
      isUnilateral: true,
    ),
    SeedExercise(
      id: 'incline-db-curl',
      name: 'Incline Curl',
      primary: Muscle.biceps,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
    ),

    // ---------------- LEGS ----------------
    SeedExercise(
      id: 'box-jump',
      name: 'Box Jump / Jump Squat',
      primary: Muscle.quads,
      role: ExerciseRole.explosive,
      isExplosive: true,
      sets: 4,
      repMin: 3,
      repMax: 3,
      isBodyweight: true,
      notes: 'Max intent, never to failure. No auto weight progression.',
    ),
    SeedExercise(
      id: 'leg-press',
      name: 'Leg Press',
      primary: Muscle.quads,
      secondary: Muscle.glutes,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 10,
      repMax: 12,
    ),
    SeedExercise(
      id: 'bulgarian-split-squat',
      name: 'Bulgarian Split Squat',
      primary: Muscle.quads,
      secondary: Muscle.glutes,
      role: ExerciseRole.primary,
      sets: 4,
      repMin: 5,
      repMax: 6,
      isUnilateral: true,
      notes: 'Primary leg movement — 4×5 per leg.',
    ),
    SeedExercise(
      id: 'leg-extension',
      name: 'Leg Extension',
      primary: Muscle.quads,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
    ),
    SeedExercise(
      id: 'walking-lunge',
      name: 'Walking Lunge',
      primary: Muscle.quads,
      secondary: Muscle.glutes,
      role: ExerciseRole.secondary,
      sets: 2,
      repMin: 10,
      repMax: 12,
      isUnilateral: true,
    ),
    SeedExercise(
      id: 'romanian-deadlift',
      name: 'Romanian Deadlift',
      primary: Muscle.hamstrings,
      secondary: Muscle.glutes,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 8,
      repMax: 10,
    ),
    SeedExercise(
      id: 'lying-leg-curl',
      name: 'Lying Leg Curl',
      primary: Muscle.hamstrings,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 10,
      repMax: 12,
    ),
    SeedExercise(
      id: 'seated-leg-curl',
      name: 'Seated Leg Curl',
      primary: Muscle.hamstrings,
      role: ExerciseRole.isolation,
      sets: 4,
      repMin: 10,
      repMax: 12,
    ),
    SeedExercise(
      id: 'calf-raise',
      name: 'Calf Raises',
      primary: Muscle.calves,
      role: ExerciseRole.isolation,
      sets: 4,
      repMin: 12,
      repMax: 15,
    ),

    // ---------------- CORE ----------------
    SeedExercise(
      id: 'hanging-leg-raise',
      name: 'Hanging Leg Raise',
      primary: Muscle.core,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
      isBodyweight: true,
    ),
    SeedExercise(
      id: 'ab-wheel',
      name: 'Ab Wheel',
      primary: Muscle.core,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 10,
      repMax: 12,
      isBodyweight: true,
    ),
  ];

  static const templates = <SeedTemplate>[
    SeedTemplate(
      id: 'push',
      name: 'Push',
      weekday: DateTime.monday,
      cardioLabel: 'Rope 5 min',
      accentHex: '#7C5CFF',
      orderIndex: 0,
      exerciseIds: [
        'incline-db-press',
        'seated-shoulder-press',
        'weighted-dips',
        'cable-chest-fly',
        'overhead-tricep-ext',
        'tricep-pulldown',
      ],
    ),
    SeedTemplate(
      id: 'pull',
      name: 'Pull',
      weekday: DateTime.wednesday,
      cardioLabel: 'HIIT bike 15 min',
      accentHex: '#2D9CFF',
      orderIndex: 1,
      exerciseIds: [
        'weighted-pull-ups',
        'cable-row',
        'single-arm-db-row',
        'ez-bar-curl',
        'cross-body-hammer-curl',
        'rear-delt-fly',
      ],
    ),
    SeedTemplate(
      id: 'legs',
      name: 'Legs',
      weekday: DateTime.friday,
      cardioLabel: 'Rope 10 min',
      accentHex: '#FF4D8D',
      orderIndex: 2,
      exerciseIds: [
        'box-jump',
        'bulgarian-split-squat',
        'romanian-deadlift',
        'leg-press',
        'calf-raise',
        'hanging-leg-raise',
        'ab-wheel',
      ],
    ),
    SeedTemplate(
      id: 'extra',
      name: 'Arms',
      weekday: DateTime.saturday,
      accentHex: '#FF7A45',
      orderIndex: 3,
      exerciseIds: [
        'ez-bar-curl',
        'incline-db-curl',
        'tricep-pulldown',
        'overhead-tricep-ext',
      ],
    ),
  ];

  /// Fallback gym days for adherence when no template has a weekday assigned.
  /// The live schedule comes from the templates table — Arms is a full
  /// training day, so the default week is 4 gym days out of 7.
  static const scheduledWeekdays = <int>[
    DateTime.monday,
    DateTime.wednesday,
    DateTime.friday,
    DateTime.saturday,
  ];
}
