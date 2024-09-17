import 'package:dip_app_2/screens/login_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthService {
  Future<void> signOut(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    // Optionally navigate to the login page after signing out
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => const LoginPage()),
    );
  }
}