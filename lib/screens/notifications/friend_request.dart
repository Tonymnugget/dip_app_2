import 'package:dip_app_2/components/my_button_3.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/components/my_tile.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/matching/user_details.dart';
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
          'Follow Requests',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context).colorScheme.tertiary,
        ),
      ),
      bottomNavigationBar: MyNavigationBar(),
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
          onTap: () {
            Navigator.push(
              context,
              CustomNavigator.createSlideRoute(
                UserDetailsPage(userData: senderData),
              ),
            );
          },
          leading: CircleAvatar(
            radius: 20,
            backgroundColor: Colors.grey,
            foregroundImage: senderData['imageUrl'] != null
                ? NetworkImage(senderData['imageUrl']!)
                : null,
            child: senderData['imageUrl'] == null
                ? const Icon(Icons.person, size: 20)
                : null,
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Accept button
              MyButton3(
                color: Color.fromARGB(255, 99, 175, 99),
                onTap: () async {
                  final currentUserId = currentUser!.uid;
                  await firestoreService.acceptFriendRequest(
                      senderId, currentUserId);
                },
                icon: Icon(
                  Icons.check,
                  color: Colors.white,
                ),
              ),

              const SizedBox(width: 8),

              // Delete button
              MyButton3(
                onTap: () async {
                  final currentUserId = currentUser!.uid;
                  await firestoreService.deleteFriendRequest(
                      senderId, currentUserId);
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.white,
                ),
                color: Color.fromARGB(255, 206, 64, 64),
              ),
            ],
          ),
        );
      },
    );
  }
}
