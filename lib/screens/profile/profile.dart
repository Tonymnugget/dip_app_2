import 'package:dip_app_2/components/my_chip.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

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
          'My Profile',
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
                        Stack(
                          clipBehavior: Clip.none,
                          children: [
                            Container(
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
                              padding: const EdgeInsets.all(20.0),
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
                                    '${profileData['name']},${profileData['year'].replaceAll('Year ', 'Y')}',
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

                                  Text(
                                    '${profileData['studentType']} Student',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 10),

                                  // Bio
                                  if (profileData['bio'] != '')
                                    Container(
                                      padding: const EdgeInsets.all(8.0),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(color: Colors.grey),
                                        color: Theme.of(context)
                                            .colorScheme
                                            .inversePrimary,
                                      ),
                                      child: Text(
                                        '${profileData['bio']}',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: 'Poppins',
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  if (profileData['bio'] != '')
                                    const SizedBox(height: 10),

                                  // languages
                                  const Text(
                                    'Languages',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Language buttons
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (var language
                                          in profileData['languages'])
                                        MyChip(label: language),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                  // Interests
                                  const Text(
                                    'Interests',
                                    style: TextStyle(
                                      fontFamily: 'Poppins',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  // Interest buttons
                                  Wrap(
                                    spacing: 10,
                                    runSpacing: 10,
                                    children: [
                                      for (var interest
                                          in profileData['interests'])
                                        MyChip(label: interest),
                                    ],
                                  ),
                                ],
                              ),
                            ),

                            // Positioned Edit Button
                            Positioned(
                              top: 10,
                              right: 10,
                              child: IconButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/edit_profile');
                                },
                                icon: Icon(Icons.edit_square),
                                iconSize: 30,
                                tooltip: 'Edit profile',
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        _buildOptionButton(
                          context,
                          'Setting',
                          Icons.settings,
                          () {
                            // Navigate to Settings
                          },
                        ),
                        const SizedBox(height: 10),
                        _buildOptionButton(
                          context,
                          'Invite Friends',
                          Icons.share,
                          () {
                            // Navigate to Invite Friends
                          },
                        ),
                      ],
                    ),
                  ),
                );
              }),
    );
  }

  // Helper method to create option buttons (Edit Profile, Settings, Invite Friends)
  Widget _buildOptionButton(
      context, String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Icon(icon, size: 24),
          ],
        ),
      ),
    );
  }
}
