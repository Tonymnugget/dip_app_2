import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AuthService {
  // instance of auth & firestore
  final _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // get current user
  User? getCurrentUser() {
    return _auth.currentUser;
  }

  Future<UserCredential?> signup(
      String name, String email, String password) async {
    // Define the RegExp to match 'username@e.ntu.edu.sg'
    final RegExp emailRegex =
        RegExp(r'^[A-Za-z0-9]+@e\.ntu\.edu\.sg$', caseSensitive: false);

    // Trim email to avoid leading/trailing whitespaces
    email = email.trim();

    // Validate email format
    if (!emailRegex.hasMatch(email)) {
      Fluttertoast.showToast(
        msg: 'Invalid email format. Please use your NTU email address.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return null;
    }

    // Validate name
    if (name.isEmpty) {
      print('No name entered'); // Debugging statement
      Fluttertoast.showToast(
        msg: 'Please enter your name.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return null;
    }

    try {
      // Create user
      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = userCredential.user;

      if (user != null) {
        // Update the displayName
        await user.updateDisplayName(name);

        // Save user in Firestore
        final uid = user.uid;

        // Prepare user data
        Map<String, dynamic> userData = {
          'uid': uid,
          'email': email,
          'name': name,
          'profileComplete': false,
        };

        // Write to Firestore
        await _firestore.collection("users").doc(uid).set(userData);

        // Delay to wait for document to be created on firestore
        await Future.delayed(Duration(milliseconds: 5000));

        _firestore.collection("users").doc(uid).set({
          'uid': uid,
          'name': name,
          'profileComplete': false,
        }, SetOptions(merge: true));

        return userCredential;
      } else {
        throw Exception("User creation failed.");
      }
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'weak-password') {
        message = 'The password provided is too weak.';
      } else if (e.code == 'email-already-in-use') {
        message = 'An account already exists with that email.';
      } else if (e.code == 'invalid-email') {
        message = 'The email address is not valid.';
      } else {
        message = e.message ?? 'An unexpected error occurred.';
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: 'An error occurred. Please try again later.',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
    return null;
  }

  Future<void> sendPasswordResetEmail(String email) async {
    // Define the RegExp to match 'username@e.ntu.edu.sg'
    final RegExp emailRegex =
        RegExp(r'^[A-Za-z0-9]+@e\.ntu\.edu\.sg$', caseSensitive: false);

    // Trim email to avoid leading/trailing whitespaces
    email = email.trim();

    // Validate email format
    if (!emailRegex.hasMatch(email)) {
      Fluttertoast.showToast(
        msg: 'Invalid email format',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
      return;
    }
    try {
      await _auth.sendPasswordResetEmail(email: email);
      Fluttertoast.showToast(
        msg: "A password link has been sent. Check your email.",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    } on FirebaseAuthException catch (e) {
      String message = e.code;
      if (e.code == 'invalid-email') {
        message = 'invalid email';
      }
      if (e.code == 'missing-email') {
        message = 'missing email';
      }
      if (e.code == 'user-not-found') {
        message = 'user not found';
      }
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

  Future<UserCredential?> signin(String email, password) async {
    try {
      // Sign user in
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
          email: email, password: password);

      // Save user info if it doesn't already exist (with merge)
      await _firestore.collection("users").doc(userCredential.user!.uid).set(
          {
            'uid': userCredential.user!.uid,
            'email': email,
          },
          SetOptions(
              merge: true) // Add this to merge data instead of overwriting
          );

      print(userCredential.user);

      return userCredential;
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
      } else {
        message = e.code;
      }
      Fluttertoast.showToast(
        msg: message,
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.SNACKBAR,
        backgroundColor: Colors.black54,
        textColor: Colors.white,
        fontSize: 14.0,
      );
    }
    return null;
  }

  // sign out method
  Future<void> signout() async {
    return await _auth.signOut();
  }
}
