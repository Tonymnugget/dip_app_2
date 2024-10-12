import 'package:dip_app_2/screens/matching/user_details.dart';
import 'package:flutter/material.dart';

class FilterResultsPage extends StatelessWidget {
  final List<Map<String, dynamic>> filteredUsers;

  const FilterResultsPage({super.key, required this.filteredUsers});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Filter Results')),
      body: ListView.builder(
        itemCount: filteredUsers.length,
        itemBuilder: (context, index) {
          final user = filteredUsers[index];
          return ListTile(
            title: Text(user['name'] ?? 'Unknown'),
            subtitle: Text(user['course'] ?? 'Unknown course'),
            onTap: () {
              // Navigate to the User Details Page when tapped
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => UserDetailsPage(user: user),
                ),
              );
            },
          );
        },
      ),
    );
  }
}