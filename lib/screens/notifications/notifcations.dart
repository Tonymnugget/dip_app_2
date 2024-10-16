import 'package:dip_app_2/components/my_tile.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final FirestoreService firestoreService = FirestoreService();
  final User? currentUser = FirebaseAuth.instance.currentUser;
  
  // List to hold names and imageUrls of users who sent friend requests
  List<Map<String, String?>> friendRequestDetails = []; // Holds both name and imageUrl

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
  }

  Future<void> _fetchFriendRequests() async {
    if (currentUser == null) return;

    try {
      QuerySnapshot receivedRequestsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('receivedRequests')
          .limit(2) // Limit to first 2 requests
          .get();

      List<Map<String, String?>> requestDetails = [];

      for (var doc in receivedRequestsSnapshot.docs) {
        String senderId = doc['senderId'];

        // Fetch the sender's details
        DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .get();

        if (senderSnapshot.exists) {
          // Get both the sender's name and imageUrl
          String? senderName = senderSnapshot['name'];
          String? senderImageUrl = senderSnapshot['imageUrl'];

          if (senderName != null) {
            // Add both name and imageUrl to the list as a map
            requestDetails.add({
              'name': senderName,
              'imageUrl': senderImageUrl,
            });
          }
        }
      }

      setState(() {
        friendRequestDetails = requestDetails; // Store the names and imageUrls in the state
      });
    } catch (e) {
      print('Error fetching friend requests: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Notifications",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Friend Request tile
          MyTile(
            text: 'Friend Requests', 
            subtitle: friendRequestDetails.isNotEmpty
                ? friendRequestDetails.map((e) => e['name']).join(', ') // Display the first few names
                : 'No friend requests', // Default text if no requests
            leading: friendRequestDetails.isNotEmpty
                ? _buildProfileImages() // Show stacked or single profile image(s)
                : null,
            onTap: () {
              // Go to friend request page when tile is tapped
              Navigator.pushNamed(context, '/friend_request');
            },
            trailing: IconButton(
              icon: const Icon(Icons.arrow_right),
              tooltip: 'Next page',
              onPressed: () {},
            ),
          ),
        ],
      ),
    );
  }

  // Build profile image(s) for the friend requests
  Widget _buildProfileImages() {
    if (friendRequestDetails.length == 1) {
      // Show a single profile picture if there's only one request
      return CircleAvatar(
        radius: 20,
        backgroundImage: friendRequestDetails[0]['imageUrl'] != null
            ? NetworkImage(friendRequestDetails[0]['imageUrl']!)
            : null,
        backgroundColor: Colors.grey,
      );
    } else {
      // Stack the first two profile pictures if there are multiple requests
      return SizedBox(
        width: 50,
        height: 50,
        child: Stack(
          children: [
            // Second user's image
            Positioned(
              child: CircleAvatar(
                radius: 20,
                foregroundImage: friendRequestDetails[1]['imageUrl'] != null
                    ? NetworkImage(friendRequestDetails[1]['imageUrl']!)
                    : null,
                backgroundColor: Colors.grey,
              ),
            ),
            // First user's image, slightly overlapped
            Positioned(
              left: 10, 
              top: 10,
              child: CircleAvatar(
                radius: 20,
                foregroundImage: friendRequestDetails[0]['imageUrl'] != null
                    ? NetworkImage(friendRequestDetails[0]['imageUrl']!)
                    : null,
                backgroundColor: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }
  }
}