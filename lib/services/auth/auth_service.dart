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

  Future<UserCredential?> signup(String name, email, password) async {
    
    // Define the RegExp to match 'username@e.ntu.edu.sg'
    final RegExp emailRegex = RegExp(r'^[A-Za-z0-9]+@e\.ntu\.edu\.sg$', caseSensitive: false);

    // Trim email to avoid leading/trailing whitespaces
    email = email.trim();

    // Validate email format
    if (emailRegex.hasMatch(email)) {
      try {
        // create user
        UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password
        );

        // Force reload the current user to ensure user state is updated
        await userCredential.user!.reload();
        User? updatedUser = _auth.currentUser;
        final uid = updatedUser?.uid;

        print("Updated User UID after reload: $uid");

        // Ensure uid is not null
        if (uid != null) {
          // save user in Firestore
          _firestore.collection("users").doc(uid).set({
            'email': email
          }); 

          await Future.delayed(Duration(milliseconds: 5000));  // Add a small delay

          _firestore.collection("users").doc(uid).set({
            'uid': uid,
            'name': name,
            'profileComplete': false,
          },
          SetOptions(merge: true)  // Add this to merge data instead of overwriting
          ); 

        } else {
          throw Exception("Failed to retrieve UID");
        }
        
        return userCredential;

      } on FirebaseAuthException catch(e) {
          String message = '';
          if (e.code == 'weak-password') {
            message = 'The password provided is too weak.';
          } else if (e.code == 'email-already-in-use') {
            message = 'An account already exists with that email.';
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
      } else {
          print('Invalid email format: $email'); // Debugging statement
          Fluttertoast.showToast(
            msg: 'Invalid email format',
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.SNACKBAR,
            backgroundColor: Colors.black54,
            textColor: Colors.white,
            fontSize: 14.0,
          ); 
        return null;
      }
      return null;
    }



  Future<UserCredential?> signin(String email, password) async { 
    try {
      // Sign user in 
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password
      );

      // Save user info if it doesn't already exist (with merge)
      await _firestore.collection("users").doc(userCredential.user!.uid).set(
        {
          'uid': userCredential.user!.uid,
          'email': email,
        },
        SetOptions(merge: true)  // Add this to merge data instead of overwriting
      );
      
      return userCredential;
    
    } on FirebaseAuthException catch (e) {
      String message = '';
      if (e.code == 'invalid-email') {
        message = 'No user found for that email.';
      } else if (e.code == 'invalid-credential') {
        message = 'Wrong password provided for that user.';
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
