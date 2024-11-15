import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class UnreadRequestsModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _unreadCount = 0;
  StreamSubscription<QuerySnapshot>? _receivedRequestsSubscription;
  StreamSubscription<User?>? _authSubscription;

  int get unreadCount => _unreadCount;

  UnreadRequestsModel() {
    // Listen to auth state changes
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      if (user != null) {
        // User is signed in
        _startListening(user.uid);
      } else {
        // User is signed out
        _stopListening();
      }
    });
  }

  void _startListening(String currentUserID) {
    // Cancel any existing subscription
    _receivedRequestsSubscription?.cancel();

    // Listen to all received friend requests where 'unread' is true
    Stream<QuerySnapshot> receivedRequestsStream = _firestore
        .collection('users')
        .doc(currentUserID)
        .collection('receivedRequests')
        .where('unread', isEqualTo: true)
        .snapshots();

    // Listen to the stream and update the unread count
    _receivedRequestsSubscription = receivedRequestsStream.listen((snapshot) {
      int unreadCount = snapshot.docs.length;
      if (_unreadCount != unreadCount) {
        _unreadCount = unreadCount;
        notifyListeners();
      }
    });
  }

  void _stopListening() {
    _receivedRequestsSubscription?.cancel();
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _receivedRequestsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
