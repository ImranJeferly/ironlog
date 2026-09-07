// `isNull`/`isNotNull` collide with drift's SQL expression helpers.
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/db/seed_data.dart';
import 'package:gym/data/repositories/settings_repository.dart';
import 'package:gym/data/repositories/workout_repository.dart';
import 'package:gym/data/sync/firebase_bootstrap.dart';
import 'package:gym/data/sync/remote_store.dart';
import 'package:gym/data/sync/sync_mappers.dart';
import 'package:gym/data/sync/sync_service.dart';
import 'package:gym/domain/enums.dart';

import '../helpers/test_db.dart';

/// In-memory stand-in for Firestore. There is no Storage — photos never sync.
class FakeRemoteStore implements RemoteStore {
  final Map<String, Map<String, Map<String, dynamic>>> docs = {};

  @override
  Future<void> upsert(
    String collection,
    String id,
    Map<String, dynamic> data,
  ) async {
    docs.putIfAbsent(collection, () => {})[id] = Map.of(data);
  }

  @override
  Future<List<Map<String, dynamic>>> fetchSince(
    String collection,
    String? sinceIso,
  ) async {
    final all = docs[collection]?.values.toList() ?? const [];
    if (sinceIso == null) return all.map(Map<String, dynamic>.of).toList();
    return all
        .where((d) {
          final updated = d['updatedAt'];
          return updated is String && updated.compareTo(sinceIso) > 0;
        })
        .map(Map<String, dynamic>.of)
        .toList();
  }

  int countIn(String collection) => docs[collection]?.length ?? 0;
}

void main() {
  late AppDatabase db;
  late FakeRemoteStore remote;
  late SyncService sync;
  late WorkoutRepository workouts;
  late SettingsRepository settings;

  setUpAll(quietDrift);

  setUp(() async {
    db = await createTestDatabase();
    remote = FakeRemoteStore();
    settings = SettingsRepository(db);
    workouts = WorkoutRepository(db);
    sync = SyncService(db: db, settings: settings, store: remote);
    FirebaseBootstrap.overrideForTest(available: true, uid: 'test-uid');
  });

  tearDown(() async {
    FirebaseBootstrap.overrideForTest(available: false);
    await db.close();
  });

  group('push', () {
    test('uploads the seeded library and marks it synced', () async {
      final result = await sync.sync();

      expect(result.state, SyncState.success);
      expect(remote.countIn(SyncCollections.exercises), greaterThan(0));
      expect(
        remote.countIn(SyncCollections.templates),
        SeedData.templates.length,
      );
      expect(await sync.pendingCount(), 0);
    });

    test('pushes a logged session with its sets', () async {
      final id = await workouts.startSessionFromTemplate('push');
      await workouts.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 6,
      );
      await workouts.finishSession(id);

      await sync.sync();

      expect(remote.countIn(SyncCollections.sessions), 1);
      expect(remote.countIn(SyncCollections.sets), 1);

      final doc = remote.docs[SyncCollections.sets]!.values.single;
      expect(doc['weightKg'], 30);
      expect(doc['reps'], 6);
      expect(doc['exerciseId'], 'incline-db-press');
    });

    test('never pushes a photos collection (local-only, no Storage)', () async {
      // Insert a photo row directly so it would be "unsynced" under the old
      // design, and confirm sync leaves it entirely alone.
      await db
          .into(db.photos)
          .insert(
            PhotosCompanion.insert(
              id: 'p1',
              date: DateTime(2026, 2, 2),
              pose: PhotoPose.front,
              localPath: '/local/only/p1.jpg',
            ),
          );

      await sync.sync();

      expect(remote.docs.containsKey('photos'), isFalse);
      // The photo does not count as pending work, either.
      expect(await sync.pendingCount(), 0);
    });

    test('a second sync has nothing left to push', () async {
      await sync.sync();
      final before = remote.countIn(SyncCollections.exercises);

      final second = await sync.sync();

      expect(second.pushed, 0);
      expect(remote.countIn(SyncCollections.exercises), before);
    });

    test('local edits after a sync become pending again', () async {
      await sync.sync();
      expect(await sync.pendingCount(), 0);

      final id = await workouts.startEmptySession();
      await workouts.addExercise(id, 'cable-row');

      expect(await sync.pendingCount(), greaterThan(0));
    });

    test('tombstones are pushed so deletes propagate', () async {
      final id = await workouts.startSessionFromTemplate('push');
      await workouts.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 6,
      );
      await workouts.finishSession(id);
      await sync.sync();

      await workouts.deleteSession(id);
      await sync.sync();

      expect(remote.docs[SyncCollections.sessions]![id]!['deleted'], isTrue);
    });
  });

  group('pull', () {
    test('applies a remote row that does not exist locally', () async {
      await sync.sync();

      // Written by another device after our last pull, so it clears the cursor.
      final writtenAt = DateTime.now().toUtc().add(const Duration(minutes: 5));
      await remote.upsert(SyncCollections.sessions, 'remote-1', {
        'id': 'remote-1',
        'date': '2026-01-15',
        'templateName': 'Pull',
        'startedAt': '2026-01-15T10:00:00.000Z',
        'durationMin': 55,
        'tonnageKg': 4200.0,
        'totalSets': 18,
        'isComplete': true,
        'updatedAt': writtenAt.toIso8601String(),
        'deleted': false,
      });

      await sync.sync();

      final row = await db.sessionById('remote-1');
      expect(row, isNotNull);
      expect(row!.templateName, 'Pull');
      expect(row.durationMin, 55);
      expect(row.synced, isTrue);
    });

    test('a newer remote row wins over an older local one', () async {
      final id = await workouts.startSessionFromTemplate('push');
      await workouts.finishSession(id);
      await sync.sync();

      await remote.upsert(SyncCollections.sessions, id, {
        ...remote.docs[SyncCollections.sessions]![id]!,
        'notes': 'edited on the other device',
        'updatedAt': DateTime.now()
            .toUtc()
            .add(const Duration(hours: 1))
            .toIso8601String(),
      });

      await sync.resetPullCursor();
      await sync.sync();

      expect((await db.sessionById(id))!.notes, 'edited on the other device');
    });

    test('an older remote row loses to a newer local one', () async {
      final id = await workouts.startSessionFromTemplate('push');
      await workouts.finishSession(id);
      await sync.sync();

      await remote.upsert(SyncCollections.sessions, id, {
        ...remote.docs[SyncCollections.sessions]![id]!,
        'notes': 'stale',
        'updatedAt': '2020-01-01T00:00:00.000Z',
      });

      await workouts.setSessionNotes(id, 'fresh local edit');
      await sync.resetPullCursor();
      await sync.sync();

      expect((await db.sessionById(id))!.notes, 'fresh local edit');
    });

    test('the pull cursor stops re-reading unchanged documents', () async {
      await sync.sync();
      final second = await sync.sync();

      expect(second.pulled, 0);
    });
  });

  group('gating', () {
    test('reports disabled when Firebase is unavailable', () async {
      FirebaseBootstrap.overrideForTest(available: false);

      final result = await sync.sync();

      expect(result.state, SyncState.disabled);
      expect(remote.docs, isEmpty);
    });

    test('reports disabled when the user turned sync off', () async {
      await settings.setSyncEnabled(false);

      final result = await sync.sync();

      expect(result.state, SyncState.disabled);
      expect(result.message, contains('Settings'));
      expect(remote.docs, isEmpty);
    });

    test('forceFullPush re-dirties everything', () async {
      await sync.sync();
      expect(await sync.pendingCount(), 0);

      await sync.forceFullPush();

      expect(await sync.pendingCount(), greaterThan(0));
    });
  });

  group('mappers', () {
    test('round-trip a set through the wire format', () async {
      final id = await workouts.startSessionFromTemplate('push');
      await workouts.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 42.5,
        reps: 7,
        rpe: 8,
        note: 'felt good',
      );

      final original = (await db.setsForSession(id)).single;
      final wire = SyncMappers.workoutSet(original);
      final companion = SyncMappers.workoutSetFrom(wire);

      expect(companion, isNotNull);
      expect(companion!.weightKg.value, 42.5);
      expect(companion.reps.value, 7);
      expect(companion.rpe.value, 8);
      expect(companion.note.value, 'felt good');
      expect(companion.synced.value, isTrue);
    });

    test('a malformed document is skipped rather than crashing sync', () {
      expect(SyncMappers.workoutSetFrom({'id': 'x'}), isNull);
      expect(SyncMappers.sessionFrom(const {}), isNull);
      expect(SyncMappers.metricFrom(const {'date': 'nonsense'}), isNull);
    });

    test('metrics key on the calendar day', () async {
      await db
          .into(db.dailyMetrics)
          .insert(
            DailyMetricsCompanion.insert(
              date: DateTime(2026, 3, 4),
              waterMl: const Value(1500),
              steps: const Value(9000),
            ),
          );

      await sync.sync();

      expect(remote.docs[SyncCollections.metrics]!.keys, contains('2026-03-04'));
      final doc = remote.docs[SyncCollections.metrics]!['2026-03-04']!;
      expect(doc['waterMl'], 1500);
      expect(doc['steps'], 9000);
    });
  });
}
