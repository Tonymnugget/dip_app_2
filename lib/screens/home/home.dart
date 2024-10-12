import 'package:dip_app_2/components/my_drawer.dart';
import 'package:flutter/material.dart';
import 'package:dip_app_2/components/my_icon_button.dart'; // Import the button component

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Home",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 3, // Number of buttons per row
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: [
            MyIconButton(
              icon: Icons.people_alt_rounded,
              onTap: () {
                Navigator.pushNamed(context, '/filter');
              },
            ),
            MyIconButton(
              icon: Icons.local_dining,
              onTap: () {},
            ),
            MyIconButton(
              icon: Icons.store,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
