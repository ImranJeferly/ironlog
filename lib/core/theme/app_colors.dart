import 'package:flutter/material.dart';

/// IronLog palette. Dark only — there is no light theme by design.
abstract final class AppColors {
  /// Page background.
  static const bg = Color(0xFF0A0A0F);

  /// Default card / surface.
  static const card = Color(0xFF16161D);

  /// Raised surface (sheets, popovers, selected rows).
  static const cardHigh = Color(0xFF1E1E27);

  /// Hairline separators and card outlines.
  static const border = Color(0xFF24242E);

  /// The single neon accent — CTAs, checkmarks, PRs.
  static const volt = Color(0xFFD4FF00);

  /// Volt at low opacity, pre-flattened for fill backgrounds.
  static const voltDim = Color(0xFF2A3007);

  static const textPrimary = Color(0xFFF5F5F7);
  static const textSecondary = Color(0xFF9A9AA8);
  static const textTertiary = Color(0xFF5C5C6B);

  static const danger = Color(0xFFFF4D5E);
  static const warning = Color(0xFFFFB020);

  /// Chart gradient — purple → blue, reserved for charts only.
  static const chartFrom = Color(0xFF7C5CFF);
  static const chartTo = Color(0xFF2D9CFF);

  static const chartGradient = LinearGradient(
    colors: [chartFrom, chartTo],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const chartAreaGradient = LinearGradient(
    colors: [Color(0x557C5CFF), Color(0x002D9CFF)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Per-muscle-group accents, used only inside charts and group chips.
  static const muscleColors = <String, Color>{
    'chest': Color(0xFF7C5CFF),
    'back': Color(0xFF2D9CFF),
    'shoulders': Color(0xFF00D4B8),
    'biceps': Color(0xFFFF7A45),
    'triceps': Color(0xFFFFA033),
    'legs': Color(0xFFFF4D8D),
    'core': Color(0xFFFFC53D),
  };

  /// Heatmap ramp: empty → hardest day.
  static const heatEmpty = Color(0xFF17171F);
  static const heatSteps = <Color>[
    Color(0xFF2E3A0B),
    Color(0xFF5C7415),
    Color(0xFF9DC91F),
    volt,
  ];
}
