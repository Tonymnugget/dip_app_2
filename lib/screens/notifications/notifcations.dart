import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/components/my_tile.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/notifications/friend_request.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  final User? currentUser = FirebaseAuth.instance.currentUser;
  List<Map<String, String?>> friendRequestDetails = [];
  List<Map<String, dynamic>> friendHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchFriendRequests();
    _fetchFriendHistory();
  }

  Future<void> _fetchFriendRequests() async {
    if (currentUser == null) return;

    try {
      QuerySnapshot receivedRequestsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('receivedRequests')
          .limit(2)
          .get();

      List<Map<String, String?>> requestDetails = [];

      for (var doc in receivedRequestsSnapshot.docs) {
        String senderId = doc['senderId'];

        DocumentSnapshot senderSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(senderId)
            .get();

        if (senderSnapshot.exists) {
          String? senderName = senderSnapshot['name'];
          String? senderImageUrl = senderSnapshot['imageUrl'];

          if (senderName != null) {
            requestDetails.add({
              'name': senderName,
              'imageUrl': senderImageUrl,
            });
          }
        }
      }

      setState(() {
        friendRequestDetails = requestDetails;
      });
    } catch (e) {
      print('Error fetching friend requests: $e');
    }
  }

  Future<void> _fetchFriendHistory() async {
    if (currentUser == null) return;

    try {
      QuerySnapshot friendsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser!.uid)
          .collection('friends')
          .get();

      List<Map<String, dynamic>> history = [];

      for (var doc in friendsSnapshot.docs) {
        String friendId = doc.id;
        Timestamp timestamp = doc['timestamp'];

        DocumentSnapshot friendSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(friendId)
            .get();

        if (friendSnapshot.exists) {
          String friendName = friendSnapshot['name'];
          String? friendImageUrl = friendSnapshot['imageUrl'];
          DateTime date = timestamp.toDate();

          history.add({
            'name': friendName,
            'imageUrl': friendImageUrl,
            'date': date,
          });
        }
      }

      setState(() {
        friendHistory = history;
      });
    } catch (e) {
      print('Error fetching friend history: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    Map<String, List<Map<String, dynamic>>> categorizedHistory =
        _categorizeHistory(friendHistory);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Notifications',
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
      body: ListView(
        children: [
          // Friend Request tile at the top
          MyTile(
            text: 'Friend Requests',
            subtitle: friendRequestDetails.isNotEmpty
                ? friendRequestDetails.map((e) => e['name']).join(', ')
                : 'Accept or decline requests',
            leading: _buildProfileImages(),
            onTap: () {
              Navigator.push(
                context,
                CustomNavigator.createSlideRoute(FriendRequestPage()),
              ).then((_) => _fetchFriendRequests());
            },
            trailing: const Icon(Icons.arrow_forward_ios),
          ),
          // Friend history sections
          _buildSection('Today', categorizedHistory['Today'] ?? []),
          _buildSection('Last 7 days', categorizedHistory['Last 7 days'] ?? []),
          _buildSection(
              'Last 30 days', categorizedHistory['Last 30 days'] ?? []),
          _buildSection('Older', categorizedHistory['Older'] ?? []),
        ],
      ),
    );
  }

  Map<String, List<Map<String, dynamic>>> _categorizeHistory(
      List<Map<String, dynamic>> history) {
    Map<String, List<Map<String, dynamic>>> categorized = {
      'Today': [],
      'Last 7 days': [],
      'Last 30 days': [],
      'Older': [],
    };

    DateTime now = DateTime.now();
    DateTime todayStart = DateTime(now.year, now.month, now.day);
    DateTime weekAgo = now.subtract(Duration(days: 7));
    DateTime monthAgo = now.subtract(Duration(days: 30));

    for (var entry in history) {
      DateTime date = entry['date'];

      if (date.isAfter(todayStart)) {
        categorized['Today']!.add(entry);
      } else if (date.isAfter(weekAgo)) {
        categorized['Last 7 days']!.add(entry);
      } else if (date.isAfter(monthAgo)) {
        categorized['Last 30 days']!.add(entry);
      } else {
        categorized['Older']!.add(entry);
      }
    }

    return categorized;
  }

  Widget _buildSection(String title, List<Map<String, dynamic>> entries) {
    if (entries.isEmpty) return SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...entries.map((entry) => ListTile(
              leading: CircleAvatar(
                backgroundImage: entry['imageUrl'] != null
                    ? NetworkImage(entry['imageUrl'])
                    : null,
                backgroundColor: Colors.grey,
                child: entry['imageUrl'] == null
                    ? Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(entry['name']),
              subtitle: Text(
                'You became friends on ${DateFormat('MMM dd, yyyy').format(entry['date'])}',
              ),
            )),
      ],
    );
  }

  Widget _buildProfileImages() {
    if (friendRequestDetails.isEmpty) {
      return CircleAvatar(
        radius: 20,
        backgroundColor: Colors.grey,
        child: Icon(Icons.person_add_sharp, size: 20, color: Colors.white),
      );
    } else if (friendRequestDetails.length == 1) {
      return CircleAvatar(
        radius: 20,
        backgroundImage: friendRequestDetails[0]['imageUrl'] != null
            ? NetworkImage(friendRequestDetails[0]['imageUrl']!)
            : null,
        backgroundColor: Colors.grey,
        child: friendRequestDetails[0]['imageUrl'] == null
            ? Icon(Icons.person, size: 20, color: Colors.white)
            : null,
      );
    } else {
      return SizedBox(
        width: 40,
        height: 40,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: friendRequestDetails[0]['imageUrl'] != null
                    ? NetworkImage(friendRequestDetails[0]['imageUrl']!)
                    : null,
                backgroundColor: Colors.grey,
                child: friendRequestDetails[0]['imageUrl'] == null
                    ? Icon(Icons.person, size: 20, color: Colors.white)
                    : null,
              ),
            ),
            Positioned(
              right: 0,
              child: CircleAvatar(
                radius: 20,
                backgroundImage: friendRequestDetails[1]['imageUrl'] != null
                    ? NetworkImage(friendRequestDetails[1]['imageUrl']!)
                    : null,
                backgroundColor: Colors.grey,
                child: friendRequestDetails[1]['imageUrl'] == null
                    ? Icon(Icons.person, size: 20, color: Colors.white)
                    : null,
              ),
            ),
          ],
        ),
      );
    }
  }
}
