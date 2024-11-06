import 'package:dip_app_2/components/my_drawer.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/screens/notifications/notifcations.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:dip_app_2/services/database/firestore_service.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
// TODO report user, delete chat, unfriend,

class _HomePageState extends State<HomePage> {
  // get auth & firestore services
  final AuthService authService = AuthService();
  final FirestoreService firestoreService = FirestoreService();

  // intialize userData var
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final currentUser = authService.getCurrentUser();

    if (currentUser != null) {
      final data = await firestoreService.getProfileData(currentUser.uid);
      setState(() {
        userData = data;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'NTU Orbit',
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

        // NotificationPage
        actions: [
          IconButton(
            icon: const Icon(Icons.favorite),
            tooltip: 'Notifcations',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => NotificationPage(),
                ),
              );
            },
          ),
        ],
      ),
      bottomNavigationBar: MyNavigationBar(),
      drawer: const MyDrawer(),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            children: [
              const SizedBox(height: 20),
              if (userData != null)
                Row(
                  children: [
                    const SizedBox(width: 20),
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: userData!['imageUrl'] != null
                          ? NetworkImage(userData!['imageUrl'])
                          : null,
                      backgroundColor: Colors.grey, // Placeholder color
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Welcome back!\n${userData!['name']}',
                      style: TextStyle(
                        fontFamily: 'Poppins',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                'Food Finder',
                'The complete NTU food directory!',
                () {
                  Navigator.pushNamed(context, '/food_finder');
                },
              ),
              const SizedBox(height: 20),
              _buildHomeButton(
                context,
                'Friend Finder',
                'Make new connections around NTU!',
                () {
                  Navigator.pushNamed(context, '/friend_finder');
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}

Widget _buildHomeButton(
    BuildContext context, String title, String subtitle, VoidCallback onTap) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      constraints: BoxConstraints(
        maxHeight: 280,
        maxWidth: 400,
      ),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
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
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Image from assets
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              "assets/images/ntu_hive.png",
              fit: BoxFit.cover,
            ),
          ),
          // title
          const SizedBox(height: 10),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Poppins',
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 5),
          // subtitle
          Text(
            subtitle,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ),
  );
}
