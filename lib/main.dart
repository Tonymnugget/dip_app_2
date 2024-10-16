import 'package:dip_app_2/screens/friends/friends.dart';
import 'package:dip_app_2/screens/matching/filter.dart';
import 'package:dip_app_2/screens/notifications/friend_request.dart';
import 'package:dip_app_2/services/auth/auth_wrapper.dart';
import 'package:dip_app_2/services/auth/login_or_register.dart';
import 'package:dip_app_2/firebase_options.dart';
import 'package:dip_app_2/screens/home/home.dart';
import 'package:dip_app_2/screens/profile/profile.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:dip_app_2/theme/light_mode.dart' as light_theme;
import 'package:dip_app_2/theme/dark_mode.dart' as dark_theme;


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform
  );
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const AuthWrapper(),
      theme: light_theme.lightMode,
      darkTheme: dark_theme.darkMode,
      routes: {
        '/login_or_register':(context) => const LoginOrRegister(),
        '/home':(context) => const HomePage(),
        '/profile':(context) => ProfilePage(),
        '/friends':(context) => FriendsPage(),
        '/auth_wrapper': (context) => const AuthWrapper(),
        '/filter': (context) => FilterPage(),
        '/friend_request': (context) => FriendRequestPage(),
      }
    );
  }
}
