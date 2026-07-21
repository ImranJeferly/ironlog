import 'dart:io';

import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../core/utils/date_x.dart';
import '../db/database.dart';

/// CSV dump of everything — the plan's "escape hatch, it's your data".
class CsvExporter {
  CsvExporter(this._db);

  final AppDatabase _db;

  static String _escape(Object? value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }

  static String _row(List<Object?> cells) => cells.map(_escape).join(',');

  /// One row per logged set, joined to its session and exercise.
  Future<String> buildSessionsCsv() async {
    final sessions = await _db.watchSessions().first;
    final sets = await _db.allSets();
    final exercises = await _db.allExercises();

    final exerciseById = {for (final e in exercises) e.id: e};
    final sessionById = {for (final s in sessions) s.id: s};

    final buffer = StringBuffer()
      ..writeln(
        _row([
          'date',
          'session_id',
          'workout',
          'started_at',
          'duration_min',
          'session_tonnage_kg',
          'cardio_done',
          'sauna_done',
          'session_notes',
          'exercise',
          'muscle_group',
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
        ]),
      );

    final ordered = sets.toList()
      ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

    for (final set in ordered) {
      final session = sessionById[set.sessionId];
      final exercise = exerciseById[set.exerciseId];
      if (session == null) continue;

      buffer.writeln(
        _row([
          Dates.isoDay(session.date),
          session.id,
          session.templateName ?? '',
          session.startedAt.toIso8601String(),
          session.durationMin,
          session.tonnageKg.toStringAsFixed(1),
          session.cardioDone,
          session.saunaDone,
          session.notes ?? '',
          exercise?.name ?? set.exerciseId,
          exercise?.muscleGroup.label ?? '',
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

  Future<String> buildMetricsCsv() async {
    final now = DateTime.now();
    final rows = await _db.metricsBetween(
      now.subtract(const Duration(days: 3650)),
      now.dayEnd,
    );

    final buffer = StringBuffer()
      ..writeln(
        _row([
          'date',
          'weight_kg',
          'steps',
          'water_ml',
          'kcal',
          'protein_g',
          'sleep_hours',
        ]),
      );

    for (final m in rows) {
      buffer.writeln(
        _row([
          Dates.isoDay(m.date),
          m.weightKg ?? '',
          m.steps ?? '',
          m.waterMl,
          m.kcal ?? '',
          m.proteinG ?? '',
          m.sleepHours ?? '',
        ]),
      );
    }
    return buffer.toString();
  }

  Future<String> buildPersonalRecordsCsv() async {
    final prs = await _db.watchPersonalRecords().first;
    final exercises = await _db.allExercises();
    final exerciseById = {for (final e in exercises) e.id: e};

    final buffer = StringBuffer()
      ..writeln(
        _row([
          'achieved_at',
          'exercise',
          'type',
          'value',
          'weight_kg',
          'reps',
          'previous_value',
        ]),
      );

    for (final pr in prs) {
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
