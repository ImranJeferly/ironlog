import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Radii — deliberately hard. Brutalist surfaces are cut, not rounded.
abstract final class AppRadii {
  static const card = 6.0;
  static const cardSmall = 4.0;
  static const chip = 3.0;
  static const sheet = 12.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Font families bundled in pubspec.
abstract final class AppFonts {
  /// Sharp condensed caps — headlines, eyebrows, buttons, nav.
  static const display = 'BebasNeue';

  /// UI copy.
  static const body = 'Barlow';

  /// Dense secondary titles and table cells.
  static const condensed = 'BarlowCondensed';

  /// Numerals only: weights, reps, timers, stat headlines.
  static const numeric = 'ChakraPetch';
}

/// Numerals are tabular everywhere so weights/reps don't jitter as they change.
const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

/// Reusable text styles that aren't a good fit for the Material slots.
abstract final class AppText {
  /// Numeric readout in the tech face, tabular figures.
  static TextStyle numeric({
    double size = 24,
    FontWeight weight = FontWeight.w700,
    Color color = AppColors.textPrimary,
    double letterSpacing = -0.5,
    double height = 1.0,
  }) => TextStyle(
    fontFamily: AppFonts.numeric,
    fontSize: size,
    fontWeight: weight,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
    fontFeatures: _tabular,
  );

  /// Bebas display caps.
  static TextStyle display({
    double size = 28,
    Color color = AppColors.textPrimary,
    double letterSpacing = 0.8,
    double height = 0.95,
  }) => TextStyle(
    fontFamily: AppFonts.display,
    fontSize: size,
    fontWeight: FontWeight.w400,
    letterSpacing: letterSpacing,
    height: height,
    color: color,
  );

  /// Small tracked caps used for eyebrows and badges.
  static TextStyle eyebrow({
    double size = 13,
    Color color = AppColors.textTertiary,
    double letterSpacing = 2,
  }) => TextStyle(
    fontFamily: AppFonts.display,
    fontSize: size,
    fontWeight: FontWeight.w400,
    letterSpacing: letterSpacing,
    height: 1,
    color: color,
  );
}

abstract final class AppTheme {
  static ThemeData build() {
    const scheme = ColorScheme.dark(
      primary: AppColors.accent,
      onPrimary: AppColors.textPrimary,
      secondary: AppColors.ember,
      onSecondary: AppColors.bg,
      surface: AppColors.card,
      onSurface: AppColors.textPrimary,
      error: AppColors.danger,
      onError: AppColors.textPrimary,
      outline: AppColors.border,
    );

    final textTheme = _textTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: scheme,
      scaffoldBackgroundColor: AppColors.bg,
      canvasColor: AppColors.bg,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      splashFactory: NoSplash.splashFactory,
      textTheme: textTheme,
      fontFamily: AppFonts.body,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: const IconThemeData(color: AppColors.textPrimary, size: 22),
        titleTextStyle: AppText.display(size: 26, letterSpacing: 1),
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
      ),
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: AppColors.card,
        surfaceTintColor: Colors.transparent,
        modalBackgroundColor: AppColors.card,
        showDragHandle: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(AppRadii.sheet),
          ),
          side: BorderSide(color: AppColors.borderStrong),
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.cardHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
          side: BorderSide(color: AppColors.borderStrong),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardHigh,
        contentTextStyle: textTheme.bodyMedium?.copyWith(
          color: AppColors.textPrimary,
        ),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          side: const BorderSide(color: AppColors.borderStrong),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.textPrimary
              : AppColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.accent
              : AppColors.cardHigh,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.borderStrong),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.accent,
        inactiveTrackColor: AppColors.cardHigh,
        thumbColor: AppColors.textPrimary,
        overlayColor: Color(0x22FF1F2F),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.accent,
        linearTrackColor: AppColors.cardHigh,
        circularTrackColor: AppColors.cardHigh,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.cardHigh,
        hintStyle: const TextStyle(color: AppColors.textTertiary),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          borderSide: const BorderSide(color: AppColors.borderStrong),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          borderSide: const BorderSide(color: AppColors.accent, width: 1.5),
        ),
      ),
      iconTheme: const IconThemeData(color: AppColors.textSecondary),
      listTileTheme: const ListTileThemeData(
        iconColor: AppColors.textSecondary,
        textColor: AppColors.textPrimary,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.cardHigh,
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          border: Border.all(color: AppColors.borderStrong),
        ),
        textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),
    );
  }

  static TextTheme _textTheme() {
    return const TextTheme(
      // Hero numerals — wheel picker, session tonnage, stat headline.
      // Chakra Petch stays on numbers: it's the one thing that read as
      // "machine" in the old design.
      displayLarge: TextStyle(
        fontFamily: AppFonts.numeric,
        fontSize: 72,
        fontWeight: FontWeight.w700,
        letterSpacing: -3,
        height: 1.0,
        color: AppColors.textPrimary,
        fontFeatures: _tabular,
      ),
      displayMedium: TextStyle(
        fontFamily: AppFonts.numeric,
        fontSize: 48,
        fontWeight: FontWeight.w700,
        letterSpacing: -2,
        height: 1.0,
        color: AppColors.textPrimary,
        fontFeatures: _tabular,
      ),
      // Big titles ("PUSH A", "REST & RECOVER") — Bebas caps.
      displaySmall: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 44,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.6,
        height: 0.92,
        color: AppColors.textPrimary,
      ),
      headlineLarge: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 40,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        height: 0.95,
        color: AppColors.textPrimary,
      ),
      headlineMedium: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 30,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        height: 1.0,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 24,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.8,
        height: 1.0,
        color: AppColors.textPrimary,
      ),
      titleLarge: TextStyle(
        fontFamily: AppFonts.condensed,
        fontSize: 21,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.2,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.1,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 14.5,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 12.5,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      // Section eyebrows: Bebas caps, wide tracking.
      labelSmall: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 13,
        fontWeight: FontWeight.w400,
        letterSpacing: 2,
        height: 1,
        color: AppColors.textTertiary,
      ),
      labelMedium: TextStyle(
        fontFamily: AppFonts.body,
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      ),
      // Buttons and nav.
      labelLarge: TextStyle(
        fontFamily: AppFonts.display,
        fontSize: 17,
        fontWeight: FontWeight.w400,
        letterSpacing: 1.4,
        height: 1,
        color: AppColors.textPrimary,
      ),
    );
  }
}
