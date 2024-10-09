import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class VerifyEmailPage extends StatefulWidget {
  const VerifyEmailPage({super.key});

  @override
  State<VerifyEmailPage> createState() => _VerifyEmailState();
}

class _VerifyEmailState extends State<VerifyEmailPage> {
  // by default email is not verified
  bool isEmailVerified = false;

  bool canResendEmail = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    // user needs to be created before!
    isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;

    // if not verified send verification link
    if (!isEmailVerified) {
      sendVerificationLink();

      timer = Timer.periodic(
        const Duration(seconds: 3),
        (_) => checkEmailVerified(),
      );
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future checkEmailVerified() async {
    // call after email verification!
    await FirebaseAuth.instance.currentUser!.reload();
    
    setState(() {
      isEmailVerified = FirebaseAuth.instance.currentUser!.emailVerified;
    });

    if (isEmailVerified) {
      timer?.cancel();
      // Once email is verified, navigate to the AuthWrapper
      Navigator.pushReplacementNamed(context, '/auth_wrapper');
    }
  }

  Future<dynamic> sendVerificationLink() async {
    try {
      await FirebaseAuth.instance.currentUser?.sendEmailVerification();
      
      setState(() => canResendEmail = false);
      await Future.delayed(const Duration(seconds: 5));
      setState(() => canResendEmail = true);

    } catch (e) {
      String message = e.toString();
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) => isEmailVerified
    ? const Center(child: CircularProgressIndicator()) // Temporary placeholder until redirection
    : Scaffold(
      appBar: AppBar(
        title: const Text('Verify Email'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'A verification email has been sent to your email.',
              style: TextStyle(fontSize: 20),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              icon: const Icon(Icons.email, size: 32),
              label: const Text(
                'Resend Email',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: canResendEmail ? sendVerificationLink : null,
            ),
            const SizedBox(height: 8),
            TextButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(fontSize: 24),
              ),
              onPressed: () => FirebaseAuth.instance.signOut(),
            ),
          ],
        ),
      ),
    );
}
