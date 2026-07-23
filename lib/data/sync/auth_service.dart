import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';

/// Email/password account management on top of the anonymous bootstrap.
///
/// The key trick: when the current user is anonymous, creating an account
/// *links* the email credential to it instead of creating a fresh user. The
/// uid — and therefore every stat already synced to Firestore under
/// `users/{uid}` — carries over to the new account untouched.
class AuthService {
  FirebaseAuth get _auth => FirebaseAuth.instance;

  bool get isAvailable => FirebaseBootstrap.isAvailable;

  User? get currentUser {
    if (!isAvailable) return null;
    try {
      return _auth.currentUser;
    } on Object {
      return null;
    }
  }

  /// Null while signed out or anonymous — a non-null value means the stats are
  /// tied to a real account the user can always get back into.
  String? get email {
    final user = currentUser;
    if (user == null || user.isAnonymous) return null;
    return user.email;
  }

  Stream<User?> authStateChanges() {
    if (!isAvailable) return Stream<User?>.value(null);
    try {
      return _auth.authStateChanges();
    } on Object {
      return Stream<User?>.value(null);
    }
  }

  /// Creates (or upgrades to) a permanent account. Returns null on success,
  /// otherwise a human-readable error.
  Future<String?> createAccount(String email, String password) async {
    if (!isAvailable) return 'Firebase is not available on this device.';
    try {
      final credential = EmailAuthProvider.credential(
        email: email,
        password: password,
      );
      final user = _auth.currentUser;
      if (user != null && user.isAnonymous) {
        // Same uid before and after — all synced stats transfer automatically.
        await user.linkWithCredential(credential);
      } else {
        await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendly(e);
    } on Object catch (e) {
      debugPrint('IronLog: createAccount failed ($e)');
      return 'Could not create the account. Check your connection.';
    }
  }

  /// Signs into an existing account. Returns null on success.
  Future<String?> signIn(String email, String password) async {
    if (!isAvailable) return 'Firebase is not available on this device.';
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendly(e);
    } on Object catch (e) {
      debugPrint('IronLog: signIn failed ($e)');
      return 'Could not sign in. Check your connection.';
    }
  }

  /// Signs out and drops back to a fresh anonymous user so sync keeps working.
  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await _auth.signOut();
      await _auth.signInAnonymously();
    } on Object catch (e) {
      debugPrint('IronLog: signOut failed ($e)');
    }
  }

  static String _friendly(FirebaseAuthException e) => switch (e.code) {
    'email-already-in-use' ||
    'credential-already-in-use' =>
      'That email already has an account — use Sign in instead.',
    'invalid-email' => 'That email address doesn\'t look right.',
    'weak-password' => 'Password too weak — use at least 6 characters.',
    'wrong-password' ||
    'invalid-credential' ||
    'user-not-found' =>
      'Wrong email or password.',
    'too-many-requests' => 'Too many attempts — try again in a minute.',
    'network-request-failed' => 'No connection — try again when online.',
    _ => 'Sign-in failed (${e.code}).',
  };
}
