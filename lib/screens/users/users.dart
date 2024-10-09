import 'package:dip_app_2/components/user_tile.dart';
import 'package:dip_app_2/screens/chat/chat.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/chat/chat_service.dart';
import 'package:flutter/material.dart';

class UsersPage extends StatelessWidget {
  
  UsersPage({super.key});

  // chat & auth service
  final ChatService _chatService = ChatService();
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Users"),
        backgroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
      ),
      body: _buildUserList(),
    );
  }

  // build a list of users except for the current logged in user
  Widget _buildUserList() {
    return StreamBuilder(
      stream: _chatService.getUsersStream(), 
      builder: (context, snapshot) {
        // error
        if (snapshot.hasError) {
          // Display the actual error message
          return Center(
            child: Text(
              'Error: ${snapshot.error}', // Show the error
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        // loading...
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        // check if data exists
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Center(
            child: Text('No users found'), // Handle empty state
          );
        }

        // return list view
        return ListView(
          children: snapshot.data!.map<Widget>((userData) => _buildUserListItem(userData, context)).toList(),
        );
      },
    );
  }

  // build individual list tile for user
  Widget _buildUserListItem(
    Map<String, dynamic> userData, BuildContext context) {
    //display all users except current user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return UserTile(
      text: userData["email"], 
      onTap: () {
        //tapped on a user -> go to chat page
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatPage(
              receiverEmail: userData["email"],
              receiverID: userData["uid"],
            ),
          ),
        );
      },
    );
    } else {
      return Container();
    }
  }
}

