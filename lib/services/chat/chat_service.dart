import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dip_app_2/models/message.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  // get instance of auth & firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // get user stream
  /*

  List<Map<String, dynamic>> = 

  List of Maps!
  [
  {
    'email': test@e.ntu.edu.sg,
    'id': ...
  },
  {
    'email': test2@e.ntu.edu.sg,
    'id': ...
  }
  ]
  */

  // Function to generate chat room ID for two users
  String getChatRoomId(String userId1, String userId2) {
    List<String> ids = [userId1, userId2];
    ids.sort(); // Ensure the IDs are in a consistent order
    return ids.join('_'); // Join the sorted IDs with an underscore
  }

  Stream<List<Map<String, dynamic>>> getUsersStream() {
    return _firestore.collection("users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        // go through each individual user
        final user = doc.data();

        // return user
        return user;
      }).toList();
    });
  }

  // send message
  Future<void> sendMessage(
      String receiverID, String message, String senderName) async {
    try {
      // get current user info
      final String currentUserID = _auth.currentUser!.uid;
      final String currentUserEmail = _auth.currentUser!.email!;
      final Timestamp timestamp = Timestamp.now();

      // add chatFrequency
      await incrementChatFrequency(currentUserID, receiverID);

      // create a new message
      Message newMessage = Message(
        senderID: currentUserID,
        senderEmail: currentUserEmail,
        receiverID: receiverID,
        message: message,
        senderName: senderName, // Add senderName to Message
        timestamp: timestamp,
        isUnread: true,
      );

      // construct chat room ID for the two users (sorted to ensure uniqueness)
      List<String> ids = [currentUserID, receiverID];
      ids.sort();
      String chatRoomID = ids.join('_');

      // add new message to database
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print('Failed to send message or update chat frequency: $e');
    }
  }

  //get messages
  Stream<QuerySnapshot> getMessage(String userID, otherUserID) {
    // construct a chatroom ID for the two users
    List<String> ids = [userID, otherUserID];
    ids.sort();
    String chatRoomID = ids.join('_');

    return _firestore
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy("timestamp", descending: false)
        .snapshots();
  }

// TODO: currently not being used. Hard to implement with current logic in FriendsPage
  Future<int> numberOfUnreadMessages(String chatRoomID, String userID) async {
    try {
      final QuerySnapshot unreadMessagesSnapshot = await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .where('isUnread', isEqualTo: true)
          .get();

      return unreadMessagesSnapshot.size;
    } catch (e) {
      print('Failed to mark messages as read: $e');
      return 0;
    }
  }

  Future<void> markMessagesAsRead(String chatRoomID, String userID) async {
    try {
      final QuerySnapshot unreadMessagesSnapshot = await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .where('receiverID', isEqualTo: userID)
          .where('isUnread', isEqualTo: true)
          .get();

      WriteBatch batch = _firestore.batch();

      for (var doc in unreadMessagesSnapshot.docs) {
        await doc.reference.update({'isUnread': false});
      }

      await batch.commit();
    } catch (e) {
      print('Failed to mark messages as read: $e');
    }
  }

  Future<void> incrementChatFrequency(
      String currentUserId, String friendId) async {
    try {
      // Reference to the current user's friends collection
      DocumentReference friendDocRef = FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(friendId);

      // Run transaction to safely increment chatFrequency
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        DocumentSnapshot friendSnapshot = await transaction.get(friendDocRef);

        if (friendSnapshot.exists) {
          // Check if data is not null and contains 'chatFrequency'
          final friendData = friendSnapshot.data()
              as Map<String, dynamic>?; // Explicitly cast to Map
          int currentChatFrequency = 0;

          if (friendData != null && friendData.containsKey('chatFrequency')) {
            currentChatFrequency = friendData['chatFrequency'] ?? 0;
          }

          // Increment chatFrequency
          transaction.update(friendDocRef, {
            'chatFrequency': currentChatFrequency + 1,
          });
        } else {
          // If the document does not exist, create it with an initial frequency
          transaction.set(friendDocRef, {
            'friendId': friendId,
            'chatFrequency': 1,
          });
        }
      });
    } catch (error) {
      print("Failed to update chat frequency: $error");
    }
  }

  Future<QuerySnapshot> getMessages({
    required String chatRoomID,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) {
    Query query = FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy('timestamp', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.get();
  }

  Stream<QuerySnapshot> getMessagesStream({required String chatRoomID}) {
    return FirebaseFirestore.instance
        .collection("chat_rooms")
        .doc(chatRoomID)
        .collection("messages")
        .orderBy('timestamp')
        .snapshots();
  }
}
