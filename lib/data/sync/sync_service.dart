import 'package:drift/drift.dart';
import 'package:flutter/foundation.dart';

import '../../core/utils/date_x.dart';
import '../../domain/enums.dart';
import '../db/database.dart';
import '../repositories/settings_repository.dart';
import 'firebase_bootstrap.dart';
import 'remote_store.dart';
import 'sync_mappers.dart';

class SyncStatus {
  const SyncStatus({
    this.state = SyncState.idle,
    this.lastSyncAt,
    this.message,
    this.pending = 0,
    this.pushed = 0,
    this.pulled = 0,
  });

  final SyncState state;
  final DateTime? lastSyncAt;
  final String? message;
  final int pending;
  final int pushed;
  final int pulled;

  SyncStatus copyWith({
    SyncState? state,
    DateTime? lastSyncAt,
    String? message,
    int? pending,
    int? pushed,
    int? pulled,
  }) => SyncStatus(
    state: state ?? this.state,
    lastSyncAt: lastSyncAt ?? this.lastSyncAt,
    message: message ?? this.message,
    pending: pending ?? this.pending,
    pushed: pushed ?? this.pushed,
    pulled: pulled ?? this.pulled,
  );

  String get label => switch (state) {
    SyncState.idle => pending > 0 ? '$pending change(s) pending' : 'Up to date',
    SyncState.syncing => 'Syncing…',
    SyncState.success => 'Synced',
    SyncState.failed => message ?? 'Sync failed',
    SyncState.disabled => message ?? 'Sync off',
  };
}

/// Background push/pull against Firestore.
///
/// Single user, so the conflict rule is simply last-write-wins on `updatedAt`.
/// Nothing here ever blocks the UI: the local database is the source of truth
/// and a failed sync just leaves rows flagged unsynced for the next attempt.
class SyncService {
  SyncService({
    required AppDatabase db,
    required SettingsRepository settings,
    RemoteStore? store,
  }) : _db = db,
       _settings = settings,
       _store = store;

  final AppDatabase _db;
  final SettingsRepository _settings;
  RemoteStore? _store;

  static const _lastPullKey = 'last_pull_iso';

  bool _running = false;

  RemoteStore get _remote => _store ??= FirestoreRemoteStore();

  /// Total rows waiting to be pushed.
  Future<int> pendingCount() async {
    var total = 0;
    total += (await _db.unsyncedExercises()).length;
    total += (await _db.unsyncedTemplates()).length;
    total += (await _db.unsyncedTemplateExercises()).length;
    total += (await _db.unsyncedSessions()).length;
    total += (await _db.unsyncedSessionExercises()).length;
    total += (await _db.unsyncedSets()).length;
    total += (await _db.unsyncedPersonalRecords()).length;
    total += (await _db.unsyncedMetrics()).length;
    // Photos are intentionally never synced — they live only on local external
    // storage, so they never count as pending.
    return total;
  }

  /// Runs a full push-then-pull cycle. Safe to call often — overlapping calls
  /// are dropped rather than queued.
  Future<SyncStatus> sync() async {
    final settings = await _settings.read();
    if (!settings.syncEnabled) {
      return SyncStatus(
        state: SyncState.disabled,
        message: 'Sync turned off in Settings',
        pending: await pendingCount(),
        lastSyncAt: settings.lastSyncAt,
      );
    }
    if (!FirebaseBootstrap.isAvailable) {
      return SyncStatus(
        state: SyncState.disabled,
        message: FirebaseBootstrap.unavailableReason ?? 'Firebase unavailable',
        pending: await pendingCount(),
        lastSyncAt: settings.lastSyncAt,
      );
    }
    if (_running) {
      return SyncStatus(
        state: SyncState.syncing,
        pending: await pendingCount(),
        lastSyncAt: settings.lastSyncAt,
      );
    }

    _running = true;
    try {
      final pushed = await _pushAll();
      final pulled = await _pullAll();
      final now = DateTime.now();
      await _settings.setLastSyncAt(now);
      return SyncStatus(
        state: SyncState.success,
        lastSyncAt: now,
        pending: await pendingCount(),
        pushed: pushed,
        pulled: pulled,
      );
    } on Object catch (e) {
      debugPrint('IronLog: sync failed ($e)');
      return SyncStatus(
        state: SyncState.failed,
        message: '$e',
        pending: await pendingCount(),
        lastSyncAt: settings.lastSyncAt,
      );
    } finally {
      _running = false;
    }
  }

  // -------------------------------------------------------------------- push

  Future<int> _pushAll() async {
    var count = 0;

    for (final row in await _db.unsyncedExercises()) {
      await _remote.upsert(
        SyncCollections.exercises,
        row.id,
        SyncMappers.exercise(row),
      );
      await (_db.update(
        _db.exercises,
      )..where((t) => t.id.equals(row.id))).write(
        const ExercisesCompanion(synced: Value(true)),
      );
      count++;
    }

    for (final row in await _db.unsyncedTemplates()) {
      await _remote.upsert(
        SyncCollections.templates,
        row.id,
        SyncMappers.template(row),
      );
      await (_db.update(
        _db.templates,
      )..where((t) => t.id.equals(row.id))).write(
        const TemplatesCompanion(synced: Value(true)),
      );
      count++;
    }

    for (final row in await _db.unsyncedTemplateExercises()) {
      await _remote.upsert(
        SyncCollections.templateExercises,
        row.id,
        SyncMappers.templateExercise(row),
      );
      await (_db.update(
        _db.templateExercises,
      )..where((t) => t.id.equals(row.id))).write(
        const TemplateExercisesCompanion(synced: Value(true)),
      );
      count++;
    }

    for (final row in await _db.unsyncedSessions()) {
      await _remote.upsert(
        SyncCollections.sessions,
        row.id,
        SyncMappers.session(row),
      );
      await (_db.update(_db.sessions)..where((t) => t.id.equals(row.id))).write(
        const SessionsCompanion(synced: Value(true)),
      );
      count++;
    }

    for (final row in await _db.unsyncedSessionExercises()) {
      await _remote.upsert(
        SyncCollections.sessionExercises,
        row.id,
        SyncMappers.sessionExercise(row),
      );
      await (_db.update(
        _db.sessionExercises,
      )..where((t) => t.id.equals(row.id))).write(
        const SessionExercisesCompanion(synced: Value(true)),
      );
      count++;
    }

    for (final row in await _db.unsyncedSets()) {
      await _remote.upsert(
        SyncCollections.sets,
        row.id,
        SyncMappers.workoutSet(row),
      );
      await (_db.update(
        _db.workoutSets,
      )..where((t) => t.id.equals(row.id))).write(
        const WorkoutSetsCompanion(synced: Value(true)),
      );
      count++;
    }

    for (final row in await _db.unsyncedPersonalRecords()) {
      await _remote.upsert(
        SyncCollections.personalRecords,
        row.id,
        SyncMappers.personalRecord(row),
      );
      await (_db.update(
        _db.personalRecords,
      )..where((t) => t.id.equals(row.id))).write(
        const PersonalRecordsCompanion(synced: Value(true)),
      );
      count++;
    }

    for (final row in await _db.unsyncedMetrics()) {
      await _remote.upsert(
        SyncCollections.metrics,
        Dates.isoDay(row.date),
        SyncMappers.metric(row),
      );
      await (_db.update(
        _db.dailyMetrics,
      )..where((t) => t.date.equals(row.date))).write(
        const DailyMetricsCompanion(synced: Value(true)),
      );
      count++;
    }

    // Photos are deliberately not pushed — there is no Firebase Storage in this
    // app, so progress photos stay entirely on local external storage.
    return count;
  }

  // -------------------------------------------------------------------- pull

  Future<int> _pullAll() async {
    final stored = await _db.getSetting(_lastPullKey);
    // An empty cursor means "pull everything" — see [resetPullCursor].
    final since = (stored == null || stored.isEmpty) ? null : stored;
    var newest = since;
    var count = 0;

    /// Tracks the high-water mark so the next pull only asks for newer docs.
    void trackNewest(Map<String, dynamic> doc) {
      final updated = doc['updatedAt'];
      if (updated is String && (newest == null || updated.compareTo(newest!) > 0)) {
        newest = updated;
      }
    }

    for (final doc in await _remote.fetchSince(
      SyncCollections.exercises,
      since,
    )) {
      trackNewest(doc);
      final companion = SyncMappers.exerciseFrom(doc);
      if (companion == null) continue;
      final id = companion.id.value;
      final local = await _db.exerciseById(id);
      if (local != null &&
          !local.updatedAt.isBefore(companion.updatedAt.value)) {
        continue;
      }
      await _db.into(_db.exercises).insertOnConflictUpdate(companion);
      count++;
    }

    for (final doc in await _remote.fetchSince(
      SyncCollections.templates,
      since,
    )) {
      trackNewest(doc);
      final companion = SyncMappers.templateFrom(doc);
      if (companion == null) continue;
      final local = await _db.templateById(companion.id.value);
      if (local != null &&
          !local.updatedAt.isBefore(companion.updatedAt.value)) {
        continue;
      }
      await _db.into(_db.templates).insertOnConflictUpdate(companion);
      count++;
    }

    for (final doc in await _remote.fetchSince(
      SyncCollections.templateExercises,
      since,
    )) {
      trackNewest(doc);
      final companion = SyncMappers.templateExerciseFrom(doc);
      if (companion == null) continue;
      final local = await (_db.select(
        _db.templateExercises,
      )..where((t) => t.id.equals(companion.id.value))).getSingleOrNull();
      if (local != null &&
          !local.updatedAt.isBefore(companion.updatedAt.value)) {
        continue;
      }
      await _db.into(_db.templateExercises).insertOnConflictUpdate(companion);
      count++;
    }

    for (final doc in await _remote.fetchSince(
      SyncCollections.sessions,
      since,
    )) {
      trackNewest(doc);
      final companion = SyncMappers.sessionFrom(doc);
      if (companion == null) continue;
      final local = await _db.sessionById(companion.id.value);
      if (local != null &&
          !local.updatedAt.isBefore(companion.updatedAt.value)) {
        continue;
      }
      await _db.into(_db.sessions).insertOnConflictUpdate(companion);
      count++;
    }

    for (final doc in await _remote.fetchSince(
      SyncCollections.sessionExercises,
      since,
    )) {
      trackNewest(doc);
      final companion = SyncMappers.sessionExerciseFrom(doc);
      if (companion == null) continue;
      final local = await (_db.select(
        _db.sessionExercises,
      )..where((t) => t.id.equals(companion.id.value))).getSingleOrNull();
      if (local != null &&
          !local.updatedAt.isBefore(companion.updatedAt.value)) {
        continue;
      }
      await _db.into(_db.sessionExercises).insertOnConflictUpdate(companion);
      count++;
    }

    for (final doc in await _remote.fetchSince(SyncCollections.sets, since)) {
      trackNewest(doc);
      final companion = SyncMappers.workoutSetFrom(doc);
      if (companion == null) continue;
      final local = await (_db.select(
        _db.workoutSets,
      )..where((t) => t.id.equals(companion.id.value))).getSingleOrNull();
      if (local != null &&
          !local.updatedAt.isBefore(companion.updatedAt.value)) {
        continue;
      }
      await _db.into(_db.workoutSets).insertOnConflictUpdate(companion);
      count++;
    }

    for (final doc in await _remote.fetchSince(
      SyncCollections.personalRecords,
      since,
    )) {
      trackNewest(doc);
      final companion = SyncMappers.personalRecordFrom(doc);
      if (companion == null) continue;
      final local = await (_db.select(
        _db.personalRecords,
      )..where((t) => t.id.equals(companion.id.value))).getSingleOrNull();
      if (local != null &&
          !local.updatedAt.isBefore(companion.updatedAt.value)) {
        continue;
      }
      await _db.into(_db.personalRecords).insertOnConflictUpdate(companion);
      count++;
    }

    for (final doc in await _remote.fetchSince(
      SyncCollections.metrics,
      since,
    )) {
      trackNewest(doc);
      final companion = SyncMappers.metricFrom(doc);
      if (companion == null) continue;
      final local = await _db.metricForDate(companion.date.value);
      if (local != null &&
          !local.updatedAt.isBefore(companion.updatedAt.value)) {
        continue;
      }
      await _db.into(_db.dailyMetrics).insertOnConflictUpdate(companion);
      count++;
    }

    // Photos are never pulled — they are local-only, on external storage.

    if (newest != null && newest != since) {
      await _db.setSetting(_lastPullKey, newest!);
    }
    return count;
  }

  /// Marks every local row dirty so the next sync re-uploads everything.
  Future<void> forceFullPush() async {
    await _db.batch((b) {
      b.update(_db.exercises, const ExercisesCompanion(synced: Value(false)));
      b.update(_db.templates, const TemplatesCompanion(synced: Value(false)));
      b.update(
        _db.templateExercises,
        const TemplateExercisesCompanion(synced: Value(false)),
      );
      b.update(_db.sessions, const SessionsCompanion(synced: Value(false)));
      b.update(
        _db.sessionExercises,
        const SessionExercisesCompanion(synced: Value(false)),
      );
      b.update(_db.workoutSets, const WorkoutSetsCompanion(synced: Value(false)));
      b.update(
        _db.personalRecords,
        const PersonalRecordsCompanion(synced: Value(false)),
      );
      b.update(
        _db.dailyMetrics,
        const DailyMetricsCompanion(synced: Value(false)),
      );
      // Photos are not synced, so they are left untouched here.
    });
  }

  /// Forgets the pull high-water mark so the next sync re-reads everything.
  Future<void> resetPullCursor() async {
    await _db.setSetting(_lastPullKey, '');
  }
}
