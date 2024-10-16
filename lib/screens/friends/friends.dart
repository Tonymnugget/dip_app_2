import 'package:dip_app_2/components/my_tile.dart';
import 'package:dip_app_2/screens/chat/chat.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendsPage extends StatelessWidget {
  FriendsPage({super.key});

  // Auth service instances
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Friends",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: _buildFriendsList(),
    );
  }

  // Build a list of friends by using friendId to fetch user details
  Widget _buildFriendsList() {
    // Get current user ID
    final currentUser = _authService.getCurrentUser();

    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('friends')
          .snapshots(),
      builder: (context, snapshot) {
        // Error handling
        if (snapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${snapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        // Loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // Check if data exists
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(
            child: Text('No friends found'),
          );
        }

        // Return a list view of friends
        List<Widget> friendWidgets = snapshot.data!.docs.map<Widget>((doc) {
          String friendId =
              doc['friendId']; // Fetch friendId from the friends subcollection

          // Fetch friend data from the 'users' collection using friendId
          return FutureBuilder(
            future: FirebaseFirestore.instance
                .collection('users')
                .doc(friendId)
                .get(),
            builder: (context, userSnapshot) {
              if (userSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!userSnapshot.hasData || !userSnapshot.data!.exists) {
                return Container(); // If no data, show an empty container
              }

              // Friend data retrieved from the users collection
              Map<String, dynamic> friendData =
                  userSnapshot.data!.data() as Map<String, dynamic>;

              return _buildFriendListItem(friendData,
                  context); // Build friend list item with friendData
            },
          );
        }).toList();

        return ListView(children: friendWidgets);
      },
    );
  }

  // Build individual list tile for each friend
  Widget _buildFriendListItem(
      Map<String, dynamic> friendData, BuildContext context) {
    return MyTile(
      text: friendData["name"] ??
          friendData[
              "email"], // Display friend's name or email if name is not available
      onTap: () {
        // TODO only for debugging
        print('Tapped on ${friendData["email"]}');
      },
      leading: CircleAvatar(
        radius: 20,
        foregroundImage: friendData['imageUrl'] != null
            ? NetworkImage(friendData['imageUrl']!)
            : null,
        backgroundColor: Colors.grey,
      ),
      trailing: IconButton(
        icon: const Icon(Icons.message),
        tooltip: 'Message',
        onPressed: () {
          // Go to chat page when message icon is tapped
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatPage(
                receiverEmail: friendData["email"],
                receiverID: friendData["uid"],
                receiverName: friendData["name"],
                profileImageUrl: friendData['imageUrl'],
              ),
            ),
          );
        },
      ),
    );
  }
}
