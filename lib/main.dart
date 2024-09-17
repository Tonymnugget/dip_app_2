import 'package:dip_app_2/firebase_options.dart';
import 'package:dip_app_2/screens/home_page.dart';
import 'package:dip_app_2/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';


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
      title: 'Microsoft Auth Test',
      home: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if(snapshot.connectionState == ConnectionState.waiting) {
            // while the snapshot is waiting, show a loading spinner
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            // If user is signed in
            final user = snapshot.data;
            return HomePage(user: user);
          } else {
            // if user is not signed in
            return const LoginPage();
          }
        }
      ),
    );
  }
}
