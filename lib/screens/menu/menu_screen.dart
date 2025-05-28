import 'package:flutter/material.dart';

import '../../main.dart';
import '../Auth/login_screen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  // bool _notificationsEnabled = true; // Keep if needed

  @override
  Widget build(BuildContext context) {
    // Determine current brightness to set the switch state
    final Brightness currentBrightness = Theme.of(context).brightness;
    final bool isDarkMode = currentBrightness == Brightness.dark;

    // Get the theme for styling section headers based on current brightness
    final Color sectionHeaderColor =
        Theme.of(context).textTheme.titleMedium?.color ??
        (isDarkMode ? Colors.tealAccent : Colors.blueAccent);

    return Scaffold(
      body: ListView(
        children: <Widget>[
          // --- General Settings Section ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
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
            title: const Text('Account Settings'),
            subtitle: const Text('Manage your account details'),
            trailing: const Icon(Icons.arrow_forward_ios),
            onTap: () {
              // Navigate
            },
          ),
          const Divider(),

          // --- Appearance Section ---
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 8.0,
            ),
            child: Text(
              'Appearance',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: sectionHeaderColor,
              ),
            ),
          ),
          SwitchListTile(
            title: const Text('Dark Mode'),
            subtitle: Text(isDarkMode ? 'Enabled' : 'Disabled'),
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
            child: Text(
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
            title: const Text('App Version'),
            subtitle: const Text('1.0.0'),
            onTap: () {},
          ),
          ListTile(
            leading: const Icon(Icons.policy),
            title: const Text('Privacy Policy'),
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('View Privacy Policy (Not Implemented)'),
                ),
              );
            },
          ),
          const Divider(),

          // --- Logout ---
          ListTile(
            leading: Icon(Icons.logout, color: Colors.red[700]),
            title: Text('Logout', style: TextStyle(color: Colors.red[700])),
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => const LoginScreen()),
                (Route<dynamic> route) => false,
              );
            },
          ),
        ],
      ),
    );
  }
}
