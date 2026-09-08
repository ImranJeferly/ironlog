import '../../domain/enums.dart';
import '../../domain/program.dart';
import '../../domain/volume.dart';
import '../db/database.dart';

class AppSettings {
  const AppSettings({
    this.unit = WeightUnit.kg,
    this.restSeconds = 120,
    this.restSecondsPrimary = 180,
    this.restSecondsExercise = 300,
    this.hapticsEnabled = true,
    this.restTimerEnabled = true,
    this.syncEnabled = true,
    this.healthEnabled = true,
    this.stepGoal = 20000,
    this.firstRunComplete = false,
    this.lastSyncAt,
    this.programId,
    this.programCursor = 0,
    this.programStartedAt,
    this.deloadRemaining = 0,
    this.nutritionReminderEnabled = true,
    this.bwTargetMinKg = 0.2,
    this.bwTargetMaxKg = 0.35,
  });

  final WeightUnit unit;

  /// Default rest between sets, in seconds.
  final int restSeconds;

  /// Heavy primary compounds get a longer default rest.
  final int restSecondsPrimary;

  /// Rest between exercises — started when an exercise's last set is logged
  /// and there is another exercise still to do. Default 5 minutes.
  final int restSecondsExercise;
  final bool hapticsEnabled;
  final bool restTimerEnabled;
  final bool syncEnabled;
  final bool healthEnabled;

  /// Daily step target the home progress ring fills toward. Changeable.
  final int stepGoal;
  final bool firstRunComplete;
  final DateTime? lastSyncAt;

  /// Active program (null = plain weekday templates) and where in its
  /// rotation the lifter is.
  final String? programId;
  final int programCursor;
  final DateTime? programStartedAt;

  /// Sessions left to run at deload intensity.
  final int deloadRemaining;

  bool get deloadActive => deloadRemaining > 0;

  /// Nightly 21:00 "log protein + kcal" nudge.
  final bool nutritionReminderEnabled;

  /// Body-weight target band, kg per week (default: lean bulk 0.2–0.35).
  final double bwTargetMinKg;
  final double bwTargetMaxKg;

  int restForRole(ExerciseRole role) => switch (role) {
    ExerciseRole.primary || ExerciseRole.explosive => restSecondsPrimary,
    _ => restSeconds,
  };

  AppSettings copyWith({
    WeightUnit? unit,
    int? restSeconds,
    int? restSecondsPrimary,
    int? restSecondsExercise,
    bool? hapticsEnabled,
    bool? restTimerEnabled,
    bool? syncEnabled,
    bool? healthEnabled,
    int? stepGoal,
    bool? firstRunComplete,
    DateTime? lastSyncAt,
    String? programId,
    int? programCursor,
    DateTime? programStartedAt,
    int? deloadRemaining,
    bool? nutritionReminderEnabled,
    double? bwTargetMinKg,
    double? bwTargetMaxKg,
  }) {
    return AppSettings(
      unit: unit ?? this.unit,
      restSeconds: restSeconds ?? this.restSeconds,
      restSecondsPrimary: restSecondsPrimary ?? this.restSecondsPrimary,
      restSecondsExercise: restSecondsExercise ?? this.restSecondsExercise,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      restTimerEnabled: restTimerEnabled ?? this.restTimerEnabled,
      syncEnabled: syncEnabled ?? this.syncEnabled,
      healthEnabled: healthEnabled ?? this.healthEnabled,
      stepGoal: stepGoal ?? this.stepGoal,
      firstRunComplete: firstRunComplete ?? this.firstRunComplete,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      programId: programId ?? this.programId,
      programCursor: programCursor ?? this.programCursor,
      programStartedAt: programStartedAt ?? this.programStartedAt,
      deloadRemaining: deloadRemaining ?? this.deloadRemaining,
      nutritionReminderEnabled:
          nutritionReminderEnabled ?? this.nutritionReminderEnabled,
      bwTargetMinKg: bwTargetMinKg ?? this.bwTargetMinKg,
      bwTargetMaxKg: bwTargetMaxKg ?? this.bwTargetMaxKg,
    );
  }
}

abstract final class SettingKeys {
  static const unit = 'unit';
  static const restSeconds = 'rest_seconds';
  static const restSecondsPrimary = 'rest_seconds_primary';
  static const restSecondsExercise = 'rest_seconds_exercise';
  static const haptics = 'haptics_enabled';
  static const restTimer = 'rest_timer_enabled';
  static const sync = 'sync_enabled';
  static const health = 'health_enabled';
  static const stepGoal = 'step_goal';
  static const firstRun = 'first_run_complete';
  static const lastSync = 'last_sync_at';
  static const healthImported = 'health_history_imported';
  static const nutritionReminder = 'nutrition_reminder_enabled';
  static const bwTargetMin = 'bw_target_min_kg_wk';
  static const bwTargetMax = 'bw_target_max_kg_wk';
  static const bodyweightPromptSkips = 'bodyweight_prompt_skips';
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
      restSecondsExercise:
          int.tryParse(map[SettingKeys.restSecondsExercise] ?? '') ?? 300,
      hapticsEnabled: map[SettingKeys.haptics] != 'false',
      restTimerEnabled: map[SettingKeys.restTimer] != 'false',
      syncEnabled: map[SettingKeys.sync] != 'false',
      healthEnabled: map[SettingKeys.health] != 'false',
      stepGoal: int.tryParse(map[SettingKeys.stepGoal] ?? '') ?? 20000,
      firstRunComplete: map[SettingKeys.firstRun] == 'true',
      lastSyncAt: map[SettingKeys.lastSync] == null
          ? null
          : DateTime.tryParse(map[SettingKeys.lastSync]!),
      programId: map[ProgramKeys.id],
      programCursor: int.tryParse(map[ProgramKeys.cursor] ?? '') ?? 0,
      programStartedAt: map[ProgramKeys.startedAt] == null
          ? null
          : DateTime.tryParse(map[ProgramKeys.startedAt]!),
      deloadRemaining:
          int.tryParse(map[ProgramKeys.deloadRemaining] ?? '') ?? 0,
      nutritionReminderEnabled: map[SettingKeys.nutritionReminder] != 'false',
      bwTargetMinKg:
          double.tryParse(map[SettingKeys.bwTargetMin] ?? '') ?? 0.2,
      bwTargetMaxKg:
          double.tryParse(map[SettingKeys.bwTargetMax] ?? '') ?? 0.35,
    );
  }

  Future<void> setNutritionReminder(bool on) =>
      _db.setSetting(SettingKeys.nutritionReminder, '$on');

  Future<void> setBwTargetMin(double kgPerWeek) => _db.setSetting(
    SettingKeys.bwTargetMin,
    (kgPerWeek.clamp(-1.0, 1.5)).toStringAsFixed(2),
  );

  Future<void> setBwTargetMax(double kgPerWeek) => _db.setSetting(
    SettingKeys.bwTargetMax,
    (kgPerWeek.clamp(-1.0, 1.5)).toStringAsFixed(2),
  );

  // ------------------------------------------------------- volume targets

  static String _volumeKey(Muscle m) => 'vol_target_${m.key}';

  /// Weekly hard-set bands per muscle: user overrides on top of the spec
  /// defaults.
  Future<Map<Muscle, VolumeTarget>> volumeTargets() async {
    final out = Map<Muscle, VolumeTarget>.of(VolumeCalc.defaultTargets);
    for (final m in Muscle.values) {
      final raw = await _db.getSetting(_volumeKey(m));
      if (raw == null) continue;
      final parts = raw.split('-');
      if (parts.length != 2) continue;
      final lo = int.tryParse(parts[0]);
      final hi = int.tryParse(parts[1]);
      if (lo == null || hi == null || lo < 0 || hi < lo) continue;
      out[m] = VolumeTarget(lo, hi);
    }
    return out;
  }

  Future<void> setVolumeTarget(Muscle m, int min, int max) =>
      _db.setSetting(_volumeKey(m), '$min-$max');

  /// How often the pre-session weigh-in was skipped — kept so it's visible,
  /// not to nag.
  Future<int> bodyweightPromptSkips() async =>
      int.tryParse(await _db.getSetting(SettingKeys.bodyweightPromptSkips) ?? '') ??
      0;

  Future<void> countBodyweightPromptSkip() async => _db.setSetting(
    SettingKeys.bodyweightPromptSkips,
    '${await bodyweightPromptSkips() + 1}',
  );

  Future<void> setUnit(WeightUnit unit) =>
      _db.setSetting(SettingKeys.unit, unit.name);

  Future<void> setRestSeconds(int seconds) =>
      _db.setSetting(SettingKeys.restSeconds, '$seconds');

  Future<void> setRestSecondsPrimary(int seconds) =>
      _db.setSetting(SettingKeys.restSecondsPrimary, '$seconds');

  Future<void> setRestSecondsExercise(int seconds) =>
      _db.setSetting(SettingKeys.restSecondsExercise, '$seconds');

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
