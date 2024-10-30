import 'package:dip_app_2/components/my_friendltile.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FriendFinderPage extends StatelessWidget {
  FriendFinderPage({super.key});

  // get FirestoreService
  final FirestoreService firestoreService = FirestoreService();

  @override
  Widget build(BuildContext context) {
    final User? user = AuthService().getCurrentUser();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Friend Finder',
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
      body: user == null
          ? const Center(child: Text("No user logged in"))
          : FutureBuilder<Map<String, dynamic>?>(
              future: firestoreService.getProfileData(user.uid),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading profile data"));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("Profile not found"));
                }

                // Retrieve and display profile data
                final profileData = snapshot.data!;

                return SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Column(
                      children: [
                        const SizedBox(height: 10),
                        // Profile Card
                        Container(
                          width: 350,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15),
                            color: Theme.of(context).colorScheme.secondary,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 5),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            children: [
                              // Profile Image and Edit Button
                              if (profileData['imageUrl'] != null)
                                CircleAvatar(
                                  radius: 60,
                                  backgroundImage:
                                      NetworkImage(profileData['imageUrl']),
                                )
                              else
                                const CircleAvatar(
                                  radius: 60,
                                  child: Icon(Icons.person,
                                      size: 50, color: Colors.white),
                                ),

                              const SizedBox(height: 10),
                              // Name and Course/Hall
                              Text(
                                '${profileData['name']}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 24,
                                ),
                              ),

                              Text(
                                '${profileData['course']}/${profileData['hall']}',
                                style: TextStyle(
                                  fontFamily: 'Poppins',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 10),

                        FriendsListTile(currentUserId: user.uid),

                        const SizedBox(height: 20),

                        // Select Filters Button
                        Container(
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
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 7),
                            onTap: () {
                              Navigator.pushNamed(context, '/filter');
                            },
                            title: const Text(
                              'Select Filters',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Notifications Button
                        Container(
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
                          child: ListTile(
                            contentPadding: EdgeInsets.symmetric(horizontal: 7),
                            title: const Text(
                              'Notifications',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.pushNamed(context, '/notification');
                            },
                            trailing: const Icon(Icons.arrow_forward_ios),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }
}
