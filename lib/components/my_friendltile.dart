import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/chat/chat.dart';
import 'package:dip_app_2/screens/friends/friends.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendsListTile extends StatefulWidget {
  final String currentUserId;

  const FriendsListTile({super.key, required this.currentUserId});

  @override
  State<FriendsListTile> createState() => _FriendsListTileState();
}

class _FriendsListTileState extends State<FriendsListTile> {
  final FirestoreService firestoreService = FirestoreService();

  // Method to navigate to ChatPage
  void _navigateToChatPage(BuildContext context, String friendId,
      String friendEmail, String friendName, String profileImageUrl) {
    Navigator.push(
      context,
      CustomNavigator.createSlideRoute(ChatPage(
        receiverEmail: friendEmail,
        receiverID: friendId,
        receiverName: friendName,
        profileImageUrl: profileImageUrl,
      )),
    ).then((shouldRefresh) {
      if (shouldRefresh == true) {
        setState(() {}); // Refresh FriendsPage or FriendFinderPage
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<String>>(
      stream: firestoreService.getBlockedUidsStreamFromFirebase(),
      builder: (context, blockedUsersSnapshot) {
        if (blockedUsersSnapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (blockedUsersSnapshot.hasError) {
          return Center(child: Text('Error: ${blockedUsersSnapshot.error}'));
        }

        final List<String> blockedUserIds = blockedUsersSnapshot.data ?? [];

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(widget.currentUserId)
              .collection('friends')
              .orderBy('chatFrequency', descending: true)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> friendsSnapshot) {
            if (!friendsSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            // Filter out blocked users and apply a limit of 4 after filtering
            final unblockedFriendsData = friendsSnapshot.data!.docs
                .where((doc) => !blockedUserIds.contains(doc['friendId']))
                .toList();

            // If fewer than 4 friends remain after blocking, backfill with additional friends
            final friendsData = unblockedFriendsData.take(4).toList();

            if (friendsData.isEmpty) {
              return const Center(
                child: Text(
                  "It looks a bit quiet here... Tap 'Select Filters' to start exploring and make new friends!",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
              );
            }

            // Extract friend IDs
            final List<String> friendIds =
                friendsData.map((doc) => doc['friendId'] as String).toList();

            return FutureBuilder<QuerySnapshot>(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(FieldPath.documentId, whereIn: friendIds)
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
                if (!usersSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = usersSnapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Friends(${friendIds.length})', // Show actual friend count
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          CustomNavigator.createSlideRoute(FriendsPage()),
                        ).then((_) {
                          // Trigger a rebuild after coming back from FriendsPage
                          setState(() {});
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.all(8.0),
                        decoration: BoxDecoration(
                          color: Theme.of(context).colorScheme.secondary,
                          borderRadius: BorderRadius.circular(15),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: Row(
                          children: [
                            ...users.map(
                              (friendData) {
                                return Padding(
                                  padding: const EdgeInsets.only(right: 8.0),
                                  child: GestureDetector(
                                    onTap: () => _navigateToChatPage(
                                      context,
                                      friendData.id,
                                      friendData['email'] ?? '',
                                      friendData['name'] ?? '',
                                      friendData['imageUrl'] ?? '',
                                    ),
                                    child: Column(
                                      children: [
                                        friendData['imageUrl'] != null
                                            ? CircleAvatar(
                                                radius: 28,
                                                backgroundImage: NetworkImage(
                                                    friendData['imageUrl']),
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                              )
                                            : CircleAvatar(
                                                radius: 28,
                                                backgroundColor:
                                                    Theme.of(context)
                                                        .colorScheme
                                                        .primary,
                                                child: Icon(Icons.person),
                                              ),
                                        const SizedBox(height: 5),
                                        Text(
                                          friendData['name'] ??
                                              friendData['email'],
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                            Spacer(),
                            const Icon(Icons.arrow_forward_ios),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          },
        );
      },
    );
  }
}
