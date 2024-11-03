import 'package:flutter/material.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            children: [
              // drawer header
              DrawerHeader(
                child: Icon(
                  Icons.favorite,
                  color: Theme.of(context).colorScheme.inversePrimary,
                ),
              ),

              const SizedBox(height: 25),

              // home tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.home,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("H O M E"),
                  onTap: () {
                    // this is already the home screen so just pop drawer
                    Navigator.pop(context);
                  },
                ),
              ),

              // profile tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("P R O F I L E"),
                  onTap: () {
                    // pop drawer
                    Navigator.pop(context);

                    // navigator to profile page
                    Navigator.pushNamed(context, '/profile');
                  },
                ),
              ),

              // users tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.person_2,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("F R I E N D S"),
                  onTap: () {
                    // pop drawer
                    Navigator.pop(context);

                    // navigator to users page
                    Navigator.pushNamed(context, '/friends');
                  },
                ),
              ),

              // settings tile
              Padding(
                padding: const EdgeInsets.only(left: 25.0),
                child: ListTile(
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.inversePrimary,
                  ),
                  title: const Text("S E T T I N G S"),
                  onTap: () {
                    // pop drawer
                    Navigator.pop(context);

                    // navigator to users page
                    Navigator.pushNamed(context, '/settings');
                  },
                ),
              ),
            ],
          ),

          // logout tile
          Padding(
            padding: const EdgeInsets.only(left: 25.0, bottom: 25.0),
            child: ListTile(
              leading: Icon(
                Icons.logout,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
              title: const Text("S I G N O U T"),
              onTap: () async {
                // pop drawer
                Navigator.pop(context);

                // sign out
                await AuthService().signout();

                Navigator.pushReplacementNamed(context, '/auth_wrapper');
              },
            ),
          ),
        ],
      ),
    );
  }
}
