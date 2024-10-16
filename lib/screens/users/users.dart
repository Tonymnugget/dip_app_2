import 'package:dip_app_2/components/user_tile.dart';
import 'package:dip_app_2/screens/chat/chat.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  UsersPage({super.key});

  // Chat & Auth service instances
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Users",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: _buildUserList(),
    );
  }

  // Build a list of users except for the current logged-in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(),
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
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No users found'),
          );
        }

        // Return a list view of users
        return ListView(
          children: snapshot.data!
              .map<Widget>((userData) => _buildUserListItem(userData, context))
              .toList(),
        );
      },
    );
  }

  // Build individual list tile for each user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Display all users except the current logged-in user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
        text: userData["email"],
        onTap: () {
          // Handle tile tap (optional)
          print('Tapped on ${userData["email"]}');
        },
        trailing: IconButton(
          icon: const Icon(Icons.message),
          tooltip: 'Message',
          onPressed: () {
            // Go to chat page when message icon is tapped
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatPage(
                  receiverEmail: userData["email"],
                  receiverID: userData["uid"],
                  receiverName: userData["name"],
                  profileImageUrl: userData["imageUrl"],
                ),
              ),
            );
          },
        ),
      );
    } else {
      return Container();
    }
  }
}
