import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import '../../domain/enums.dart';
import 'seed_data.dart';
import 'tables.dart';

part 'database.g.dart';

@DriftDatabase(
  tables: [
    Exercises,
    Templates,
    TemplateExercises,
    Sessions,
    SessionExercises,
    WorkoutSets,
    PersonalRecords,
    DailyMetrics,
    Photos,
    Settings,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(driftDatabase(name: 'ironlog'));

  /// Used by tests with `NativeDatabase.memory()`.
  AppDatabase.withExecutor(super.executor);

  @override
  int get schemaVersion => 1;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Seeding runs on every open but only inserts what's missing, so adding
      // an exercise to SeedData in a later release backfills existing installs
      // without touching anything the user has edited.
      await seedIfNeeded();
    },
  );

  /// Inserts any seed exercise/template rows that aren't present yet. Existing
  /// rows are left alone — the user's own edits win.
  Future<void> seedIfNeeded() async {
    final existingExercises = await select(exercises).get();
    final existingIds = existingExercises.map((e) => e.id).toSet();
    final now = DateTime.now();

    await batch((b) {
      for (final seed in SeedData.exercises) {
        if (existingIds.contains(seed.id)) continue;
        b.insert(
          exercises,
          ExercisesCompanion.insert(
            id: seed.id,
            name: seed.name,
            muscleGroup: seed.muscleGroup,
            role: seed.role,
            targetSets: seed.sets,
            repRangeMin: seed.repMin,
            repRangeMax: seed.repMax,
            incrementKg: seed.resolvedIncrementKg,
            isUnilateral: Value(seed.isUnilateral),
            isBodyweight: Value(seed.isBodyweight),
            notes: Value(seed.notes),
            updatedAt: Value(now),
          ),
        );
      }
    });

    // One-time fixup for installs seeded before Arms became a scheduled day:
    // it used to be an unscheduled "Extra — Arms" finisher, but it is a full
    // training day — 4 gym days out of 7. Guarded by a flag so a user who
    // later takes it off the schedule isn't fought on every open.
    const armsFixupKey = 'arms_weekday_fixup_v1';
    if (await getSetting(armsFixupKey) == null) {
      await (update(templates)
            ..where((t) => t.id.equals('extra') & t.weekday.isNull()))
          .write(
        TemplatesCompanion(
          name: const Value('Arms'),
          weekday: const Value(DateTime.saturday),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
      await setSetting(armsFixupKey, 'done');
    }

    final existingTemplates = await select(templates).get();
    final existingTemplateIds = existingTemplates.map((t) => t.id).toSet();

    await batch((b) {
      for (final seed in SeedData.templates) {
        if (existingTemplateIds.contains(seed.id)) continue;
        b.insert(
          templates,
          TemplatesCompanion.insert(
            id: seed.id,
            name: seed.name,
            weekday: Value(seed.weekday),
            cardioLabel: Value(seed.cardioLabel),
            accentHex: Value(seed.accentHex),
            orderIndex: Value(seed.orderIndex),
            updatedAt: Value(now),
          ),
        );
        for (var i = 0; i < seed.exerciseIds.length; i++) {
          b.insert(
            templateExercises,
            TemplateExercisesCompanion.insert(
              id: '${seed.id}__${seed.exerciseIds[i]}',
              templateId: seed.id,
              exerciseId: seed.exerciseIds[i],
              orderIndex: i,
              updatedAt: Value(now),
            ),
          );
        }
      }
    });
  }

  // ---------------------------------------------------------------- settings

  Future<String?> getSetting(String key) async {
    final row = await (select(
      settings,
    )..where((t) => t.key.equals(key))).getSingleOrNull();
    return row?.value;
  }

  Future<void> setSetting(String key, String value) async {
    await into(
      settings,
    ).insertOnConflictUpdate(SettingRow(key: key, value: value));
  }

  Stream<String?> watchSetting(String key) {
    return (select(settings)..where((t) => t.key.equals(key)))
        .watchSingleOrNull()
        .map((row) => row?.value);
  }

  // --------------------------------------------------------------- exercises

  Stream<List<ExerciseRow>> watchExercises() {
    return (select(exercises)
          ..where((t) => t.deleted.equals(false) & t.archived.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .watch();
  }

  Future<List<ExerciseRow>> allExercises() {
    return (select(
      exercises,
    )..where((t) => t.deleted.equals(false))).get();
  }

  Future<ExerciseRow?> exerciseById(String id) {
    return (select(
      exercises,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  // --------------------------------------------------------------- templates

  Stream<List<TemplateRow>> watchTemplates() {
    return (select(templates)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .watch();
  }

  Future<TemplateRow?> templateById(String id) {
    return (select(
      templates,
    )..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  /// Distinct weekdays that have a template scheduled — the gym days the
  /// adherence percentage and streaks are measured against.
  Future<Set<int>> scheduledWeekdays() async {
    final rows = await (select(
      templates,
    )..where((t) => t.deleted.equals(false))).get();
    return rows.map((t) => t.weekday).whereType<int>().toSet();
  }

  /// Template exercises joined to their exercise definitions, in order.
  Future<List<(TemplateExerciseRow, ExerciseRow)>> templateExerciseRows(
    String templateId,
  ) async {
    final query =
        select(templateExercises).join([
          innerJoin(
            exercises,
            exercises.id.equalsExp(templateExercises.exerciseId),
          ),
        ])
          ..where(
            templateExercises.templateId.equals(templateId) &
                templateExercises.deleted.equals(false) &
                exercises.deleted.equals(false),
          )
          ..orderBy([OrderingTerm.asc(templateExercises.orderIndex)]);

    final rows = await query.get();
    return rows
        .map(
          (r) => (r.readTable(templateExercises), r.readTable(exercises)),
        )
        .toList();
  }

  // ---------------------------------------------------------------- sessions

  Stream<List<SessionRow>> watchSessions({int? limit}) {
    final q = select(sessions)
      ..where((t) => t.deleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.startedAt)]);
    if (limit != null) q.limit(limit);
    return q.watch();
  }

  Future<List<SessionRow>> sessionsBetween(DateTime from, DateTime to) {
    return (select(sessions)
          ..where(
            (t) =>
                t.deleted.equals(false) &
                t.date.isBiggerOrEqualValue(from) &
                t.date.isSmallerOrEqualValue(to),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  Future<SessionRow?> sessionById(String id) {
    return (select(sessions)..where((t) => t.id.equals(id))).getSingleOrNull();
  }

  Stream<SessionRow?> watchSessionById(String id) {
    return (select(
      sessions,
    )..where((t) => t.id.equals(id))).watchSingleOrNull();
  }

  /// The in-progress session, if any. There is at most one.
  Stream<SessionRow?> watchActiveSession() {
    return (select(sessions)
          ..where((t) => t.isComplete.equals(false) & t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Future<SessionRow?> activeSession() {
    return (select(sessions)
          ..where((t) => t.isComplete.equals(false) & t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.startedAt)])
          ..limit(1))
        .getSingleOrNull();
  }

  Future<List<SessionExerciseRow>> sessionExerciseRows(String sessionId) {
    return (select(sessionExercises)
          ..where(
            (t) => t.sessionId.equals(sessionId) & t.deleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .get();
  }

  Stream<List<SessionExerciseRow>> watchSessionExercises(String sessionId) {
    return (select(sessionExercises)
          ..where(
            (t) => t.sessionId.equals(sessionId) & t.deleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]))
        .watch();
  }

  // -------------------------------------------------------------------- sets

  Stream<List<WorkoutSetRow>> watchSetsForSession(String sessionId) {
    return (select(workoutSets)
          ..where(
            (t) => t.sessionId.equals(sessionId) & t.deleted.equals(false),
          )
          ..orderBy([
            (t) => OrderingTerm.asc(t.exerciseId),
            (t) => OrderingTerm.asc(t.setNo),
          ]))
        .watch();
  }

  Future<List<WorkoutSetRow>> setsForSession(String sessionId) {
    return (select(workoutSets)
          ..where(
            (t) => t.sessionId.equals(sessionId) & t.deleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.setNo)]))
        .get();
  }

  Future<List<WorkoutSetRow>> setsForExercise(String exerciseId) {
    return (select(workoutSets)
          ..where(
            (t) =>
                t.exerciseId.equals(exerciseId) &
                t.deleted.equals(false) &
                t.isWarmup.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.completedAt)]))
        .get();
  }

  Future<List<WorkoutSetRow>> allSets() {
    return (select(workoutSets)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.asc(t.completedAt)]))
        .get();
  }

  /// Working sets of the most recent *completed* session that contained this
  /// exercise. Drives both ghost prefill and the progression decision.
  Future<List<WorkoutSetRow>> lastCompletedSetsForExercise(
    String exerciseId, {
    String? excludingSessionId,
  }) async {
    final query =
        select(workoutSets).join([
          innerJoin(sessions, sessions.id.equalsExp(workoutSets.sessionId)),
        ])..where(
          workoutSets.exerciseId.equals(exerciseId) &
              workoutSets.deleted.equals(false) &
              workoutSets.isWarmup.equals(false) &
              sessions.isComplete.equals(true) &
              sessions.deleted.equals(false),
        );

    if (excludingSessionId != null) {
      query.where(sessions.id.equals(excludingSessionId).not());
    }
    query.orderBy([OrderingTerm.desc(sessions.startedAt)]);

    final rows = await query.get();
    if (rows.isEmpty) return const [];

    final latestSessionId = rows.first.readTable(workoutSets).sessionId;
    final sets = rows
        .map((r) => r.readTable(workoutSets))
        .where((s) => s.sessionId == latestSessionId)
        .toList()
      ..sort((a, b) => a.setNo.compareTo(b.setNo));
    return sets;
  }

  // --------------------------------------------------------------------- PRs

  Stream<List<PersonalRecordRow>> watchPersonalRecords({int? limit}) {
    final q = select(personalRecords)
      ..where((t) => t.deleted.equals(false))
      ..orderBy([(t) => OrderingTerm.desc(t.achievedAt)]);
    if (limit != null) q.limit(limit);
    return q.watch();
  }

  Future<List<PersonalRecordRow>> personalRecordsForExercise(
    String exerciseId,
  ) {
    return (select(personalRecords)
          ..where(
            (t) => t.exerciseId.equals(exerciseId) & t.deleted.equals(false),
          )
          ..orderBy([(t) => OrderingTerm.desc(t.achievedAt)]))
        .get();
  }

  // ----------------------------------------------------------------- metrics

  Future<DailyMetricRow?> metricForDate(DateTime date) {
    return (select(
      dailyMetrics,
    )..where((t) => t.date.equals(date))).getSingleOrNull();
  }

  Stream<DailyMetricRow?> watchMetricForDate(DateTime date) {
    return (select(
      dailyMetrics,
    )..where((t) => t.date.equals(date))).watchSingleOrNull();
  }

  Stream<List<DailyMetricRow>> watchMetricsBetween(DateTime from, DateTime to) {
    return (select(dailyMetrics)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(from) &
                t.date.isSmallerOrEqualValue(to),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .watch();
  }

  Future<List<DailyMetricRow>> metricsBetween(DateTime from, DateTime to) {
    return (select(dailyMetrics)
          ..where(
            (t) =>
                t.date.isBiggerOrEqualValue(from) &
                t.date.isSmallerOrEqualValue(to),
          )
          ..orderBy([(t) => OrderingTerm.asc(t.date)]))
        .get();
  }

  // ------------------------------------------------------------------ photos

  Stream<List<PhotoRow>> watchPhotos() {
    return (select(photos)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .watch();
  }

  Future<List<PhotoRow>> allPhotos() {
    return (select(photos)
          ..where((t) => t.deleted.equals(false))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  // -------------------------------------------------------------------- sync

  Future<List<ExerciseRow>> unsyncedExercises() =>
      (select(exercises)..where((t) => t.synced.equals(false))).get();

  Future<List<TemplateRow>> unsyncedTemplates() =>
      (select(templates)..where((t) => t.synced.equals(false))).get();

  Future<List<TemplateExerciseRow>> unsyncedTemplateExercises() =>
      (select(templateExercises)..where((t) => t.synced.equals(false))).get();

  Future<List<SessionRow>> unsyncedSessions() =>
      (select(sessions)..where((t) => t.synced.equals(false))).get();

  Future<List<SessionExerciseRow>> unsyncedSessionExercises() =>
      (select(sessionExercises)..where((t) => t.synced.equals(false))).get();

  Future<List<WorkoutSetRow>> unsyncedSets() =>
      (select(workoutSets)..where((t) => t.synced.equals(false))).get();

  Future<List<PersonalRecordRow>> unsyncedPersonalRecords() =>
      (select(personalRecords)..where((t) => t.synced.equals(false))).get();

  Future<List<DailyMetricRow>> unsyncedMetrics() =>
      (select(dailyMetrics)..where((t) => t.synced.equals(false))).get();

  Future<List<PhotoRow>> unsyncedPhotos() =>
      (select(photos)..where((t) => t.synced.equals(false))).get();

  /// Wipes user-generated data but keeps the exercise/template library.
  Future<void> clearWorkoutData() async {
    await batch((b) {
      b.deleteAll(workoutSets);
      b.deleteAll(sessionExercises);
      b.deleteAll(sessions);
      b.deleteAll(personalRecords);
    });
  }
}
