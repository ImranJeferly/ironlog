import 'package:drift/drift.dart';

import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../db/database.dart';

/// Reads one measurement off a daily row. Lives here rather than on the enum
/// so `domain` keeps knowing nothing about Drift.
extension BodyMeasurementValue on BodyMeasurement {
  double? of(DailyMetricRow row) => switch (this) {
    BodyMeasurement.chest => row.chestCm,
    BodyMeasurement.waist => row.waistCm,
    BodyMeasurement.hips => row.hipsCm,
    BodyMeasurement.arm => row.armCm,
    BodyMeasurement.thigh => row.thighCm,
    BodyMeasurement.neck => row.neckCm,
  };
}

class MetricsRepository {
  MetricsRepository(this._db);

  final AppDatabase _db;

  /// One glass.
  static const glassMl = 250;

  Stream<DailyMetricRow?> watchDay(DateTime date) =>
      _db.watchMetricForDate(date.dayStart);

  Future<DailyMetricRow?> readDay(DateTime date) =>
      _db.metricForDate(date.dayStart);

  Stream<List<DailyMetricRow>> watchRange(DateTime from, DateTime to) =>
      _db.watchMetricsBetween(from.dayStart, to.dayEnd);

  /// Upserts the row for [date], touching only the fields passed in.
  Future<void> upsert(
    DateTime date, {
    Value<double?> weightKg = const Value.absent(),
    Value<int?> steps = const Value.absent(),
    Value<int> waterMl = const Value.absent(),
    Value<int?> kcal = const Value.absent(),
    Value<int?> proteinG = const Value.absent(),
    Value<double?> sleepHours = const Value.absent(),
    Value<bool> stepsFromHealth = const Value.absent(),
    Value<bool> sleepFromHealth = const Value.absent(),
    Value<bool> weightFromHealth = const Value.absent(),
    Value<double?> chestCm = const Value.absent(),
    Value<double?> waistCm = const Value.absent(),
    Value<double?> hipsCm = const Value.absent(),
    Value<double?> armCm = const Value.absent(),
    Value<double?> thighCm = const Value.absent(),
    Value<double?> neckCm = const Value.absent(),
  }) async {
    final day = date.dayStart;
    final now = DateTime.now();
    final existing = await _db.metricForDate(day);

    final companion = DailyMetricsCompanion(
      date: Value(day),
      weightKg: weightKg,
      steps: steps,
      waterMl: waterMl,
      kcal: kcal,
      proteinG: proteinG,
      sleepHours: sleepHours,
      stepsFromHealth: stepsFromHealth,
      sleepFromHealth: sleepFromHealth,
      weightFromHealth: weightFromHealth,
      chestCm: chestCm,
      waistCm: waistCm,
      hipsCm: hipsCm,
      armCm: armCm,
      thighCm: thighCm,
      neckCm: neckCm,
      updatedAt: Value(now),
      synced: const Value(false),
    );

    if (existing == null) {
      await _db.into(_db.dailyMetrics).insert(companion);
    } else {
      await (_db.update(
        _db.dailyMetrics,
      )..where((t) => t.date.equals(day))).write(companion);
    }
  }

  Future<void> addWater(DateTime date, {int ml = glassMl}) async {
    final existing = await _db.metricForDate(date.dayStart);
    final next = ((existing?.waterMl ?? 0) + ml).clamp(0, 20000);
    await upsert(date, waterMl: Value(next));
  }

  Future<void> setWater(DateTime date, int ml) =>
      upsert(date, waterMl: Value(ml.clamp(0, 20000)));

  Future<void> setWeight(DateTime date, double? kg) =>
      upsert(date, weightKg: Value(kg), weightFromHealth: const Value(false));

  Future<void> setKcal(DateTime date, int? kcal) =>
      upsert(date, kcal: Value(kcal));

  Future<void> setProtein(DateTime date, int? grams) =>
      upsert(date, proteinG: Value(grams));

  Future<void> setSleep(DateTime date, double? hours) =>
      upsert(date, sleepHours: Value(hours), sleepFromHealth: const Value(false));

  /// Writes one tape measurement. Null clears it.
  Future<void> setMeasurement(
    DateTime date,
    BodyMeasurement which,
    double? cm,
  ) {
    final v = Value(cm);
    return switch (which) {
      BodyMeasurement.chest => upsert(date, chestCm: v),
      BodyMeasurement.waist => upsert(date, waistCm: v),
      BodyMeasurement.hips => upsert(date, hipsCm: v),
      BodyMeasurement.arm => upsert(date, armCm: v),
      BodyMeasurement.thigh => upsert(date, thighCm: v),
      BodyMeasurement.neck => upsert(date, neckCm: v),
    };
  }

  /// Most recent non-null value for each measurement, with the day it was
  /// taken — what the Body tab shows when today has nothing logged.
  Future<Map<BodyMeasurement, (double, DateTime)>> latestMeasurements() async {
    final now = DateTime.now();
    final rows = await _db.metricsBetween(
      now.subtract(const Duration(days: 3650)),
      now.dayEnd,
    );
    rows.sort((a, b) => b.date.compareTo(a.date));
    final out = <BodyMeasurement, (double, DateTime)>{};
    for (final r in rows) {
      if (r.deleted) continue;
      for (final m in BodyMeasurement.values) {
        if (out.containsKey(m)) continue;
        final v = m.of(r);
        if (v != null) out[m] = (v, r.date);
      }
      if (out.length == BodyMeasurement.values.length) break;
    }
    return out;
  }

  // Steps are intentionally read-only in the UI: they are always sourced from
  // the platform health store (Health Connect / Samsung Health) via
  // [mergeFromHealth], never entered by hand.

  /// Writes Health-sourced values without clobbering anything typed in by hand.
  Future<void> mergeFromHealth(
    DateTime date, {
    int? steps,
    double? sleepHours,
    double? weightKg,
  }) async {
    final existing = await _db.metricForDate(date.dayStart);

    final canWriteSteps =
        steps != null && (existing == null || existing.stepsFromHealth || existing.steps == null);
    final canWriteSleep = sleepHours != null &&
        (existing == null || existing.sleepFromHealth || existing.sleepHours == null);
    final canWriteWeight = weightKg != null &&
        (existing == null || existing.weightFromHealth || existing.weightKg == null);

    if (!canWriteSteps && !canWriteSleep && !canWriteWeight) return;

    await upsert(
      date,
      steps: canWriteSteps ? Value(steps) : const Value.absent(),
      stepsFromHealth: canWriteSteps ? const Value(true) : const Value.absent(),
      sleepHours: canWriteSleep ? Value(sleepHours) : const Value.absent(),
      sleepFromHealth: canWriteSleep ? const Value(true) : const Value.absent(),
      weightKg: canWriteWeight ? Value(weightKg) : const Value.absent(),
      weightFromHealth:
          canWriteWeight ? const Value(true) : const Value.absent(),
    );
  }

  /// Most recent weigh-in inside the last [withinDays] days (today counts as
  /// day 1), or null — drives the "weigh in?" prompt on session start.
  Future<double?> latestWeightWithin({int withinDays = 3}) async {
    final now = DateTime.now();
    final rows = await _db.metricsBetween(
      now.dayStart.subtract(Duration(days: withinDays - 1)),
      now.dayEnd,
    );
    for (final row in rows.reversed) {
      if (row.weightKg != null) return row.weightKg;
    }
    return null;
  }

  /// Most recent logged body weight, looking back up to a year.
  Future<double?> latestWeightKg() async {
    final now = DateTime.now();
    final rows = await _db.metricsBetween(
      now.dayStart.subtract(const Duration(days: 365)),
      now.dayEnd,
    );
    for (final row in rows.reversed) {
      if (row.weightKg != null) return row.weightKg;
    }
    return null;
  }
}
