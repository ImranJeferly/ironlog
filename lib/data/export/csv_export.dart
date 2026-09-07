import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../../domain/exercise_x.dart';
import '../../domain/program.dart';
import '../../domain/volume.dart';
import '../db/database.dart';
import '../db/seed_data.dart';

/// CSV dump of everything — the plan's "escape hatch, it's your data".
///
/// Soft-deleted rows (tombstones waiting to sync) never make it into a file:
/// sessions, sets, exercises, PRs and daily metrics are all filtered on the
/// `deleted` flag, and a set whose session is gone is dropped with it.
class CsvExporter {
  CsvExporter(this._db, {ProgramDefinition? program})
    : _program = program ?? SeedData.program;

  final AppDatabase _db;
  final ProgramDefinition _program;

  static String _escape(Object? value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<Object?> cells) => cells.map(_escape).join(',');

  static const sessionColumns = [
    'date',
    'session_id',
    'workout',
    'program_day',
    'started_at',
    'ended_at',
    'duration_min',
    'duration_suspect',
    'session_tonnage_kg',
    'cardio_done',
    'sauna_done',
    'session_notes',
    'exercise',
    'muscle_group',
    'primary_muscle',
    'secondary_muscle',
    'is_explosive',
    'role',
    'set_no',
    'weight_kg',
    'reps',
    'volume_kg',
    'rpe',
    'is_pr',
    'is_warmup',
    'set_note',
    'completed_at',
  ];

  /// One row per logged set, joined to its session and exercise.
  Future<String> buildSessionsCsv() async {
    final sessions = await _db.watchSessions().first;
    final sets = await _db.allSets();
    final exercises = await _db.allExercises();

    final exerciseById = {for (final e in exercises) e.id: e};
    final sessionById = {
      for (final s in sessions)
        if (!s.deleted) s.id: s,
    };

    final buffer = StringBuffer()..writeln(_row(sessionColumns));

    final ordered = sets.where((s) => !s.deleted).toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    for (final set in ordered) {
      final session = sessionById[set.sessionId];
      if (session == null) continue;
      final exercise = exerciseById[set.exerciseId];

      buffer.writeln(
        _row([
          Dates.isoDay(session.date),
          session.id,
          session.templateName ?? '',
          _programDay(session),
          session.startedAt.toIso8601String(),
          session.endedAt?.toIso8601String() ?? '',
          session.durationMin,
          session.durationSuspect,
          session.tonnageKg.toStringAsFixed(1),
          session.cardioDone,
          session.saunaDone,
          session.notes ?? '',
          exercise?.name ?? set.exerciseId,
          exercise?.muscleGroup.label ?? '',
          exercise?.primary.label ?? '',
          exercise?.secondary?.label ?? '',
          exercise?.isExplosive ?? '',
          exercise?.role.label ?? '',
          set.setNo,
          set.weightKg.toStringAsFixed(2),
          set.reps,
          (set.weightKg * set.reps).toStringAsFixed(1),
          set.rpe ?? '',
          set.isPr,
          set.isWarmup,
          set.note ?? '',
          set.completedAt.toIso8601String(),
        ]),
      );
    }

    return buffer.toString();
  }

  /// "Push A", "Legs B"… when the session came from a day of the active
  /// program; blank for ad-hoc and legacy-template sessions. A deload run of
  /// a program day still reports the day (the "· Deload" suffix is stripped).
  String _programDay(SessionRow session) {
    if (!_program.contains(session.templateId)) return '';
    final name = session.templateName ?? '';
    final cut = name.indexOf(' · ');
    return cut < 0 ? name : name.substring(0, cut);
  }

  static const metricColumns = [
    'date',
    'weight_kg',
    'steps',
    'water_ml',
    'kcal',
    'protein_g',
    'sleep_hours',
    'weight_from_health',
    'steps_from_health',
    'sleep_from_health',
    'updated_at',
  ];

  /// Every column of the daily metrics table, one row per day.
  Future<String> buildMetricsCsv() async {
    final now = DateTime.now();
    final rows = await _db.metricsBetween(
      now.subtract(const Duration(days: 3650)),
      now.dayEnd,
    );

    final buffer = StringBuffer()..writeln(_row(metricColumns));

    for (final m in rows) {
      if (m.deleted) continue;
      buffer.writeln(
        _row([
          Dates.isoDay(m.date),
          m.weightKg ?? '',
          m.steps ?? '',
          m.waterMl,
          m.kcal ?? '',
          m.proteinG ?? '',
          m.sleepHours ?? '',
          m.weightFromHealth,
          m.stepsFromHealth,
          m.sleepFromHealth,
          m.updatedAt.toIso8601String(),
        ]),
      );
    }
    return buffer.toString();
  }

  static const prColumns = [
    'achieved_at',
    'exercise',
    'type',
    'value',
    'weight_kg',
    'reps',
    'previous_value',
  ];

  Future<String> buildPersonalRecordsCsv() async {
    final prs = await _db.watchPersonalRecords().first;
    final exercises = await _db.allExercises();
    final exerciseById = {for (final e in exercises) e.id: e};

    final buffer = StringBuffer()..writeln(_row(prColumns));

    for (final pr in prs) {
      if (pr.deleted) continue;
      buffer.writeln(
        _row([
          pr.achievedAt.toIso8601String(),
          exerciseById[pr.exerciseId]?.name ?? pr.exerciseId,
          pr.type.name,
          pr.value.toStringAsFixed(2),
          pr.weightKg.toStringAsFixed(2),
          pr.reps,
          pr.previousValue?.toStringAsFixed(2) ?? '',
        ]),
      );
    }
    return buffer.toString();
  }

  static const volumeColumns = ['week', 'muscle', 'hard_sets', 'tonnage_kg'];

  /// Weekly hard sets + tonnage per muscle, the same accounting as the Volume
  /// screen (primary 1, secondary 0.5, warm-ups and explosive work excluded).
  /// Covers every calendar week from the first completed session to [now];
  /// weeks with no training are skipped, muscles with zero sets inside a
  /// trained week are kept so the table is rectangular per week.
  Future<String> buildWeeklyVolumeCsv({DateTime? now}) async {
    final clock = now ?? DateTime.now();
    final sessions = await _db.watchSessions().first;
    final completed = sessions.where((s) => s.isComplete && !s.deleted);
    final dateBySession = {for (final s in completed) s.id: s.date};

    final buffer = StringBuffer()..writeln(_row(volumeColumns));
    if (dateBySession.isEmpty) return buffer.toString();

    final earliest = dateBySession.values.reduce(
      (a, b) => a.isBefore(b) ? a : b,
    );
    final span = clock.weekStart.difference(earliest.weekStart).inDays ~/ 7;
    final weeks = (span + 1).clamp(1, 520).toInt();

    final exercises = await _db.allExercises();
    final credits = {for (final e in exercises) e.id: e.volumeCredits};

    final inputs = <VolumeSetInput>[];
    for (final set in await _db.allSets()) {
      if (set.deleted) continue;
      final date = dateBySession[set.sessionId];
      if (date == null) continue;
      inputs.add(
        VolumeSetInput(
          exerciseId: set.exerciseId,
          weightKg: set.weightKg,
          reps: set.reps,
          isWarmup: set.isWarmup,
          date: date,
        ),
      );
    }

    final byWeek = VolumeCalc.weekly(
      sets: inputs,
      credits: credits,
      now: clock,
      weeks: weeks,
    );

    for (final week in byWeek) {
      if (week.totalHardSets == 0) continue;
      for (final muscle in Muscle.values) {
        buffer.writeln(
          _row([
            Dates.isoDay(week.weekStart),
            muscle.label,
            _trim(week.hardSets[muscle] ?? 0),
            (week.tonnageKg[muscle] ?? 0).toStringAsFixed(1),
          ]),
        );
      }
    }
    return buffer.toString();
  }

  /// "12" rather than "12.0", "7.5" stays "7.5".
  static String _trim(double v) =>
      v == v.roundToDouble() ? v.round().toString() : v.toStringAsFixed(1);

  /// Writes the CSVs to a temp folder and opens the share sheet.
  Future<List<File>> exportAndShare() async {
    final dir = await getTemporaryDirectory();
    final stamp = Dates.isoDay(DateTime.now());
    final files = <File>[];

    Future<void> write(String name, String contents) async {
      final file = File(p.join(dir.path, name));
      await file.writeAsString(contents);
      files.add(file);
    }

    await write('ironlog_sessions_$stamp.csv', await buildSessionsCsv());
    await write('ironlog_metrics_$stamp.csv', await buildMetricsCsv());
    await write('ironlog_prs_$stamp.csv', await buildPersonalRecordsCsv());
    await write(
      'ironlog_weekly_volume_$stamp.csv',
      await buildWeeklyVolumeCsv(),
    );

    await SharePlus.instance.share(
      ShareParams(
        files: files.map((f) => XFile(f.path)).toList(),
        subject: 'IronLog export $stamp',
        text: 'IronLog data export — $stamp',
      ),
    );

    return files;
  }
}
