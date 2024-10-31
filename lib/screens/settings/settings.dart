import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/theme/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        appBar: AppBar(
          title: Text(
            'Select Filters',
            style: TextStyle(
              fontFamily: 'Poppins',
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onPrimary,
            ),
          ),
          backgroundColor: Theme.of(context).colorScheme.primary,
          centerTitle: true,
          iconTheme: IconThemeData(
            color: Theme.of(context).colorScheme.tertiary,
          ),
        ),
        bottomNavigationBar: MyNavigationBar(),

        // body
        body: Column(
          children: [
            // Dark mode tile
            ListTile(
              title: Text("dark mode"),
              trailing: Switch.adaptive(
                onChanged: (value) =>
                    Provider.of<ThemeProvider>(context, listen: false)
                        .toggleTheme(),
                value: Provider.of<ThemeProvider>(context, listen: false)
                    .isDarkMode,
              ),
            )

            // TODO: Block User tile

            // TODO: Account settings tile
          ],
        ));
  }
}
