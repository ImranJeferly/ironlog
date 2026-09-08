import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

import 'notifications.dart';

/// Runs in its own isolate while the app is in the background or dead. FCM
/// has already put the notification in the tray (the Cloud Function sends a
/// `notification` block on our channel); all that's left is the delivered
/// receipt so the sender's ticks move on. Never throws.
@pragma('vm:entry-point')
Future<void> pushBackgroundHandler(RemoteMessage message) async {
  try {
    if (Firebase.apps.isEmpty) await Firebase.initializeApp();
    await PushService.markDelivered(message.data);
  } on Object catch (e) {
    debugPrint('IronLog: background push handling failed ($e)');
  }
}

/// Firebase Cloud Messaging glue: device token registration, foreground
/// display, and turning a tapped notification into an in-app route.
///
/// The actual sending happens server-side (`functions/index.js`) whenever a
/// chat message or friend request is written — the app never needs a server
/// key.
abstract final class PushService {
  static bool _ready = false;
  static StreamSubscription<String>? _tokenSub;
  static StreamSubscription<RemoteMessage>? _foregroundSub;
  static StreamSubscription<RemoteMessage>? _openedSub;

  /// Chat currently on screen. A foreground push for it is swallowed — the
  /// screen itself shows the message and writes the seen receipt.
  static String? activeChatId;

  /// Wires up FCM once. [onToken] is called with the current token and again
  /// whenever it rotates, so the caller can store it on the profile.
  static Future<void> init({
    required Future<void> Function(String token) onToken,
  }) async {
    if (_ready) return;
    try {
      final messaging = FirebaseMessaging.instance;
      FirebaseMessaging.onBackgroundMessage(pushBackgroundHandler);
      await Notifications.ensureSocialChannel();

      _foregroundSub = FirebaseMessaging.onMessage.listen(_onForeground);
      _openedSub = FirebaseMessaging.onMessageOpenedApp.listen(_onOpened);
      // Cold start from a tapped notification.
      final initial = await messaging.getInitialMessage();
      if (initial != null) _onOpened(initial);

      _tokenSub = messaging.onTokenRefresh.listen((t) {
        unawaited(onToken(t));
      });
      final token = await messaging.getToken();
      if (token != null) await onToken(token);
      _ready = true;
    } on Object catch (e) {
      debugPrint('IronLog: push unavailable ($e)');
    }
  }

  /// Android 13+ needs the runtime prompt; older versions return granted.
  static Future<void> requestPermission() async {
    try {
      await FirebaseMessaging.instance.requestPermission();
    } on Object catch (e) {
      debugPrint('IronLog: push permission request failed ($e)');
    }
  }

  static Future<String?> currentToken() async {
    try {
      return await FirebaseMessaging.instance.getToken();
    } on Object {
      return null;
    }
  }

  /// Drops this device's token so a signed-out phone stops receiving the
  /// previous user's messages. The next sign-in mints a fresh one.
  static Future<void> forgetToken() async {
    try {
      await FirebaseMessaging.instance.deleteToken();
    } on Object catch (e) {
      debugPrint('IronLog: deleteToken failed ($e)');
    }
  }

  static Future<void> dispose() async {
    await _tokenSub?.cancel();
    await _foregroundSub?.cancel();
    await _openedSub?.cancel();
    _ready = false;
  }

  // ------------------------------------------------------------------ routes

  static String? routeFor(Map<String, dynamic> data) {
    switch (data['type']) {
      case 'chat':
        final chatId = data['chatId'] as String?;
        final friendUid = data['friendUid'] as String?;
        if (chatId == null || friendUid == null) return null;
        return Notifications.routeChat(chatId, friendUid);
      case 'friends':
        return Notifications.routeFriends;
    }
    return null;
  }

  static void _onOpened(RemoteMessage message) {
    final route = routeFor(message.data);
    if (route != null) Notifications.pendingRoute.value = route;
  }

  /// App in the foreground: Android shows nothing on its own, so mirror the
  /// push as a local notification unless that chat is already open.
  static Future<void> _onForeground(RemoteMessage message) async {
    final data = message.data;
    final chatId = data['chatId'] as String?;
    if (data['type'] == 'chat' && chatId != null && chatId == activeChatId) {
      return;
    }
    unawaited(markDelivered(data));
    final title = message.notification?.title ?? data['title'] as String?;
    final body = message.notification?.body ?? data['body'] as String?;
    if (title == null || body == null) return;
    await Notifications.showSocial(
      title: title,
      body: body,
      payload: routeFor(data),
      tag: chatId ?? 'friends',
    );
  }

  /// Writes `deliveredAt` on the message this push is about. Rules only let
  /// chat members do this, and the recipient is one.
  static Future<void> markDelivered(Map<String, dynamic> data) async {
    final chatId = data['chatId'] as String?;
    final messageId = data['messageId'] as String?;
    if (data['type'] != 'chat' || chatId == null || messageId == null) return;
    try {
      final ref = FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId);
      final snap = await ref.get();
      if (!snap.exists || snap.data()?['deliveredAt'] != null) return;
      await ref.update({'deliveredAt': FieldValue.serverTimestamp()});
    } on Object catch (e) {
      debugPrint('IronLog: delivered receipt failed ($e)');
    }
  }
}
