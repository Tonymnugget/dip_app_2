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

  Widget _buildUserListItem(
      Map<String, dynamic> userData, BuildContext context) {
    // Check if userData contains 'email' and it is not null
    final currentUserEmail = _authService.getCurrentUser()?.email;
    if (currentUserEmail != null && userData["email"] != currentUserEmail) {
      // Ensure name and imageUrl are not null
      final userName = userData["name"] ??
          'Unknown User'; // TODO: when user don't fill the name textfield when registering run into error, does not display all the users.
      final imageUrl = userData['imageUrl'];

      return MyTile(
        text: userName,
        leading: CircleAvatar(
          radius: 20,
          foregroundImage: (imageUrl != null && imageUrl.isNotEmpty)
              ? NetworkImage(imageUrl)
              : null,
          backgroundColor: Colors.grey,
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserDetailsPage(userData: userData),
            ),
          );
        },
      );
    } else {
      return SizedBox.shrink(); // Return a widget that takes no space
    }
  }
}
