import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import 'firebase_bootstrap.dart';

/// Email/password account management.
///
/// There is no anonymous tier: the app requires a real account before it
/// syncs or shows anything social, so every uid belongs to a login the user
/// can always get back into.
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

  /// Null while signed out.
  String? get email => currentUser?.email;

  Stream<User?> authStateChanges() {
    if (!isAvailable) return Stream<User?>.value(null);
    try {
      // userChanges, not authStateChanges: it also fires on profile edits
      // (e.g. a verified email landing), which the account UI reflects.
      return _auth.userChanges();
    } on Object {
      return Stream<User?>.value(null);
    }
  }

  /// Creates a permanent account. Returns null on success, otherwise a
  /// human-readable error.
  Future<String?> createAccount(String email, String password) async {
    if (!isAvailable) return 'Firebase is not available on this device.';
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
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

  /// Emails a password-reset link. Returns null on success.
  Future<String?> sendPasswordReset(String email) async {
    if (!isAvailable) return 'Firebase is not available on this device.';
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _friendly(e);
    } on Object catch (e) {
      debugPrint('IronLog: password reset failed ($e)');
      return 'Could not send the reset email. Check your connection.';
    }
  }

  /// Signs out. The app falls back to the login screen; nothing syncs until
  /// somebody signs in again.
  Future<void> signOut() async {
    if (!isAvailable) return;
    try {
      await _auth.signOut();
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
