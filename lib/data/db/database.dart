import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../../domain/program.dart';
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
  int get schemaVersion => 5;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) async {
      await m.createAll();
    },
    onUpgrade: (m, from, to) async {
      // v2: sessions.duration_suspect (implausible durations are capped and
      // flagged instead of silently inflating history).
      if (from < 2) {
        await m.addColumn(sessions, sessions.durationSuspect);
      }
      // v3: fine-grained muscle attribution + explosive flag on exercises.
      if (from < 3) {
        await m.addColumn(exercises, exercises.isExplosive);
        await m.addColumn(exercises, exercises.primaryMuscle);
        await m.addColumn(exercises, exercises.secondaryMuscle);
      }
      // v4: per-day rep ranges on template exercises (the 6-day program
      // prescribes different ranges for the same lift on different days).
      if (from < 4) {
        await m.addColumn(templateExercises, templateExercises.repMinOverride);
        await m.addColumn(templateExercises, templateExercises.repMaxOverride);
      }
      // v5: tape measurements on the daily row, and superset grouping on both
      // the template and the per-session snapshot.
      if (from < 5) {
        await m.addColumn(dailyMetrics, dailyMetrics.chestCm);
        await m.addColumn(dailyMetrics, dailyMetrics.waistCm);
        await m.addColumn(dailyMetrics, dailyMetrics.hipsCm);
        await m.addColumn(dailyMetrics, dailyMetrics.armCm);
        await m.addColumn(dailyMetrics, dailyMetrics.thighCm);
        await m.addColumn(dailyMetrics, dailyMetrics.neckCm);
        await m.addColumn(templateExercises, templateExercises.supersetGroup);
        await m.addColumn(sessionExercises, sessionExercises.supersetGroup);
      }
    },
    beforeOpen: (details) async {
      await customStatement('PRAGMA foreign_keys = ON');
      // Reclassify the old single "Arms" group into Biceps/Triceps. Runs as raw
      // SQL *before* any enum-mapped read, because the old rows still store
      // 'arms', which no longer maps to a MuscleGroup value.
      await _splitArmsIntoBicepsTriceps();
      // Seeding runs on every open but only inserts what's missing, so adding
      // an exercise to SeedData in a later release backfills existing installs
      // without touching anything the user has edited.
      await seedIfNeeded();
      await _backfillMuscleTaxonomy();
      await _repairDataIntegrity();
    },
  );

  /// One-time backfill for installs that predate primary/secondary muscles:
  /// seeded exercises get the spec's attribution by id, custom ones get their
  /// coarse group's best-guess primary, and anything with the explosive role
  /// gets the explosive flag. Untouched rows are left alone.
  Future<void> _backfillMuscleTaxonomy() async {
    const flag = 'muscle_taxonomy_v1';
    if (await getSetting(flag) != null) return;
    final now = DateTime.now();
    final seedById = {for (final s in SeedData.exercises) s.id: s};

    final rows = await select(exercises).get();
    var touched = 0;
    for (final row in rows) {
      final seed = seedById[row.id];
      final primary =
          row.primaryMuscle ?? seed?.primary ?? Muscle.fromGroup(row.muscleGroup);
      final secondary = row.secondaryMuscle ?? seed?.secondary;
      final explosive =
          row.isExplosive || (seed?.isExplosive ?? false) ||
          row.role == ExerciseRole.explosive;
      final unchanged =
          row.primaryMuscle == primary &&
          row.secondaryMuscle == secondary &&
          row.isExplosive == explosive;
      if (unchanged) continue;
      await (update(exercises)..where((t) => t.id.equals(row.id))).write(
        ExercisesCompanion(
          primaryMuscle: Value(primary),
          secondaryMuscle: Value(secondary),
          isExplosive: Value(explosive),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
      touched++;
    }
    debugPrint('IronLog: muscle taxonomy backfilled on $touched exercise(s)');
    await setSetting(flag, 'done');
  }

  /// Maximum plausible session length. Anything longer is almost always the
  /// app left open — it gets capped and flagged rather than counted.
  static const maxSessionMinutes = 240;

  /// One-time data repair: cap and flag implausibly long sessions, tombstone
  /// completed sessions that have no working sets, and tombstone "phantom"
  /// sets (0 kg and ≤1 rep on a non-bodyweight exercise). Tombstones rather
  /// than hard deletes so the fixes reach the account. Runs once per install.
  Future<void> _repairDataIntegrity() async {
    const flag = 'data_repair_v1';
    if (await getSetting(flag) != null) return;
    final now = DateTime.now();

    // 1) Sessions over the cap.
    final long = await (select(
      sessions,
    )..where((t) => t.durationMin.isBiggerThanValue(maxSessionMinutes))).get();
    for (final s in long) {
      await (update(sessions)..where((t) => t.id.equals(s.id))).write(
        SessionsCompanion(
          durationMin: const Value(maxSessionMinutes),
          durationSuspect: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
    }

    // 2) Phantom sets, sparing bodyweight moves where 0 kg is legitimate.
    final bodyweightIds = (await (select(
      exercises,
    )..where((t) => t.isBodyweight.equals(true))).get()).map((e) => e.id).toSet();
    final phantoms =
        await (select(workoutSets)..where(
              (t) =>
                  t.deleted.equals(false) &
                  t.weightKg.equals(0.0) &
                  t.reps.isSmallerOrEqualValue(1),
            ))
            .get();
    var phantomCount = 0;
    for (final s in phantoms) {
      if (bodyweightIds.contains(s.exerciseId)) continue;
      await (update(workoutSets)..where((t) => t.id.equals(s.id))).write(
        WorkoutSetsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
      await (update(personalRecords)..where((t) => t.setId.equals(s.id))).write(
        PersonalRecordsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
      phantomCount++;
    }

    // 3) Completed sessions with no working sets left.
    final complete = await (select(
      sessions,
    )..where((t) => t.isComplete.equals(true) & t.deleted.equals(false))).get();
    var emptyCount = 0;
    for (final s in complete) {
      final working =
          await (select(workoutSets)..where(
                (t) =>
                    t.sessionId.equals(s.id) &
                    t.deleted.equals(false) &
                    t.isWarmup.equals(false),
              ))
              .get();
      if (working.isNotEmpty) continue;
      await (update(sessions)..where((t) => t.id.equals(s.id))).write(
        SessionsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
      emptyCount++;
    }

    debugPrint(
      'IronLog: data repair — ${long.length} long session(s) capped, '
      '$phantomCount phantom set(s) removed, $emptyCount empty session(s) removed',
    );
    await setSetting(flag, 'done');
  }

  /// One-time migration: the "Arms" muscle group became "Biceps" and "Triceps".
  /// Known tricep movements go to Triceps; every other former-arms exercise
  /// (curls, and any custom ones) defaults to Biceps. Guarded by a flag so it
  /// only runs once per install.
  Future<void> _splitArmsIntoBicepsTriceps() async {
    const flag = 'arms_split_biceps_triceps_v1';
    if (await getSetting(flag) != null) return;

    // Triceps: seeded ids plus anything that reads like a tricep movement.
    await customStatement(
      "UPDATE exercises SET muscle_group = 'triceps' "
      "WHERE muscle_group = 'arms' AND ("
      "id IN ('overhead-tricep-ext', 'tricep-pulldown') "
      "OR lower(name) LIKE '%tricep%' "
      "OR lower(name) LIKE '%pushdown%' "
      "OR lower(name) LIKE '%skull%' "
      "OR lower(name) LIKE '%dip%' "
      "OR lower(name) LIKE '%extension%')",
    );
    // Everything still tagged 'arms' (curls, custom) becomes Biceps.
    await customStatement(
      "UPDATE exercises SET muscle_group = 'biceps' WHERE muscle_group = 'arms'",
    );

    await setSetting(flag, 'done');
  }

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
            isExplosive: Value(seed.isExplosive),
            primaryMuscle: Value(seed.primary),
            secondaryMuscle: Value(seed.secondary),
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
        final items = seed.items;
        for (var i = 0; i < items.length; i++) {
          final p = items[i];
          b.insert(
            templateExercises,
            TemplateExercisesCompanion.insert(
              id: '${seed.id}__${p.exerciseId}',
              templateId: seed.id,
              exerciseId: p.exerciseId,
              orderIndex: i,
              setsOverride: Value(p.sets),
              repMinOverride: Value(p.repMin),
              repMaxOverride: Value(p.repMax),
              updatedAt: Value(now),
            ),
          );
        }
      }
    });

    await _activateProgramIfNeeded(now);
  }

  /// Makes the seeded 6-day program the active rotation on first launch after
  /// it ships. Guarded so a user who later switches programs isn't fought.
  Future<void> _activateProgramIfNeeded(DateTime now) async {
    const flag = 'program_${_programActivationVersion}_activated';
    if (await getSetting(flag) != null) return;
    if (await getSetting(ProgramKeys.id) == null) {
      await setSetting(ProgramKeys.id, SeedData.program.id);
      await setSetting(ProgramKeys.cursor, '0');
      await setSetting(ProgramKeys.startedAt, now.dayStart.toIso8601String());
    }
    await setSetting(flag, 'done');
  }

  static const _programActivationVersion = 'ppl6v2';

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

  /// Live version of [templateExerciseRows] — drives the template editor.
  Stream<List<(TemplateExerciseRow, ExerciseRow)>> watchTemplateExerciseRows(
    String templateId,
  ) {
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

    return query.watch().map(
      (rows) => rows
          .map(
            (r) => (r.readTable(templateExercises), r.readTable(exercises)),
          )
          .toList(),
    );
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
