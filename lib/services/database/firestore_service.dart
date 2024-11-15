import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirestoreService {
  // get instance of auth & firestore
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final AuthService authService = AuthService();

  // In FirestoreService
  Future<String> getCurrentUserName() async {
    final currentUser = authService.getCurrentUser();
    if (currentUser != null) {
      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUser.uid)
          .get();
      if (userDoc.exists) {
        return userDoc.data()?['name'] ??
            'User'; // Default to 'User' if name is null
      }
    }
    return 'User'; // Default to 'User' if currentUser is null or document does not exist
  }

  Future<Map<String, dynamic>?> getProfileData(String uid) async {
    // Query Firestore to retrieve profile information
    final doc =
        await FirebaseFirestore.instance.collection('users').doc(uid).get();
    if (doc.exists) {
      return doc.data();
    }
    return null;
  }

  // Get filtered users based on the provided criteria and exclude users who are already friends
  Future<List<Map<String, dynamic>>> getFilteredUsers({
    String? gender,
    String? course,
    String? year,
    String? hall,
    String? studentType,
    String? country,
    List<String>? selectedLanguages,
    List<String>? selectedInterests,
  }) async {
    // Get the current user ID (assuming it's stored in your auth service)
    final currentUser = authService.getCurrentUser();
    if (currentUser == null) return [];

    String currentUserId = currentUser.uid;

    // Fetch the current user's 'friends' collection
    QuerySnapshot friendsSnapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('friends')
        .get();

    // Extract friend IDs from the snapshot
    List<String> friendsList =
        friendsSnapshot.docs.map((doc) => doc['friendId'] as String).toList();

    // Query to get all users that match the filtered criteria
    Query query = _firestore.collection('users');

    // Add filters based on the provided criteria
    if (gender != null && gender != "NA") {
      query = query.where('gender', isEqualTo: gender);
    }

    if (course != null && course != "NA") {
      query = query.where('course', isEqualTo: course);
    }
    if (year != null && year != "NA") {
      query = query.where('year', isEqualTo: year);
    }
    if (hall != null && hall != "NA") {
      query = query.where('hall', isEqualTo: hall);
    }
    if (studentType != null && studentType != "NA") {
      query = query.where('studentType', isEqualTo: studentType);
    }
    if (country != null && country != "NA") {
      query = query.where('country', isEqualTo: country);
    }

    // Handle multiple selected languages
    if (selectedLanguages != null && selectedLanguages.isNotEmpty) {
      query = query.where('languages', arrayContainsAny: selectedLanguages);
    }

    // Handle multiple selected interests
    if (selectedInterests != null && selectedInterests.isNotEmpty) {
      query = query.where('interests', arrayContainsAny: selectedInterests);
    }

    // Execute the query and retrieve the data
    QuerySnapshot snapshot = await query.get();
    List<Map<String, dynamic>> filteredUsers = [];

    for (var doc in snapshot.docs) {
      Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

      // Exclude users that are already friends
      if (!friendsList.contains(userData['uid']) &&
          userData['uid'] != currentUserId) {
        filteredUsers.add(userData);
      }
    }

    return filteredUsers;
  }

  // Send a friend request
  Future<void> sendFriendRequest(String receiverId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Add to current user's sentRequests
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('sentRequests')
          .doc(receiverId)
          .set({
        'receiverId': receiverId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Add to the target user's receivedRequests
      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('receivedRequests')
          .doc(currentUser.uid)
          .set({
        'senderId': currentUser.uid,
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending friend request: $e');
    }
  }

  // Cancel a friend request
  Future<void> cancelFriendRequest(String receiverId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      // Remove from current user's sentRequests
      await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .collection('sentRequests')
          .doc(receiverId)
          .delete();

      // Remove from the target user's receivedRequests
      await _firestore
          .collection('users')
          .doc(receiverId)
          .collection('receivedRequests')
          .doc(currentUser.uid)
          .delete();
    } catch (e) {
      print('Error canceling friend request: $e');
    }
  }

  // Check if a friend request is already sent
  Future<bool> isFriendRequestSent(String receiverId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final sentRequestRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('sentRequests')
        .doc(receiverId);

    final requestDoc = await sentRequestRef.get();
    return requestDoc.exists;
  }

  // Check if a friend request is already received
  Future<bool> isFriendRequestReceived(String receiverId) async {
    User? currentUser = _auth.currentUser;
    if (currentUser == null) return false;

    final sentRequestRef = _firestore
        .collection('users')
        .doc(currentUser.uid)
        .collection('receivedRequests')
        .doc(receiverId);

    final requestDoc = await sentRequestRef.get();
    return requestDoc.exists;
  }

  // Function to accept a friend request
  Future<void> acceptFriendRequest(String senderId, currentUserId) async {
    try {
      // Add sender to current user's 'friends' collection
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(senderId)
          .set({
        'friendId': senderId,
        'timestamp': FieldValue.serverTimestamp(),
        'chatFrequency': 0,
        'blockedByFriend': false,
      });

      // Add current user to sender's 'friends' collection
      await _firestore
          .collection('users')
          .doc(senderId)
          .collection('friends')
          .doc(currentUserId)
          .set({
        'friendId': currentUserId,
        'timestamp': FieldValue.serverTimestamp(),
        'chatFrequency': 0,
        'blockedByFriend': false,
      });

      // Remove the friend request from the current user's 'receivedRequests'
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('receivedRequests')
          .doc(senderId)
          .delete();

      // Remove the friend request from the sender's 'sentRequests'
      await _firestore
          .collection('users')
          .doc(senderId)
          .collection('sentRequests')
          .doc(currentUserId)
          .delete();

      print('Friend request from $senderId accepted');
    } catch (e) {
      print('Error accepting friend request: $e');
      rethrow;
    }
  }

  // Function to delete the friend request
  Future<void> deleteFriendRequest(String senderId, currentUserId) async {
    try {
      // Remove the friend request from the current user's 'receivedRequests'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('receivedRequests')
          .doc(senderId)
          .delete();

      // Remove the friend request from the sender's 'sentRequests'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('sentRequests')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      print('Error deleting friend request: $e');
      rethrow;
    }
  }

  // Function to check whether is already friend
  Future<bool> isFriend(String currentUserID, String otherUserID) async {
    final friendDoc = await FirebaseFirestore.instance
        .collection('users')
        .doc(currentUserID)
        .collection('friends')
        .doc(otherUserID)
        .get();
    return friendDoc.exists;
  }

  // Function to unfriend
  Future<void> unfriend(String senderId, currentUserId) async {
    try {
      // Remove the sender from the current user's 'friends' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .collection('friends')
          .doc(senderId)
          .delete();

      // Remove the current user from the sender's 'friends' collection
      await FirebaseFirestore.instance
          .collection('users')
          .doc(senderId)
          .collection('friends')
          .doc(currentUserId)
          .delete();
    } catch (e) {
      print('Error unfriending user: $e');
      rethrow;
    }
  }

  // Block User
  Future<void> blockUserInFirebase(String userId) async {
    // get current user id
    final currentUserId = authService.getCurrentUser()!.uid;

    // add this user to blocked list
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(userId)
        .set({});

    // update the blockedByFriend condition for the blockedUser's friend document
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('friends')
        .doc(currentUserId)
        .update({
      'blockedByFriend': true,
    });
  }

  // Unblock user
  Future<void> unblockUserInFirebase(String blockedUserId) async {
    // get current user id
    final currentUserId = authService.getCurrentUser()!.uid;

    // remove this user from blocked list
    await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .doc(blockedUserId)
        .delete();

    // update the blockedByFriend condition for the blockedUser's friend document
    await _firestore
        .collection('users')
        .doc(blockedUserId)
        .collection('friends')
        .doc(currentUserId)
        .update({
      'blockedByFriend': false,
    });
  }

  // Get list of blocked user ids
  Future<List<String>> getBlockedUidsFromFirebase() async {
    // get current user id
    final currentUserId = authService.getCurrentUser()!.uid;

    final snapshot = await _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .get();

    // return as a list of uids
    return snapshot.docs.map((doc) => doc.id).toList();
  }

  // Get stream of blocked user ids
  Stream<List<String>> getBlockedUidsStreamFromFirebase() {
    // get current user id
    final currentUserId = authService.getCurrentUser()!.uid;

    return _firestore
        .collection('users')
        .doc(currentUserId)
        .collection('blockedUsers')
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => doc.id).toList());
  }

  // increase the like vote for that particular stall and decrease the dislike vote if disliked before
  // decrease the like vote if liked before
  Future<void> voteThumbsUp(String categoryId, String canteenId, String stallId,
      String userId) async {
    DocumentReference voteDoc = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId)
        .collection('votes')
        .doc(userId);

    DocumentReference stallDoc = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId);

    DocumentSnapshot docSnapshot = await voteDoc.get();

    if (docSnapshot.exists) {
      Map<String, dynamic> existingData =
          docSnapshot.data() as Map<String, dynamic>;

      if (existingData['vote'] == 'thumbsUp') {
        // User wants to remove their like
        await stallDoc.update({'thumbsUp': FieldValue.increment(-1)});
        await voteDoc.delete();
      } else if (existingData['vote'] == 'thumbsDown') {
        // User changes vote from dislike to like
        await stallDoc.update({
          'thumbsUp': FieldValue.increment(1),
          'thumbsDown': FieldValue.increment(-1),
        });
        await voteDoc.update({'vote': 'thumbsUp'});
      }
    } else {
      // User hasn't voted yet, add a like
      await stallDoc.update({'thumbsUp': FieldValue.increment(1)});
      await voteDoc.set({'vote': 'thumbsUp'});
    }
  }

  // increase the dislike vote for that particular stall and decrease the like vote if disliked before
  // decrease the dislike vote if liked before
  Future<void> voteThumbsDown(String categoryId, String canteenId,
      String stallId, String userId) async {
    DocumentReference voteDoc = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId)
        .collection('votes')
        .doc(userId);

    DocumentReference stallDoc = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId);

    DocumentSnapshot docSnapshot = await voteDoc.get();

    if (docSnapshot.exists) {
      Map<String, dynamic> existingData =
          docSnapshot.data() as Map<String, dynamic>;

      if (existingData['vote'] == 'thumbsDown') {
        // User wants to remove their dislike
        await stallDoc.update({'thumbsDown': FieldValue.increment(-1)});
        await voteDoc.delete();
      } else if (existingData['vote'] == 'thumbsUp') {
        // User changes vote from like to dislike
        await stallDoc.update({
          'thumbsUp': FieldValue.increment(-1),
          'thumbsDown': FieldValue.increment(1),
        });
        await voteDoc.update({'vote': 'thumbsDown'});
      }
    } else {
      // User hasn't voted yet, add a dislike
      await stallDoc.update({'thumbsDown': FieldValue.increment(1)});
      await voteDoc.set({'vote': 'thumbsDown'});
    }
  }

  // return the user's vote
  Future<String?> getUserVote(String categoryId, String canteenId,
      String stallId, String userId) async {
    DocumentReference voteDoc = _firestore
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId)
        .collection('votes')
        .doc(userId);

    DocumentSnapshot docSnapshot = await voteDoc.get();

    if (docSnapshot.exists) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      return data['vote'] as String?;
    }
    return null;
  }
}
