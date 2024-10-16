import 'package:dip_app_2/components/my_tile.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendRequestPage extends StatelessWidget {
  // Instance of FirestoreService
  final FirestoreService firestoreService = FirestoreService();

  final User? currentUser = FirebaseAuth.instance.currentUser;

  FriendRequestPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Friend Requests",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: _buildUserList(), // Fetch and display friend requests
    );
  }

  // Fetch the list of pending friend requests from Firestore
  Widget _buildUserList() {
    if (currentUser == null) {
      return const Center(child: Text("No user logged in"));
    }

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('receivedRequests')
          .snapshots(), // Real-time stream of received requests
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text("No friend requests"));
        }

        final requestDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: requestDocs.length,
          itemBuilder: (context, index) {
            return _buildUserListItem(requestDocs[index], context);
          },
        );
      },
    );
  }

  // Build each friend request tile with Accept and Delete buttons
  Widget _buildUserListItem(DocumentSnapshot doc, BuildContext context) {
    Map<String, dynamic> requestData = doc.data() as Map<String, dynamic>;
    String senderId = requestData['senderId']; // The user who sent the request

    // Fetch sender details (you may cache this in your app to reduce Firestore reads)
    return FutureBuilder<DocumentSnapshot>(
      future:
          FirebaseFirestore.instance.collection('users').doc(senderId).get(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return const SizedBox
              .shrink(); // If the sender data doesn't exist, show nothing
        }

        Map<String, dynamic> senderData =
            snapshot.data!.data() as Map<String, dynamic>;

        return MyTile(
          text: senderData['name'] ?? 'Unknown', // Display sender's name
          leading: CircleAvatar(
            radius: 20,
            foregroundImage: senderData['imageUrl'] != null
                ? NetworkImage(senderData['imageUrl']!)
                : null,
            backgroundColor: Colors.grey,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accept button
              ElevatedButton(
                onPressed: () async {
                  final currentUserId = currentUser!.uid;
                  await firestoreService.acceptFriendRequest(
                      senderId, currentUserId);
                },
                child: const Text('Accept'),
              ),

              const SizedBox(width: 8),

              // Delete button
              ElevatedButton(
                onPressed: () async {
                  final currentUserId = currentUser!.uid;
                  await firestoreService.deleteFriendRequest(
                      senderId, currentUserId);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red, // Red for delete button
                ),
                child: const Text('Delete'),
              ),
            ],
          ),
          onTap: () {},
        );
      },
    );
  }
}
