import 'package:dip_app_2/screens/home/home.dart';
import 'package:dip_app_2/screens/matching/friend_finder.dart';
import 'package:dip_app_2/screens/notifications/notifcations.dart';
import 'package:dip_app_2/screens/profile/profile.dart';
import 'package:dip_app_2/screens/settings/settings.dart';
import 'package:flutter/material.dart';

class MyNavigationBar extends StatelessWidget {
  const MyNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 60,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.home,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        HomePage(),
                    transitionDuration: Duration.zero, // No animation
                    reverseTransitionDuration:
                        Duration.zero, // No reverse animation
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.person,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        FriendFinderPage(),
                    transitionDuration: Duration.zero, // No animation
                    reverseTransitionDuration:
                        Duration.zero, // No reverse animation
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.explore,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        ProfilePage(),
                    transitionDuration: Duration.zero, // No animation
                    reverseTransitionDuration:
                        Duration.zero, // No reverse animation
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.notifications,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        NotificationPage(),
                    transitionDuration: Duration.zero, // No animation
                    reverseTransitionDuration:
                        Duration.zero, // No reverse animation
                  ),
                );
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.settings,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  PageRouteBuilder(
                    pageBuilder: (context, animation, secondaryAnimation) =>
                        SettingsPage(),
                    transitionDuration: Duration.zero, // No animation
                    reverseTransitionDuration:
                        Duration.zero, // No reverse animation
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
