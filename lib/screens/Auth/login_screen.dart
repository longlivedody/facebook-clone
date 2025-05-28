import 'package:facebook_clone/screens/Auth/signup_screen.dart';
import 'package:facebook_clone/services/auth_service.dart';
import 'package:facebook_clone/widgets/custom_button.dart';
import 'package:facebook_clone/widgets/custom_text.dart';
import 'package:facebook_clone/widgets/custom_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import FirebaseAuthException
import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  final AuthService authService;

  const LoginScreen({super.key, required this.authService});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  String? _errorMessage;
  bool _isLoading = false; // Added for loading state

  bool obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    // Validate form before proceeding
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    setState(() {
      _errorMessage = null;
      _isLoading = true; // Start loading
    });

    try {
      await widget.authService.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      // Navigation will be handled by the StreamBuilder in MyApp if successful
      // No need to set _isLoading to false here if navigation occurs
    } on FirebaseAuthException catch (e) {
      String message;
      // Map Firebase error codes to user-friendly messages
      switch (e.code) {
        case 'user-not-found':
          message = 'No user found for that email.';
          break;
        case 'wrong-password':
          message = 'Wrong password provided for that user.';
          break;
        case 'invalid-email':
          message = 'The email address is not valid.';
          break;
        case 'user-disabled':
          message = 'This user account has been disabled.';
          break;
        case 'too-many-requests':
          message = 'Too many login attempts. Please try again later.';
          break;
        case 'network-request-failed':
          message =
              'Network error. Please check your connection and try again.';
          break;
        default:
          message = 'An unexpected error occurred. Please try again.';
      }
      if (mounted) {
        // Check if the widget is still in the tree
        setState(() {
          _errorMessage = message;
        });
      }
      debugPrint(
        "Sign in failed with FirebaseAuthException: ${e.code} - ${e.message}",
      );
    } catch (e) {
      // Catch any other generic errors
      if (mounted) {
        setState(() {
          _errorMessage = 'An unexpected error occurred. Please try again.';
        });
      }
      debugPrint("Sign in failed with general error: $e");
    } finally {
      if (mounted) {
        setState(() {
          _isLoading =
              false; // Stop loading in all cases (error or if navigation doesn't happen)
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const CustomText(
                      'Welcome Back!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    CustomTextField(
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@') || !value.contains('.')) {
                          return 'Please enter a valid email address';
                        }
                        return null;
                      },
                      keyboardType: TextInputType.emailAddress,
                      prefixIcon: Icons.email,
                      controller: _emailController,
                      labelText: 'Email', // Corrected label
                    ),
                    const SizedBox(height: 16),
                    CustomTextField(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your password';
                        }
                        // You could add password length validation here if desired
                        return null;
                      },
                      controller: _passwordController,
                      labelText: 'Password',
                      obscureText: obscureText,
                      prefixIcon: Icons.lock,
                      keyboardType: TextInputType.visiblePassword,
                      suffixIcon: obscureText
                          ? Icons.visibility
                          : Icons.visibility_off,
                      onSuffixIconTap: () {
                        setState(() {
                          obscureText = !obscureText;
                        });
                      },
                    ),
                    const SizedBox(height: 16), // Added space for error message
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _errorMessage!,
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    const SizedBox(height: 10), // Adjusted space
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : CustomButton(
                              onPressed: _signIn,
                              // No need for anonymous function if types match
                              text: 'Login',
                            ),
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: _isLoading
                          ? null
                          : () {
                              // Disable button while loading
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(
                                  builder: (context) {
                                    return SignupScreen(
                                      authService: widget.authService,
                                    );
                                  },
                                ),
                              );
                              debugPrint('Navigate to Sign Up');
                            },
                      child: const Text('Don\'t have an account? Sign Up'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
