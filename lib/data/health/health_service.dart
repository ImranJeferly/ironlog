import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:health/health.dart';

import '../../core/utils/date_x.dart';
import '../repositories/metrics_repository.dart';

class HealthDaySample {
  const HealthDaySample({
    required this.date,
    this.steps,
    this.sleepHours,
    this.weightKg,
  });

  final DateTime date;
  final int? steps;
  final double? sleepHours;
  final double? weightKg;

  bool get isEmpty => steps == null && sleepHours == null && weightKg == null;
}

/// Wraps Apple Health / Health Connect. Every call is guarded: the app has to
/// stay fully usable when the platform has no health store at all (desktop,
/// tests, permission denied).
class HealthService {
  HealthService(this._metrics);

  final MetricsRepository _metrics;
  final Health _health = Health();

  bool _configured = false;

  static const _types = <HealthDataType>[
    HealthDataType.STEPS,
    HealthDataType.WEIGHT,
    HealthDataType.SLEEP_ASLEEP,
  ];

  bool get isSupported {
    if (kIsWeb) return false;
    try {
      return Platform.isIOS || Platform.isAndroid;
    } on Object {
      return false;
    }
  }

  /// Human name of the platform health store. On Android this is Health
  /// Connect, which is where Samsung Health (and Google Fit, Fitbit, …)
  /// write their steps/sleep/weight — so reading here pulls Samsung Health data.
  static String get providerName {
    if (kIsWeb) return 'Health';
    try {
      if (Platform.isIOS) return 'Apple Health';
      if (Platform.isAndroid) return 'Health Connect';
    } on Object {
      // Fall through to the generic label.
    }
    return 'Health';
  }

  Future<void> _ensureConfigured() async {
    if (_configured || !isSupported) return;
    await _health.configure();
    _configured = true;
  }

  Future<bool> requestPermissions() async {
    if (!isSupported) return false;
    try {
      await _ensureConfigured();
      return await _health.requestAuthorization(
        _types,
        permissions: _types.map((_) => HealthDataAccess.READ).toList(),
      );
    } on Object catch (e) {
      debugPrint('IronLog: health authorization failed ($e)');
      return false;
    }
  }

  Future<bool> hasPermissions() async {
    if (!isSupported) return false;
    try {
      await _ensureConfigured();
      return await _health.hasPermissions(_types) ?? false;
    } on Object catch (e) {
      debugPrint('IronLog: health permission check failed ($e)');
      return false;
    }
  }

  /// Reads one day. Returns an empty sample rather than throwing when Health is
  /// unavailable.
  Future<HealthDaySample> readDay(DateTime date) async {
    final day = date.dayStart;
    if (!isSupported) return HealthDaySample(date: day);

    try {
      await _ensureConfigured();
      final start = day;
      final end = day.dayEnd;

      // Manual entries included — Samsung Health/Fit imports sometimes land
      // as "manual" in Health Connect and would otherwise read as 0 here.
      final steps = await _health.getTotalStepsInInterval(
        start,
        end,
        includeManualEntry: true,
      );

      final points = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WEIGHT, HealthDataType.SLEEP_ASLEEP],
        startTime: start,
        endTime: end,
      );

      double? weight;
      var sleepMinutes = 0.0;
      for (final point in points) {
        switch (point.type) {
          case HealthDataType.WEIGHT:
            final value = point.value;
            if (value is NumericHealthValue) {
              weight = value.numericValue.toDouble();
            }
          case HealthDataType.SLEEP_ASLEEP:
            // Durations are more reliable across platforms than the raw value.
            sleepMinutes +=
                point.dateTo.difference(point.dateFrom).inMinutes.toDouble();
          default:
            break;
        }
      }

      return HealthDaySample(
        date: day,
        steps: steps,
        sleepHours: sleepMinutes > 0 ? sleepMinutes / 60.0 : null,
        weightKg: weight,
      );
    } on Object catch (e) {
      debugPrint('IronLog: health read failed ($e)');
      return HealthDaySample(date: day);
    }
  }

  /// Pulls today's numbers into the local DB without overwriting manual entries.
  Future<bool> syncToday() => syncRecent(days: 1);

  /// Pulls the last [days] days (today included), so days the app wasn't
  /// opened still get their steps filled in instead of staying blank forever.
  Future<bool> syncRecent({int days = 7}) async {
    if (!isSupported) return false;
    final today = DateTime.now().dayStart;
    var any = false;
    for (var i = days - 1; i >= 0; i--) {
      final sample = await readDay(today.subtract(Duration(days: i)));
      if (sample.isEmpty) continue;
      await _metrics.mergeFromHealth(
        sample.date,
        steps: sample.steps,
        sleepHours: sample.sleepHours,
        weightKg: sample.weightKg,
      );
      any = true;
    }
    return any;
  }

  /// First-run backfill of weight and step history.
  Future<int> importHistory({int days = 180}) async {
    if (!isSupported) return 0;
    var imported = 0;
    final today = DateTime.now().dayStart;

    try {
      await _ensureConfigured();

      // Weight comes as discrete readings — one query for the whole window is
      // far cheaper than 180 day-queries.
      final weightPoints = await _health.getHealthDataFromTypes(
        types: const [HealthDataType.WEIGHT],
        startTime: today.subtract(Duration(days: days)),
        endTime: DateTime.now(),
      );
      final weightByDay = <DateTime, double>{};
      for (final point in weightPoints) {
        final value = point.value;
        if (value is NumericHealthValue) {
          weightByDay[point.dateFrom.dayStart] = value.numericValue.toDouble();
        }
      }

      for (var i = days; i >= 0; i--) {
        final day = today.subtract(Duration(days: i));
        final steps = await _health.getTotalStepsInInterval(
          day,
          day.dayEnd,
          includeManualEntry: true,
        );
        final weight = weightByDay[day];
        if (steps == null && weight == null) continue;
        await _metrics.mergeFromHealth(day, steps: steps, weightKg: weight);
        imported++;
      }
    } on Object catch (e) {
      debugPrint('IronLog: health history import failed ($e)');
    }
    return imported;
  }
}
