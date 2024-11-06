import 'package:dip_app_2/components/my_button_3.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/components/my_tile.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/matching/user_details.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:flutter/material.dart';

class BlockedUsersPage extends StatefulWidget {
  const BlockedUsersPage({super.key});

  @override
  State<BlockedUsersPage> createState() => _BlockedUsersPageState();
}

class _BlockedUsersPageState extends State<BlockedUsersPage> {
  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final currentUser = authService.getCurrentUser();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Blocked Users',
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
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : _buildBlockedUsersList(currentUser.uid),
    );
  }

  // Build a list of blocked users
  Widget _buildBlockedUsersList(String currentUserId) {
    return FutureBuilder<List<String>>(
      future: firestoreService.getBlockedUidsFromFirebase(),
      builder: (context, blockedUsersSnapshot) {
        if (blockedUsersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (blockedUsersSnapshot.hasError) {
          return Center(
            child: Text(
              'Error: ${blockedUsersSnapshot.error}',
              style: const TextStyle(color: Colors.red, fontSize: 16),
            ),
          );
        }

        // List of blocked user IDs
        List<String> blockedUserIds = blockedUsersSnapshot.data ?? [];

        if (blockedUserIds.isEmpty) {
          return const Center(
            child: Text('No blocked users found'),
          );
        }

        // Fetch blocked users' data
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('users')
              .where(FieldPath.documentId, whereIn: blockedUserIds)
              .get(),
          builder: (context, usersSnapshot) {
            if (usersSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (!usersSnapshot.hasData || usersSnapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No blocked users found'),
              );
            }

            List<Widget> blockedUserWidgets =
                usersSnapshot.data!.docs.map((doc) {
              Map<String, dynamic> userData =
                  doc.data() as Map<String, dynamic>;
              return _buildBlockedUserTile(doc.id, userData, context);
            }).toList();

            return ListView(children: blockedUserWidgets);
          },
        );
      },
    );
  }

  // Build individual list tile for each blocked user
  Widget _buildBlockedUserTile(
      String userId, Map<String, dynamic> userData, BuildContext context) {
    return MyTile(
      text: userData["name"] ?? userData["email"],
      onTap: () {
        Navigator.push(
          context,
          CustomNavigator.createSlideRoute(UserDetailsPage(userData: userData)),
        ).then((shouldRefresh) {
          if (shouldRefresh == true) {
            setState(() {}); // Refresh Blocked Users
          }
        });
      },
      leading: CircleAvatar(
        radius: 20,
        foregroundImage: userData['imageUrl'] != null
            ? NetworkImage(userData['imageUrl'])
            : null,
        backgroundColor: Colors.grey,
      ),
      trailing: MyButton3(
        text: 'unblock',
        onTap: () async {
          await firestoreService.unblockUserInFirebase(userId);
          setState(() {}); // Refresh list after unblocking
        },
        color: Color.fromARGB(255, 137, 201, 220),
      ),
    );
  }
}
