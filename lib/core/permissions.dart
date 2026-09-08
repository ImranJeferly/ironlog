import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';

/// Requests the runtime permissions the app uses, all up front when it opens.
/// Every request is guarded — a denial (or an unsupported platform) never stops
/// the app from running; the relevant feature just stays inert until granted.
abstract final class Permissions {
  static Future<void> requestRuntime() async {
    if (kIsWeb) return;
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return;
    } on Object {
      return;
    }

    try {
      final perms = <Permission>[
        Permission.notification, // rest-timer + update alerts
        Permission.camera, // progress photos
        Permission.photos, // gallery (READ_MEDIA_IMAGES on Android 13+)
        Permission.microphone, // voice messages
      ];
      try {
        if (Platform.isAndroid) {
          perms.add(Permission.activityRecognition); // step syncing
        }
      } on Object {
        // Platform check unavailable — skip the Android-only permission.
      }
      await perms.request();
    } on Object catch (e) {
      debugPrint('IronLog: runtime permission request failed ($e)');
    }
  }
}
