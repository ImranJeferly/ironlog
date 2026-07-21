import '../../domain/enums.dart';
import '../db/database.dart';

class AppSettings {
  const AppSettings({
    this.unit = WeightUnit.kg,
    this.restSeconds = 120,
    this.restSecondsPrimary = 180,
    this.hapticsEnabled = true,
    this.restTimerEnabled = true,
    this.syncEnabled = true,
    this.healthEnabled = true,
    this.stepGoal = 20000,
    this.firstRunComplete = false,
    this.lastSyncAt,
  });

  final WeightUnit unit;

  /// Default rest between sets, in seconds.
  final int restSeconds;

  /// Heavy primary compounds get a longer default rest.
  final int restSecondsPrimary;
  final bool hapticsEnabled;
  final bool restTimerEnabled;
  final bool syncEnabled;
  final bool healthEnabled;

  /// Daily step target the home progress ring fills toward. Changeable.
  final int stepGoal;
  final bool firstRunComplete;
  final DateTime? lastSyncAt;

  int restForRole(ExerciseRole role) => switch (role) {
    ExerciseRole.primary || ExerciseRole.explosive => restSecondsPrimary,
    _ => restSeconds,
  };

  AppSettings copyWith({
    WeightUnit? unit,
    int? restSeconds,
    int? restSecondsPrimary,
    bool? hapticsEnabled,
    bool? restTimerEnabled,
    bool? syncEnabled,
    bool? healthEnabled,
    int? stepGoal,
    bool? firstRunComplete,
    DateTime? lastSyncAt,
  }) {
    return AppSettings(
      unit: unit ?? this.unit,
      restSeconds: restSeconds ?? this.restSeconds,
      restSecondsPrimary: restSecondsPrimary ?? this.restSecondsPrimary,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      restTimerEnabled: restTimerEnabled ?? this.restTimerEnabled,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      healthEnabled: healthEnabled ?? this.healthEnabled,
      stepGoal: stepGoal ?? this.stepGoal,
      firstRunComplete: firstRunComplete ?? this.firstRunComplete,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    );
  }
}

abstract final class SettingKeys {
  static const unit = 'unit';
  static const restSeconds = 'rest_seconds';
  static const restSecondsPrimary = 'rest_seconds_primary';
  static const haptics = 'haptics_enabled';
  static const restTimer = 'rest_timer_enabled';
  static const sync = 'sync_enabled';
  static const health = 'health_enabled';
  static const stepGoal = 'step_goal';
  static const firstRun = 'first_run_complete';
  static const lastSync = 'last_sync_at';
  static const healthImported = 'health_history_imported';
}

class SettingsRepository {
  SettingsRepository(this._db);

  final AppDatabase _db;

  /// Emits the whole settings object on any change to the settings table.
  Stream<AppSettings> watch() {
    return _db.select(_db.settings).watch().map(_fromRows);
  }

  Future<AppSettings> read() async {
    final rows = await _db.select(_db.settings).get();
    return _fromRows(rows);
  }

  AppSettings _fromRows(List<SettingRow> rows) {
    final map = {for (final r in rows) r.key: r.value};
    return AppSettings(
      unit: map[SettingKeys.unit] == WeightUnit.lb.name
          ? WeightUnit.lb
          : WeightUnit.kg,
      restSeconds: int.tryParse(map[SettingKeys.restSeconds] ?? '') ?? 120,
      restSecondsPrimary:
          int.tryParse(map[SettingKeys.restSecondsPrimary] ?? '') ?? 180,
      hapticsEnabled: map[SettingKeys.haptics] != 'false',
      restTimerEnabled: map[SettingKeys.restTimer] != 'false',
      syncEnabled: map[SettingKeys.sync] != 'false',
      healthEnabled: map[SettingKeys.health] != 'false',
      stepGoal: int.tryParse(map[SettingKeys.stepGoal] ?? '') ?? 20000,
      firstRunComplete: map[SettingKeys.firstRun] == 'true',
      lastSyncAt: map[SettingKeys.lastSync] == null
          ? null
          : DateTime.tryParse(map[SettingKeys.lastSync]!),
    );
  }

  Future<void> setUnit(WeightUnit unit) =>
      _db.setSetting(SettingKeys.unit, unit.name);

  Future<void> setRestSeconds(int seconds) =>
      _db.setSetting(SettingKeys.restSeconds, '$seconds');

  Future<void> setRestSecondsPrimary(int seconds) =>
      _db.setSetting(SettingKeys.restSecondsPrimary, '$seconds');

  Future<void> setHaptics(bool on) =>
      _db.setSetting(SettingKeys.haptics, '$on');

  Future<void> setRestTimerEnabled(bool on) =>
      _db.setSetting(SettingKeys.restTimer, '$on');

  Future<void> setSyncEnabled(bool on) => _db.setSetting(SettingKeys.sync, '$on');

  Future<void> setHealthEnabled(bool on) =>
      _db.setSetting(SettingKeys.health, '$on');

  Future<void> setStepGoal(int steps) =>
      _db.setSetting(SettingKeys.stepGoal, '${steps.clamp(1000, 100000)}');

  Future<void> completeFirstRun() =>
      _db.setSetting(SettingKeys.firstRun, 'true');

  Future<void> setLastSyncAt(DateTime at) =>
      _db.setSetting(SettingKeys.lastSync, at.toIso8601String());

  Future<bool> healthHistoryImported() async =>
      (await _db.getSetting(SettingKeys.healthImported)) == 'true';

  Future<void> markHealthHistoryImported() =>
      _db.setSetting(SettingKeys.healthImported, 'true');

  /// Used by the "reset first run" debug affordance in Settings.
  Future<void> clearAll() async {
    await _db.delete(_db.settings).go();
  }
}
