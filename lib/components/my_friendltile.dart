import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/chat/chat.dart';
import 'package:dip_app_2/screens/friends/friends.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class FriendsListTile extends StatelessWidget {
  final String currentUserId;
  final FirestoreService firestoreService = FirestoreService();

  FriendsListTile({super.key, required this.currentUserId});

  // Method to navigate to ChatPage
  void _navigateToChatPage(BuildContext context, String friendId,
      String friendEmail, String friendName, String profileImageUrl) {
    Navigator.push(
      context,
      CustomNavigator.createSlideRoute(
        ChatPage(
          receiverEmail: friendEmail,
          receiverID: friendId,
          receiverName: friendName,
          profileImageUrl: profileImageUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder(
      stream: FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> totalFriendsSnapshot) {
        if (!totalFriendsSnapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        // Total number of friends (for the counter)
        final totalFriendsCount = totalFriendsSnapshot.data!.docs.length;

        return StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(currentUserId)
              .collection('friends')
              .orderBy('chatFrequency', descending: true)
              .limit(4)
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> friendSnapshot) {
            if (!friendSnapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final friends = friendSnapshot.data!.docs;

            if (friends.isEmpty) {
              return const Center(
                child: // Encouraging message
                    Text(
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

            // Get all friend IDs
            final List<String> friendIds =
                friends.map((doc) => doc['friendId'] as String).toList();

            // Batch request for all friends' data in one go using whereIn
            return FutureBuilder(
              future: FirebaseFirestore.instance
                  .collection('users')
                  .where(FieldPath.documentId,
                      whereIn: friendIds) // Batch fetch friends' data
                  .get(),
              builder: (context, AsyncSnapshot<QuerySnapshot> usersSnapshot) {
                if (!usersSnapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final users = usersSnapshot.data!.docs;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Display "Friends" label with total friends count
                    Text(
                      'Friends($totalFriendsCount)',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                      ),
                    ),
                    const SizedBox(height: 5),
                    // Container to hold the friends' avatars and names
                    InkWell(
                      onTap: () {
                        // Naviagte to FriendsPage when the container is tapped
                        Navigator.push(
                          context,
                          CustomNavigator.createSlideRoute(FriendsPage()),
                        );
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
                            ...users.map((friendData) {
                              return Padding(
                                padding: const EdgeInsets.only(right: 8.0),
                                child: GestureDetector(
                                  onTap: () => _navigateToChatPage(
                                    context,
                                    friendData.id, // friendId
                                    friendData['email'] ?? '',
                                    friendData['name'] ?? '',
                                    friendData['imageUrl'] ?? '',
                                  ),
                                  child: Column(
                                    children: [
                                      CircleAvatar(
                                        radius: 28,
                                        backgroundImage:
                                            friendData['imageUrl'] != null
                                                ? NetworkImage(
                                                    friendData['imageUrl'])
                                                : null,
                                        backgroundColor:
                                            Colors.grey, // Placeholder color
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        friendData['name'] ??
                                            friendData[
                                                'email'], // Display name or email
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
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
