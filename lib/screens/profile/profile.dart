import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'profile__edit.dart';

class ProfilePage extends StatelessWidget {
  
  ProfilePage({super.key});

  // get FirestoreService
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final User? user = AuthService().getCurrentUser();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Profile",
          style: TextStyle(
            color: Theme.of(context).colorScheme.inversePrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.grey,
        elevation: 0,
        // Add the edit button next to the AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit Profile',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ProfileEditPage(),
                ),
              );
            },
          ),
        ],
      ),
      // Retrieve and display profile information
      body: user == null
          ? const Center(child: Text("No user logged in"))
          : FutureBuilder<Map<String, dynamic>?>(
              future: firestoreService.getProfileData(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(child: Text("Error loading profile data"));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("Profile not found"));
                }

                // Retrieve and display profile data
                final profileData = snapshot.data!;
                return Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Display Profile Image if available
                      if (profileData['imageUrl'] != null) 
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: NetworkImage(profileData['imageUrl']),
                        )
                      else
                        const CircleAvatar(
                          radius: 50,
                          child: Icon(Icons.person, size: 40, color: Colors.white),
                        ),
                      Text(
                        "Name: ${profileData['name'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Email: ${profileData['email'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Year: ${profileData['year'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Course: ${profileData['course'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Gender: ${profileData['country'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Hall: ${profileData['hall'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Interests: ${profileData['interests'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Languages: ${profileData['languages'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Student type: ${profileData['studentType'] ?? 'N/A'}",
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}