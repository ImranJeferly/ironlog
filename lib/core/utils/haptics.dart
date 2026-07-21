import 'package:flutter/services.dart';

/// Thin wrapper so haptics can be muted from Settings and stubbed in tests.
abstract final class Haptics {
  static bool enabled = true;

  static Future<void> _guard(Future<void> Function() action) async {
    if (!enabled) return;
    try {
      await action();
    } on MissingPluginException {
      // No haptics engine (tests, desktop) — silently ignore.
    }
  }

  /// Wheel picker ticking past a value.
  static Future<void> tick() => _guard(HapticFeedback.selectionClick);

  /// Set logged.
  static Future<void> impact() => _guard(HapticFeedback.mediumImpact);

  static Future<void> light() => _guard(HapticFeedback.lightImpact);

  /// PR hit / session finished.
  static Future<void> celebrate() => _guard(() async {
    await HapticFeedback.heavyImpact();
    await Future<void>.delayed(const Duration(milliseconds: 90));
    await HapticFeedback.mediumImpact();
    await Future<void>.delayed(const Duration(milliseconds: 70));
    await HapticFeedback.heavyImpact();
  });
}
