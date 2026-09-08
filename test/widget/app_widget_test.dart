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
import 'package:gym/features/settings/pages/data_settings_page.dart';
import 'package:gym/features/settings/pages/session_settings_page.dart';
import 'package:gym/features/settings/pages/training_settings_page.dart';
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
        expect(find.textContaining('4×5–6'), findsOneWidget);
        // The pinned bar: big Log set for the current exercise, Finish beside.
        expect(find.textContaining('Log set'), findsWidgets);
        expect(find.text('Finish'), findsOneWidget);
      });
    });

    testWidgets('opens the wheel-picker sheet from the log button', (
      tester,
    ) async {
      final id = await WorkoutRepository(db).startSessionFromTemplate('push');
      await withScreen(tester, ActiveSessionScreen(sessionId: id), () async {
        await tester.tap(find.textContaining('Log set').first);
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
        expect(find.text('Finish'), findsOneWidget);
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
    testWidgets('progress renders its three tabs', (tester) async {
      await withScreen(tester, const ProgressScreen(), () async {
        expect(find.text('Exercises'), findsOneWidget);
        expect(find.text('Muscles'), findsOneWidget);
        expect(find.text('Body'), findsOneWidget);
        // Photos has its own bottom-nav tab — not duplicated here.
        expect(find.text('Photos'), findsNothing);

        for (final tab in ['Muscles', 'Body']) {
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

    testWidgets('settings shows the profile and one row per area', (
      tester,
    ) async {
      await withScreen(tester, const SettingsScreen(), () async {
        expect(find.text('Guest'), findsOneWidget);
        // The lower rows sit below the fold of the test viewport.
        for (final label in [
          'Training',
          'Session',
          HealthService.providerName,
          'Sync & data',
          'About',
        ]) {
          await tester.scrollUntilVisible(
            find.text(label),
            200,
            maxScrolls: 30,
          );
          expect(find.text(label), findsOneWidget, reason: label);
        }
        // The detail no longer lives here.
        expect(find.text('Weight unit'), findsNothing);
        expect(find.text('Firebase sync'), findsNothing);
      });
    });

    testWidgets('training page: schedule, units, and lb persists', (
      tester,
    ) async {
      await withScreen(tester, const TrainingSettingsPage(), () async {
        expect(find.text('Push'), findsOneWidget);
        expect(find.text('Arms'), findsOneWidget);

        // scrollUntilVisible stops once the ListView has *built* the row,
        // which can still be in the cache extent below the fold, so bring
        // it fully on-screen before tapping.
        await tester.scrollUntilVisible(
          find.text('Weight unit'),
          300,
          maxScrolls: 30,
        );
        await tester.ensureVisible(find.text('LB'));
        await tester.pump(const Duration(milliseconds: 300));
        await tester.tap(find.text('LB'));
        await tester.pump(const Duration(milliseconds: 300));

        final settings = await SettingsRepository(db).read();
        expect(settings.unit.label, 'lb');
      });
    });

    testWidgets('session page exposes the rest timer and haptics', (
      tester,
    ) async {
      await withScreen(tester, const SessionSettingsPage(), () async {
        expect(find.text('Auto-start after each set'), findsOneWidget);
        expect(find.text('Haptics'), findsOneWidget);
      });
    });

    testWidgets('data page exposes sync and export', (tester) async {
      await withScreen(tester, const DataSettingsPage(), () async {
        expect(find.text('Firebase sync'), findsOneWidget);
        expect(find.text('Export CSV'), findsOneWidget);
      });
    });
  });
}
