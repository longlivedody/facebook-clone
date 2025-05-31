import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._(); // Private constructor to prevent instantiation

  // --- Light Theme Colors ---
  static final Color _lightPrimary = Colors.blue.shade700;
  static final Color _lightOnPrimary = Colors.white;
  static final Color _lightPrimaryContainer =
      Colors.blue.shade100; // Lighter variant for containers
  static final Color _lightOnPrimaryContainer =
      Colors.blue.shade900; // For text/icons on primaryContainer
  static final Color _lightSecondary = Colors.lightBlue.shade300;
  static final Color _lightOnSecondary = Colors.black;
  static final Color _lightSurface = Colors.white;
  static final Color _lightOnSurface = Colors.black;
  static final Color _lightError = Colors.red.shade700;
  static final Color _lightOnError = Colors.white;
  static final Color _lightOutline =
      Colors.grey.shade400; // For borders, dividers
  static final Color _lightScafooldBackground =
      Colors.grey.shade50; // Slightly off-white

  // --- Dark Theme Colors ---
  static final Color _darkPrimary = Colors.blue.shade300;
  static final Color _darkOnPrimary = Colors.black;
  static final Color _darkPrimaryContainer =
      Colors.blue.shade700; // Darker variant for containers
  static final Color _darkOnPrimaryContainer =
      Colors.blue.shade50; // For text/icons on primaryContainer
  static final Color _darkSecondary = Colors.blue.shade700;
  static final Color _darkOnSecondary = Colors.white;
  static final Color _darkSurface = Colors.grey.shade800;
  static final Color _darkOnSurface = Colors.white;
  static final Color _darkError = Colors.redAccent.shade200;
  static final Color _darkOnError = Colors.black;
  static final Color _darkOutline =
      Colors.grey.shade700; // For borders, dividers
  static final Color _darkScaffoldBackground = Colors.grey.shade900;

  // --- Common Text Styles (can be shared or overridden) ---
  static const _baseTextStyle =
      TextStyle(fontFamily: 'YourAppFont'); // Example: Define a base font

  static final TextTheme _lightTextTheme = TextTheme(
    displayLarge: _baseTextStyle.copyWith(
        fontSize: 32.0, fontWeight: FontWeight.bold, color: _lightOnSurface),
    headlineMedium: _baseTextStyle.copyWith(
        fontSize: 24.0, fontWeight: FontWeight.w600, color: _lightOnSurface),
    bodyLarge: _baseTextStyle.copyWith(
        fontSize: 16.0, color: _lightOnSurface.withAlpha((0.87 * 255).round())),
    // CHANGED
    bodyMedium: _baseTextStyle.copyWith(
        fontSize: 14.0, color: _lightOnSurface.withAlpha((0.75 * 255).round())),
    // CHANGED
    labelLarge: _baseTextStyle.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: _lightOnPrimary), // For buttons on primary background
  ).apply(
    bodyColor: _lightOnSurface, // Default color for text if not specified
    displayColor: _lightOnSurface, // Default color for display text
  );

  static final TextTheme _darkTextTheme = TextTheme(
    displayLarge: _baseTextStyle.copyWith(
        fontSize: 32.0, fontWeight: FontWeight.bold, color: _darkOnSurface),
    headlineMedium: _baseTextStyle.copyWith(
        fontSize: 24.0, fontWeight: FontWeight.w600, color: _darkOnSurface),
    bodyLarge: _baseTextStyle.copyWith(
        fontSize: 16.0, color: _darkOnSurface.withAlpha((0.87 * 255).round())),
    // CHANGED
    bodyMedium: _baseTextStyle.copyWith(
        fontSize: 14.0, color: _darkOnSurface.withAlpha((0.75 * 255).round())),
    // CHANGED
    labelLarge: _baseTextStyle.copyWith(
        fontSize: 16.0,
        fontWeight: FontWeight.bold,
        color: _darkOnPrimary), // For buttons on primary background
  ).apply(
    bodyColor: _darkOnSurface,
    displayColor: _darkOnSurface,
  );

  // --- Light Theme Definition ---
  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    colorScheme: ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: _lightOnPrimary,
      primaryContainer: _lightPrimaryContainer,
      onPrimaryContainer: _lightOnPrimaryContainer,
      secondary: _lightSecondary,
      onSecondary: _lightOnSecondary,
      surface: _lightSurface,
      onSurface: _lightOnSurface,
      error: _lightError,
      onError: _lightOnError,
      outline: _lightOutline,
    ),
    scaffoldBackgroundColor: _lightScafooldBackground,
    appBarTheme: AppBarTheme(
      color: _lightPrimary,
      foregroundColor: _lightOnPrimary,
      elevation: 2.0,
      titleTextStyle:
          _lightTextTheme.headlineMedium?.copyWith(color: _lightOnPrimary),
    ),
    textTheme: _lightTextTheme,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _lightOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _lightPrimary, width: 2.0),
      ),
      labelStyle: _lightTextTheme.bodyMedium
          ?.copyWith(color: _lightOnSurface.withAlpha((0.6 * 255).round())),
      // CHANGED
      hintStyle: _lightTextTheme.bodyMedium
          ?.copyWith(color: _lightOnSurface.withAlpha((0.5 * 255).round())),
      // CHANGED
      filled: false,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimary,
        foregroundColor: _lightOnPrimary,
        textStyle: _lightTextTheme.labelLarge,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2.0,
      ),
    ),
    dividerTheme: DividerThemeData(color: _lightOutline, thickness: 1.0),
  );

  // --- Dark Theme Definition ---
  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: _darkOnPrimary,
      primaryContainer: _darkPrimaryContainer,
      onPrimaryContainer: _darkOnPrimaryContainer,
      secondary: _darkSecondary,
      onSecondary: _darkOnSecondary,
      surface: _darkSurface,
      onSurface: _darkOnSurface,
      error: _darkError,
      onError: _darkOnError,
      outline: _darkOutline,
    ),
    scaffoldBackgroundColor: _darkScaffoldBackground,
    appBarTheme: AppBarTheme(
      color: _darkSurface,
      foregroundColor: _darkOnSurface,
      elevation: 0,
      titleTextStyle:
          _darkTextTheme.headlineMedium?.copyWith(color: _darkOnSurface),
    ),
    textTheme: _darkTextTheme,
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _darkOutline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _darkPrimary, width: 2.0),
      ),
      labelStyle: _darkTextTheme.bodyMedium
          ?.copyWith(color: _darkOnSurface.withAlpha((0.6 * 255).round())),
      // CHANGED
      hintStyle: _darkTextTheme.bodyMedium
          ?.copyWith(color: _darkOnSurface.withAlpha((0.5 * 255).round())),
      // CHANGED
      filled: true,
      fillColor: _darkSurface
          .withBlue(((_darkSurface.b * 255.0).round() + 10).clamp(0, 255))
          .withAlpha(15),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimary,
        foregroundColor: _darkOnPrimary,
        textStyle: _darkTextTheme.labelLarge,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        elevation: 2.0,
      ),
    ),
    dividerTheme: DividerThemeData(color: _darkOutline, thickness: 1.0),
  );
}
