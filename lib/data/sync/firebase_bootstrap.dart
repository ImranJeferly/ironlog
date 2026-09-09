import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../../firebase_options.dart';

/// Brings Firebase up if — and only if — the app has a real project configured.
///
/// Nothing here is allowed to throw into the app: an unconfigured or
/// unreachable Firebase must leave IronLog fully usable offline, which is the
/// whole point of the local-first design.
abstract final class FirebaseBootstrap {
  static bool _available = false;
  static String? _reason;
  static String? _uid;

  /// Sentinel project id used by the checked-in placeholder `firebase_options`.
  /// Once `flutterfire configure` has run this no longer matches, so sync
  /// switches on automatically.
  static const _placeholderProjectId = 'ironlog-unconfigured';

  static bool get isAvailable => _available;

  /// Human-readable explanation shown in Settings when sync is off.
  static String? get unavailableReason => _reason;

  /// Uid of whoever is signed in right now — the single-user document root in
  /// Firestore. Live rather than cached so signing into a real account (or
  /// linking the anonymous one) immediately points sync at the right data.
  static String? get uid {
    if (!_available) return null;
    try {
      return FirebaseAuth.instance.currentUser?.uid ?? _uid;
    } on Object {
      // No Firebase app in this process (tests) — fall back to the override.
      return _uid;
    }
  }

  static Future<void> init() async {
    // The whole thing is guarded: the generated options throw
    // `UnsupportedError` on any platform that wasn't configured (e.g. iOS,
    // desktop, web when only Android is set up), and the app must still open
    // fully offline in that case rather than crash at startup.
    try {
      final options = DefaultFirebaseOptions.currentPlatform;
      if (options.projectId == _placeholderProjectId) {
        _reason = 'Firebase not configured — run `flutterfire configure`.';
        return;
      }

      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(options: options);
      }
      // Online-first, offline fallback: every read goes to the server and
      // falls back to the local cache when it can't; every write is queued
      // on disk and flushed when the network allows. Unlimited cache so the
      // fallback is the whole history, not the last 100 MB of it. Must be
      // set before the first Firestore call.
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: true,
        cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
      );
      final auth = FirebaseAuth.instance;
      final credential =
          auth.currentUser ?? (await auth.signInAnonymously()).user;
      if (credential == null) {
        _reason = 'Anonymous sign-in returned no user.';
        return;
      }
      _uid = credential.uid;
      _available = true;
      _reason = null;
    } on UnsupportedError {
      _reason = 'Firebase not configured for this platform.';
      _available = false;
    } on Object catch (e) {
      _reason = 'Firebase unavailable: $e';
      _available = false;
      debugPrint('IronLog: $_reason');
    }
  }

  /// Test seam.
  @visibleForTesting
  static void overrideForTest({required bool available, String? uid}) {
    _available = available;
    _uid = uid;
    _reason = available ? null : 'Disabled for test';
  }
}
