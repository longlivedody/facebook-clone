import 'package:facebook_clone/widgets/custom_button.dart';
import 'package:facebook_clone/widgets/custom_text.dart';
import 'package:facebook_clone/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

import '../layout/layout_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool obscureText = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _login() {
    if (_formKey.currentState!.validate()) {
      // Process login
      String email = _emailController.text;
      String password = _passwordController.text;
      debugPrint('Login attempt with Email: $email, Password: $password');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login Successful (Placeholder)')),
      );
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (context) {
            return const LayoutScreen();
          },
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const CustomText(
                  'Welcome Back!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 32),
                CustomTextField(
                  keyboardType: TextInputType.emailAddress,
                  prefixIcon: Icons.email,
                  controller: _emailController,
                  labelText: 'email',
                ),
                const SizedBox(height: 16),
                CustomTextField(
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
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0),
                  child: CustomButton(
                    onPressed: () {
                      _login();
                    },
                    text: 'Login',
                  ),
                ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    debugPrint('Navigate to Sign Up or Forgot Password');
                  },
                  child: const Text('Don\'t have an account? Sign Up'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
