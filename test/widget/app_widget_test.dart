import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:gym/app/providers.dart';
import 'package:gym/core/theme/app_theme.dart';
import 'package:gym/data/db/database.dart';
import 'package:gym/data/health/health_service.dart';
import 'package:gym/data/repositories/settings_repository.dart';
import 'package:gym/data/repositories/workout_repository.dart';
import 'package:gym/features/first_run/first_run_screen.dart';
import 'package:gym/features/history/history_screen.dart';
import 'package:gym/features/progress/progress_screen.dart';
import 'package:gym/features/session/active_session_screen.dart';
import 'package:gym/features/session/session_summary_screen.dart';
import 'package:gym/features/session/set_logger_sheet.dart';
import 'package:gym/widgets/buttons.dart';
import 'package:gym/features/settings/settings_screen.dart';
import 'package:gym/features/shell/app_shell.dart';
import 'package:gym/widgets/wheel_picker.dart';

import '../helpers/test_db.dart';

void main() {
  late AppDatabase db;

  setUpAll(quietDrift);

  setUp(() async {
    db = await createTestDatabase();
  });

  // Widget tests mount stream-backed screens; see [closeTestDatabase] for why
  // this can't be a plain `db.close()`.
  tearDown(() => closeTestDatabase(db));

  /// Mounts [child], runs [body], then unmounts inside the test.
  ///
  /// The unmount matters: disposing the ProviderScope cancels drift's query
  /// streams, which schedules a zero-duration cleanup timer. Letting that flush
  /// here keeps flutter_test's "no pending timers" invariant happy.
  ///
  /// Note there is no `pumpAndSettle` anywhere in this file — the active
  /// session runs a 1-second periodic clock, so the tree never goes idle.
  Future<void> withScreen(
    WidgetTester tester,
    Widget child,
    Future<void> Function() body,
  ) async {
    // Tab screens (Home/Progress/History/Settings) normally live inside the
    // AppShell Scaffold; standalone in a test they need one so Material widgets
    // like Switch have an ancestor. Screens that bring their own Scaffold just
    // nest harmlessly inside this one.
    await tester.pumpWidget(
      ProviderScope(
        overrides: [appDatabaseProvider.overrideWithValue(db)],
        child: MaterialApp(
          theme: AppTheme.build(),
          home: Scaffold(body: child),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    await body();

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  Future<void> completeFirstRun() => SettingsRepository(db).completeFirstRun();

  group('first run', () {
    testWidgets('asks for units and Health, nothing else', (tester) async {
      await withScreen(tester, const FirstRunScreen(), () async {
        expect(find.text('IronLog'), findsOneWidget);
        expect(find.text('KG'), findsOneWidget);
        expect(find.text('LB'), findsOneWidget);
        expect(
          find.text('Connect ${HealthService.providerName}'),
          findsOneWidget,
        );
        expect(find.text('Start training'), findsOneWidget);
      });
    });
  });

  group('home', () {
    testWidgets('renders local data with no spinner', (tester) async {
      await completeFirstRun();
      await withScreen(tester, const AppShell(), () async {
        // Local data must never render a loading indicator.
        expect(find.byType(CircularProgressIndicator), findsNothing);
        expect(find.textContaining('Start'), findsWidgets);
        expect(find.textContaining('Steps'), findsWidgets);
        expect(find.text('Water'), findsWidgets);
        expect(find.text('Calories'), findsOneWidget);
        expect(find.text('Protein'), findsOneWidget);
      });
    });

    testWidgets('shows the resume card while a session is open', (
      tester,
    ) async {
      await completeFirstRun();
      await WorkoutRepository(db).startSessionFromTemplate('push');

      await withScreen(tester, const AppShell(), () async {
        expect(find.text('IN PROGRESS'), findsOneWidget);
        expect(find.text('Resume session'), findsOneWidget);
      });
    });

    testWidgets('navigates between all five tabs', (tester) async {
      await completeFirstRun();
      await withScreen(tester, const AppShell(), () async {
        for (final tab in ['Progress', 'History', 'Photos', 'Settings']) {
          await tester.tap(find.text(tab));
          await tester.pump(const Duration(milliseconds: 400));
        }
        expect(tester.takeException(), isNull);
      });
    });
  });

  group('active session', () {
    testWidgets('lists the Push template and its schemes', (tester) async {
      final id = await WorkoutRepository(db).startSessionFromTemplate('push');
      await withScreen(tester, ActiveSessionScreen(sessionId: id), () async {
        expect(find.text('Push'), findsOneWidget);
        expect(find.text('Incline DB Press'), findsOneWidget);
        expect(find.text('4×5–6'), findsOneWidget);
        // The Finish button is pinned regardless of scroll position.
        expect(find.text('Finish workout'), findsOneWidget);
      });
    });

    testWidgets('opens the wheel-picker sheet from a set row', (tester) async {
      final id = await WorkoutRepository(db).startSessionFromTemplate('push');
      await withScreen(tester, ActiveSessionScreen(sessionId: id), () async {
        await tester.tap(find.text('Start').first);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Two big numeral wheels (weight × reps) plus the RPE row.
        expect(find.byType(NumberWheel), findsNWidgets(2));
        expect(find.text('REPS'), findsOneWidget);
        expect(find.text('HOW DID IT FEEL?'), findsOneWidget);
        expect(
          find.descendant(
            of: find.byType(SetLoggerSheet),
            matching: find.byType(VoltButton),
          ),
          findsOneWidget,
        );
      });
    });

    testWidgets('the ↑ WEIGHT flag reaches the session UI', (tester) async {
      final repo = WorkoutRepository(db);
      final first = await repo.startSessionFromTemplate('push');
      for (var i = 0; i < 4; i++) {
        await repo.logSet(
          sessionId: first,
          exerciseId: 'incline-db-press',
          weightKg: 30,
          reps: 6,
        );
      }
      await repo.finishSession(first);
      final second = await repo.startSessionFromTemplate('push');

      await withScreen(
        tester,
        ActiveSessionScreen(sessionId: second),
        () async {
          expect(find.text('↑ WEIGHT'), findsOneWidget);
        },
      );
    });

    testWidgets('ghost values from last session are shown', (tester) async {
      final repo = WorkoutRepository(db);
      final first = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: first,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 5,
      );
      await repo.finishSession(first);
      final second = await repo.startSessionFromTemplate('push');

      await withScreen(
        tester,
        ActiveSessionScreen(sessionId: second),
        () async {
          expect(find.text('30 kg × 5'), findsWidgets);
          expect(find.text('last time'), findsWidgets);
        },
      );
    });

    testWidgets('renders the Pull session with its primary lift', (
      tester,
    ) async {
      final id = await WorkoutRepository(db).startSessionFromTemplate('pull');
      await withScreen(tester, ActiveSessionScreen(sessionId: id), () async {
        expect(find.text('Pull'), findsOneWidget);
        expect(find.text('Weighted Pull-ups'), findsOneWidget);
        expect(find.text('Finish workout'), findsOneWidget);
      });
    });
  });

  group('session summary', () {
    testWidgets('shows duration, tonnage, sets and PRs', (tester) async {
      final repo = WorkoutRepository(db);
      final id = await repo.startSessionFromTemplate('push');
      await repo.logSet(
        sessionId: id,
        exerciseId: 'incline-db-press',
        weightKg: 30,
        reps: 10,
      );
      await repo.finishSession(id);

      await withScreen(tester, SessionSummaryScreen(sessionId: id), () async {
        expect(find.text('Duration'), findsOneWidget);
        expect(find.text('Tonnage'), findsOneWidget);
        // 300 kg shows as both the session tonnage and the exercise tonnage.
        expect(find.text('300 kg'), findsWidgets);
        expect(find.text('Sets'), findsOneWidget);
        expect(find.text('PRs'), findsOneWidget);
      });
    });
  });

  group('other screens', () {
    testWidgets('progress renders all four tabs', (tester) async {
      await withScreen(tester, const ProgressScreen(), () async {
        expect(find.text('Exercises'), findsOneWidget);
        expect(find.text('Muscles'), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);
        expect(find.text('Photos'), findsOneWidget);

        for (final tab in ['Muscles', 'Body', 'Photos']) {
          await tester.tap(find.text(tab));
          await tester.pump(const Duration(milliseconds: 400));
        }
        expect(tester.takeException(), isNull);
      });
    });

    testWidgets('history shows the heatmap and the PR feed toggle', (
      tester,
    ) async {
      await withScreen(tester, const HistoryScreen(), () async {
        expect(find.text('CONSISTENCY'), findsOneWidget);

        await tester.tap(find.text('PR feed'));
        await tester.pump(const Duration(milliseconds: 300));

        expect(find.text('No PRs yet'), findsOneWidget);
      });
    });

    testWidgets('settings exposes units, rest, health, sync and export', (
      tester,
    ) async {
      await withScreen(tester, const SettingsScreen(), () async {
        // Top of the list is visible immediately.
        expect(find.text('Weight unit'), findsOneWidget);
        expect(find.text('Auto-start after each set'), findsOneWidget);

        // The rest are further down the scrolling list.
        for (final label in ['Haptics', 'Firebase sync', 'Export CSV']) {
          await tester.scrollUntilVisible(
            find.text(label),
            300,
            maxScrolls: 20,
          );
          expect(find.text(label), findsOneWidget);
        }
      });
    });

    testWidgets('switching to lb persists the unit', (tester) async {
      await withScreen(tester, const SettingsScreen(), () async {
        await tester.tap(find.text('LB'));
        await tester.pump(const Duration(milliseconds: 300));

        final settings = await SettingsRepository(db).read();
        expect(settings.unit.label, 'lb');
      });
    });
  });
}
