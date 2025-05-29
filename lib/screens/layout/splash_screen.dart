import 'package:facebook_clone/services/auth_service.dart'; // Your AuthService
import 'package:flutter/material.dart';

// Assuming you have these screen imports
// import 'package:your_app/screens/layout_screen.dart';
// import 'package:your_app/screens/login_screen.dart';

import '../../widgets/custom_text.dart';
import '../Auth/login_screen.dart';
import 'layout_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  // It's good practice to instantiate your AuthService here or get it from a provider
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkLoginStatusAndNavigate();
  }

  Future<void> _checkLoginStatusAndNavigate() async {
    // Simulate a delay for the splash screen (optional)
    await Future.delayed(const Duration(seconds: 2));

    // Check Firebase Auth state using your AuthService
    final user = _authService.currentUser; // Get the current user

    if (!mounted) return; // Check if the widget is still in the tree

    if (user != null) {
      // User is logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Pass the user object and authService to LayoutScreen if needed
          builder: (context) =>
              LayoutScreen(user: user, authService: _authService),
        ),
      );
    } else {
      // User is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          // Pass the authService to LoginScreen if needed
          builder: (context) => LoginScreen(authService: _authService),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.facebook, size: 100, color: Colors.blue),
              CustomText(
                'Facebook',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
