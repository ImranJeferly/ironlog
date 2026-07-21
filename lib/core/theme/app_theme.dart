import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

/// Radii used across the app. Cards sit in the 16–20 band per the design spec.
abstract final class AppRadii {
  static const card = 20.0;
  static const cardSmall = 16.0;
  static const chip = 999.0;
  static const sheet = 28.0;
}

abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

/// Numerals are tabular everywhere so weights/reps don't jitter as they change.
const List<FontFeature> _tabular = [FontFeature.tabularFigures()];

abstract final class AppTheme {
  static ThemeData build() {
    const scheme = ColorScheme.dark(
      primary: AppColors.volt,
      onPrimary: Color(0xFF11150A),
      secondary: AppColors.chartFrom,
      onSecondary: AppColors.textPrimary,
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
      fontFamily: _fontFamily,
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 1,
        space: 1,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bg,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.4,
        ),
        systemOverlayStyle: SystemUiOverlayStyle(
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
        ),
      ),
      dialogTheme: const DialogThemeData(
        backgroundColor: AppColors.cardHigh,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadii.card)),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppColors.cardHigh,
        contentTextStyle: textTheme.bodyMedium,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? const Color(0xFF11150A)
              : AppColors.textSecondary,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected)
              ? AppColors.volt
              : AppColors.cardHigh,
        ),
        trackOutlineColor: const WidgetStatePropertyAll(AppColors.border),
      ),
      sliderTheme: const SliderThemeData(
        activeTrackColor: AppColors.volt,
        inactiveTrackColor: AppColors.cardHigh,
        thumbColor: AppColors.volt,
        overlayColor: Color(0x22D4FF00),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: AppColors.volt,
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
          borderSide: const BorderSide(color: AppColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadii.cardSmall),
          borderSide: const BorderSide(color: AppColors.volt, width: 1.5),
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
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: AppColors.border),
        ),
        textStyle: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
      ),
    );
  }

  /// `null` lets Flutter pick the platform UI font (SF Pro on iOS, Roboto on
  /// Android) which is what the design calls for; no webfont download at runtime.
  static const String? _fontFamily = null;

  static TextTheme _textTheme() {
    return const TextTheme(
      // Hero numerals — wheel picker, session tonnage, stat headline.
      displayLarge: TextStyle(
        fontSize: 72,
        fontWeight: FontWeight.w800,
        letterSpacing: -3,
        height: 1.0,
        color: AppColors.textPrimary,
        fontFeatures: _tabular,
      ),
      displayMedium: TextStyle(
        fontSize: 48,
        fontWeight: FontWeight.w800,
        letterSpacing: -2,
        height: 1.0,
        color: AppColors.textPrimary,
        fontFeatures: _tabular,
      ),
      displaySmall: TextStyle(
        fontSize: 34,
        fontWeight: FontWeight.w800,
        letterSpacing: -1.2,
        height: 1.05,
        color: AppColors.textPrimary,
        fontFeatures: _tabular,
      ),
      headlineMedium: TextStyle(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.8,
        color: AppColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.5,
        color: AppColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
        color: AppColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.textPrimary,
      ),
      bodyLarge: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: AppColors.textPrimary,
      ),
      bodyMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      bodySmall: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: AppColors.textSecondary,
      ),
      // Section eyebrows: uppercase, wide tracking.
      labelSmall: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w700,
        letterSpacing: 1.4,
        color: AppColors.textTertiary,
      ),
      labelMedium: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
        color: AppColors.textSecondary,
      ),
    );
  }
}
