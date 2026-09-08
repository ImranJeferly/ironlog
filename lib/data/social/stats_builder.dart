import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../db/database.dart';
import '../repositories/progress_repository.dart';
import 'social_models.dart';

/// Turns local training data into the numbers a profile shows to friends.
Future<ProfileStats> buildProfileStats(
  AppDatabase db,
  ProgressRepository progress,
) async {
  final consistency = await progress.consistency();
  final prs = await db.watchPersonalRecords().first;
  final exercises = await db.allExercises();
  final nameOf = {for (final e in exercises) e.id: e.name};

  // Best estimated 1RM per exercise, top six.
  final best = <String, double>{};
  for (final pr in prs) {
    if (pr.type != PrType.estimated1RM) continue;
    final name = nameOf[pr.exerciseId];
    if (name == null) continue;
    if ((best[name] ?? 0) < pr.value) best[name] = pr.value;
  }
  final ranked = best.entries.toList()
    ..sort((a, b) => b.value.compareTo(a.value));
  final bestLifts = {for (final e in ranked.take(6)) e.key: e.value};

  // Hard sets this calendar week.
  final weekStart = DateTime.now().weekStart;
  var weeklySets = 0;
  consistency.setsByDay.forEach((day, sets) {
    if (!day.isBefore(weekStart)) weeklySets += sets;
  });

  SessionRow? last;
  for (final s in await db.watchSessions(limit: 10).first) {
    if (s.isComplete) {
      last = s;
      break;
    }
  }

  return ProfileStats(
    sessions: consistency.totalSessions,
    streak: consistency.currentStreak,
    prs: prs.length,
    adherence4w: consistency.fourWeekAdherence,
    weeklySets: weeklySets,
    lastWorkoutName: last?.templateName,
    lastWorkoutAt: last?.startedAt,
    bestLifts: bestLifts,
  );
}
