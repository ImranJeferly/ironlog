import 'package:drift/drift.dart';

import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../db/database.dart';

/// Firestore collection names under `users/{uid}/`.
abstract final class SyncCollections {
  static const exercises = 'exercises';
  static const templates = 'templates';
  static const templateExercises = 'template_exercises';
  static const sessions = 'sessions';
  static const sessionExercises = 'session_exercises';
  static const sets = 'sets';
  static const personalRecords = 'personal_records';
  static const metrics = 'metrics';
  // Photos are intentionally not listed — they never sync (local-only, no
  // Firebase Storage).
}

/// Timestamps travel as UTC ISO-8601 strings. They sort lexicographically in
/// chronological order, which keeps the incremental `updatedAt >` pull query
/// working without any Firestore-specific types leaking into these mappers.
String isoUtc(DateTime dt) => dt.toUtc().toIso8601String();

DateTime? parseIso(Object? value) {
  if (value is! String || value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

double? _double(Object? v) =>
    v == null ? null : (v is num ? v.toDouble() : double.tryParse('$v'));

int? _int(Object? v) =>
    v == null ? null : (v is num ? v.toInt() : int.tryParse('$v'));

bool _bool(Object? v) => v == true || v == 'true';

T? _enumOf<T extends Enum>(List<T> values, Object? v) {
  if (v is! String) return null;
  for (final value in values) {
    if (value.name == v) return value;
  }
  return null;
}

abstract final class SyncMappers {
  // ------------------------------------------------------------- exercises

  static Map<String, dynamic> exercise(ExerciseRow r) => {
    'id': r.id,
    'name': r.name,
    'muscleGroup': r.muscleGroup.name,
    'role': r.role.name,
    'targetSets': r.targetSets,
    'repRangeMin': r.repRangeMin,
    'repRangeMax': r.repRangeMax,
    'incrementKg': r.incrementKg,
    'isUnilateral': r.isUnilateral,
    'isBodyweight': r.isBodyweight,
    'notes': r.notes,
    'isCustom': r.isCustom,
    'archived': r.archived,
    'updatedAt': isoUtc(r.updatedAt),
    'deleted': r.deleted,
  };

  static ExercisesCompanion? exerciseFrom(Map<String, dynamic> m) {
    final id = m['id'];
    final updatedAt = parseIso(m['updatedAt']);
    if (id is! String || updatedAt == null) return null;
    return ExercisesCompanion(
      id: Value(id),
      name: Value(m['name'] as String? ?? id),
      muscleGroup: Value(
        _enumOf(MuscleGroup.values, m['muscleGroup']) ?? MuscleGroup.chest,
      ),
      role: Value(
        _enumOf(ExerciseRole.values, m['role']) ?? ExerciseRole.isolation,
      ),
      targetSets: Value(_int(m['targetSets']) ?? 3),
      repRangeMin: Value(_int(m['repRangeMin']) ?? 8),
      repRangeMax: Value(_int(m['repRangeMax']) ?? 12),
      incrementKg: Value(_double(m['incrementKg']) ?? 2.5),
      isUnilateral: Value(_bool(m['isUnilateral'])),
      isBodyweight: Value(_bool(m['isBodyweight'])),
      notes: Value(m['notes'] as String?),
      isCustom: Value(_bool(m['isCustom'])),
      archived: Value(_bool(m['archived'])),
      updatedAt: Value(updatedAt),
      deleted: Value(_bool(m['deleted'])),
      synced: const Value(true),
    );
  }

  // ------------------------------------------------------------- templates

  static Map<String, dynamic> template(TemplateRow r) => {
    'id': r.id,
    'name': r.name,
    'weekday': r.weekday,
    'cardioLabel': r.cardioLabel,
    'accentHex': r.accentHex,
    'orderIndex': r.orderIndex,
    'updatedAt': isoUtc(r.updatedAt),
    'deleted': r.deleted,
  };

  static TemplatesCompanion? templateFrom(Map<String, dynamic> m) {
    final id = m['id'];
    final updatedAt = parseIso(m['updatedAt']);
    if (id is! String || updatedAt == null) return null;
    return TemplatesCompanion(
      id: Value(id),
      name: Value(m['name'] as String? ?? id),
      weekday: Value(_int(m['weekday'])),
      cardioLabel: Value(m['cardioLabel'] as String?),
      accentHex: Value(m['accentHex'] as String?),
      orderIndex: Value(_int(m['orderIndex']) ?? 0),
      updatedAt: Value(updatedAt),
      deleted: Value(_bool(m['deleted'])),
      synced: const Value(true),
    );
  }

  static Map<String, dynamic> templateExercise(TemplateExerciseRow r) => {
    'id': r.id,
    'templateId': r.templateId,
    'exerciseId': r.exerciseId,
    'orderIndex': r.orderIndex,
    'setsOverride': r.setsOverride,
    'updatedAt': isoUtc(r.updatedAt),
    'deleted': r.deleted,
  };

  static TemplateExercisesCompanion? templateExerciseFrom(
    Map<String, dynamic> m,
  ) {
    final id = m['id'];
    final templateId = m['templateId'];
    final exerciseId = m['exerciseId'];
    final updatedAt = parseIso(m['updatedAt']);
    if (id is! String ||
        templateId is! String ||
        exerciseId is! String ||
        updatedAt == null) {
      return null;
    }
    return TemplateExercisesCompanion(
      id: Value(id),
      templateId: Value(templateId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(_int(m['orderIndex']) ?? 0),
      setsOverride: Value(_int(m['setsOverride'])),
      updatedAt: Value(updatedAt),
      deleted: Value(_bool(m['deleted'])),
      synced: const Value(true),
    );
  }

  // -------------------------------------------------------------- sessions

  static Map<String, dynamic> session(SessionRow r) => {
    'id': r.id,
    'date': Dates.isoDay(r.date),
    'templateId': r.templateId,
    'templateName': r.templateName,
    'startedAt': isoUtc(r.startedAt),
    'endedAt': r.endedAt == null ? null : isoUtc(r.endedAt!),
    'durationMin': r.durationMin,
    'tonnageKg': r.tonnageKg,
    'totalSets': r.totalSets,
    'cardioDone': r.cardioDone,
    'saunaDone': r.saunaDone,
    'notes': r.notes,
    'isComplete': r.isComplete,
    'updatedAt': isoUtc(r.updatedAt),
    'deleted': r.deleted,
  };

  static SessionsCompanion? sessionFrom(Map<String, dynamic> m) {
    final id = m['id'];
    final updatedAt = parseIso(m['updatedAt']);
    final startedAt = parseIso(m['startedAt']);
    final dateRaw = m['date'];
    if (id is! String ||
        updatedAt == null ||
        startedAt == null ||
        dateRaw is! String) {
      return null;
    }
    final date = DateTime.tryParse(dateRaw);
    if (date == null) return null;

    return SessionsCompanion(
      id: Value(id),
      date: Value(date.dayStart),
      templateId: Value(m['templateId'] as String?),
      templateName: Value(m['templateName'] as String?),
      startedAt: Value(startedAt),
      endedAt: Value(parseIso(m['endedAt'])),
      durationMin: Value(_int(m['durationMin']) ?? 0),
      tonnageKg: Value(_double(m['tonnageKg']) ?? 0),
      totalSets: Value(_int(m['totalSets']) ?? 0),
      cardioDone: Value(_bool(m['cardioDone'])),
      saunaDone: Value(_bool(m['saunaDone'])),
      notes: Value(m['notes'] as String?),
      isComplete: Value(_bool(m['isComplete'])),
      updatedAt: Value(updatedAt),
      deleted: Value(_bool(m['deleted'])),
      synced: const Value(true),
    );
  }

  static Map<String, dynamic> sessionExercise(SessionExerciseRow r) => {
    'id': r.id,
    'sessionId': r.sessionId,
    'exerciseId': r.exerciseId,
    'orderIndex': r.orderIndex,
    'targetSets': r.targetSets,
    'repRangeMin': r.repRangeMin,
    'repRangeMax': r.repRangeMax,
    'suggestedWeightKg': r.suggestedWeightKg,
    'increaseFlagged': r.increaseFlagged,
    'notes': r.notes,
    'updatedAt': isoUtc(r.updatedAt),
    'deleted': r.deleted,
  };

  static SessionExercisesCompanion? sessionExerciseFrom(
    Map<String, dynamic> m,
  ) {
    final id = m['id'];
    final sessionId = m['sessionId'];
    final exerciseId = m['exerciseId'];
    final updatedAt = parseIso(m['updatedAt']);
    if (id is! String ||
        sessionId is! String ||
        exerciseId is! String ||
        updatedAt == null) {
      return null;
    }
    return SessionExercisesCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      orderIndex: Value(_int(m['orderIndex']) ?? 0),
      targetSets: Value(_int(m['targetSets']) ?? 3),
      repRangeMin: Value(_int(m['repRangeMin']) ?? 8),
      repRangeMax: Value(_int(m['repRangeMax']) ?? 12),
      suggestedWeightKg: Value(_double(m['suggestedWeightKg'])),
      increaseFlagged: Value(_bool(m['increaseFlagged'])),
      notes: Value(m['notes'] as String?),
      updatedAt: Value(updatedAt),
      deleted: Value(_bool(m['deleted'])),
      synced: const Value(true),
    );
  }

  // ------------------------------------------------------------------ sets

  static Map<String, dynamic> workoutSet(WorkoutSetRow r) => {
    'id': r.id,
    'sessionId': r.sessionId,
    'exerciseId': r.exerciseId,
    'setNo': r.setNo,
    'weightKg': r.weightKg,
    'reps': r.reps,
    'rpe': r.rpe,
    'note': r.note,
    'isPr': r.isPr,
    'isWarmup': r.isWarmup,
    'completedAt': isoUtc(r.completedAt),
    'updatedAt': isoUtc(r.updatedAt),
    'deleted': r.deleted,
  };

  static WorkoutSetsCompanion? workoutSetFrom(Map<String, dynamic> m) {
    final id = m['id'];
    final sessionId = m['sessionId'];
    final exerciseId = m['exerciseId'];
    final updatedAt = parseIso(m['updatedAt']);
    final completedAt = parseIso(m['completedAt']);
    if (id is! String ||
        sessionId is! String ||
        exerciseId is! String ||
        updatedAt == null ||
        completedAt == null) {
      return null;
    }
    return WorkoutSetsCompanion(
      id: Value(id),
      sessionId: Value(sessionId),
      exerciseId: Value(exerciseId),
      setNo: Value(_int(m['setNo']) ?? 1),
      weightKg: Value(_double(m['weightKg']) ?? 0),
      reps: Value(_int(m['reps']) ?? 0),
      rpe: Value(_int(m['rpe'])),
      note: Value(m['note'] as String?),
      isPr: Value(_bool(m['isPr'])),
      isWarmup: Value(_bool(m['isWarmup'])),
      completedAt: Value(completedAt),
      updatedAt: Value(updatedAt),
      deleted: Value(_bool(m['deleted'])),
      synced: const Value(true),
    );
  }

  // ------------------------------------------------------------------- PRs

  static Map<String, dynamic> personalRecord(PersonalRecordRow r) => {
    'id': r.id,
    'exerciseId': r.exerciseId,
    'setId': r.setId,
    'sessionId': r.sessionId,
    'type': r.type.name,
    'value': r.value,
    'weightKg': r.weightKg,
    'reps': r.reps,
    'previousValue': r.previousValue,
    'achievedAt': isoUtc(r.achievedAt),
    'updatedAt': isoUtc(r.updatedAt),
    'deleted': r.deleted,
  };

  static PersonalRecordsCompanion? personalRecordFrom(
    Map<String, dynamic> m,
  ) {
    final id = m['id'];
    final exerciseId = m['exerciseId'];
    final updatedAt = parseIso(m['updatedAt']);
    final achievedAt = parseIso(m['achievedAt']);
    if (id is! String ||
        exerciseId is! String ||
        updatedAt == null ||
        achievedAt == null) {
      return null;
    }
    return PersonalRecordsCompanion(
      id: Value(id),
      exerciseId: Value(exerciseId),
      setId: Value(m['setId'] as String?),
      sessionId: Value(m['sessionId'] as String?),
      type: Value(_enumOf(PrType.values, m['type']) ?? PrType.weight),
      value: Value(_double(m['value']) ?? 0),
      weightKg: Value(_double(m['weightKg']) ?? 0),
      reps: Value(_int(m['reps']) ?? 0),
      previousValue: Value(_double(m['previousValue'])),
      achievedAt: Value(achievedAt),
      updatedAt: Value(updatedAt),
      deleted: Value(_bool(m['deleted'])),
      synced: const Value(true),
    );
  }

  // --------------------------------------------------------------- metrics

  static Map<String, dynamic> metric(DailyMetricRow r) => {
    'id': Dates.isoDay(r.date),
    'date': Dates.isoDay(r.date),
    'weightKg': r.weightKg,
    'steps': r.steps,
    'waterMl': r.waterMl,
    'kcal': r.kcal,
    'proteinG': r.proteinG,
    'sleepHours': r.sleepHours,
    'stepsFromHealth': r.stepsFromHealth,
    'sleepFromHealth': r.sleepFromHealth,
    'weightFromHealth': r.weightFromHealth,
    'updatedAt': isoUtc(r.updatedAt),
    'deleted': r.deleted,
  };

  static DailyMetricsCompanion? metricFrom(Map<String, dynamic> m) {
    final dateRaw = m['date'];
    final updatedAt = parseIso(m['updatedAt']);
    if (dateRaw is! String || updatedAt == null) return null;
    final date = DateTime.tryParse(dateRaw);
    if (date == null) return null;

    return DailyMetricsCompanion(
      date: Value(date.dayStart),
      weightKg: Value(_double(m['weightKg'])),
      steps: Value(_int(m['steps'])),
      waterMl: Value(_int(m['waterMl']) ?? 0),
      kcal: Value(_int(m['kcal'])),
      proteinG: Value(_int(m['proteinG'])),
      sleepHours: Value(_double(m['sleepHours'])),
      stepsFromHealth: Value(_bool(m['stepsFromHealth'])),
      sleepFromHealth: Value(_bool(m['sleepFromHealth'])),
      weightFromHealth: Value(_bool(m['weightFromHealth'])),
      updatedAt: Value(updatedAt),
      deleted: Value(_bool(m['deleted'])),
      synced: const Value(true),
    );
  }

  // Photos have no mapper — they never sync. See [SyncCollections].
}
