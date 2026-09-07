import 'package:drift/drift.dart';

import '../../domain/enums.dart';

/// Columns every synced row carries. `updatedAt` drives last-write-wins and
/// `synced` marks rows the push loop still owes Firestore.
mixin SyncColumns on Table {
  DateTimeColumn get updatedAt =>
      dateTime().withDefault(currentDateAndTime)();
  BoolColumn get synced => boolean().withDefault(const Constant(false))();

  /// Tombstone. Deletes have to survive locally so they can be pushed.
  BoolColumn get deleted => boolean().withDefault(const Constant(false))();
}

@DataClassName('ExerciseRow')
class Exercises extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text().withLength(min: 1, max: 80)();
  TextColumn get muscleGroup => textEnum<MuscleGroup>()();
  TextColumn get role => textEnum<ExerciseRole>()();
  IntColumn get targetSets => integer()();
  IntColumn get repRangeMin => integer()();
  IntColumn get repRangeMax => integer()();
  RealColumn get incrementKg => real()();

  /// Bulgarian split squats, single-arm rows: the logged set is per side.
  BoolColumn get isUnilateral => boolean().withDefault(const Constant(false))();

  /// Weighted pull-ups / dips log *added* load, which can legitimately be 0.
  BoolColumn get isBodyweight => boolean().withDefault(const Constant(false))();

  /// Power work (box jumps): excluded from hypertrophy volume and from
  /// auto-progression.
  BoolColumn get isExplosive => boolean().withDefault(const Constant(false))();

  /// Fine-grained attribution for volume tracking. Primary gets a full set of
  /// credit, secondary half. Nullable so rows that predate the taxonomy load;
  /// resolve through `ExerciseMuscles` rather than reading these directly.
  TextColumn get primaryMuscle => textEnum<Muscle>().nullable()();
  TextColumn get secondaryMuscle => textEnum<Muscle>().nullable()();
  TextColumn get notes => text().nullable()();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  BoolColumn get archived => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TemplateRow')
class Templates extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get name => text()();

  /// 1 = Mon … 7 = Sun, matching [DateTime.weekday]. Null for a template the
  /// user has taken off the weekly schedule.
  IntColumn get weekday => integer().nullable()();

  /// "Rope 5 min", "HIIT bike 15 min" — the cardio prescription for the day.
  TextColumn get cardioLabel => text().nullable()();
  TextColumn get accentHex => text().nullable()();
  IntColumn get orderIndex => integer().withDefault(const Constant(0))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('TemplateExerciseRow')
class TemplateExercises extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get templateId => text().references(Templates, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();

  /// Overrides the exercise default when a template wants a different volume
  /// (e.g. calf raises are 4 sets on legs day, 3 elsewhere).
  IntColumn get setsOverride => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionRow')
class Sessions extends Table with SyncColumns {
  TextColumn get id => text()();

  /// Local calendar day, normalised to midnight — the key for the heatmap.
  DateTimeColumn get date => dateTime()();
  TextColumn get templateId => text().nullable()();
  TextColumn get templateName => text().nullable()();
  DateTimeColumn get startedAt => dateTime()();
  DateTimeColumn get endedAt => dateTime().nullable()();
  IntColumn get durationMin => integer().withDefault(const Constant(0))();

  /// Total kg lifted, denormalised at finish time so history lists stay cheap.
  RealColumn get tonnageKg => real().withDefault(const Constant(0))();
  IntColumn get totalSets => integer().withDefault(const Constant(0))();
  BoolColumn get cardioDone => boolean().withDefault(const Constant(false))();
  BoolColumn get saunaDone => boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();
  BoolColumn get isComplete => boolean().withDefault(const Constant(false))();

  /// True when the wall-clock duration was implausible (>240 min — e.g. the
  /// app was left open overnight) and `durationMin` was capped.
  BoolColumn get durationSuspect =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('SessionExerciseRow')
class SessionExercises extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get orderIndex => integer()();
  IntColumn get targetSets => integer()();
  IntColumn get repRangeMin => integer()();
  IntColumn get repRangeMax => integer()();

  /// Weight the progression engine suggested when the session was built, and
  /// whether that suggestion was an increase. Frozen here so past sessions keep
  /// showing what the app actually told you at the time.
  RealColumn get suggestedWeightKg => real().nullable()();
  BoolColumn get increaseFlagged =>
      boolean().withDefault(const Constant(false))();
  TextColumn get notes => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('WorkoutSetRow')
class WorkoutSets extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get sessionId => text().references(Sessions, #id)();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  IntColumn get setNo => integer()();
  RealColumn get weightKg => real()();
  IntColumn get reps => integer()();
  IntColumn get rpe => integer().nullable()();
  TextColumn get note => text().nullable()();
  BoolColumn get isPr => boolean().withDefault(const Constant(false))();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('PersonalRecordRow')
class PersonalRecords extends Table with SyncColumns {
  TextColumn get id => text()();
  TextColumn get exerciseId => text().references(Exercises, #id)();
  TextColumn get setId => text().nullable()();
  TextColumn get sessionId => text().nullable()();
  TextColumn get type => textEnum<PrType>()();

  /// The headline number: kg for weight PRs, reps for rep PRs, estimated kg for
  /// e1RM PRs.
  RealColumn get value => real()();
  RealColumn get weightKg => real()();
  IntColumn get reps => integer()();
  RealColumn get previousValue => real().nullable()();
  DateTimeColumn get achievedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DataClassName('DailyMetricRow')
class DailyMetrics extends Table with SyncColumns {
  /// Midnight-normalised local day. One row per day.
  DateTimeColumn get date => dateTime()();
  RealColumn get weightKg => real().nullable()();
  IntColumn get steps => integer().nullable()();
  IntColumn get waterMl => integer().withDefault(const Constant(0))();
  IntColumn get kcal => integer().nullable()();
  IntColumn get proteinG => integer().nullable()();
  RealColumn get sleepHours => real().nullable()();

  /// Steps/sleep can come from Health or be typed in; remember which so a
  /// Health refresh never stomps a manual entry.
  BoolColumn get stepsFromHealth =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get sleepFromHealth =>
      boolean().withDefault(const Constant(false))();
  BoolColumn get weightFromHealth =>
      boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {date};
}

@DataClassName('PhotoRow')
class Photos extends Table with SyncColumns {
  TextColumn get id => text()();
  DateTimeColumn get date => dateTime()();
  TextColumn get pose => textEnum<PhotoPose>()();

  /// Absolute path inside the app documents directory. Always populated —
  /// photos are local-first and readable with no network.
  TextColumn get localPath => text()();
  TextColumn get storagePath => text().nullable()();
  IntColumn get widthPx => integer().nullable()();
  IntColumn get heightPx => integer().nullable()();
  IntColumn get byteSize => integer().nullable()();
  TextColumn get note => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

/// Single-row-per-key settings store. Kept in Drift so the local DB stays the
/// one source of truth the plan asks for.
@DataClassName('SettingRow')
class Settings extends Table {
  TextColumn get key => text()();
  TextColumn get value => text()();

  @override
  Set<Column> get primaryKey => {key};
}
