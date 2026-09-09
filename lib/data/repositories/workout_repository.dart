import 'package:drift/drift.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../../domain/pr_detector.dart';
import '../../domain/progression.dart';
import '../../domain/session_view.dart';
import '../../domain/program.dart';
import '../../domain/strength_math.dart';
import '../db/database.dart';
import '../db/seed_data.dart';

/// Thrown when a set is too empty to be real: 0 kg and at most 1 rep on an
/// exercise that isn't bodyweight. Such rows are almost always mis-taps and
/// would poison volume and PR history.
class PhantomSetException implements Exception {
  const PhantomSetException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// The result of logging a set — the UI uses this to decide whether to fire the
/// PR celebration and start the rest timer.
class LogSetResult {
  const LogSetResult({required this.setId, required this.prs});

  final String setId;
  final List<PrCandidate> prs;

  bool get isPr => prs.isNotEmpty;

  PrCandidate? get headline => prs.isEmpty ? null : prs.first;
}

class WorkoutRepository {
  WorkoutRepository(this._db);

  final AppDatabase _db;
  static const _uuid = Uuid();

  // ------------------------------------------------------------- session CRUD

  /// Creates a session from a template, freezing each exercise's prescription
  /// (the day's own sets / rep range when the program sets one) and the
  /// progression engine's suggestion at start time.
  ///
  /// If a deload is in progress (see [applyDeload]) the session is built at
  /// deload intensity — half the sets, −10 % load — and the counter ticks down.
  Future<String> startSessionFromTemplate(String templateId) async {
    final template = await _db.templateById(templateId);
    final rows = await _db.templateExerciseRows(templateId);
    final now = DateTime.now();
    final sessionId = _uuid.v4();

    final deloadLeft =
        int.tryParse(await _db.getSetting(ProgramKeys.deloadRemaining) ?? '') ??
        0;
    final deload = deloadLeft > 0;

    await _db.into(_db.sessions).insert(
      SessionsCompanion.insert(
        id: sessionId,
        date: now.dayStart,
        startedAt: now,
        templateId: Value(templateId),
        templateName: Value(
          template == null
              ? null
              : (deload ? '${template.name} · Deload' : template.name),
        ),
        updatedAt: Value(now),
      ),
    );

    for (var i = 0; i < rows.length; i++) {
      final (link, exercise) = rows[i];
      await _addExerciseToSession(
        sessionId: sessionId,
        exercise: exercise,
        orderIndex: i,
        setsOverride: link.setsOverride,
        repMinOverride: link.repMinOverride,
        repMaxOverride: link.repMaxOverride,
        supersetGroup: link.supersetGroup,
        deload: deload,
      );
    }

    if (deload) {
      await _db.setSetting(ProgramKeys.deloadRemaining, '${deloadLeft - 1}');
    }

    return sessionId;
  }

  /// Schedules the next [sessions] sessions at deload intensity.
  Future<void> applyDeload({int sessions = 6}) async {
    await _db.setSetting(ProgramKeys.deloadRemaining, '$sessions');
    await _db.setSetting(
      ProgramKeys.lastDeloadAt,
      DateTime.now().dayStart.toIso8601String(),
    );
  }

  Future<void> cancelDeload() =>
      _db.setSetting(ProgramKeys.deloadRemaining, '0');

  /// "Not now" on the deload banner — quiet for three weeks.
  Future<void> dismissDeload() => _db.setSetting(
    ProgramKeys.deloadDismissedAt,
    DateTime.now().dayStart.toIso8601String(),
  );

  /// An empty session the user fills in as they go.
  Future<String> startEmptySession({String? name}) async {
    final now = DateTime.now();
    final sessionId = _uuid.v4();
    await _db.into(_db.sessions).insert(
      SessionsCompanion.insert(
        id: sessionId,
        date: now.dayStart,
        startedAt: now,
        templateName: Value(name ?? 'Freestyle'),
        updatedAt: Value(now),
      ),
    );
    return sessionId;
  }

  Future<void> addExercise(String sessionId, String exerciseId) async {
    final exercise = await _db.exerciseById(exerciseId);
    if (exercise == null) return;
    final existing = await _db.sessionExerciseRows(sessionId);
    await _addExerciseToSession(
      sessionId: sessionId,
      exercise: exercise,
      orderIndex: existing.length,
    );
  }

  Future<void> _addExerciseToSession({
    required String sessionId,
    required ExerciseRow exercise,
    required int orderIndex,
    int? setsOverride,
    int? repMinOverride,
    int? repMaxOverride,
    int? supersetGroup,
    bool deload = false,
  }) async {
    final suggestion = await suggestionFor(
      exercise,
      excludingSessionId: sessionId,
      setsOverride: setsOverride,
      repMinOverride: repMinOverride,
      repMaxOverride: repMaxOverride,
    );
    final now = DateTime.now();

    var targetSets = setsOverride ?? exercise.targetSets;
    var suggested = suggestion.suggestedWeightKg;
    var increase = suggestion.increaseFlagged;
    if (deload) {
      // Same exercises, half the sets (rounded up), −10 % load, no jumps.
      final halved = (targetSets / 2).ceil();
      targetSets = halved < 1 ? 1 : halved;
      if (suggested != null) {
        final base = suggestion.previousWeightKg ?? suggested;
        suggested = StrengthMath.roundToIncrement(
          base * 0.9,
          exercise.incrementKg > 0 ? exercise.incrementKg : 2.5,
        );
      }
      increase = false;
    }

    await _db.into(_db.sessionExercises).insert(
      SessionExercisesCompanion.insert(
        id: _uuid.v4(),
        sessionId: sessionId,
        exerciseId: exercise.id,
        orderIndex: orderIndex,
        targetSets: targetSets,
        repRangeMin: repMinOverride ?? exercise.repRangeMin,
        repRangeMax: repMaxOverride ?? exercise.repRangeMax,
        suggestedWeightKg: Value(suggested),
        increaseFlagged: Value(increase),
        supersetGroup: Value(supersetGroup),
        updatedAt: Value(now),
      ),
    );
  }

  /// Runs the double-progression engine against the last completed session.
  Future<ProgressionSuggestion> suggestionFor(
    ExerciseRow exercise, {
    String? excludingSessionId,
    int? setsOverride,
    int? repMinOverride,
    int? repMaxOverride,
  }) async {
    final lastSets = await _db.lastCompletedSetsForExercise(
      exercise.id,
      excludingSessionId: excludingSessionId,
    );
    return ProgressionEngine.suggest(
      spec: ProgressionSpec(
        // Explosive work never auto-progresses, whichever role it was saved as.
        role: exercise.isExplosive ? ExerciseRole.explosive : exercise.role,
        targetSets: setsOverride ?? exercise.targetSets,
        repRangeMin: repMinOverride ?? exercise.repRangeMin,
        repRangeMax: repMaxOverride ?? exercise.repRangeMax,
        incrementKg: exercise.incrementKg,
      ),
      lastSets: lastSets
          .map(
            (s) => SetPerformance(
              weightKg: s.weightKg,
              reps: s.reps,
              rpe: s.rpe,
            ),
          )
          .toList(),
    );
  }

  Future<void> removeExerciseFromSession(String sessionExerciseId) async {
    final row = await (_db.select(
      _db.sessionExercises,
    )..where((t) => t.id.equals(sessionExerciseId))).getSingleOrNull();
    if (row == null) return;

    await _db.transaction(() async {
      await (_db.update(_db.workoutSets)..where(
            (t) =>
                t.sessionId.equals(row.sessionId) &
                t.exerciseId.equals(row.exerciseId),
          ))
          .write(
            WorkoutSetsCompanion(
              deleted: const Value(true),
              synced: const Value(false),
              updatedAt: Value(DateTime.now()),
            ),
          );
      await (_db.update(
        _db.sessionExercises,
      )..where((t) => t.id.equals(sessionExerciseId))).write(
        SessionExercisesCompanion(
          deleted: const Value(true),
          synced: const Value(false),
          updatedAt: Value(DateTime.now()),
        ),
      );
    });
  }

  Future<void> reorderExercises(
    String sessionId,
    List<String> orderedIds,
  ) async {
    final now = DateTime.now();
    await _db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          _db.sessionExercises,
          SessionExercisesCompanion(
            orderIndex: Value(i),
            updatedAt: Value(now),
            synced: const Value(false),
          ),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  /// Bumps the prescribed set count — used by "add a set" in the session UI.
  Future<void> setTargetSets(String sessionExerciseId, int targetSets) async {
    await (_db.update(
      _db.sessionExercises,
    )..where((t) => t.id.equals(sessionExerciseId))).write(
      SessionExercisesCompanion(
        targetSets: Value(targetSets.clamp(1, 12)),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  // ------------------------------------------------------------------ logging

  /// Logs a set, detects PRs against all prior history, and records them.
  Future<LogSetResult> logSet({
    required String sessionId,
    required String exerciseId,
    required double weightKg,
    required int reps,
    int? rpe,
    String? note,
    bool isWarmup = false,
    int? setNo,
  }) async {
    final now = DateTime.now();

    // Reject phantom sets (0 kg × ≤1 rep) unless the movement is bodyweight,
    // where an added load of 0 is a real, loggable set.
    if (weightKg <= 0 && reps <= 1) {
      final exercise = await _db.exerciseById(exerciseId);
      if (exercise == null || !exercise.isBodyweight) {
        throw const PhantomSetException(
          'That set is empty (0 kg × 1 rep) — set a weight and reps first.',
        );
      }
    }

    final existing = await (_db.select(_db.workoutSets)..where(
          (t) =>
              t.sessionId.equals(sessionId) &
              t.exerciseId.equals(exerciseId) &
              t.deleted.equals(false),
        ))
        .get();
    final nextSetNo = setNo ?? (existing.length + 1);

    // History is every prior working set of this exercise, including earlier
    // sets in this same session.
    final prs = isWarmup
        ? const <PrCandidate>[]
        : PrDetector.detect(
            weightKg: weightKg,
            reps: reps,
            history: (await _db.setsForExercise(exerciseId))
                .map((s) => SetPerformance(weightKg: s.weightKg, reps: s.reps))
                .toList(),
          );

    final setId = _uuid.v4();
    await _db.into(_db.workoutSets).insert(
      WorkoutSetsCompanion.insert(
        id: setId,
        sessionId: sessionId,
        exerciseId: exerciseId,
        setNo: nextSetNo,
        weightKg: weightKg,
        reps: reps,
        rpe: Value(rpe),
        note: Value(note),
        isPr: Value(prs.isNotEmpty),
        isWarmup: Value(isWarmup),
        completedAt: now,
        updatedAt: Value(now),
      ),
    );

    for (final pr in prs) {
      await _db.into(_db.personalRecords).insert(
        PersonalRecordsCompanion.insert(
          id: _uuid.v4(),
          exerciseId: exerciseId,
          setId: Value(setId),
          sessionId: Value(sessionId),
          type: pr.type,
          value: pr.value,
          weightKg: pr.weightKg,
          reps: pr.reps,
          previousValue: Value(pr.previousValue),
          achievedAt: now,
          updatedAt: Value(now),
        ),
      );
    }

    await _touchSession(sessionId);
    return LogSetResult(setId: setId, prs: prs);
  }

  Future<void> updateSet({
    required String setId,
    double? weightKg,
    int? reps,
    int? rpe,
    String? note,
  }) async {
    await (_db.update(_db.workoutSets)..where((t) => t.id.equals(setId))).write(
      WorkoutSetsCompanion(
        weightKg: weightKg == null ? const Value.absent() : Value(weightKg),
        reps: reps == null ? const Value.absent() : Value(reps),
        rpe: rpe == null ? const Value.absent() : Value(rpe),
        note: note == null ? const Value.absent() : Value(note),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  Future<void> deleteSet(String setId) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      final row = await (_db.select(
        _db.workoutSets,
      )..where((t) => t.id.equals(setId))).getSingleOrNull();
      if (row == null) return;

      await (_db.update(_db.workoutSets)..where((t) => t.id.equals(setId)))
          .write(
            WorkoutSetsCompanion(
              deleted: const Value(true),
              updatedAt: Value(now),
              synced: const Value(false),
            ),
          );

      // A PR attached to a deleted set is no longer real.
      await (_db.update(
        _db.personalRecords,
      )..where((t) => t.setId.equals(setId))).write(
        PersonalRecordsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );

      // Renumber what's left so set numbers stay 1..n.
      final remaining =
          await (_db.select(_db.workoutSets)
                ..where(
                  (t) =>
                      t.sessionId.equals(row.sessionId) &
                      t.exerciseId.equals(row.exerciseId) &
                      t.deleted.equals(false),
                )
                ..orderBy([(t) => OrderingTerm.asc(t.setNo)]))
              .get();
      for (var i = 0; i < remaining.length; i++) {
        if (remaining[i].setNo == i + 1) continue;
        await (_db.update(
          _db.workoutSets,
        )..where((t) => t.id.equals(remaining[i].id))).write(
          WorkoutSetsCompanion(
            setNo: Value(i + 1),
            updatedAt: Value(now),
            synced: const Value(false),
          ),
        );
      }
    });
  }

  // ---------------------------------------------------------------- lifecycle

  Future<void> setCardioDone(String sessionId, bool done) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        cardioDone: Value(done),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  Future<void> setSaunaDone(String sessionId, bool done) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        saunaDone: Value(done),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  Future<void> setSessionNotes(String sessionId, String? notes) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  Future<void> setExerciseNotes(String sessionExerciseId, String? notes) async {
    await (_db.update(
      _db.sessionExercises,
    )..where((t) => t.id.equals(sessionExerciseId))).write(
      SessionExercisesCompanion(
        notes: Value(notes),
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  /// Closes the session and denormalises duration/tonnage/set count.
  ///
  /// Refuses (returns null, leaving the session open) when there are no
  /// working sets — an empty session must be discarded, never saved.
  /// [endedAt] lets an auto-ended session close at its last real set rather
  /// than at "now". Durations over [AppDatabase.maxSessionMinutes] are capped
  /// and flagged `durationSuspect` so a forgotten open app can't inflate stats.
  Future<SessionRow?> finishSession(
    String sessionId, {
    DateTime? endedAt,
  }) async {
    final session = await _db.sessionById(sessionId);
    if (session == null) return null;

    final sets = await _db.setsForSession(sessionId);
    final working = sets.where((s) => !s.isWarmup).toList();
    if (working.isEmpty) return null;

    final now = DateTime.now();
    final end = endedAt ?? now;
    final tonnage = StrengthMath.tonnage(
      working.map((s) => SetPerformance(weightKg: s.weightKg, reps: s.reps)),
    );
    final rawMinutes = end.difference(session.startedAt).inMinutes;
    final suspect = rawMinutes > AppDatabase.maxSessionMinutes;
    final minutes = suspect
        ? AppDatabase.maxSessionMinutes
        : (rawMinutes < 0 ? 0 : rawMinutes);

    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        endedAt: Value(end),
        durationMin: Value(minutes),
        durationSuspect: Value(suspect),
        tonnageKg: Value(tonnage),
        totalSets: Value(working.length),
        isComplete: const Value(true),
        updatedAt: Value(now),
        synced: const Value(false),
      ),
    );

    await _advanceRotation(session.templateId);

    return _db.sessionById(sessionId);
  }

  /// Moves the active program's cursor past the day just completed, so the
  /// next session offered is the next one in the rotation whatever the date.
  /// Completing a day out of order re-anchors the rotation there.
  Future<void> _advanceRotation(String? templateId) async {
    if (templateId == null) return;
    final program = SeedData.program;
    if (await _db.getSetting(ProgramKeys.id) != program.id) return;
    if (!program.contains(templateId)) return;
    await _db.setSetting(
      ProgramKeys.cursor,
      '${program.cursorAfter(templateId)}',
    );
    if (await _db.getSetting(ProgramKeys.startedAt) == null) {
      await _db.setSetting(
        ProgramKeys.startedAt,
        DateTime.now().dayStart.toIso8601String(),
      );
    }
  }

  /// Throws away an abandoned session and everything attached to it. Used for
  /// "discard" — a hard delete is right here because nothing was ever synced
  /// that a tombstone would need to undo.
  Future<void> discardSession(String sessionId) async {
    await _db.transaction(() async {
      await (_db.delete(
        _db.workoutSets,
      )..where((t) => t.sessionId.equals(sessionId))).go();
      await (_db.delete(
        _db.personalRecords,
      )..where((t) => t.sessionId.equals(sessionId))).go();
      await (_db.delete(
        _db.sessionExercises,
      )..where((t) => t.sessionId.equals(sessionId))).go();
      await (_db.delete(
        _db.sessions,
      )..where((t) => t.id.equals(sessionId))).go();
    });
  }

  /// Soft-deletes a finished session so the tombstone can reach Firestore.
  Future<void> deleteSession(String sessionId) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      await (_db.update(
        _db.workoutSets,
      )..where((t) => t.sessionId.equals(sessionId))).write(
        WorkoutSetsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
      await (_db.update(
        _db.personalRecords,
      )..where((t) => t.sessionId.equals(sessionId))).write(
        PersonalRecordsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
      await (_db.update(
        _db.sessionExercises,
      )..where((t) => t.sessionId.equals(sessionId))).write(
        SessionExercisesCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
      await (_db.update(
        _db.sessions,
      )..where((t) => t.id.equals(sessionId))).write(
        SessionsCompanion(
          deleted: const Value(true),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
    });
  }

  Future<void> _touchSession(String sessionId) async {
    await (_db.update(_db.sessions)..where((t) => t.id.equals(sessionId))).write(
      SessionsCompanion(
        updatedAt: Value(DateTime.now()),
        synced: const Value(false),
      ),
    );
  }

  // ------------------------------------------------------------------- reads

  /// Assembles a full [SessionView]. Ghost sets are resolved per exercise from
  /// the previous completed session.
  Future<SessionView?> loadSessionView(String sessionId) async {
    final session = await _db.sessionById(sessionId);
    if (session == null) return null;

    final links = await _db.sessionExerciseRows(sessionId);
    final sets = await _db.setsForSession(sessionId);
    final views = <SessionExerciseView>[];

    for (final link in links) {
      final exercise = await _db.exerciseById(link.exerciseId);
      if (exercise == null) continue;
      final ghosts = await _db.lastCompletedSetsForExercise(
        link.exerciseId,
        excludingSessionId: sessionId,
      );
      final mySets =
          sets.where((s) => s.exerciseId == link.exerciseId).toList()
            ..sort((a, b) => a.setNo.compareTo(b.setNo));
      views.add(
        SessionExerciseView(
          link: link,
          exercise: exercise,
          sets: mySets,
          ghostSets: ghosts
              .map((s) => SetPerformance(weightKg: s.weightKg, reps: s.reps))
              .toList(),
        ),
      );
    }

    return SessionView(session: session, exercises: views);
  }

  /// Ghost sets for every exercise in a session, loaded once per session so the
  /// live view can rebuild on every logged set without re-querying history.
  Future<Map<String, List<SetPerformance>>> loadGhosts(String sessionId) async {
    final links = await _db.sessionExerciseRows(sessionId);
    final out = <String, List<SetPerformance>>{};
    for (final link in links) {
      final ghosts = await _db.lastCompletedSetsForExercise(
        link.exerciseId,
        excludingSessionId: sessionId,
      );
      out[link.exerciseId] = ghosts
          .map(
            (s) => SetPerformance(
              weightKg: s.weightKg,
              reps: s.reps,
              rpe: s.rpe,
            ),
          )
          .toList();
    }
    return out;
  }

  // ------------------------------------------------------------ exercise CRUD

  /// Creates a custom exercise. It lives in the library (and syncs to the
  /// account) permanently — available in every future session and template.
  ///
  /// Pass [primary] (and optionally [secondary]) for full attribution; the
  /// coarse [muscleGroup] is derived from it. Passing only [muscleGroup] is
  /// still supported and picks that group's best-guess primary.
  Future<ExerciseRow?> createExercise({
    required String name,
    required int targetSets,
    required int repRangeMin,
    required int repRangeMax,
    Muscle? primary,
    Muscle? secondary,
    MuscleGroup? muscleGroup,
    bool isBodyweight = false,
    bool isUnilateral = false,
    bool isExplosive = false,
  }) async {
    final resolvedPrimary =
        primary ?? Muscle.fromGroup(muscleGroup ?? MuscleGroup.chest);
    final group = muscleGroup ?? resolvedPrimary.group;
    final id = _uuid.v4();
    final now = DateTime.now();
    await _db.into(_db.exercises).insert(
      ExercisesCompanion.insert(
        id: id,
        name: name,
        muscleGroup: group,
        role: isExplosive ? ExerciseRole.explosive : ExerciseRole.secondary,
        targetSets: targetSets,
        repRangeMin: repRangeMin,
        repRangeMax: repRangeMax,
        incrementKg: resolvedPrimary.defaultIncrementKg,
        isBodyweight: Value(isBodyweight),
        isUnilateral: Value(isUnilateral),
        isExplosive: Value(isExplosive),
        primaryMuscle: Value(resolvedPrimary),
        secondaryMuscle: Value(
          secondary == resolvedPrimary ? null : secondary,
        ),
        isCustom: const Value(true),
        updatedAt: Value(now),
      ),
    );
    return _db.exerciseById(id);
  }

  /// Adds an exercise to a template permanently (future sessions include it).
  /// Re-adding something that was removed earlier just revives the row.
  Future<void> addExerciseToTemplate(
    String templateId,
    String exerciseId,
  ) async {
    final existing = await _db.templateExerciseRows(templateId);
    await _db.into(_db.templateExercises).insertOnConflictUpdate(
      TemplateExercisesCompanion.insert(
        id: '${templateId}__$exerciseId',
        templateId: templateId,
        exerciseId: exerciseId,
        orderIndex: existing.length,
        updatedAt: Value(DateTime.now()),
        deleted: const Value(false),
        synced: const Value(false),
      ),
    );
  }

  /// Groups (or ungroups) a template exercise with the one above it. A
  /// superset is just a shared group number on consecutive rows; passing null
  /// breaks the row out on its own again.
  Future<void> setTemplateSuperset(
    String templateExerciseId,
    int? group,
  ) async {
    await (_db.update(
      _db.templateExercises,
    )..where((t) => t.id.equals(templateExerciseId))).write(
      TemplateExercisesCompanion(
        supersetGroup: Value(group),
        synced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  /// Toggles "superset with the exercise above": the pair (or run) gets the
  /// first row's group number, creating one if it doesn't have one yet.
  Future<void> toggleSupersetWithPrevious(String templateId, int index) async {
    final rows = await _db.templateExerciseRows(templateId);
    if (index <= 0 || index >= rows.length) return;
    final (me, _) = rows[index];
    final (prev, _) = rows[index - 1];

    if (me.supersetGroup != null && me.supersetGroup == prev.supersetGroup) {
      // Already joined — break this row (and anything below it in the same
      // run) out, so ungrouping the middle doesn't silently merge the ends.
      for (var i = index; i < rows.length; i++) {
        final (row, _) = rows[i];
        if (row.supersetGroup != me.supersetGroup) break;
        await setTemplateSuperset(row.id, null);
      }
      return;
    }

    final group =
        prev.supersetGroup ??
        (rows
                .map((r) => r.$1.supersetGroup ?? 0)
                .fold(0, (a, b) => a > b ? a : b) +
            1);
    if (prev.supersetGroup == null) await setTemplateSuperset(prev.id, group);
    await setTemplateSuperset(me.id, group);
  }

  /// Persists a new exercise order for a template. [orderedIds] are the
  /// TemplateExercise row ids in their new top-to-bottom order; future sessions
  /// are built in exactly this order.
  Future<void> reorderTemplateExercises(List<String> orderedIds) async {
    final now = DateTime.now();
    await _db.batch((b) {
      for (var i = 0; i < orderedIds.length; i++) {
        b.update(
          _db.templateExercises,
          TemplateExercisesCompanion(
            orderIndex: Value(i),
            updatedAt: Value(now),
            synced: const Value(false),
          ),
          where: (t) => t.id.equals(orderedIds[i]),
        );
      }
    });
  }

  /// Takes an exercise off a template for good (tombstoned so the removal
  /// syncs). Past sessions are untouched.
  Future<void> removeExerciseFromTemplate(String templateExerciseId) async {
    await (_db.update(
      _db.templateExercises,
    )..where((t) => t.id.equals(templateExerciseId))).write(
      TemplateExercisesCompanion(
        deleted: const Value(true),
        synced: const Value(false),
        updatedAt: Value(DateTime.now()),
      ),
    );
  }

  // ---------------------------------------------------------------- templates

  /// Moves a template to a weekday (or off the schedule with null). A weekday
  /// can only host one template, so any current holder gets unscheduled.
  Future<void> setTemplateWeekday(String templateId, int? weekday) async {
    final now = DateTime.now();
    await _db.transaction(() async {
      if (weekday != null) {
        await (_db.update(_db.templates)..where(
              (t) => t.weekday.equals(weekday) & t.id.equals(templateId).not(),
            ))
            .write(
          TemplatesCompanion(
            weekday: const Value(null),
            updatedAt: Value(now),
            synced: const Value(false),
          ),
        );
      }
      await (_db.update(
        _db.templates,
      )..where((t) => t.id.equals(templateId))).write(
        TemplatesCompanion(
          weekday: Value(weekday),
          updatedAt: Value(now),
          synced: const Value(false),
        ),
      );
    });
  }

  /// Which template is scheduled for a given weekday, if any.
  Future<TemplateRow?> templateForDate(DateTime date) async {
    final all = await _db.watchTemplates().first;
    for (final t in all) {
      if (t.weekday == date.weekday) return t;
    }
    return null;
  }
}
