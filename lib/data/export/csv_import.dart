import 'dart:io';

import 'package:drift/drift.dart';

import '../../core/utils/date_x.dart';
import '../db/database.dart';

/// What a restore did, so the UI can say something honest afterwards.
class ImportReport {
  const ImportReport({
    this.metrics = 0,
    this.sessions = 0,
    this.sets = 0,
    this.skipped = 0,
    this.errors = const [],
  });

  final int metrics;
  final int sessions;
  final int sets;

  /// Rows that referenced something missing, or didn't parse.
  final int skipped;
  final List<String> errors;

  bool get isEmpty => metrics == 0 && sessions == 0 && sets == 0;

  String get summary {
    if (isEmpty) {
      return errors.isEmpty
          ? 'Nothing to import — no rows matched.'
          : errors.first;
    }
    final parts = <String>[
      if (sessions > 0) '$sessions session${sessions == 1 ? '' : 's'}',
      if (sets > 0) '$sets set${sets == 1 ? '' : 's'}',
      if (metrics > 0) '$metrics day${metrics == 1 ? '' : 's'} of metrics',
    ];
    final tail = skipped > 0 ? ' · $skipped row(s) skipped' : '';
    return 'Imported ${parts.join(', ')}$tail.';
  }
}

/// Reads back the files [CsvExporter] writes.
///
/// The export is the backup format, so import has to accept exactly what it
/// produces — no more. Rows are matched on the ids the export carries, and
/// anything already present wins: a restore fills gaps, it never overwrites
/// what's on the phone. That makes running it twice harmless.
class CsvImporter {
  CsvImporter(this._db);

  final AppDatabase _db;

  /// Splits one CSV line, honouring the doubled-quote escaping the exporter
  /// uses. Hand-rolled because the file format is ours and tiny.
  static List<String> parseLine(String line) {
    final out = <String>[];
    final buf = StringBuffer();
    var inQuotes = false;
    for (var i = 0; i < line.length; i++) {
      final c = line[i];
      if (inQuotes) {
        if (c == '"') {
          if (i + 1 < line.length && line[i + 1] == '"') {
            buf.write('"');
            i++;
          } else {
            inQuotes = false;
          }
        } else {
          buf.write(c);
        }
      } else if (c == '"') {
        inQuotes = true;
      } else if (c == ',') {
        out.add(buf.toString());
        buf.clear();
      } else {
        buf.write(c);
      }
    }
    out.add(buf.toString());
    return out;
  }

  /// Header → index, so column order changes between versions don't matter.
  static Map<String, int> _header(String line) {
    final cells = parseLine(line);
    return {
      for (var i = 0; i < cells.length; i++) cells[i].trim().toLowerCase(): i,
    };
  }

  static String? _cell(List<String> row, Map<String, int> header, String key) {
    final i = header[key];
    if (i == null || i >= row.length) return null;
    final v = row[i].trim();
    return v.isEmpty ? null : v;
  }

  static double? _double(List<String> r, Map<String, int> h, String k) =>
      double.tryParse(_cell(r, h, k) ?? '');

  static int? _int(List<String> r, Map<String, int> h, String k) =>
      int.tryParse(_cell(r, h, k) ?? '');

  static bool _bool(List<String> r, Map<String, int> h, String k) =>
      (_cell(r, h, k) ?? '').toLowerCase() == 'true';

  static DateTime? _date(List<String> r, Map<String, int> h, String k) {
    final raw = _cell(r, h, k);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  /// Restores a `ironlog_metrics_*.csv`. Days already in the database are
  /// left alone.
  Future<ImportReport> importMetrics(File file) async {
    final lines = await _readLines(file);
    if (lines.length < 2) {
      return const ImportReport(errors: ['That file has no rows.']);
    }
    final header = _header(lines.first);
    if (!header.containsKey('date')) {
      return const ImportReport(
        errors: ['That doesn\'t look like an IronLog metrics export.'],
      );
    }

    var imported = 0;
    var skipped = 0;
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final row = parseLine(line);
      final date = _date(row, header, 'date');
      if (date == null) {
        skipped++;
        continue;
      }
      final day = date.dayStart;
      if (await _db.metricForDate(day) != null) {
        skipped++;
        continue;
      }
      await _db
          .into(_db.dailyMetrics)
          .insert(
            DailyMetricsCompanion(
              date: Value(day),
              weightKg: Value(_double(row, header, 'weight_kg')),
              steps: Value(_int(row, header, 'steps')),
              waterMl: Value(_int(row, header, 'water_ml') ?? 0),
              kcal: Value(_int(row, header, 'kcal')),
              proteinG: Value(_int(row, header, 'protein_g')),
              sleepHours: Value(_double(row, header, 'sleep_hours')),
              chestCm: Value(_double(row, header, 'chest_cm')),
              waistCm: Value(_double(row, header, 'waist_cm')),
              hipsCm: Value(_double(row, header, 'hips_cm')),
              armCm: Value(_double(row, header, 'arm_cm')),
              thighCm: Value(_double(row, header, 'thigh_cm')),
              neckCm: Value(_double(row, header, 'neck_cm')),
              weightFromHealth: Value(_bool(row, header, 'weight_from_health')),
              stepsFromHealth: Value(_bool(row, header, 'steps_from_health')),
              sleepFromHealth: Value(_bool(row, header, 'sleep_from_health')),
              updatedAt: Value(DateTime.now()),
              synced: const Value(false),
            ),
          );
      imported++;
    }
    return ImportReport(metrics: imported, skipped: skipped);
  }

  /// Restores a `ironlog_sessions_*.csv` — one row per logged set, so
  /// sessions are rebuilt from the set rows that reference them.
  ///
  /// Exercises are matched by **name** against what's already in the library;
  /// a set naming an exercise this install doesn't have is skipped rather
  /// than inventing one, because a made-up exercise would poison progression.
  Future<ImportReport> importSessions(File file) async {
    final lines = await _readLines(file);
    if (lines.length < 2) {
      return const ImportReport(errors: ['That file has no rows.']);
    }
    final header = _header(lines.first);
    if (!header.containsKey('session_id') || !header.containsKey('exercise')) {
      return const ImportReport(
        errors: ['That doesn\'t look like an IronLog sessions export.'],
      );
    }

    final exercises = await _db.allExercises();
    final byName = {
      for (final e in exercises) e.name.toLowerCase().trim(): e,
    };
    final existingSessions = {
      for (final s in await _db.watchSessions().first) s.id,
    };

    // Group the flat set rows back into sessions.
    final grouped = <String, List<List<String>>>{};
    var skipped = 0;
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final row = parseLine(line);
      final id = _cell(row, header, 'session_id');
      if (id == null) {
        skipped++;
        continue;
      }
      if (existingSessions.contains(id)) {
        skipped++;
        continue;
      }
      grouped.putIfAbsent(id, () => []).add(row);
    }

    var sessions = 0;
    var sets = 0;
    final now = DateTime.now();

    for (final entry in grouped.entries) {
      final rows = entry.value;
      final first = rows.first;
      final date = _date(first, header, 'date');
      final startedAt = _date(first, header, 'started_at');
      if (date == null || startedAt == null) {
        skipped += rows.length;
        continue;
      }

      await _db
          .into(_db.sessions)
          .insert(
            SessionsCompanion(
              id: Value(entry.key),
              date: Value(date.dayStart),
              templateName: Value(_cell(first, header, 'workout')),
              startedAt: Value(startedAt),
              endedAt: Value(_date(first, header, 'ended_at')),
              durationMin: Value(_int(first, header, 'duration_min') ?? 0),
              durationSuspect: Value(_bool(first, header, 'duration_suspect')),
              tonnageKg: Value(
                _double(first, header, 'session_tonnage_kg') ?? 0,
              ),
              cardioDone: Value(_bool(first, header, 'cardio_done')),
              saunaDone: Value(_bool(first, header, 'sauna_done')),
              notes: Value(_cell(first, header, 'session_notes')),
              isComplete: const Value(true),
              updatedAt: Value(now),
              synced: const Value(false),
            ),
          );
      sessions++;

      var order = 0;
      final seen = <String>{};
      for (final row in rows) {
        final name = _cell(row, header, 'exercise')?.toLowerCase().trim();
        final exercise = name == null ? null : byName[name];
        final weight = _double(row, header, 'weight_kg');
        final reps = _int(row, header, 'reps');
        final completedAt = _date(row, header, 'completed_at');
        if (exercise == null ||
            weight == null ||
            reps == null ||
            completedAt == null) {
          skipped++;
          continue;
        }

        if (seen.add(exercise.id)) {
          await _db
              .into(_db.sessionExercises)
              .insert(
                SessionExercisesCompanion.insert(
                  id: '${entry.key}__${exercise.id}',
                  sessionId: entry.key,
                  exerciseId: exercise.id,
                  orderIndex: order++,
                  targetSets: exercise.targetSets,
                  repRangeMin: exercise.repRangeMin,
                  repRangeMax: exercise.repRangeMax,
                  updatedAt: Value(now),
                ),
              );
        }

        final setNo = _int(row, header, 'set_no') ?? 1;
        await _db
            .into(_db.workoutSets)
            .insert(
              WorkoutSetsCompanion.insert(
                id: '${entry.key}__${exercise.id}__$setNo',
                sessionId: entry.key,
                exerciseId: exercise.id,
                setNo: setNo,
                weightKg: weight,
                reps: reps,
                rpe: Value(_int(row, header, 'rpe')),
                note: Value(_cell(row, header, 'set_note')),
                isPr: Value(_bool(row, header, 'is_pr')),
                isWarmup: Value(_bool(row, header, 'is_warmup')),
                completedAt: completedAt,
                updatedAt: Value(now),
              ),
            );
        sets++;
      }
    }

    return ImportReport(sessions: sessions, sets: sets, skipped: skipped);
  }

  Future<List<String>> _readLines(File file) async {
    final text = await file.readAsString();
    return text.split(RegExp(r'\r?\n'));
  }
}
