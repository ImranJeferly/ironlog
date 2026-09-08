import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../data/social/social_models.dart';

/// Reads what the phone is playing (Spotify, YouTube Music, …) through the
/// Android media-session API. Needs the "notification access" special
/// permission, which the user grants in system settings.
abstract final class NowPlayingService {
  static const _channel = MethodChannel('ironlog/now_playing');

  static Future<bool> hasAccess() async {
    try {
      return await _channel.invokeMethod<bool>('hasAccess') ?? false;
    } on Object {
      return false;
    }
  }

  /// Opens the system "notification access" screen.
  static Future<void> requestAccess() async {
    try {
      await _channel.invokeMethod<void>('requestAccess');
    } on Object catch (e) {
      debugPrint('IronLog: now-playing settings unavailable ($e)');
    }
  }

  /// Null when nothing is playing or access isn't granted.
  static Future<NowPlaying?> current() async {
    try {
      final raw = await _channel.invokeMethod<Map<Object?, Object?>>('current');
      if (raw == null) return null;
      final title = raw['title'] as String?;
      if (title == null || title.isEmpty) return null;
      if (raw['playing'] != true) return null;
      return NowPlaying(
        title: title,
        artist: raw['artist'] as String?,
        app: raw['app'] as String?,
        updatedAt: DateTime.now(),
      );
    } on Object {
      return null;
    }
  }
}
