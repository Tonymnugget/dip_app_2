import 'package:dip_app_2/screens/home/home.dart';
import 'package:dip_app_2/screens/profile/profile_edit.dart';
import 'package:dip_app_2/services/auth/login_or_register.dart';
import 'package:dip_app_2/screens/verification/verification.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  Future<bool> _checkProfileComplete(String uid) async {
    // Query Firestore to check if profile is complete
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists && doc.data() != null) {
      return doc.data()!['profileComplete'] ==
          true; // Check profileComplete field
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          print('Auth state changed: ${snapshot.data}');
          // If the connection state is waiting, show a loading spinner
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // User is NOT logged in
          if (snapshot.data == null) {
            return const LoginOrRegister();
          }

          // User is logged in
          User? user = snapshot.data;

          // TODO: Remove the comment to activate verify email func
          /*
          // Check if the user's email is verified
          if (user != null && !user.emailVerified) {
            // If the email is not verified, redirect to VerifyEmailPage
            return const VerifyEmailPage();
          }
          */

          if (user != null) {
            return FutureBuilder<bool>(
              future: _checkProfileComplete(user.uid),
              builder: (context, profileSnapshot) {
                if (profileSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (profileSnapshot.hasData) {
                  bool isProfileComplete = profileSnapshot.data!;

                  // If the profile is complete, go to the homepage
                  if (isProfileComplete) {
                    return const HomePage();
                  } else {
                    // If profile is incomplete, go to profile creation page
                    return ProfileEditPage();
                  }
                } else {
                  // In case something goes wrong, fallback to login/register screen
                  return const LoginOrRegister();
                }
              },
            );
          } else {
            return const LoginOrRegister(); // fallback if no user is found
          }
        },
      ),
    );
  }
}
