import 'package:flutter/material.dart';

class UserDetailsPage extends StatelessWidget {
  final Map<String, dynamic> user;

  const UserDetailsPage({super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('${user['name'] ?? 'User Details'}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: ${user['name'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            Text('Course: ${user['course'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            Text('Year: ${user['year'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            Text('Gender: ${user['gender'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            Text('Hall: ${user['hall'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            Text('Student Type: ${user['studentType'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            Text('Country: ${user['country'] ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            Text('Languages: ${(user['languages'] as List<dynamic>?)?.join(', ') ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
            Text('Interests: ${(user['interests'] as List<dynamic>?)?.join(', ') ?? 'Unknown'}', style: TextStyle(fontSize: 18)),
          ],
        ),
      ),
    );
  }
}