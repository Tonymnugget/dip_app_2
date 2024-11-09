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

    if (mounted) {
      if (isEmailVerified) {
        timer?.cancel();
        // Once email is verified, navigate to the AuthWrapper
        Navigator.pushReplacementNamed(context, '/auth_wrapper');
      }
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
      ? const Center(
          child:
              CircularProgressIndicator()) // Temporary placeholder until redirection
      : Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surfaceDim,
          appBar: AppBar(
            title: Text(
              'Verify Email',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimary,
              ),
            ),
            backgroundColor: Theme.of(context).colorScheme.primary,
            centerTitle: true,
            iconTheme: IconThemeData(
              color: Theme.of(context)
                  .colorScheme
                  .tertiary, // Change the back arrow color to white
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.all(10),
            child: Center(
              child: Column(
                children: [
                  const SizedBox(height: 80),
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 25, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.email_rounded,
                      color: Theme.of(context).colorScheme.primary,
                      size: 150,
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'An Email Has Been Sent',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 28,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: const Text(
                      "To start using NTU Orbit, we need verify to your email. Please check your email and confirm it's really you.",
                      style: TextStyle(fontSize: 17),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryFixed,
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
                      backgroundColor:
                          Theme.of(context).colorScheme.secondaryFixed,
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
          ),
        );
}
