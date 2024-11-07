import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .tertiary, // Change the back arrow color to white
        ),
      ),
      bottomNavigationBar: MyNavigationBar(),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Appearance',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
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
      ),
    );
  }
}
