import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static final Color _lightPrimaryColor = Colors.blue.shade700;
  static final Color _lightPrimaryVariantColor = Colors.blue.shade800;
  static final Color _lightOnPrimaryColor = Colors.white;
  static final Color _lightSecondaryColor = Colors.lightBlue.shade300;
  static final Color _lightOnSecondaryColor = Colors.black;

  static final Color _darkPrimaryColor = Colors.blue.shade300;
  static final Color _darkPrimaryVariantColor = Colors.blue.shade700;
  static final Color _darkOnPrimaryColor = Colors.black;
  static final Color _darkSecondaryColor = Colors.blue.shade700;
  static final Color _darkOnSecondaryColor = Colors.white;

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    // Recommended for new Flutter projects
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _lightPrimaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _lightPrimaryColor, width: 2.0),
      ),
      labelStyle: TextStyle(color: _lightPrimaryColor),
      hintStyle: TextStyle(color: Colors.grey.shade500),
      // ... other input decoration defaults
    ),
    scaffoldBackgroundColor: Colors.white,
    dividerTheme: DividerThemeData(color: Colors.grey[400], thickness: 2.0),
    appBarTheme: AppBarTheme(
      color: _lightPrimaryColor,
      iconTheme: IconThemeData(color: _lightOnPrimaryColor),
      actionsIconTheme: IconThemeData(color: _lightOnPrimaryColor),
      titleTextStyle: TextStyle(
        color: _lightOnPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    colorScheme: ColorScheme.light(
      primary: _lightPrimaryColor,
      onPrimary: _lightOnPrimaryColor,
      primaryContainer: _lightPrimaryVariantColor,
      // Or a lighter shade of blue
      secondary: _lightSecondaryColor,
      onSecondary: _lightOnSecondaryColor,
      surface: Colors.white,
      onSurface: Colors.black,
      error: Colors.red,
      onError: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _lightPrimaryColor,
        foregroundColor: _lightOnPrimaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: _lightTextTheme,
    // Add other theme properties like inputDecorationTheme, cardTheme, etc.
  );

  static final ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: Colors.grey.shade900,
    appBarTheme: AppBarTheme(
      color: _darkPrimaryColor,
      iconTheme: IconThemeData(color: _darkOnPrimaryColor),
      actionsIconTheme: IconThemeData(color: Colors.white),

      titleTextStyle: TextStyle(
        color: _darkOnPrimaryColor,
        fontSize: 20,
        fontWeight: FontWeight.w500,
      ),
    ),
    colorScheme: ColorScheme.dark(
      primary: _darkPrimaryColor,
      onPrimary: _darkOnPrimaryColor,
      primaryContainer: _darkPrimaryVariantColor,
      // Or a darker shade of blue
      secondary: _darkSecondaryColor,
      onSecondary: _darkOnSecondaryColor,
      surface: Colors.grey.shade800,
      onSurface: Colors.white,
      error: Colors.redAccent,
      onError: Colors.black,
    ),
    dividerTheme: DividerThemeData(color: Colors.black, thickness: 2.0),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _darkPrimaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8.0),
        borderSide: BorderSide(color: _darkPrimaryColor, width: 2.0),
      ),
      labelStyle: TextStyle(color: Colors.white),
      hintStyle: TextStyle(color: Colors.grey.shade700),
      filled: true,
      fillColor: Colors.grey.shade800.withAlpha(50),
      // ... other input decoration defaults
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: _darkPrimaryColor,
        foregroundColor: _darkOnPrimaryColor,
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    textTheme: _darkTextTheme,
    // Add other theme properties
  );

  static const TextTheme _lightTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.black87),
    labelLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ), // For buttons
    // Define other text styles
  );

  static const TextTheme _darkTextTheme = TextTheme(
    displayLarge: TextStyle(
      fontSize: 32.0,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
    bodyLarge: TextStyle(fontSize: 16.0, color: Colors.white70),
    labelLarge: TextStyle(
      fontSize: 16.0,
      fontWeight: FontWeight.bold,
      color: Colors.black,
    ), // For buttons
    // Define other text styles
  );
}
