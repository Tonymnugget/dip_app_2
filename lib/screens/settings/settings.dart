import 'package:dip_app_2/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Settings'),
      ),
      body: Column(
        children: [
          SwitchListTile(
            title: Text('Dark Mode'),
            value: themeProvider.themeMode == ThemeMode.dark,
            onChanged: (bool isDarkMode) {
              if (isDarkMode) {
                themeProvider.toggleTheme(true);
              } else {
                themeProvider.toggleTheme(false);
              }
            },
          ),
          ListTile(
            title: Text('Use System Theme'),
            onTap: () {
              themeProvider.useSystemTheme();
            },
          ),
        ],
      ),
    );
  }
}
