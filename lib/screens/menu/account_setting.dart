import 'package:facebook_clone/widgets/custom_button.dart';
import 'package:facebook_clone/widgets/custom_icon_button.dart';
import 'package:facebook_clone/widgets/custom_text.dart';
import 'package:facebook_clone/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

import '../../services/auth_services/auth_service.dart';

class AccountSetting extends StatelessWidget {
  final User user;
  final AuthService authService;

  const AccountSetting({
    super.key,
    required this.user,
    required this.authService,
  });

  @override
  Widget build(BuildContext context) {
    final TextEditingController displayNameController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();
    final TextEditingController oldPasswordController = TextEditingController();

    final String? displayName = authService.currentUser?.displayName;
    final String? email = user.email;
    displayNameController.text = displayName ?? '';
    emailController.text = email ?? '';
    bool obscureText = true;

    Future<void> updatePasswordOrUserName() async {
      {
        await authService.updateUserProfile(
          displayName: displayNameController.text,
        );
        if (passwordController.text.isNotEmpty) {
          await authService.updatePassword(
            newPassword: passwordController.text,
            oldPassword: oldPasswordController.text,
          );
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Password updated successfully!')),
            );
          }
          oldPasswordController.text = '';
          passwordController.text = '';
        }
      }
    }

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CustomIconButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    iconData: Icons.arrow_back_ios_new,
                  ),
                  const SizedBox(width: 10),
                  const CustomText(
                    'Account Setting',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 15),
              CustomTextField(
                onChanged: (value) {
                  displayNameController.text = value;
                },
                controller: displayNameController,
                labelText: 'Display Name',
              ),
              const SizedBox(height: 25),
              CustomTextField(
                prefixIcon: Icons.email,
                controller: emailController,
                labelText: 'E-mail',
                enabled: false,
              ),
              const SizedBox(height: 20),
              const CustomText('Update Password'),
              const SizedBox(height: 15),
              CustomTextField(
                prefixIcon: Icons.lock,
                obscureText: true,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  oldPasswordController.text = value;
                },
                controller: oldPasswordController,
                labelText: 'Please entre your old password',
              ),
              const SizedBox(height: 15),
              CustomTextField(
                prefixIcon: Icons.lock_reset,
                obscureText: obscureText,
                keyboardType: TextInputType.visiblePassword,
                onChanged: (value) {
                  passwordController.text = value;
                },
                controller: passwordController,
                labelText: 'New Password',
              ),
              const SizedBox(height: 25),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: CustomButton(
                  onPressed: updatePasswordOrUserName,
                  text: 'Update',
                  style: const ButtonStyle(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
