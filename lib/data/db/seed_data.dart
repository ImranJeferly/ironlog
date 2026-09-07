import '../../domain/enums.dart';
import '../../domain/program.dart';

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

/// One exercise slot in a seeded template, with the day's own prescription
/// when it differs from the exercise default.
class SeedPrescription {
  const SeedPrescription(this.exerciseId, {this.sets, this.repMin, this.repMax});

  final String exerciseId;
  final int? sets;
  final int? repMin;
  final int? repMax;
}

class SeedTemplate {
  const SeedTemplate({
    required this.id,
    required this.name,
    required this.orderIndex,
    this.exerciseIds = const [],
    this.prescriptions,
    this.weekday,
    this.cardioLabel,
    this.accentHex,
  });

  final String id;
  final String name;

  /// Plain list form — exercise defaults apply.
  final List<String> exerciseIds;

  /// Prescribed form — per-slot sets / rep range. Wins over [exerciseIds].
  final List<SeedPrescription>? prescriptions;
  final int orderIndex;
  final int? weekday;
  final String? cardioLabel;
  final String? accentHex;

  List<SeedPrescription> get items =>
      prescriptions ?? [for (final id in exerciseIds) SeedPrescription(id)];
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

    // ---------------- PPL 6-Day v2 (rotation, not weekday-bound) ----------
    // Weaknesses first: chest, quads, hams. Sessions target 70–80 min.
    SeedTemplate(
      id: 'ppl6-push-a',
      name: 'Push A',
      accentHex: '#7C5CFF',
      orderIndex: 10,
      prescriptions: [
        SeedPrescription('flat-db-press', sets: 4, repMin: 6, repMax: 8),
        SeedPrescription('weighted-dips', sets: 3, repMin: 8, repMax: 10),
        SeedPrescription('incline-db-press', sets: 3, repMin: 10, repMax: 12),
        SeedPrescription('cable-chest-fly', sets: 3, repMin: 12, repMax: 15),
        SeedPrescription('lateral-raise', sets: 4, repMin: 12, repMax: 15),
        SeedPrescription('tricep-pulldown', sets: 3, repMin: 10, repMax: 12),
      ],
    ),
    SeedTemplate(
      id: 'ppl6-pull-a',
      name: 'Pull A',
      accentHex: '#2D9CFF',
      orderIndex: 11,
      prescriptions: [
        SeedPrescription('weighted-pull-ups', sets: 4, repMin: 5, repMax: 8),
        SeedPrescription('cable-row', sets: 3, repMin: 8, repMax: 12),
        SeedPrescription('single-arm-db-row', sets: 3, repMin: 10, repMax: 12),
        SeedPrescription('rear-delt-fly', sets: 3, repMin: 15, repMax: 15),
        SeedPrescription('ez-bar-curl', sets: 3, repMin: 8, repMax: 12),
        SeedPrescription('cross-body-hammer-curl', sets: 2, repMin: 12, repMax: 12),
      ],
    ),
    SeedTemplate(
      id: 'ppl6-legs-a',
      name: 'Legs A',
      accentHex: '#FF4D8D',
      orderIndex: 12,
      prescriptions: [
        SeedPrescription('leg-press', sets: 4, repMin: 8, repMax: 12),
        SeedPrescription('bulgarian-split-squat', sets: 3, repMin: 8, repMax: 10),
        SeedPrescription('leg-extension', sets: 3, repMin: 12, repMax: 15),
        SeedPrescription('lying-leg-curl', sets: 3, repMin: 10, repMax: 12),
        SeedPrescription('calf-raise', sets: 4, repMin: 10, repMax: 15),
        SeedPrescription('hanging-leg-raise', sets: 3, repMin: 12, repMax: 12),
      ],
    ),
    SeedTemplate(
      id: 'ppl6-push-b',
      name: 'Push B',
      accentHex: '#9D7CFF',
      orderIndex: 13,
      prescriptions: [
        SeedPrescription('incline-db-press', sets: 4, repMin: 6, repMax: 8),
        SeedPrescription('seated-shoulder-press', sets: 3, repMin: 8, repMax: 10),
        SeedPrescription('machine-chest-press', sets: 3, repMin: 10, repMax: 12),
        SeedPrescription('lateral-raise', sets: 4, repMin: 15, repMax: 15),
        SeedPrescription('overhead-tricep-ext', sets: 3, repMin: 10, repMax: 12),
        SeedPrescription('skull-crusher', sets: 2, repMin: 10, repMax: 10),
      ],
    ),
    SeedTemplate(
      id: 'ppl6-pull-b',
      name: 'Pull B',
      accentHex: '#4DB0FF',
      orderIndex: 14,
      prescriptions: [
        SeedPrescription('chest-supported-row', sets: 4, repMin: 8, repMax: 10),
        SeedPrescription('lat-pulldown', sets: 3, repMin: 10, repMax: 12),
        SeedPrescription('cable-row', sets: 3, repMin: 12, repMax: 15),
        SeedPrescription('shrugs', sets: 3, repMin: 10, repMax: 12),
        SeedPrescription('incline-db-curl', sets: 3, repMin: 10, repMax: 12),
        SeedPrescription('ez-bar-curl', sets: 2, repMin: 12, repMax: 12),
      ],
    ),
    SeedTemplate(
      id: 'ppl6-legs-b',
      name: 'Legs B',
      accentHex: '#FF6FA5',
      orderIndex: 15,
      prescriptions: [
        SeedPrescription('romanian-deadlift', sets: 4, repMin: 6, repMax: 8),
        SeedPrescription('seated-leg-curl', sets: 4, repMin: 10, repMax: 12),
        SeedPrescription('leg-press', sets: 3, repMin: 12, repMax: 15),
        SeedPrescription('walking-lunge', sets: 2, repMin: 10, repMax: 10),
        SeedPrescription('calf-raise', sets: 4, repMin: 10, repMax: 15),
        SeedPrescription('ab-wheel', sets: 3, repMin: 10, repMax: 10),
      ],
    ),
  ];

  /// The active rotation: Push A → Pull A → Legs A → Push B → Pull B →
  /// Legs B → (rest) → repeat. Target 6 sessions a week.
  static const program = ProgramDefinition(
    id: 'ppl6v2',
    name: 'PPL 6-Day v2',
    sessionsPerWeek: 6,
    dayIds: [
      'ppl6-push-a',
      'ppl6-pull-a',
      'ppl6-legs-a',
      'ppl6-push-b',
      'ppl6-pull-b',
      'ppl6-legs-b',
    ],
  );

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
