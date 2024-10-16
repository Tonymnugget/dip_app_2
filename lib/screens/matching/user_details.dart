import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:flutter/material.dart';

class UserDetailsPage extends StatefulWidget {
  final Map<String, dynamic> userData; // Selected user data

  const UserDetailsPage({super.key, required this.userData});

  @override
  State<UserDetailsPage> createState() => _UserDetailsPageState();
}

class _UserDetailsPageState extends State<UserDetailsPage> {
  // state to track friend request status
  bool isFriendRequestSent = false;
  final FirestoreService firestoreService = FirestoreService(); // Instance of FirestoreService
  final AuthService authService = AuthService();

  @override
  void initState() {
    super.initState();
    _checkIfFriendRequestSent();
  }

  // Check if a friend request has already been sent
  Future<void> _checkIfFriendRequestSent() async {
    final userId = widget.userData['uid'];
    final isSent = await firestoreService.isFriendRequestSent(userId);
    setState(() {
      isFriendRequestSent = isSent;
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${widget.userData['name'] ?? 'User Profile'}",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Display user profile picture if available
            widget.userData['imageUrl'] != null
              ? CircleAvatar(
                  radius: 50,
                  backgroundImage: NetworkImage(widget.userData['imageUrl']),
                )
              : const CircleAvatar(
                  radius: 50,
                  child: Icon(Icons.person, size: 50),
                ),
            const SizedBox(height: 16),

            // Display user information
            Text("Name: ${widget.userData['name'] ?? 'N/A'}", style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text("Email: ${widget.userData['email'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Course: ${widget.userData['course'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Year: ${widget.userData['year'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Country: ${widget.userData['country'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Hall: ${widget.userData['hall'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Student Type: ${widget.userData['studentType'] ?? 'N/A'}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Interests: ${(widget.userData['interests'] as List<dynamic>)}", style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Languages: ${(widget.userData['languages'] as List<dynamic>)}", style: const TextStyle(fontSize: 16)),

            // Friend request button
            ElevatedButton(
              onPressed: isFriendRequestSent ? cancelFriendRequest : sendFriendRequest,
              style: ElevatedButton.styleFrom(
                backgroundColor: isFriendRequestSent ? Colors.red : Colors.green,
              ),
              child: Text(
                style: TextStyle(
                  color: Theme.of(context).colorScheme.inversePrimary
                ), 
                isFriendRequestSent ? 'Cancel Friend Request' : 'Send Friend Request'),
            ),
          ],
        ),
      ),
    );
  }
}