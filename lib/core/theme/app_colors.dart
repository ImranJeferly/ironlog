import 'package:flutter/material.dart';

/// IronLog palette — "iron brutalism". Near-black steel, bone-white type and
/// one blood-red accent. Dark only; there is no light theme by design.
abstract final class AppColors {
  /// Page background.
  static const bg = Color(0xFF060607);

  /// Default card / surface.
  static const card = Color(0xFF0E0E10);

  /// Raised surface (sheets, popovers, selected rows).
  static const cardHigh = Color(0xFF161618);

  /// Hairline separators and card outlines.
  static const border = Color(0xFF232326);

  /// Heavier outline for emphasised panels and dividers.
  static const borderStrong = Color(0xFF36363C);

  /// Steel grey used in hazard stripes and inactive gauges.
  static const steel = Color(0xFF3A3A40);

  /// The accent — blood red. CTAs, checkmarks, PRs, live indicators.
  ///
  /// Kept under its historical name (`volt`) so call sites read the same;
  /// [accent] is the preferred alias in new code.
  static const volt = Color(0xFFFF1F2F);
  static const accent = volt;

  /// Deeper red for large fills and pressed states.
  static const accentDeep = Color(0xFFB8101F);

  /// Accent at low opacity, pre-flattened for fill backgrounds.
  static const voltDim = Color(0xFF2A090D);

  /// Secondary heat — ember orange. Warnings, deload, stalled.
  static const ember = Color(0xFFFF6A2A);

  /// Bone white, not pure white — reads like chalk on iron.
  static const textPrimary = Color(0xFFF3F0EA);
  static const textSecondary = Color(0xFF9E9B95);
  static const textTertiary = Color(0xFF615F5B);

  static const danger = Color(0xFFFF3B4A);
  static const warning = ember;

  /// Chart gradient — red → ember, reserved for charts.
  static const chartFrom = accent;
  static const chartTo = ember;

  static const chartGradient = LinearGradient(
    colors: [chartFrom, chartTo],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const chartAreaGradient = LinearGradient(
    colors: [Color(0x55FF1F2F), Color(0x00FF6A2A)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  /// Per-muscle-group accents — a hot, industrial ramp rather than a rainbow.
  static const muscleColors = <String, Color>{
    'chest': Color(0xFFFF1F2F),
    'back': Color(0xFFFF6A2A),
    'shoulders': Color(0xFFF3F0EA),
    'biceps': Color(0xFFD9B48F),
    'triceps': Color(0xFF9E9B95),
    'legs': Color(0xFFB8101F),
    'core': Color(0xFF6E6A64),
  };

  /// Accent for a workout day, by name. The seed rows carry legacy purple /
  /// blue hexes that fight the red skin, so day colour is derived from the
  /// name instead: push = red, pull = ember, legs = bone, anything else = tan.
  static Color forTemplateName(String? name) {
    final n = (name ?? '').toLowerCase();
    if (n.startsWith('push')) return accent;
    if (n.startsWith('pull')) return ember;
    if (n.startsWith('leg')) return textPrimary;
    return const Color(0xFFD9B48F);
  }

  /// Heatmap ramp: empty → hardest day.
  static const heatEmpty = Color(0xFF141416);
  static const heatSteps = <Color>[
    Color(0xFF3A0C13),
    Color(0xFF6E111C),
    Color(0xFFB8101F),
    volt,
  ];
}
