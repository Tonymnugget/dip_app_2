import 'package:dip_app_2/components/my_drawer.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/screens/notifications/notifcations.dart';
import 'package:flutter/material.dart';
import 'package:dip_app_2/components/my_icon_button.dart'; // Import the button component

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  // TODO add block user, report user, delete chat, unfriend, (if friend do not show in filter) same for block

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Home',
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

        // NotificationPage
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Notifcations',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: MyNavigationBar(),
      drawer: const MyDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.count(
          crossAxisCount: 1, // Number of buttons per row
          crossAxisSpacing: 10.0,
          mainAxisSpacing: 10.0,
          children: [
            MyIconButton(
              icon: Icons.people_alt_rounded,
              size: 60,
              onTap: () {
                Navigator.pushNamed(context, '/friend_finder');
              },
            ),
            MyIconButton(
              icon: Icons.local_dining,
              size: 60,
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}
