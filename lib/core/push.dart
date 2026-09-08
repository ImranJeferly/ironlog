import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'notifications.dart';

/// Friend notifications without a push server.
///
/// The Android side (`FriendPushService`) keeps Firestore listeners open on
/// this user's chats and requests and posts system notifications itself, so
/// a message, PR or session broadcast reaches the phone even when the app is
/// closed — all on the free Firebase plan. This class is the thin channel to
/// start/stop it and to hand tapped-notification routes back to Flutter.
abstract final class PushService {
  static const _channel = MethodChannel('ironlog/push');
  static bool _bound = false;

  /// Listens for routes pushed from a tapped notification while the app is
  /// already running. Safe to call more than once.
  static void bind() {
    if (_bound) return;
    _bound = true;
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'route') {
        final route = call.arguments as String?;
        if (route != null) Notifications.pendingRoute.value = route;
      }
    });
  }

  /// Route from the notification that launched the app (cold start), if any.
  static Future<String?> takePendingRoute() =>
      _invoke<String>('pendingRoute');

  /// Starts the listener service and the periodic catch-up job. No-op unless
  /// a real account is signed in (the native side checks too).
  static Future<void> start() => _invoke<void>('start');

  /// Sign-out: stop listening for the old account.
  static Future<void> stop() => _invoke<void>('stop');

  /// The chat on screen; its notifications are swallowed and dismissed.
  static Future<void> setActiveChat(String? chatId) =>
      _invoke<void>('setActiveChat', chatId);

  static Future<void> dismissChat(String chatId) =>
      _invoke<void>('dismissChat', chatId);

  static Future<bool> isBatteryExempt() async =>
      await _invoke<bool>('isBatteryExempt') ?? false;

  /// Opens the system dialog that exempts IronLog from battery optimisation —
  /// what keeps the listener alive in Doze, same as any messaging app.
  static Future<void> requestBatteryExemption() =>
      _invoke<void>('requestBatteryExemption');

  static Future<T?> _invoke<T>(String method, [Object? args]) async {
    try {
      return await _channel.invokeMethod<T>(method, args);
    } on MissingPluginException {
      return null; // Tests / non-Android.
    } on PlatformException catch (e) {
      debugPrint('IronLog: push $method failed (${e.message})');
      return null;
    }
  }
}
