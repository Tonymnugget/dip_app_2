import 'package:dip_app_2/services/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HomePage extends StatelessWidget {
final User? user;

  const HomePage({super.key, this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Create an instance of AuthService
              AuthService authService = AuthService();
              await authService.signOut(context); // Call the signOut function
            },
          ),
        ],
      ),
      body: Center(
        child: Text('Hello, ${user?.email}'),
      ),
    );
  }
}