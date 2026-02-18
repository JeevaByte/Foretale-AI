import 'package:flutter/material.dart';

class AppConstants {
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 10.0;
  static const double buttonMinWidth = 140.0;
  static const double buttonMinHeight = 46.0;
  static const double cardMargin = 8.0;
}

class BrandColors {
  // Primary - Executive Ink Blue
  static const primary = Color(0xFF1B2A41);
  static const primaryLight = Color(0xFF2E4366);
  static const primaryDark = Color(0xFF121C2C);
  static const onPrimary = Color(0xFFFFFFFF);

  // Accent - Graphite Lavender (AI identity)
  static const accent = Color(0xFFA89BC7);
  static const accentDark = Color(0xFFBA94F2);

  // Neutral Tones – Platinum & Graphite
  static const backgroundLight = Color(0xFFF7F7F9);
  static const backgroundDim = Color(0xFFE6E7EC);
  static const surfaceLight = Color(0xFFFFFFFF);

  static const backgroundDark = Color(0xFF0D1017);
  static const surfaceDark = Color(0xFF161A23);
  static const surfaceElevatedDark = Color(0xFF1F2430);

  static const textPrimaryLight = Color(0xFF1B1D22);
  static const textSecondaryLight = Color(0xFF6A6E76);
  static const textPrimaryDark = Color(0xFFE9E9EC);
  static const textSecondaryDark = Color(0xFFACADB3);

  static const success = Color(0xFF3E7C59);
  static const danger = Color(0xFFB83A4B);
  static const warning = Color(0xFFB07A1F);
  static const info = Color(0xFF3D6FB4);

  // Borders & Dividers
  static const borderLight = Color(0xFFD8D9DE);
  static const borderDark = Color(0xFF4A4D55);

  // Disabled states
  static const disabledLight = Color(0xFFF1F2F4);
  static const disabledDark = Color(0xFF1A1D26);
  static const disabledText = Color(0xFF8E9096);

  // Shadows
  static const shadowLight = Color(0x14000000);
  static const shadowDark = Color(0x33000000);
}

class AppTheme {
  /// LIGHT THEME — Ink on Platinum
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: BrandColors.backgroundLight,
    canvasColor: BrandColors.backgroundLight,
    primaryColor: BrandColors.primary,
    colorScheme: ColorScheme.light(
      primary: BrandColors.primary,
      onPrimary: BrandColors.onPrimary,
      secondary: BrandColors.accent,
      onSecondary: BrandColors.primaryDark,
      background: BrandColors.backgroundLight,
      onBackground: BrandColors.textPrimaryLight,
      surface: BrandColors.surfaceLight,
      onSurface: BrandColors.textPrimaryLight,
      outline: BrandColors.borderLight,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BrandColors.surfaceLight,
      foregroundColor: BrandColors.textPrimaryLight,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: BrandColors.borderLight,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BrandColors.surfaceLight,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusSmall)),
        borderSide: BorderSide(color: BrandColors.borderLight),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusSmall)),
        borderSide: BorderSide(color: BrandColors.primary, width: 2),
      ),
      labelStyle: const TextStyle(color: BrandColors.textSecondaryLight),
      hintStyle: const TextStyle(color: BrandColors.textSecondaryLight),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.disabled)
                ? BrandColors.disabledLight
                : BrandColors.primary),
        foregroundColor: WidgetStateProperty.all(BrandColors.onPrimary),
        elevation: WidgetStateProperty.all(0),
        shape: WidgetStateProperty.all(
          RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.borderRadiusMedium),
          ),
        ),
      ),
    ),
  );

  /// DARK THEME — Platinum on Ink
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: 'Inter',
    scaffoldBackgroundColor: BrandColors.backgroundDark,
    canvasColor: BrandColors.backgroundDark,
    primaryColor: BrandColors.primaryLight,
    colorScheme: ColorScheme.dark(
      primary: BrandColors.accentDark,
      onPrimary: BrandColors.primaryDark,
      secondary: BrandColors.accent,
      background: BrandColors.backgroundDark,
      onBackground: BrandColors.textPrimaryDark,
      surface: BrandColors.surfaceDark,
      onSurface: BrandColors.textPrimaryDark,
      surfaceBright: BrandColors.surfaceLight,
      outline: BrandColors.borderDark,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: BrandColors.surfaceDark,
      foregroundColor: BrandColors.textPrimaryDark,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
    ),
    dividerTheme: const DividerThemeData(
      color: BrandColors.borderDark,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: BrandColors.surfaceElevatedDark,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusSmall)),
        borderSide: BorderSide(color: BrandColors.borderDark),
      ),
      focusedBorder: const OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(AppConstants.borderRadiusSmall)),
        borderSide: BorderSide(color: BrandColors.accentDark, width: 2),
      ),
      labelStyle: const TextStyle(color: BrandColors.textSecondaryDark),
      hintStyle: const TextStyle(color: BrandColors.textSecondaryDark),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.all(BrandColors.accentDark),
        foregroundColor: WidgetStateProperty.all(BrandColors.primaryDark),
        elevation: WidgetStateProperty.all(0),
      ),
    ),
  );
}
