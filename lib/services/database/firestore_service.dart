import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Add a new user to Firestore
  Future<void> addUser(Map<String, dynamic> userData) async {
    await _firestore.collection('users').add(userData);
  }

  // Stream of all users for real-time updates
  Stream<QuerySnapshot> getUsersStream() {
    return _firestore.collection('users').snapshots();
  }

  // Get filtered users based on the provided criteria
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
    Query query = _firestore.collection('users');

    // Add filters based on the provided criteria
    if (gender != null && gender != "NA") query = query.where('gender', isEqualTo: gender);
    if (course != null && course != "NA") query = query.where('course', isEqualTo: course);
    if (year != null && year != "NA") query = query.where('year', isEqualTo: year);
    if (hall != null && hall != "NA") query = query.where('hall', isEqualTo: hall);
    if (studentType != null && studentType != "NA") query = query.where('studentType', isEqualTo: studentType);
    if (country != null && country != "NA") query = query.where('country', isEqualTo: country);

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

    snapshot.docs.forEach((doc) {
      filteredUsers.add(doc.data() as Map<String, dynamic>);
    });

    return filteredUsers;
  }
}