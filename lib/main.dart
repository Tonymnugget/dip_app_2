import 'package:dip_app_2/models/unread_messages.dart';
import 'package:dip_app_2/screens/food_finder/category.dart';
import 'package:dip_app_2/screens/friends/friends.dart';
import 'package:dip_app_2/screens/matching/filter.dart';
import 'package:dip_app_2/screens/matching/friend_finder.dart';
import 'package:dip_app_2/screens/notifications/friend_request.dart';
import 'package:dip_app_2/screens/notifications/notifcations.dart';
import 'package:dip_app_2/screens/profile/profile_edit.dart';
import 'package:dip_app_2/screens/settings/settings.dart';
import 'package:dip_app_2/services/auth/auth_wrapper.dart';
import 'package:dip_app_2/services/auth/login_or_register.dart';
import 'package:dip_app_2/firebase_options.dart';
import 'package:dip_app_2/screens/home/home.dart';
import 'package:dip_app_2/screens/profile/profile.dart';
import 'package:dip_app_2/theme/dark_mode.dart';
import 'package:dip_app_2/theme/light_mode.dart';
import 'package:dip_app_2/theme/theme_provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  WidgetsFlutterBinding.ensureInitialized();

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider<ThemeProvider>(
        create: (_) => ThemeProvider()..setInitialThemeMode(),
      ),
      ChangeNotifierProvider<UnreadMessagesModel>(
        create: (_) => UnreadMessagesModel(),
      ),
    ],
    child: const MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: const AuthWrapper(),
        theme: lightMode, //Provider.of<ThemeProvider>(context).themeData
        darkTheme: darkMode,
        themeMode: themeProvider.themeMode,
        routes: {
          '/login_or_register': (context) => const LoginOrRegister(),
          '/auth_wrapper': (context) => const AuthWrapper(),
          '/home': (context) => const HomePage(),
          '/profile': (context) => ProfilePage(),
          '/friend_finder': (context) => FriendFinderPage(),
          '/filter': (context) => FilterPage(),
          '/friend_request': (context) => FriendRequestPage(),
          '/notification': (context) => NotificationPage(),
          '/friends': (context) => FriendsPage(),
          '/settings': (context) => SettingsPage(),
          '/edit_profile': (context) => ProfileEditPage(),
          '/food_finder': (context) => CategoryScreen(),
        });
  }
}
