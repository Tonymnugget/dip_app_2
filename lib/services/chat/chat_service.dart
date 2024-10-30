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
  Future<void> sendMessage(String receiverID, message) async {
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
        timestamp: timestamp,
      );

      // construct chat room ID for the two users (sorted to ensure uniqueness)
      List<String> ids = [currentUserID, receiverID];
      ids.sort(); // sort the ids (this ensure the chatroomID is the same for any 2 people)
      String chatRoomID = ids.join('_');

      // add new message to database
      await _firestore
          .collection("chat_rooms")
          .doc(chatRoomID)
          .collection("messages")
          .add(newMessage.toMap());
    } catch (e) {
      print('Failed to send message or update chat frequency: $e');
      // Optionally, you can show a snackbar or alert dialog here to inform the user of the error.
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
}
