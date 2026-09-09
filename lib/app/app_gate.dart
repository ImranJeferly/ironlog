import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/permissions.dart';
import '../data/sync/firebase_bootstrap.dart';
import '../features/auth/auth_screen.dart';
import '../features/shell/app_shell.dart';
import 'providers.dart';

/// Decides what the app shows on open:
///  1. Requests the runtime permissions it needs (camera, gallery, notifications,
///     activity, Health Connect) up front.
///  2. Requires a real (non-anonymous) account — shows [AuthScreen] until then.
///  3. Once signed in, shows the app ([AppShell]), already syncing the account's
///     data down.
///
/// If Firebase isn't configured/available at all, it falls back to letting the
/// user in offline rather than trapping them on a login they can't complete.
class AppGate extends ConsumerStatefulWidget {
  const AppGate({super.key});

  @override
  ConsumerState<AppGate> createState() => _AppGateState();
}

class _AppGateState extends ConsumerState<AppGate> {
  bool _startedPermissions = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _requestPermissions());
  }

  Future<void> _requestPermissions() async {
    if (_startedPermissions) return;
    _startedPermissions = true;
    // Standard runtime permissions first…
    await Permissions.requestRuntime();
    if (!mounted) return;
    // …then Health Connect / Apple Health, which has its own consent screen.
    try {
      final health = ref.read(healthServiceProvider);
      final granted = await health.requestPermissions();
      if (granted) {
        // One-time backfill of step/weight history on first grant.
        final settingsRepo = ref.read(settingsRepositoryProvider);
        if (!await settingsRepo.healthHistoryImported()) {
          await health.importHistory();
          await settingsRepo.markHealthHistoryImported();
          ref.read(analyticsRevisionProvider.notifier).bump();
        }
      }
    } on Object {
      // Health stays optional — ignore denial.
    }
  }

  @override
  Widget build(BuildContext context) {
    // No Firebase project reachable → don't trap the user behind a login.
    if (!FirebaseBootstrap.isAvailable) return const AppShell();

    // Prefer the live auth stream, but fall back to the synchronously-known
    // current user so a persisted session doesn't flash the login screen.
    final streamed = ref.watch(authUserProvider).value;
    final user = streamed ?? ref.read(authServiceProvider).currentUser;

    if (user == null) return const AuthScreen();
    return const AppShell();
  }
}
