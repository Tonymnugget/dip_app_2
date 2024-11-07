import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';

class UnreadMessagesModel extends ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _unreadCount = 0;
  StreamSubscription<QuerySnapshot>? _chatRoomsSubscription;
  StreamSubscription<User?>? _authSubscription;

  int get unreadCount => _unreadCount;

  UnreadMessagesModel() {
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
    _chatRoomsSubscription?.cancel();

    // Listen to all chat rooms where the current user is a participant
    Stream<QuerySnapshot> chatRoomsStream = _firestore
        .collection('chat_rooms')
        .where('participants', arrayContains: currentUserID)
        .snapshots();

    // Listen to the stream and update the unread count
    _chatRoomsSubscription = chatRoomsStream.listen((snapshot) {
      int unreadCount = 0;
      for (var doc in snapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;

        // Retrieve the 'unreadBy' field
        Map<String, dynamic>? unreadBy =
            data['unreadBy'] as Map<String, dynamic>?;

        if (unreadBy != null && unreadBy[currentUserID] == true) {
          // If 'unreadBy' exists and is true for the current user, increment count
          unreadCount++;
        }
        // If 'unreadBy' is null or false, do not increment count
      }
      if (_unreadCount != unreadCount) {
        _unreadCount = unreadCount;
        notifyListeners();
      }
    });
  }

  void _stopListening() {
    _chatRoomsSubscription?.cancel();
    _unreadCount = 0;
    notifyListeners();
  }

  @override
  void dispose() {
    _chatRoomsSubscription?.cancel();
    _authSubscription?.cancel();
    super.dispose();
  }
}
