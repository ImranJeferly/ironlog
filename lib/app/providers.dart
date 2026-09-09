import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/utils/date_x.dart';
import '../core/utils/format.dart';
import '../core/utils/haptics.dart';
import '../core/utils/stream_x.dart';
import '../data/db/database.dart';
import '../data/db/seed_data.dart';
import '../data/export/csv_export.dart';
import '../data/health/health_service.dart';
import '../data/repositories/metrics_repository.dart';
import '../data/repositories/photo_repository.dart';
import '../data/repositories/progress_repository.dart';
import '../data/repositories/settings_repository.dart';
import '../data/repositories/workout_repository.dart';
import '../data/social/social_models.dart';
import '../data/social/social_repository.dart';
import '../data/social/stats_builder.dart';
import '../data/sync/auth_service.dart';
import '../core/notifications.dart';
import '../core/now_playing.dart';
import '../core/push.dart';
import '../core/update/update_service.dart';
import '../data/sync/sync_service.dart';
import '../domain/enums.dart';
import '../domain/program.dart';
import '../domain/volume.dart';
import '../domain/session_view.dart';
import '../domain/strength_math.dart';

// ---------------------------------------------------------------- foundation

/// Overridden in `main()` (and in tests, with an in-memory database).
final appDatabaseProvider = Provider<AppDatabase>(
  (ref) => throw UnimplementedError('appDatabaseProvider must be overridden'),
);

final settingsRepositoryProvider = Provider<SettingsRepository>(
  (ref) => SettingsRepository(ref.watch(appDatabaseProvider)),
);

final workoutRepositoryProvider = Provider<WorkoutRepository>(
  (ref) => WorkoutRepository(ref.watch(appDatabaseProvider)),
);

final progressRepositoryProvider = Provider<ProgressRepository>(
  (ref) => ProgressRepository(ref.watch(appDatabaseProvider)),
);

final metricsRepositoryProvider = Provider<MetricsRepository>(
  (ref) => MetricsRepository(ref.watch(appDatabaseProvider)),
);

final photoRepositoryProvider = Provider<PhotoRepository>(
  (ref) => PhotoRepository(ref.watch(appDatabaseProvider)),
);

final healthServiceProvider = Provider<HealthService>(
  (ref) => HealthService(ref.watch(metricsRepositoryProvider)),
);

final updateServiceProvider = Provider<UpdateService>((ref) => UpdateService());

final csvExporterProvider = Provider<CsvExporter>(
  (ref) => CsvExporter(ref.watch(appDatabaseProvider)),
);

final syncServiceProvider = Provider<SyncService>(
  (ref) => SyncService(
    db: ref.watch(appDatabaseProvider),
    settings: ref.watch(settingsRepositoryProvider),
  ),
);

// ------------------------------------------------------------------ settings

/// Settings are exposed synchronously with sane defaults so no screen ever has
/// to render a spinner while waiting for a local read.
class SettingsController extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    final repo = ref.watch(settingsRepositoryProvider);
    final sub = repo.watch().listen((value) {
      state = value;
      Haptics.enabled = value.hapticsEnabled;
    });
    ref.onDispose(sub.cancel);
    return const AppSettings();
  }

  SettingsRepository get _repo => ref.read(settingsRepositoryProvider);

  Future<void> setUnit(WeightUnit unit) => _repo.setUnit(unit);

  Future<void> setRestSeconds(int seconds) => _repo.setRestSeconds(seconds);

  Future<void> setRestSecondsPrimary(int seconds) =>
      _repo.setRestSecondsPrimary(seconds);

  Future<void> setRestSecondsExercise(int seconds) =>
      _repo.setRestSecondsExercise(seconds);

  Future<void> setHaptics(bool on) async {
    Haptics.enabled = on;
    await _repo.setHaptics(on);
  }

  Future<void> setRestTimerEnabled(bool on) => _repo.setRestTimerEnabled(on);

  Future<void> setSyncEnabled(bool on) => _repo.setSyncEnabled(on);

  Future<void> setHealthEnabled(bool on) async {
    await _repo.setHealthEnabled(on);
    // Turning Health on should immediately connect and pull recent numbers,
    // so steps start syncing without waiting for the next app launch.
    if (on) {
      final health = ref.read(healthServiceProvider);
      if (await health.requestPermissions()) {
        await health.syncRecent();
      }
    }
  }

  Future<void> setStepGoal(int steps) => _repo.setStepGoal(steps);

  Future<void> setNutritionReminder(bool on) async {
    await _repo.setNutritionReminder(on);
    await Notifications.syncNutritionReminder(enabled: on);
  }

  Future<void> setShareNowPlaying(bool on) => _repo.setShareNowPlaying(on);

  Future<void> setBwTargetMin(double kgPerWeek) =>
      _repo.setBwTargetMin(kgPerWeek);

  Future<void> setBwTargetMax(double kgPerWeek) =>
      _repo.setBwTargetMax(kgPerWeek);

  Future<void> completeFirstRun() => _repo.completeFirstRun();
}

final settingsProvider = NotifierProvider<SettingsController, AppSettings>(
  SettingsController.new,
);

final unitProvider = Provider<WeightUnit>(
  (ref) => ref.watch(settingsProvider).unit,
);

// -------------------------------------------------------------- library data

final templatesProvider = StreamProvider<List<TemplateRow>>(
  (ref) => ref.watch(appDatabaseProvider).watchTemplates(),
);

final allExercisesProvider = StreamProvider<List<ExerciseRow>>(
  (ref) => ref.watch(appDatabaseProvider).watchExercises(),
);

final exerciseByIdProvider = Provider.family<ExerciseRow?, String>((ref, id) {
  final all = ref.watch(allExercisesProvider).value ?? const [];
  for (final e in all) {
    if (e.id == id) return e;
  }
  return null;
});

/// Template scheduled for today's weekday, if any.
final todayTemplateProvider = Provider<TemplateRow?>((ref) {
  final templates = ref.watch(templatesProvider).value ?? const [];
  final weekday = DateTime.now().weekday;
  for (final t in templates) {
    if (t.weekday == weekday) return t;
  }
  return null;
});

/// The active program, when settings point at the seeded rotation.
final activeProgramProvider = Provider<ProgramDefinition?>((ref) {
  final id = ref.watch(settingsProvider).programId;
  return id == SeedData.program.id ? SeedData.program : null;
});

/// The workout to offer next: the program's next rotation day when a program
/// is active (whatever the date), otherwise today's weekday template.
final nextWorkoutProvider = Provider<TemplateRow?>((ref) {
  final program = ref.watch(activeProgramProvider);
  if (program == null) return ref.watch(todayTemplateProvider);
  final id = program.dayAt(ref.watch(settingsProvider).programCursor);
  for (final t in ref.watch(templatesProvider).value ?? const <TemplateRow>[]) {
    if (t.id == id) return t;
  }
  return ref.watch(todayTemplateProvider);
});

/// Per-muscle hard sets / tonnage for the last four calendar weeks.
final volumeWeeksProvider = FutureProvider<List<MuscleWeek>>((ref) {
  ref.watch(analyticsRevisionProvider);
  ref.watch(recentSessionsProvider);
  return ref.watch(progressRepositoryProvider).volumeWeeks();
});

/// Weekly hard-set target band per muscle (spec defaults + user overrides).
final volumeTargetsProvider = FutureProvider<Map<Muscle, VolumeTarget>>(
  (ref) => ref.watch(settingsRepositoryProvider).volumeTargets(),
);

/// Exercise ids with no e1RM PR in the last four weeks despite being trained.
final stalledExercisesProvider = FutureProvider<Set<String>>((ref) {
  ref.watch(analyticsRevisionProvider);
  ref.watch(recentSessionsProvider);
  return ref.watch(progressRepositoryProvider).stalledExerciseIds();
});

/// Non-null when a deload week should be suggested.
final deloadRecommendationProvider = FutureProvider<DeloadRecommendation?>((
  ref,
) {
  ref.watch(analyticsRevisionProvider);
  ref.watch(settingsProvider);
  return ref.watch(progressRepositoryProvider).deloadRecommendation();
});

/// The live exercise list of a template — drives the workout editor and the
/// hero card, updating the moment an exercise is added or removed.
final templateExercisesProvider =
    StreamProvider.family<List<(TemplateExerciseRow, ExerciseRow)>, String>(
      (ref, templateId) =>
          ref.watch(appDatabaseProvider).watchTemplateExerciseRows(templateId),
    );

/// (exercise count, total prescribed working sets) for a template — the
/// "what am I in for" line on the hero card.
final templatePlanProvider = Provider.family<(int, int)?, String>((
  ref,
  templateId,
) {
  final rows = ref.watch(templateExercisesProvider(templateId)).value;
  if (rows == null) return null;
  var sets = 0;
  for (final (link, exercise) in rows) {
    sets += link.setsOverride ?? exercise.targetSets;
  }
  return (rows.length, sets);
});

/// The next scheduled workout strictly after today — what a rest day looks
/// forward to. Null when nothing is scheduled at all.
final nextTemplateProvider = Provider<TemplateRow?>((ref) {
  final templates = ref.watch(templatesProvider).value ?? const [];
  final today = DateTime.now().weekday;
  for (var offset = 1; offset <= 7; offset++) {
    final day = (today - 1 + offset) % 7 + 1;
    for (final t in templates) {
      if (t.weekday == day) return t;
    }
  }
  return null;
});

// ------------------------------------------------------------------ sessions

final activeSessionProvider = StreamProvider<SessionRow?>(
  (ref) => ref.watch(appDatabaseProvider).watchActiveSession(),
);

final recentSessionsProvider = StreamProvider<List<SessionRow>>(
  (ref) => ref.watch(appDatabaseProvider).watchSessions(),
);

/// Ghost values (last session's sets) for every exercise in a session. Loaded
/// once per session so logging a set doesn't re-query history.
final sessionGhostsProvider =
    FutureProvider.family<Map<String, List<SetPerformance>>, String>(
      (ref, sessionId) =>
          ref.watch(workoutRepositoryProvider).loadGhosts(sessionId),
    );

/// The live view of a session, recombining whenever the session row, its
/// exercise list or its sets change.
final sessionViewProvider = StreamProvider.family<SessionView?, String>((
  ref,
  sessionId,
) {
  final db = ref.watch(appDatabaseProvider);
  final ghosts =
      ref.watch(sessionGhostsProvider(sessionId)).value ??
      const <String, List<SetPerformance>>{};
  final exercises = ref.watch(allExercisesProvider).value ?? const <ExerciseRow>[];
  final exerciseById = {for (final e in exercises) e.id: e};

  return combineLatest3<
    SessionRow?,
    List<SessionExerciseRow>,
    List<WorkoutSetRow>,
    SessionView?
  >(db.watchSessionById(sessionId), db.watchSessionExercises(sessionId), db
      .watchSetsForSession(sessionId), (session, links, sets) {
    if (session == null) return null;

    final views = <SessionExerciseView>[];
    for (final link in links) {
      final exercise = exerciseById[link.exerciseId];
      if (exercise == null) continue;
      final mySets = sets.where((s) => s.exerciseId == link.exerciseId).toList()
        ..sort((a, b) => a.setNo.compareTo(b.setNo));
      views.add(
        SessionExerciseView(
          link: link,
          exercise: exercise,
          sets: mySets,
          ghostSets: ghosts[link.exerciseId] ?? const [],
        ),
      );
    }
    return SessionView(session: session, exercises: views);
  });
});

// ----------------------------------------------------------------- analytics

final personalRecordsProvider = StreamProvider<List<PersonalRecordRow>>(
  (ref) => ref.watch(appDatabaseProvider).watchPersonalRecords(limit: 200),
);

/// Bumped after a session finishes so the analytics screens recompute.
final analyticsRevisionProvider = NotifierProvider<AnalyticsRevision, int>(
  AnalyticsRevision.new,
);

class AnalyticsRevision extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final consistencyProvider = FutureProvider<ConsistencyStats>((ref) {
  ref.watch(analyticsRevisionProvider);
  ref.watch(recentSessionsProvider);
  // Adherence is measured against the template schedule, so editing a
  // training day recomputes it immediately.
  ref.watch(templatesProvider);
  return ref.watch(progressRepositoryProvider).consistency();
});

final muscleSummaryProvider = FutureProvider<MuscleGroupSummary>((ref) {
  ref.watch(analyticsRevisionProvider);
  ref.watch(recentSessionsProvider);
  return ref.watch(progressRepositoryProvider).muscleGroupSummary();
});

final bodyWeightProvider = FutureProvider<BodyWeightSeries>((ref) {
  ref.watch(analyticsRevisionProvider);
  ref.watch(todayMetricsProvider);
  return ref.watch(progressRepositoryProvider).bodyWeight();
});

final exerciseIndexProvider =
    FutureProvider<List<(ExerciseRow, DateTime?, int)>>((ref) {
      ref.watch(analyticsRevisionProvider);
      ref.watch(recentSessionsProvider);
      return ref.watch(progressRepositoryProvider).exerciseIndex();
    });

final exerciseProgressProvider = FutureProvider.family<ExerciseProgress, String>(
  (ref, exerciseId) {
    ref.watch(analyticsRevisionProvider);
    return ref.watch(progressRepositoryProvider).exerciseProgress(exerciseId);
  },
);

// ------------------------------------------------------------------- metrics

final selectedMetricDateProvider =
    NotifierProvider<SelectedMetricDate, DateTime>(SelectedMetricDate.new);

class SelectedMetricDate extends Notifier<DateTime> {
  @override
  DateTime build() => DateTime.now().dayStart;

  void set(DateTime date) => state = date.dayStart;
}

final todayMetricsProvider = StreamProvider<DailyMetricRow?>((ref) {
  final date = ref.watch(selectedMetricDateProvider);
  return ref.watch(metricsRepositoryProvider).watchDay(date);
});

/// The last seven days of metrics (today included) — rolling averages.
final recentMetricsProvider = StreamProvider<List<DailyMetricRow>>((ref) {
  final today = DateTime.now().dayStart;
  return ref
      .watch(metricsRepositoryProvider)
      .watchRange(today.subtract(const Duration(days: 6)), today);
});

// -------------------------------------------------------------------- photos

final photosProvider = StreamProvider<List<PhotoRow>>(
  (ref) => ref.watch(photoRepositoryProvider).watchAll(),
);

// ---------------------------------------------------------------------- auth

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

/// The signed-in Firebase user (anonymous or real). Null when Firebase is
/// unavailable — the app keeps working fully offline in that case.
final authUserProvider = StreamProvider<User?>(
  (ref) => ref.watch(authServiceProvider).authStateChanges(),
);

// ---------------------------------------------------------------------- sync

class SyncController extends Notifier<SyncStatus> {
  Timer? _debounce;
  StreamSubscription<List<ConnectivityResult>>? _connectivity;

  @override
  SyncStatus build() {
    // Push whenever the device comes back online — the plan's background sync.
    try {
      _connectivity = Connectivity().onConnectivityChanged.listen(
        (results) {
          final online = results.any((r) => r != ConnectivityResult.none);
          if (online) _scheduleSync();
        },
        // No connectivity plugin (tests/desktop) — fall back to manual sync
        // rather than letting an unhandled stream error escape.
        onError: (Object _) {},
      );
    } on Object {
      // Connectivity plugin unavailable (tests/desktop) — manual sync only.
    }

    ref.onDispose(() {
      _debounce?.cancel();
      _connectivity?.cancel();
    });

    unawaited(refreshPending());
    return const SyncStatus();
  }

  void _scheduleSync() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 2), sync);
  }

  Future<void> refreshPending() async {
    final pending = await ref.read(syncServiceProvider).pendingCount();
    final settings = ref.read(settingsProvider);
    state = state.copyWith(pending: pending, lastSyncAt: settings.lastSyncAt);
  }

  Future<void> sync() async {
    if (state.state == SyncState.syncing) return;
    state = state.copyWith(state: SyncState.syncing);
    // Never leave the UI stranded on "Syncing…": any escape from sync() resolves
    // to a terminal state.
    try {
      state = await ref.read(syncServiceProvider).sync();
    } on Object catch (e) {
      state = state.copyWith(state: SyncState.failed, message: '$e');
    }
  }

  Future<void> forceFullPush() async {
    final service = ref.read(syncServiceProvider);
    await service.forceFullPush();
    await service.resetPullCursor();
    await refreshPending();
  }
}

final syncControllerProvider = NotifierProvider<SyncController, SyncStatus>(
  SyncController.new,
);

// -------------------------------------------------------------------- social

final socialRepositoryProvider = Provider<SocialRepository>(
  (ref) => SocialRepository(),
);

/// True once somebody is signed in — the gate for everything social.
final socialEnabledProvider = Provider<bool>((ref) {
  return ref.watch(authUserProvider).value != null;
});

final myProfileProvider = StreamProvider<UserProfile?>((ref) {
  if (!ref.watch(socialEnabledProvider)) return Stream.value(null);
  return ref.watch(socialRepositoryProvider).watchMyProfile();
});

final friendProfileProvider = StreamProvider.family<UserProfile?, String>(
  (ref, uid) => ref.watch(socialRepositoryProvider).watchProfile(uid),
);

final friendsProvider = StreamProvider<List<Friend>>((ref) {
  if (!ref.watch(socialEnabledProvider)) return Stream.value(const []);
  return ref.watch(socialRepositoryProvider).watchFriends();
});

final incomingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  if (!ref.watch(socialEnabledProvider)) return Stream.value(const []);
  return ref.watch(socialRepositoryProvider).watchIncomingRequests();
});

final outgoingRequestsProvider = StreamProvider<List<FriendRequest>>((ref) {
  if (!ref.watch(socialEnabledProvider)) return Stream.value(const []);
  return ref.watch(socialRepositoryProvider).watchOutgoingRequests();
});

final chatsProvider = StreamProvider<List<ChatSummary>>((ref) {
  if (!ref.watch(socialEnabledProvider)) return Stream.value(const []);
  return ref.watch(socialRepositoryProvider).watchChats();
});

final chatMessagesProvider = StreamProvider.family<List<ChatMessage>, String>(
  (ref, chatId) => ref.watch(socialRepositoryProvider).watchMessages(chatId),
);

/// Unread messages across every chat + pending friend requests — the badge
/// on the Friends tab.
final socialBadgeProvider = Provider<int>((ref) {
  final me = ref.watch(socialRepositoryProvider).uid;
  if (me == null) return 0;
  final chats = ref.watch(chatsProvider).value ?? const [];
  final requests = ref.watch(incomingRequestsProvider).value ?? const [];
  var n = requests.length;
  for (final c in chats) {
    n += c.unreadFor(me);
  }
  return n;
});

/// Side effects that keep friends in the loop: profile bootstrap, stats and
/// now-playing publishing, and the "started / finished / PR" broadcasts.
class SocialHooks {
  SocialHooks(this._ref);

  final Ref _ref;
  DateTime? _lastNowPlayingPush;
  String? _lastNowPlayingKey;
  DateTime? _lastProfileTouch;
  String? _lastStatsSignature;

  /// PRs hit during the session in progress. Broadcast as one line when the
  /// session is finished rather than one message (and one push) per PR.
  final List<String> _sessionPrs = [];

  /// How stale a profile's `lastSeenAt` is allowed to get before a resume
  /// writes it again. Resume fires on every app switch, and the field is only
  /// used for a "last seen" line.
  static const _profileTouchEvery = Duration(minutes: 15);

  SocialRepository get _repo => _ref.read(socialRepositoryProvider);

  bool get _enabled => _ref.read(socialEnabledProvider);

  /// On app open / resume: make sure the profile exists and is current.
  Future<void> onResume() async {
    if (!_enabled) return;
    try {
      final now = DateTime.now();
      final due =
          _lastProfileTouch == null ||
          now.difference(_lastProfileTouch!) > _profileTouchEvery;
      if (due) {
        _lastProfileTouch = now;
        await _repo.ensureProfile(email: _ref.read(authServiceProvider).email);
      }
      await publishStats();
      await publishNowPlaying();
      // Registers this device's FCM token; the Cloud Functions push to it.
      await PushService.start();
    } on Object catch (e) {
      debugPrint('IronLog: social resume failed ($e)');
    }
  }

  /// Sign-out: stop notifying for the old account on this phone.
  Future<void> stopPush() async {
    _lastProfileTouch = null;
    _lastStatsSignature = null;
    _sessionPrs.clear();
    await PushService.stop();
  }

  /// Publishes the profile stats, but only when a number actually moved —
  /// resume fires on every app switch and these rarely change.
  Future<void> publishStats() async {
    if (!_enabled) return;
    try {
      final stats = await buildProfileStats(
        _ref.read(appDatabaseProvider),
        _ref.read(progressRepositoryProvider),
      );
      final signature = stats.signature;
      if (signature == _lastStatsSignature) return;
      _lastStatsSignature = signature;
      await _repo.publishStats(stats);
    } on Object catch (e) {
      debugPrint('IronLog: publishStats failed ($e)');
    }
  }

  /// Reads the phone's media session and publishes it when it changed (or
  /// every few minutes so it doesn't go stale for friends).
  Future<void> publishNowPlaying() async {
    if (!_enabled) return;
    try {
      if (!_ref.read(settingsProvider).shareNowPlaying) {
        if (_lastNowPlayingKey != null) {
          _lastNowPlayingKey = null;
          await _repo.publishNowPlaying(null);
        }
        return;
      }
      final np = await NowPlayingService.current();
      final key = np == null ? '' : '${np.title}|${np.artist}';
      final now = DateTime.now();
      final refresh =
          _lastNowPlayingPush == null ||
          now.difference(_lastNowPlayingPush!) > const Duration(minutes: 3);
      if (key == _lastNowPlayingKey && !refresh) return;
      _lastNowPlayingKey = key;
      _lastNowPlayingPush = now;
      await _repo.publishNowPlaying(np);
    } on Object catch (e) {
      debugPrint('IronLog: publishNowPlaying failed ($e)');
    }
  }

  /// True when the user has a real account — the only case the hooks do
  /// anything. Lets callers skip timers and listeners when signed out.
  bool get enabled => _enabled;

  Future<void> sessionStarted(String name) => _guard(() async {
    _sessionPrs.clear();
    await _repo.setActiveSession(name);
    await _repo.broadcast('🏋️ Started $name');
  });

  /// One message per session: the summary, with the session's PRs appended.
  /// A three-PR session used to send four messages — and, now that pushes are
  /// real, four notifications — to every friend.
  Future<void> sessionFinished(SessionRow session) => _guard(() async {
    await _repo.setActiveSession(null);
    final unit = _ref.read(unitProvider);
    final summary = StringBuffer(
      '✅ Finished ${session.templateName ?? 'a workout'} · '
      '${session.totalSets} sets · ${Fmt.tonnage(session.tonnageKg, unit)}',
    );
    if (_sessionPrs.isNotEmpty) {
      final count = _sessionPrs.length;
      summary
        ..write('\n⚡ $count new PR${count == 1 ? '' : 's'}: ')
        ..write(_sessionPrs.join(' · '));
    }
    _sessionPrs.clear();
    await _repo.broadcast(summary.toString());
    await publishStats();
  });

  Future<void> sessionDiscarded() => _guard(() async {
    _sessionPrs.clear();
    await _repo.setActiveSession(null);
  });

  /// Records a PR for the end-of-session broadcast. Deliberately local: the
  /// celebration is immediate, the telling-your-friends part is batched.
  void prHit({
    required String exerciseName,
    required PrType type,
    required double value,
    required int reps,
  }) {
    if (!_enabled) return;
    final unit = _ref.read(unitProvider);
    final what = switch (type) {
      PrType.reps => '$reps reps',
      _ => Fmt.weight(value, unit),
    };
    final line = '$exerciseName $what';
    if (!_sessionPrs.contains(line)) _sessionPrs.add(line);
  }

  /// The training flow must never stall on a social write — offline, rules
  /// rejection, whatever. Log and move on.
  Future<void> _guard(Future<void> Function() body) async {
    if (!_enabled) return;
    try {
      await body();
    } on Object catch (e) {
      debugPrint('IronLog: social hook failed ($e)');
    }
  }
}

final socialHooksProvider = Provider<SocialHooks>((ref) => SocialHooks(ref));
