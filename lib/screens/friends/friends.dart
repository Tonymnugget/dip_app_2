import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/components/my_tile.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/chat/chat.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dip_app_2/services/chat/chat_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class FriendsPage extends StatefulWidget {
  const FriendsPage({super.key});

  @override
  State<FriendsPage> createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  // Auth service instances
  final AuthService authService = AuthService();

  final ChatService chatService = ChatService();

  @override
  Widget build(BuildContext context) {
    // Get current user ID
    final currentUser = authService.getCurrentUser();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Friends',
          style: TextStyle(
            fontFamily: 'Poppins',
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.onPrimary,
          ),
        ),
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        iconTheme: IconThemeData(
          color: Theme.of(context)
              .colorScheme
              .tertiary, // Change the back arrow color to white
        ),
      ),
      bottomNavigationBar: MyNavigationBar(),
      body: currentUser == null
          ? const Center(child: CircularProgressIndicator())
          : _buildFriendsList(currentUser.uid),
    );
  }

  Future<Map<String, Map<String, dynamic>>> fetchLatestMessages(
      List<String> chatRoomIds, String currentUserId) async {
    Map<String, Map<String, dynamic>> latestMessages = {};

    for (String chatRoomId in chatRoomIds) {
      QuerySnapshot messageSnapshot = await FirebaseFirestore.instance
          .collection('chat_rooms')
          .doc(chatRoomId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .limit(1)
          .get();

      if (messageSnapshot.docs.isNotEmpty) {
        var messageData =
            messageSnapshot.docs.first.data() as Map<String, dynamic>;
        String friendId = chatRoomId
            .replaceAll('${currentUserId}_', '')
            .replaceAll('_$currentUserId', '');
        String latestMessage = messageData['message'] ?? 'No messages yet';
        Timestamp timestamp = messageData['timestamp'] ?? Timestamp.now();
        bool isUnread = messageData['isUnread'] ?? false;
        String senderID = messageData['senderID'] ?? '';

        latestMessages[friendId] = {
          'message': latestMessage,
          'timestamp': timestamp,
          'isUnread': isUnread,
          'senderID': senderID,
        };
      } else {
        // If no messages yet, set default message and current timestamp
        String friendId = chatRoomId
            .replaceAll('${currentUserId}_', '')
            .replaceAll('_$currentUserId', '');
        latestMessages[friendId] = {
          'message': 'No messages yet',
          'timestamp': null,
          'isUnread': false,
          'senderID': '',
        };
      }
    }
    return latestMessages;
  }

  // Build a list of friends and their latest messages, excluding blocked users
  Widget _buildFriendsList(String currentUserId) {
    return FutureBuilder<List<String>>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('blockedUsers')
          .get()
          .then((snapshot) => snapshot.docs
              .map((doc) => doc.id)
              .toList()), // Get list of blocked user IDs
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

        // Stream for friends excluding blocked users
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('friends')
              .snapshots(),
          builder: (context, friendsSnapshot) {
            if (friendsSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (friendsSnapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${friendsSnapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            }

            if (!friendsSnapshot.hasData ||
                friendsSnapshot.data!.docs.isEmpty) {
              return const Center(
                child: Text('No friends found'),
              );
            }

            // Filter out blocked user IDs from friend IDs
            List<String> friendIds = friendsSnapshot.data!.docs
                .map((doc) => doc['friendId'] as String)
                .where((friendId) => !blockedUserIds.contains(friendId))
                .toList();

            // Fetch friends' data
            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(FieldPath.documentId, whereIn: friendIds)
                  .get(),
              builder: (context, usersSnapshot) {
                if (usersSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!usersSnapshot.hasData ||
                    usersSnapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text('No friends found'),
                  );
                }

                // Map friend IDs to their data
                Map<String, Map<String, dynamic>> friendsData = {};
                for (var doc in usersSnapshot.data!.docs) {
                  friendsData[doc.id] = doc.data() as Map<String, dynamic>;
                }

                // Build list of chat room IDs
                List<String> chatRoomIds = friendIds
                    .map((friendId) =>
                        chatService.getChatRoomId(currentUserId, friendId))
                    .toList();

                // Fetch latest messages from chat rooms
                return FutureBuilder<Map<String, Map<String, dynamic>>>(
                  future: fetchLatestMessages(chatRoomIds, currentUserId),
                  builder: (context, messagesSnapshot) {
                    if (messagesSnapshot.connectionState ==
                        ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (messagesSnapshot.hasError) {
                      return Center(
                        child: Text(
                          'Error: ${messagesSnapshot.error}',
                          style:
                              const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                      );
                    }

                    Map<String, Map<String, dynamic>> latestMessages =
                        messagesSnapshot.data ?? {};

                    // Build friend list items
                    List<Widget> friendWidgets = friendIds.map((friendId) {
                      Map<String, dynamic>? friendData = friendsData[friendId];
                      Map<String, dynamic>? messageInfo =
                          latestMessages[friendId];
                      String chatRoomID =
                          chatService.getChatRoomId(currentUserId, friendId);

                      if (friendData != null) {
                        return _buildFriendListItem(friendId, friendData,
                            messageInfo, context, chatRoomID);
                      } else {
                        return Container();
                      }
                    }).toList();

                    return ListView(children: friendWidgets);
                  },
                );
              },
            );
          },
        );
      },
    );
  }

  // Build individual list tile for each friend
  Widget _buildFriendListItem(
      String friendId,
      Map<String, dynamic> friendData,
      Map<String, dynamic>? messageInfo,
      BuildContext context,
      String chatRoomID) {
    String latestMessage = messageInfo != null
        ? messageInfo['message'] ?? 'No messages yet'
        : 'No messages yet';
    Timestamp? timestamp =
        messageInfo != null ? messageInfo['timestamp'] as Timestamp? : null;
    bool isUnread =
        messageInfo != null ? messageInfo['isUnread'] ?? false : false;
    String senderID = messageInfo != null ? messageInfo['senderID'] ?? '' : '';

    // Determine if we should show the red dot
    bool showUnreadDot =
        isUnread && senderID != authService.getCurrentUser()!.uid;

    // Format the timestamp to a readable format if it's not null
    String formattedTime = '';
    if (timestamp != null) {
      DateTime dateTime = timestamp.toDate();
      bool is24HourFormat = MediaQuery.of(context).alwaysUse24HourFormat;
      formattedTime = is24HourFormat
          ? DateFormat('HH:mm').format(dateTime)
          : DateFormat('hh:mm a').format(dateTime);
    }

    if (latestMessage.length >= 25) {
      latestMessage = '${latestMessage.substring(0, 25)}...';
    }

    return MyTile(
      timestamp: formattedTime,
      subtitle: latestMessage,
      text: friendData["name"] ?? friendData["email"],
      onTap: () {
        // Mark messages as read when tapping the message icon
        chatService.markMessagesAsRead(
            chatRoomID, authService.getCurrentUser()!.uid);

        // Navigate to chat page
        Navigator.push(
          context,
          CustomNavigator.createSlideRoute(
            ChatPage(
              receiverEmail: friendData["email"],
              receiverID: friendId,
              receiverName: friendData["name"],
              profileImageUrl: friendData['imageUrl'],
            ),
          ),
        ).then((shouldRefresh) {
          if (shouldRefresh == true) {
            setState(() {}); // Refresh FriendsPage or FriendFinderPage
          }
        });
      },
      leading: CircleAvatar(
        radius: 20,
        foregroundImage: friendData['imageUrl'] != null
            ? NetworkImage(friendData['imageUrl'])
            : null,
        backgroundColor: Colors.grey,
      ),
      trailing: Stack(
        alignment: Alignment.center,
        children: [
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
            child: const Icon(
              Icons.messenger_outline_outlined,
            ),
          ),
          if (showUnreadDot)
            Positioned(
              top: 6,
              right: 10,
              child: Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
