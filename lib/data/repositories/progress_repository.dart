import 'dart:math' as math;

import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../../domain/strength_math.dart';
import '../db/database.dart';
import '../db/seed_data.dart';

/// One session's worth of work on a single exercise.
class ExercisePoint {
  const ExercisePoint({
    required this.date,
    required this.topWeightKg,
    required this.topReps,
    required this.best1RM,
    required this.volumeKg,
    required this.sets,
  });

  final DateTime date;
  final double topWeightKg;
  final int topReps;
  final double best1RM;
  final double volumeKg;
  final int sets;
}

class ExerciseProgress {
  const ExerciseProgress({
    required this.exercise,
    required this.points,
    required this.records,
  });

  final ExerciseRow exercise;
  final List<ExercisePoint> points;
  final List<PersonalRecordRow> records;

  bool get isEmpty => points.isEmpty;

  double get bestWeightKg =>
      points.fold(0.0, (b, p) => math.max(b, p.topWeightKg));

  double get best1RM => points.fold(0.0, (b, p) => math.max(b, p.best1RM));

  double get totalVolumeKg => points.fold(0.0, (b, p) => b + p.volumeKg);

  int get totalSets => points.fold(0, (b, p) => b + p.sets);

  /// Change in estimated 1RM between the first and last logged session.
  double get e1rmDelta =>
      points.length < 2 ? 0 : points.last.best1RM - points.first.best1RM;
}

class WeeklyMuscleVolume {
  const WeeklyMuscleVolume({
    required this.weekStart,
    required this.setsByGroup,
    required this.tonnageByGroup,
  });

  final DateTime weekStart;
  final Map<MuscleGroup, int> setsByGroup;
  final Map<MuscleGroup, double> tonnageByGroup;

  int get totalSets => setsByGroup.values.fold(0, (a, b) => a + b);
}

class MuscleGroupSummary {
  const MuscleGroupSummary({
    required this.weeks,
    required this.setsLast4Weeks,
    required this.tonnageLast4Weeks,
    required this.leastTrained,
  });

  final List<WeeklyMuscleVolume> weeks;
  final Map<MuscleGroup, int> setsLast4Weeks;
  final Map<MuscleGroup, double> tonnageLast4Weeks;

  /// The group with the fewest working sets over the window — the plan's
  /// "least trained" flag.
  final MuscleGroup? leastTrained;

  int get totalSets => setsLast4Weeks.values.fold(0, (a, b) => a + b);
}

class ConsistencyStats {
  const ConsistencyStats({
    required this.currentStreak,
    required this.longestStreak,
    required this.weeklyAdherence,
    required this.sessionsThisWeek,
    required this.setsByDay,
    required this.totalSessions,
    required this.scheduledPerWeek,
  });

  /// Consecutive scheduled gym days hit without a miss.
  final int currentStreak;
  final int longestStreak;

  /// 0–1 against the scheduled gym days per week.
  final double weeklyAdherence;
  final int sessionsThisWeek;

  /// Working sets per day — drives the heatmap intensity.
  final Map<DateTime, int> setsByDay;
  final int totalSessions;

  /// How many gym days the current template schedule has per week.
  final int scheduledPerWeek;
}

class BodyWeightSeries {
  const BodyWeightSeries({
    required this.dates,
    required this.weightsKg,
    required this.movingAverageKg,
  });

  final List<DateTime> dates;
  final List<double> weightsKg;
  final List<double> movingAverageKg;

  bool get isEmpty => dates.isEmpty;

  double? get latestKg => weightsKg.isEmpty ? null : weightsKg.last;

  double? get latestAverageKg =>
      movingAverageKg.isEmpty ? null : movingAverageKg.last;

  /// Change over the window, measured on the smoothed line so day-to-day water
  /// swings don't dominate.
  double get deltaKg => movingAverageKg.length < 2
      ? 0
      : movingAverageKg.last - movingAverageKg.first;
}

class ProgressRepository {
  ProgressRepository(this._db);

  final AppDatabase _db;

  /// Per-session series for one exercise: top set, e1RM and volume over time.
  Future<ExerciseProgress> exerciseProgress(String exerciseId) async {
    final exercise = await _db.exerciseById(exerciseId);
    if (exercise == null) {
      throw StateError('Unknown exercise $exerciseId');
    }

    final sets = await _db.setsForExercise(exerciseId);
    final sessions = await _db.watchSessions().first;
    final sessionById = {for (final s in sessions) s.id: s};

    final grouped = <String, List<WorkoutSetRow>>{};
    for (final s in sets) {
      final session = sessionById[s.sessionId];
      if (session == null || !session.isComplete) continue;
      grouped.putIfAbsent(s.sessionId, () => []).add(s);
    }

    final points = <ExercisePoint>[];
    for (final entry in grouped.entries) {
      final session = sessionById[entry.key]!;
      final perf = entry.value
          .map((s) => SetPerformance(weightKg: s.weightKg, reps: s.reps))
          .toList();
      final top = StrengthMath.topSet(perf);
      points.add(
        ExercisePoint(
          date: session.date,
          topWeightKg: top?.weightKg ?? 0,
          topReps: top?.reps ?? 0,
          best1RM: StrengthMath.best1RM(perf),
          volumeKg: StrengthMath.tonnage(perf),
          sets: perf.length,
        ),
      );
    }
    points.sort((a, b) => a.date.compareTo(b.date));

    return ExerciseProgress(
      exercise: exercise,
      points: points,
      records: await _db.personalRecordsForExercise(exerciseId),
    );
  }

  /// Weekly sets and tonnage per muscle group over the last [weeks] weeks.
  Future<MuscleGroupSummary> muscleGroupSummary({int weeks = 8}) async {
    final now = DateTime.now();
    final from = now.weekStart.subtract(Duration(days: 7 * (weeks - 1)));

    final sessions = await _db.sessionsBetween(from, now.dayEnd);
    final completed = sessions.where((s) => s.isComplete).toList();
    final sessionById = {for (final s in completed) s.id: s};

    final allSets = await _db.allSets();
    final exercises = await _db.allExercises();
    final groupByExercise = {for (final e in exercises) e.id: e.muscleGroup};

    final buckets = <DateTime, WeeklyMuscleVolume>{};
    for (var i = 0; i < weeks; i++) {
      final ws = from.add(Duration(days: 7 * i));
      buckets[ws] = WeeklyMuscleVolume(
        weekStart: ws,
        setsByGroup: {for (final g in MuscleGroup.values) g: 0},
        tonnageByGroup: {for (final g in MuscleGroup.values) g: 0.0},
      );
    }

    final fourWeeksAgo = now.dayStart.subtract(const Duration(days: 28));
    final setsLast4 = {for (final g in MuscleGroup.values) g: 0};
    final tonnageLast4 = {for (final g in MuscleGroup.values) g: 0.0};

    for (final set in allSets) {
      if (set.isWarmup) continue;
      final session = sessionById[set.sessionId];
      if (session == null) continue;
      final group = groupByExercise[set.exerciseId];
      if (group == null) continue;

      final ws = session.date.weekStart;
      final bucket = buckets[ws];
      if (bucket != null) {
        bucket.setsByGroup[group] = (bucket.setsByGroup[group] ?? 0) + 1;
        bucket.tonnageByGroup[group] =
            (bucket.tonnageByGroup[group] ?? 0) + set.weightKg * set.reps;
      }

      if (!session.date.isBefore(fourWeeksAgo)) {
        setsLast4[group] = (setsLast4[group] ?? 0) + 1;
        tonnageLast4[group] = (tonnageLast4[group] ?? 0) + set.weightKg * set.reps;
      }
    }

    MuscleGroup? least;
    var leastCount = 1 << 30;
    for (final g in MuscleGroup.values) {
      final c = setsLast4[g] ?? 0;
      if (c < leastCount) {
        leastCount = c;
        least = g;
      }
    }

    final ordered = buckets.values.toList()
      ..sort((a, b) => a.weekStart.compareTo(b.weekStart));

    return MuscleGroupSummary(
      weeks: ordered,
      setsLast4Weeks: setsLast4,
      tonnageLast4Weeks: tonnageLast4,
      // Only meaningful once there's something to compare.
      leastTrained: setsLast4.values.any((v) => v > 0) ? least : null,
    );
  }

  /// Streak, adherence and the heatmap grid.
  Future<ConsistencyStats> consistency({int days = 365}) async {
    final now = DateTime.now();
    final from = now.dayStart.subtract(Duration(days: days));
    final sessions = await _db.sessionsBetween(from, now.dayEnd);
    final completed = sessions.where((s) => s.isComplete).toList();

    // Gym days come from the live template schedule (Push/Pull/Legs/Arms —
    // 4 of 7 by default), not a hardcoded list, so editing a training day in
    // Settings immediately changes what adherence is measured against.
    var scheduled = await _db.scheduledWeekdays();
    if (scheduled.isEmpty) scheduled = SeedData.scheduledWeekdays.toSet();

    final setsByDay = <DateTime, int>{};
    for (final s in completed) {
      setsByDay[s.date] = (setsByDay[s.date] ?? 0) + s.totalSets;
    }
    // A session with zero recorded sets should still light up the heatmap.
    for (final s in completed) {
      setsByDay.putIfAbsent(s.date, () => 0);
      if (setsByDay[s.date] == 0) setsByDay[s.date] = 1;
    }

    final doneDays = completed.map((s) => s.date).toSet();

    final currentStreak = _currentStreak(doneDays, now, scheduled);
    final longestStreak = _longestStreak(doneDays, from, now, scheduled);

    final weekStart = now.weekStart;
    final sessionsThisWeek = completed
        .where((s) => !s.date.isBefore(weekStart))
        .map((s) => s.date)
        .toSet()
        .length;

    return ConsistencyStats(
      currentStreak: currentStreak,
      longestStreak: longestStreak,
      weeklyAdherence:
          (sessionsThisWeek / scheduled.length).clamp(0.0, 1.0),
      sessionsThisWeek: sessionsThisWeek,
      setsByDay: setsByDay,
      totalSessions: completed.length,
      scheduledPerWeek: scheduled.length,
    );
  }

  /// Walks scheduled gym days backwards, counting until one was missed. Today
  /// is skipped rather than counted as a miss — the day isn't over yet.
  int _currentStreak(Set<DateTime> doneDays, DateTime now, Set<int> scheduled) {
    var streak = 0;
    var cursor = now.dayStart;

    if (scheduled.contains(cursor.weekday)) {
      if (doneDays.contains(cursor)) {
        streak++;
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }

    // Look back at most two years of scheduled days.
    for (var i = 0; i < 730; i++) {
      if (scheduled.contains(cursor.weekday)) {
        if (doneDays.contains(cursor)) {
          streak++;
        } else {
          break;
        }
      }
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  int _longestStreak(
    Set<DateTime> doneDays,
    DateTime from,
    DateTime to,
    Set<int> scheduled,
  ) {
    var best = 0;
    var run = 0;
    for (final day in Dates.range(from, to)) {
      if (!scheduled.contains(day.weekday)) continue;
      if (day.isAfter(DateTime.now().dayStart)) break;
      if (doneDays.contains(day)) {
        run++;
        best = math.max(best, run);
      } else if (!day.isSameDay(DateTime.now())) {
        run = 0;
      }
    }
    return best;
  }

  /// Logged body weight with a trailing 7-day moving average.
  Future<BodyWeightSeries> bodyWeight({int days = 180}) async {
    final now = DateTime.now();
    final from = now.dayStart.subtract(Duration(days: days));
    final metrics = await _db.metricsBetween(from, now.dayEnd);

    final dates = <DateTime>[];
    final weights = <double>[];
    for (final m in metrics) {
      final w = m.weightKg;
      if (w == null) continue;
      dates.add(m.date);
      weights.add(w);
    }

    return BodyWeightSeries(
      dates: dates,
      weightsKg: weights,
      movingAverageKg: StrengthMath.movingAverage(weights, 7),
    );
  }

  /// Every exercise that has at least one logged set, most recently trained
  /// first — the Exercises tab list.
  Future<List<(ExerciseRow, DateTime?, int)>> exerciseIndex() async {
    final exercises = await _db.allExercises();
    final sets = await _db.allSets();

    final lastByExercise = <String, DateTime>{};
    final countByExercise = <String, int>{};
    for (final s in sets) {
      if (s.isWarmup) continue;
      countByExercise[s.exerciseId] = (countByExercise[s.exerciseId] ?? 0) + 1;
      final prev = lastByExercise[s.exerciseId];
      if (prev == null || s.completedAt.isAfter(prev)) {
        lastByExercise[s.exerciseId] = s.completedAt;
      }
    }

    final rows = exercises
        .where((e) => !e.archived)
        .map((e) => (e, lastByExercise[e.id], countByExercise[e.id] ?? 0))
        .toList();

    rows.sort((a, b) {
      final da = a.$2;
      final db = b.$2;
      if (da == null && db == null) return a.$1.name.compareTo(b.$1.name);
      if (da == null) return 1;
      if (db == null) return -1;
      return db.compareTo(da);
    });
    return rows;
  }
}
