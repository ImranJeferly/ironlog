import 'dart:async';
import 'dart:ui' show Color;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import '../firebase_options.dart';
import 'notifications.dart';

/// Friend notifications over Firebase Cloud Messaging.
///
/// The Cloud Functions in `functions/index.js` watch chats and friend
/// requests and push to every token this phone registers under
/// `users/{uid}/fcmTokens/{token}`. Android shows those pushes itself while
/// the app is in the background or closed; while it's in the foreground FCM
/// hands them to [_onForeground] and we post a local notification instead —
/// unless the chat is already on screen.
///
/// Delivered receipts are stamped here, on arrival, which is the one thing a
/// server can't know.
abstract final class PushService {
  static const channelSocial = 'ironlog_social';

  static final _local = FlutterLocalNotificationsPlugin();
  static bool _bound = false;
  static StreamSubscription<String>? _tokenSub;
  static String? _activeChat;
  static String? _registeredToken;

  static FirebaseMessaging get _fcm => FirebaseMessaging.instance;

  static bool get _available {
    try {
      return Firebase.apps.isNotEmpty;
    } on Object {
      return false; // No Firebase in this process (tests, desktop).
    }
  }

  /// Wires message handlers. Safe to call more than once. Does nothing when
  /// Firebase isn't running in this process (tests, desktop).
  static void bind() {
    if (_bound || !_available) return;
    _bound = true;
    try {
      // App-lifetime listeners; nothing ever unbinds them.
      FirebaseMessaging.onBackgroundMessage(onBackgroundMessage);
      FirebaseMessaging.onMessage.listen(_onForeground);
      FirebaseMessaging.onMessageOpenedApp.listen(
        (m) => _route(m.data['route']),
      );
    } on Object catch (e) {
      debugPrint('IronLog: push bind failed ($e)');
    }
  }

  /// Route from the notification that launched the app (cold start), if any.
  static Future<String?> takePendingRoute() async {
    if (!_available) return null;
    try {
      final initial = await _fcm.getInitialMessage();
      return initial?.data['route'] as String?;
    } on Object {
      return null;
    }
  }

  /// Registers this phone for pushes: asks for permission, makes sure the
  /// Android channel exists, and stores the FCM token under the account.
  /// No-op unless somebody is signed in.
  static Future<void> start() async {
    if (!_available) return;
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      await _ensureChannel();
      await _fcm.requestPermission(alert: true, badge: true, sound: true);
      await _fcm.setForegroundNotificationPresentationOptions(
        alert: false,
        badge: true,
        sound: false,
      );
      final token = await _fcm.getToken();
      if (token != null) await _saveToken(user.uid, token);
      _tokenSub ??= _fcm.onTokenRefresh.listen((t) {
        final u = FirebaseAuth.instance.currentUser;
        if (u != null) unawaited(_saveToken(u.uid, t));
      });
    } on Object catch (e) {
      debugPrint('IronLog: push start failed ($e)');
    }
  }

  /// Sign-out: drop this phone's token so the old account stops reaching it.
  static Future<void> stop() async {
    if (!_available) return;
    final user = FirebaseAuth.instance.currentUser;
    try {
      final token = _registeredToken ?? await _fcm.getToken();
      if (user != null && token != null) {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .collection('fcmTokens')
            .doc(token)
            .delete();
      }
      _registeredToken = null;
      await _fcm.deleteToken();
    } on Object catch (e) {
      debugPrint('IronLog: push stop failed ($e)');
    }
  }

  /// The chat on screen; its notifications are swallowed and dismissed.
  static Future<void> setActiveChat(String? chatId) async {
    _activeChat = chatId;
    if (chatId != null) await dismissChat(chatId);
  }

  static Future<void> dismissChat(String chatId) async {
    try {
      await _local.cancel(id: _idFor(chatId), tag: chatId);
    } on Object {
      // Nothing showing.
    }
  }

  // ------------------------------------------------------------- internals

  static Future<void> _saveToken(String uid, String token) async {
    if (_registeredToken == token) return;
    _registeredToken = token;
    await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('fcmTokens')
        .doc(token)
        .set({
          'platform': defaultTargetPlatform.name,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
  }

  /// The channel the Cloud Function targets (`android.notification.channelId`).
  /// FCM won't create it; if it doesn't exist Android falls back to the
  /// default channel with default importance — no heads-up, no sound.
  static Future<void> _ensureChannel() async {
    final android = _local
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        channelSocial,
        'Friends',
        description: 'Messages, PRs and session updates from your friends.',
        importance: Importance.high,
      ),
    );
  }

  /// Foreground: Android shows nothing on its own, so post the notification
  /// ourselves — unless it's for the chat that's already open.
  static Future<void> _onForeground(RemoteMessage m) async {
    final chatId = m.data['chatId'] as String?;
    unawaited(_markDelivered(m));
    if (chatId != null && chatId == _activeChat) return;

    final n = m.notification;
    final title = n?.title ?? 'IronLog';
    final body = n?.body ?? '';
    final route = m.data['route'] as String?;
    final tag = chatId ?? (m.data['type'] as String? ?? 'friends');
    try {
      await _local.show(
        id: _idFor(tag),
        title: title,
        body: body,
        notificationDetails: NotificationDetails(
          android: AndroidNotificationDetails(
            channelSocial,
            'Friends',
            channelDescription:
                'Messages, PRs and session updates from your friends.',
            importance: Importance.high,
            priority: Priority.high,
            category: chatId != null
                ? AndroidNotificationCategory.message
                : AndroidNotificationCategory.social,
            tag: tag,
            icon: 'ic_stat_ironlog',
            color: const Color(0xFFFF1F2F),
          ),
          iOS: const DarwinNotificationDetails(),
        ),
        payload: route,
      );
    } on Object catch (e) {
      debugPrint('IronLog: foreground push failed ($e)');
    }
  }

  static void _route(Object? route) {
    if (route is String && route.isNotEmpty) {
      Notifications.pendingRoute.value = route;
    }
  }

  static int _idFor(String key) => 4000 + (key.hashCode & 0xffff);

  /// Stamps `deliveredAt` on the message that just arrived. Only the
  /// recipient may (rules), and only once.
  static Future<void> _markDelivered(RemoteMessage m) async {
    if (m.data['type'] != 'message') return;
    final chatId = m.data['chatId'] as String?;
    final messageId = m.data['messageId'] as String?;
    final me = FirebaseAuth.instance.currentUser?.uid;
    if (chatId == null || messageId == null || me == null) return;
    if (m.data['from'] == me) return;
    try {
      final ref = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);
      await FirebaseFirestore.instance.runTransaction((tx) async {
        final snap = await tx.get(ref);
        if (!snap.exists || snap.data()?['deliveredAt'] != null) return;
        tx.update(ref, {'deliveredAt': FieldValue.serverTimestamp()});
      });
    } on Object catch (e) {
      debugPrint('IronLog: delivered receipt failed ($e)');
    }
  }
}

/// Runs in a separate isolate when a push arrives while the app is in the
/// background or closed. Android has already shown the notification; all we
/// do is the delivered receipt. Must be a top-level function.
@pragma('vm:entry-point')
Future<void> onBackgroundMessage(RemoteMessage m) async {
  try {
    if (Firebase.apps.isEmpty) {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
    }
    await PushService._markDelivered(m);
  } on Object catch (e) {
    debugPrint('IronLog: background push failed ($e)');
  }
}
