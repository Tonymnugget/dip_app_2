import 'package:dip_app_2/components/my_button_3.dart';
import 'package:dip_app_2/components/my_friendltile.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/matching/filter.dart';
import 'package:dip_app_2/screens/notifications/notifcations.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FriendFinderPage extends StatefulWidget {
  const FriendFinderPage({super.key});

  @override
  FriendFinderPageState createState() => FriendFinderPageState();
}

class FriendFinderPageState extends State<FriendFinderPage> {
  final FirestoreService firestoreService = FirestoreService();
  bool showInstructions = true; // Track whether to show instructionsR
  // Cache the future returned by firestoreService.getProfileData(user.uid) to avoid
  // Rebuilding Futures, only rebuild when needed
  Future<Map<String, dynamic>?>? _profileDataFuture;
  User? user;
  SharedPreferences? _prefs;

  @override
  void initState() {
    super.initState();
    _initializePreferences();
    user = AuthService().getCurrentUser();
    if (user != null) {
      _profileDataFuture = firestoreService.getProfileData(user!.uid);
    }
  }

  // Only initialize once with the following three functions
  Future<void> _initializePreferences() async {
    _prefs = await SharedPreferences.getInstance();
    _loadPreference();
  }

  // Load the 'showInstructions' preference
  Future<void> _loadPreference() async {
    setState(() {
      showInstructions = _prefs?.getBool('showInstructions') ?? true;
    });
  }

  // Save the user preference to hide instructions in the future
  Future<void> _setPreference(bool value) async {
    await _prefs?.setBool('showInstructions', value);
  }

  Future<void> _showInstructionsDialog() async {
    bool dontShowAgain = false;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text(
                'Instructions',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                // Wrap with SingleChildScrollView to avoid overflow
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      "Welcome to Friend Finder! You can find new friends based on their course, hall, interests, and more. Friend Finder will connect you with users based on the filters you input, and you can start chatting with those you are interested in getting to know. Start making new friends now!",
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Checkbox(
                          value: dontShowAgain,
                          onChanged: (value) {
                            setState(() {
                              dontShowAgain = value ?? false;
                            });
                          },
                        ),
                        const Text("Don't show again"),
                      ],
                    ),
                  ],
                ),
              ),
              actions: [
                MyButton3(
                  color: Colors.white,
                  onTap: () {
                    Navigator.of(context)
                        .pop(); // Close the dialog without action
                  },
                  text: "Cancel",
                ),
                MyButton3(
                  color: Color.fromARGB(255, 137, 201, 220),
                  onTap: () {
                    _setPreference(
                        !dontShowAgain); // Save preference based on checkbox
                    Navigator.of(context).pop(); // Close dialog
                    _navigateToFilterPage();
                  },
                  text: "Start",
                ),
              ],
            );
          },
        );
      },
    );
  }

  // Navigate to the FilterPage
  void _navigateToFilterPage() {
    Navigator.push(
      context,
      CustomNavigator.createSlideRoute(
        FilterPage(),
      ),
    ); // Replace with your FilterPage route
  }

  // Handle the Select Filters button tap
  void _onSelectFiltersTap() {
    if (showInstructions) {
      _showInstructionsDialog();
    } else {
      _navigateToFilterPage();
    }
  }

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
              future: _profileDataFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error loading profile data"));
                } else if (!snapshot.hasData || snapshot.data == null) {
                  return const Center(child: Text("Profile not found"));
                }

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
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 7),
                            onTap: _onSelectFiltersTap,
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
                            contentPadding:
                                const EdgeInsets.symmetric(horizontal: 7),
                            title: const Text(
                              'Notifications',
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                CustomNavigator.createSlideRoute(
                                  NotificationPage(),
                                ),
                              );
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
