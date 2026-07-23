import '../../domain/enums.dart';

/// A seeded exercise definition. IDs are stable slugs so re-seeding is
/// idempotent and Firestore documents keep the same keys across installs.
class SeedExercise {
  const SeedExercise({
    required this.id,
    required this.name,
    required this.muscleGroup,
    required this.role,
    required this.sets,
    required this.repMin,
    required this.repMax,
    this.isUnilateral = false,
    this.isBodyweight = false,
    this.incrementKg,
    this.notes,
  });

  final String id;
  final String name;
  final MuscleGroup muscleGroup;
  final ExerciseRole role;
  final int sets;
  final int repMin;
  final int repMax;
  final bool isUnilateral;
  final bool isBodyweight;
  final double? incrementKg;
  final String? notes;

  double get resolvedIncrementKg =>
      incrementKg ?? muscleGroup.defaultIncrementKg;
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

/// The exercise library. Rep ranges follow the plan's double-progression rule:
/// the listed scheme is the bottom of the range, and you earn the weight jump
/// by hitting the top of the range on every set.
///
/// 4×5 → 5–6 · 3×8 → 8–10 · 3×10 → 10–12 · 3×12 → 12–15 · 3×15 → 15–18 · 4×3 → 3
abstract final class SeedData {
  static const exercises = <SeedExercise>[
    // ---------------- PUSH ----------------
    SeedExercise(
      id: 'incline-db-press',
      name: 'Incline DB Press',
      muscleGroup: MuscleGroup.chest,
      role: ExerciseRole.primary,
      sets: 4,
      repMin: 5,
      repMax: 6,
      notes: 'Primary press. 2–3 reps in reserve, 5th top set optional.',
    ),
    SeedExercise(
      id: 'seated-shoulder-press',
      name: 'Seated Shoulder Press',
      muscleGroup: MuscleGroup.shoulders,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 8,
      repMax: 10,
    ),
    SeedExercise(
      id: 'weighted-dips',
      name: 'Weighted Dips',
      muscleGroup: MuscleGroup.chest,
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
      muscleGroup: MuscleGroup.chest,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
    ),
    SeedExercise(
      id: 'overhead-tricep-ext',
      name: 'Overhead Tricep Ext',
      muscleGroup: MuscleGroup.arms,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
    ),
    SeedExercise(
      id: 'tricep-pulldown',
      name: 'Tricep Pulldown',
      muscleGroup: MuscleGroup.arms,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
    ),

    // ---------------- PULL ----------------
    SeedExercise(
      id: 'weighted-pull-ups',
      name: 'Weighted Pull-ups',
      muscleGroup: MuscleGroup.back,
      role: ExerciseRole.primary,
      sets: 4,
      repMin: 5,
      repMax: 6,
      isBodyweight: true,
      notes: 'Log added load only — 0 kg is bodyweight.',
    ),
    SeedExercise(
      id: 'cable-row',
      name: 'Cable Row',
      muscleGroup: MuscleGroup.back,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 8,
      repMax: 10,
    ),
    SeedExercise(
      id: 'single-arm-db-row',
      name: 'Single-Arm DB Row',
      muscleGroup: MuscleGroup.back,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 10,
      repMax: 12,
      isUnilateral: true,
    ),
    SeedExercise(
      id: 'ez-bar-curl',
      name: 'EZ Bar Curl',
      muscleGroup: MuscleGroup.arms,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 10,
      repMax: 12,
    ),
    SeedExercise(
      id: 'cross-body-hammer-curl',
      name: 'Cross-Body Hammer Curl',
      muscleGroup: MuscleGroup.arms,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
      isUnilateral: true,
    ),
    SeedExercise(
      id: 'rear-delt-fly',
      name: 'Rear Delt Fly',
      muscleGroup: MuscleGroup.shoulders,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 15,
      repMax: 18,
    ),

    // ---------------- LEGS ----------------
    SeedExercise(
      id: 'box-jump',
      name: 'Box Jump / Jump Squat',
      muscleGroup: MuscleGroup.legs,
      role: ExerciseRole.explosive,
      sets: 4,
      repMin: 3,
      repMax: 3,
      isBodyweight: true,
      notes: 'Max intent, never to failure. No auto weight progression.',
    ),
    SeedExercise(
      id: 'bulgarian-split-squat',
      name: 'Bulgarian Split Squat',
      muscleGroup: MuscleGroup.legs,
      role: ExerciseRole.primary,
      sets: 4,
      repMin: 5,
      repMax: 6,
      isUnilateral: true,
      notes: 'Primary leg movement — 4×5 per leg.',
    ),
    SeedExercise(
      id: 'romanian-deadlift',
      name: 'Romanian Deadlift',
      muscleGroup: MuscleGroup.legs,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 8,
      repMax: 10,
    ),
    SeedExercise(
      id: 'leg-press',
      name: 'Leg Press',
      muscleGroup: MuscleGroup.legs,
      role: ExerciseRole.secondary,
      sets: 3,
      repMin: 10,
      repMax: 12,
    ),
    SeedExercise(
      id: 'calf-raise',
      name: 'Calf Raises',
      muscleGroup: MuscleGroup.legs,
      role: ExerciseRole.isolation,
      sets: 4,
      repMin: 12,
      repMax: 15,
    ),
    SeedExercise(
      id: 'hanging-leg-raise',
      name: 'Hanging Leg Raise',
      muscleGroup: MuscleGroup.core,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
      isBodyweight: true,
    ),
    SeedExercise(
      id: 'ab-wheel',
      name: 'Ab Wheel',
      muscleGroup: MuscleGroup.core,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 10,
      repMax: 12,
      isBodyweight: true,
    ),

    // ---------------- EXTRA ----------------
    SeedExercise(
      id: 'incline-db-curl',
      name: 'Incline Curl',
      muscleGroup: MuscleGroup.arms,
      role: ExerciseRole.isolation,
      sets: 3,
      repMin: 12,
      repMax: 15,
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
