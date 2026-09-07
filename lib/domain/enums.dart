/// Role determines the rep scheme and how the progression engine treats an
/// exercise. Straight out of the plan's "role-based schemes" table.
enum ExerciseRole {
  /// 4×5, heavy, 2–3 reps in reserve. One per day.
  primary('Primary', 4, 5, 6),

  /// 3×8 in an 8–10 range, moderate-heavy.
  secondary('Secondary', 3, 8, 10),

  /// 3×12–15, chase the burn.
  isolation('Isolation', 3, 12, 15),

  /// 4×3 max intent, NOT to failure — excluded from auto-progression.
  explosive('Explosive', 4, 3, 3);

  const ExerciseRole(
    this.label,
    this.defaultSets,
    this.defaultRepMin,
    this.defaultRepMax,
  );

  final String label;
  final int defaultSets;
  final int defaultRepMin;
  final int defaultRepMax;

  /// Explosive work is driven by bar speed, not by grinding out top-of-range
  /// reps, so double progression never fires for it.
  bool get autoProgresses => this != ExerciseRole.explosive;
}

enum MuscleGroup {
  chest('Chest', 'chest', false),
  back('Back', 'back', false),
  shoulders('Shoulders', 'shoulders', false),
  biceps('Biceps', 'biceps', false),
  triceps('Triceps', 'triceps', false),
  legs('Legs', 'legs', true),
  core('Core', 'core', false);

  const MuscleGroup(this.label, this.key, this.isLowerBody);

  final String label;
  final String key;
  final bool isLowerBody;

  /// +2.5 kg upper / +5 kg lower, per the double-progression rule.
  double get defaultIncrementKg => isLowerBody ? 5.0 : 2.5;
}

/// Fine-grained muscle taxonomy that volume tracking and progression run on.
/// Every muscle rolls up to a coarse [MuscleGroup] via [group], which is what
/// the legacy charts and colour palette key on.
enum Muscle {
  chest('Chest', 'chest', MuscleGroup.chest),
  back('Back', 'back', MuscleGroup.back),
  traps('Traps', 'traps', MuscleGroup.back),
  shoulders('Shoulders', 'shoulders', MuscleGroup.shoulders),
  sideDelts('Side Delts', 'side_delts', MuscleGroup.shoulders),
  rearDelts('Rear Delts', 'rear_delts', MuscleGroup.shoulders),
  biceps('Biceps', 'biceps', MuscleGroup.biceps),
  triceps('Triceps', 'triceps', MuscleGroup.triceps),
  quads('Quads', 'quads', MuscleGroup.legs),
  hamstrings('Hamstrings', 'hamstrings', MuscleGroup.legs),
  glutes('Glutes', 'glutes', MuscleGroup.legs),
  calves('Calves', 'calves', MuscleGroup.legs),
  core('Core', 'core', MuscleGroup.core);

  const Muscle(this.label, this.key, this.group);

  final String label;
  final String key;
  final MuscleGroup group;

  bool get isLowerBody => group.isLowerBody;

  double get defaultIncrementKg => group.defaultIncrementKg;

  /// Best guess for exercises that predate the taxonomy (custom ones created
  /// with only a coarse group).
  static Muscle fromGroup(MuscleGroup g) => switch (g) {
    MuscleGroup.chest => chest,
    MuscleGroup.back => back,
    MuscleGroup.shoulders => shoulders,
    MuscleGroup.biceps => biceps,
    MuscleGroup.triceps => triceps,
    MuscleGroup.legs => quads,
    MuscleGroup.core => core,
  };
}

enum PhotoPose {
  front('Front'),
  side('Side'),
  back('Back');

  const PhotoPose(this.label);

  final String label;
}

enum PrType {
  /// Heaviest weight ever moved on this exercise (any rep count ≥ 1).
  weight('Weight PR'),

  /// Most reps ever at this weight or heavier.
  reps('Rep PR'),

  /// Best Epley-estimated one-rep max.
  estimated1RM('e1RM PR');

  const PrType(this.label);

  final String label;
}

enum WeightUnit {
  kg('kg', 1.0),
  lb('lb', 2.2046226218487757);

  const WeightUnit(this.label, this.perKg);

  final String label;
  final double perKg;

  double fromKg(double kg) => kg * perKg;

  double toKg(double value) => value / perKg;
}

/// Optional per-set difficulty. Stored as an RPE number so it charts cleanly,
/// surfaced as an emoji so logging stays one tap.
enum RpeLevel {
  easy(6, '😤', 'Easy'),
  solid(7, '💪', 'Solid'),
  hard(8, '🔥', 'Hard'),
  grinder(9, '💀', 'Grinder'),
  allOut(10, '🥵', 'Max');

  const RpeLevel(this.rpe, this.emoji, this.label);

  final int rpe;
  final String emoji;
  final String label;

  static RpeLevel? fromRpe(int? rpe) {
    if (rpe == null) return null;
    for (final level in RpeLevel.values) {
      if (level.rpe == rpe) return level;
    }
    return null;
  }
}

enum SyncState { idle, syncing, success, failed, disabled }
