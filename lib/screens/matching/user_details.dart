import 'package:dip_app_2/components/my_button_2.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:dip_app_2/components/my_chip.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData; // Selected user data

  const UserDetailsPage({super.key, required this.userData});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  // state to track friend request status
  bool isFriendRequestSent = false;
  bool isAlreadyFriend = false;
  bool isUserBlocked = false;
  final FirestoreService firestoreService =
      FirestoreService(); // Instance of FirestoreService
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkIfFriendRequestSent();
    _checkIfAlreadyFriends();
    _checkIfUserBlocked();
  }

  // Check if a friend request has already been sent
  Future<void> _checkIfFriendRequestSent() async {
    final userId = widget.userData['uid'];
    final isSent = await firestoreService.isFriendRequestSent(userId);
    setState(() {
      isFriendRequestSent = isSent;
    });
  }

  // Check if the current user is already friends with the user in userData
  Future<void> _checkIfAlreadyFriends() async {
    final currentUserID = authService.getCurrentUser()!.uid;
    final userId = widget.userData['uid'];
    final isFriend = await firestoreService.isFriend(currentUserID, userId);
    setState(() {
      isAlreadyFriend = isFriend;
    });
  }

  // Check if the user is currently blocked
  Future<void> _checkIfUserBlocked() async {
    final userId = widget.userData['uid'];
    final blockedUids = await firestoreService.getBlockedUidsFromFirebase();

    setState(() {
      isUserBlocked = blockedUids.contains(userId);
    });
  }

  // Function to send a friend request
  Future<void> sendFriendRequest() async {
    final userId = widget.userData['uid'];

    try {
      await firestoreService.sendFriendRequest(userId);
      setState(() {
        isFriendRequestSent = true;
      });
      print('Friend request sent to ${widget.userData['name']}');
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  // Function to cancel a friend request
  Future<void> cancelFriendRequest() async {
    final userId = widget.userData['uid'];

    try {
      await firestoreService.cancelFriendRequest(userId);
      setState(() {
        isFriendRequestSent = false;
      });
      print('Friend request canceled for ${widget.userData['name']}');
    } catch (e) {
      print('Error canceling friend request: $e');
    }
  }

  // Function to block the user
  Future<void> blockUser() async {
    final userId = widget.userData['uid'];
    try {
      await firestoreService.blockUserInFirebase(userId);
      setState(() {
        isUserBlocked = true;
      });
      print('User ${widget.userData['name']} has been blocked');
    } catch (e) {
      print('Error blocking user: $e');
    }
  }

  // Function to unblock the user
  Future<void> unblockUser() async {
    final userId = widget.userData['uid'];
    try {
      await firestoreService.unblockUserInFirebase(userId);
      setState(() {
        isUserBlocked = false;
      });
      print('User ${widget.userData['name']} has been unblocked');
    } catch (e) {
      print('Error unblocking user: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          widget.userData['name'],
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            const SizedBox(height: 10),
            // Profile Card
            SizedBox(
              width: 400,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: Theme.of(context).colorScheme.secondary,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    // Profile Image and Edit Button
                    if (widget.userData['imageUrl'] != null)
                      CircleAvatar(
                        radius: 60,
                        backgroundImage:
                            NetworkImage(widget.userData['imageUrl']),
                      )
                    else
                      const CircleAvatar(
                        radius: 60,
                        child:
                            Icon(Icons.person, size: 50, color: Colors.white),
                      ),

                    const SizedBox(height: 10),
                    // Name and Course/Hall
                    Text(
                      '${widget.userData['name']},${widget.userData['year'].replaceAll('Year ', 'Y')}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                      ),
                    ),

                    Text(
                      '${widget.userData['course']}/${widget.userData['hall']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    Text(
                      '${widget.userData['studentType']} Student',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),

                    // Bio
                    if (widget.userData['bio'] != '' &&
                        widget.userData['bio'] != null)
                      Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.grey),
                          color: Theme.of(context).colorScheme.inversePrimary,
                        ),
                        child: Text(
                          '${widget.userData['bio']}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontSize: 12,
                          ),
                        ),
                      ),

                    // languages
                    const Text(
                      'Languages',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Language buttons
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var language in widget.userData['languages'])
                          MyChip(label: language),
                      ],
                    ),
                    const SizedBox(height: 10),
                    // Interests
                    const Text(
                      'Interests',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Interest buttons
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: [
                        for (var interest in widget.userData['interests'])
                          MyChip(label: interest),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            if (!isAlreadyFriend)
              MyButton2(
                  onTap: isFriendRequestSent
                      ? cancelFriendRequest
                      : sendFriendRequest,
                  color: isFriendRequestSent ? Colors.red : Colors.green,
                  text: isFriendRequestSent
                      ? 'Cancel Friend Request'
                      : 'Send Friend Request'),
            if (isAlreadyFriend)
              MyButton2(
                onTap: isUserBlocked ? unblockUser : blockUser,
                color: isUserBlocked ? Colors.red : Colors.white,
                text: isUserBlocked ? 'Unblock User' : 'Block User',
              ),
          ],
        ),
      ),
    );
  }
}
