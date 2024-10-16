import 'package:dip_app_2/components/my_tile.dart';
import 'package:dip_app_2/screens/matching/user_details.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class FilterResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> filteredUsers; // List of filtered users

  FilterResultsPage({super.key, required this.filteredUsers});

  // Auth service instance
  final AuthService _authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Filtered Users",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: _buildUserList(context),
    );
  }

  // Build a list of filtered users except for the current logged-in user
  Widget _buildUserList(BuildContext context) {
    if (filteredUsers.isEmpty) {
      return const Center(
        child: Text('No users found with the selected filters.'),
      );
    }

    return ListView.builder(
      itemCount: filteredUsers.length,
      itemBuilder: (context, index) {
        return _buildUserListItem(filteredUsers[index], context);
      },
    );
  }

  // Build individual list tile for each user
  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Display all users except the current logged-in user
    if (userData["email"] != _authService.getCurrentUser()!.email) {
      return MyTile(
        text: userData["name"],
        leading: CircleAvatar(
          radius: 20,
          foregroundImage: userData['imageUrl'] != null
              ? NetworkImage(userData['imageUrl']!)
              : null,
          backgroundColor: Colors.grey,
        ),
        onTap: () {
          // Navigate to UserDetailsPage and pass userData
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsPage(userData: userData),
            ),
          );
        },
      );
    } else {
      return Container(); // Return empty widget for the current user
    }
  }
}
