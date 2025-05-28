import 'package:facebook_clone/consts/theme.dart';
import 'package:facebook_clone/screens/Auth/login_screen.dart';
import 'package:facebook_clone/screens/layout/layout_screen.dart';
import 'package:facebook_clone/screens/layout/splash_screen.dart';
import 'package:facebook_clone/services/auth_service.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('firebase initialized');

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  static MyAppState? of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>();

  @override
  State<MyApp> createState() => MyAppState();
}

class MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  static const String _themePreferenceKey = 'theme_preference';

  @override
  void initState() {
    super.initState();
    _loadThemePreference();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();

    String savedTheme = prefs.getString(_themePreferenceKey) ?? 'light';

    setState(() {
      if (savedTheme == 'dark') {
        _themeMode = ThemeMode.dark;
      } else {
        _themeMode = ThemeMode.light;
      }
    });
  }

  Future<void> _saveThemePreference(ThemeMode themeMode) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      _themePreferenceKey,
      themeMode.toString().split('.').last,
    );
  }

  void changeTheme(ThemeMode themeMode) {
    setState(() {
      _themeMode = themeMode;
    });
    _saveThemePreference(themeMode);
  }

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: _themeMode,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      home: StreamBuilder<User?>(
        stream: _authService.authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return SplashScreen();
            // Or a splash screen
          }
          if (snapshot.hasData && snapshot.data != null) {
            // User is logged in
            // Pass snapshot.data (which is your User object) to the home screen
            return LayoutScreen(
              user: snapshot.data!,
              authService: _authService,
            );
          }
          // User is not logged in
          return LoginScreen(authService: _authService);
        },
      ),
    );
  }
}
