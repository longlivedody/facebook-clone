import 'package:facebook_clone/screens/Auth/login_screen.dart';
import 'package:facebook_clone/widgets/custom_text.dart';
import 'package:flutter/material.dart';

import '../../main.dart';
import '../../services/auth_service.dart';
import 'account_setting.dart';

class MenuScreen extends StatefulWidget {
  final User user;
  final AuthService authService;

  const MenuScreen({super.key, required this.user, required this.authService});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  Widget build(BuildContext context) {
    // Determine current brightness to set the switch state
    final Brightness currentBrightness = Theme.of(context).brightness;
    final bool isDarkMode = currentBrightness == Brightness.dark;

    final Color sectionHeaderColor =
        Theme.of(context).textTheme.titleMedium?.color ??
        (isDarkMode ? Colors.tealAccent : Colors.blueAccent);

    return Scaffold(
      body: ListView(
        children: [
          // --- General Settings Section ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: CustomText(
              'General',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sectionHeaderColor,
              ),
            ),
          ),

          // --- Account Settings Section ---
          ListTile(
            leading: const Icon(Icons.account_circle),
            title: const CustomText('Account Settings'),
            subtitle: const CustomText('Manage your account details'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) {
                    return AccountSetting(
                      user: widget.user,
                      authService: widget.authService,
                    );
                  },
                ),
              );
            },
          ),
          const Divider(),

          // --- Appearance Section ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: CustomText(
              'Appearance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sectionHeaderColor,
              ),
            ),
          ),
          // --- Dark Mode Switch ---
          SwitchListTile(
            title: const CustomText('Dark Mode'),
            subtitle: CustomText(isDarkMode ? 'Enabled' : 'Disabled'),
            value: isDarkMode,
            onChanged: (bool value) {
              // Call the changeTheme method from _MyAppState
              MyApp.of(
                context,
              )?.changeTheme(value ? ThemeMode.dark : ThemeMode.light);
              // No need for setState here as MaterialApp's rebuild will update this screen
            },
            secondary: Icon(isDarkMode ? Icons.dark_mode : Icons.light_mode),
          ),
          const Divider(),

          // --- About Section ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: CustomText(
              'About',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sectionHeaderColor,
              ),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const CustomText('App Version'),
            subtitle: const CustomText('1.0.0'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const CustomText('Privacy Policy'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: CustomText('View Privacy Policy (Not Implemented)'),
                ),
              );
            },
          ),
          const Divider(),

          // --- Logout ---
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[700]),
            title: CustomText(
              'Logout',
              style: TextStyle(color: Colors.red[700]),
            ),
            onTap: () async {
              // Navigate to LoginScreen
              await widget.authService.signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (context) =>
                        LoginScreen(authService: widget.authService),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}
