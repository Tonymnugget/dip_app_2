import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  bool isAuthentication = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Center(
            child: ElevatedButton.icon(
              onPressed: () async {
                try {
                  final OAuthProvider provider = OAuthProvider("microsoft.com");
                  provider.setCustomParameters(
                    {"tenant": "77715af5-84fe-413b-b323-d4ec6a53a90f"});

                  await FirebaseAuth.instance.signInWithProvider(provider);
                } catch (e) {
                  // You can also show an error message to the user
                  }
              },
              label: const Text("Sign In with Microsoft"),
            ),
          ),
          const SizedBox(height:10),
        ],
      ),
    );
  }
}