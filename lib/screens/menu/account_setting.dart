import 'package:facebook_clone/widgets/custom_icon_button.dart';
import 'package:facebook_clone/widgets/custom_text.dart';
import 'package:facebook_clone/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';

import '../../services/auth_service.dart';

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

    final String? displayName = user.displayName;
    final String? email = user.email;
    displayNameController.text = displayName ?? '';
    emailController.text = email ?? '';

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
                  CustomText(
                    'Account Setting',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  CustomIconButton(
                    onPressed: () async {
                      await authService.updateUserProfile(
                        displayName: displayNameController.text,
                      );
                      if (passwordController.text.isNotEmpty) {
                        await authService.updatePassword(
                          passwordController.text,
                        );
                      }
                    },
                    iconData: Icons.check,
                  ),
                ],
              ),
              SizedBox(height: 15),
              CustomTextField(
                onChanged: (value) {
                  displayNameController.text = value;
                },
                controller: displayNameController,
                labelText: 'Display Name',
              ),
              SizedBox(height: 25),
              CustomTextField(
                controller: emailController,
                labelText: 'E-mail',
                enabled: false,
              ),
              SizedBox(height: 20),
              CustomText('Update Password'),
              SizedBox(height: 15),
              CustomTextField(
                onChanged: (value) {
                  passwordController.text = value;
                },
                controller: passwordController,
                labelText: 'Password',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
