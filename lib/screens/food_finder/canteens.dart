import 'package:dip_app_2/screens/food_finder/stall.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CanteenScreen extends StatelessWidget {
  final String categoryId;

  const CanteenScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Canteens')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('canteens')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No canteens available"));
          }

          var canteens = snapshot.data!.docs;

          return ListView.builder(
            itemCount: canteens.length,
            itemBuilder: (context, index) {
              var canteen = canteens[index];
              var canteenData = canteen.data() as Map<String, dynamic>;

              // Access the image URL and name
              String? imageUrl = canteenData['imageURL'] as String?;
              imageUrl ??= canteenData['imageUrl'] as String?;

              String canteenName = canteenData['name'] ?? canteen.id;

              return ListTile(
                title: Text(
                  canteenName,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(
                            imageUrl,
                            height: 100,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                height: 100,
                                color: Colors.grey,
                                child: const Center(
                                    child: Text("Failed to load image")),
                              );
                            },
                          )
                        : Container(
                            height: 100,
                            color: Colors.grey,
                            child:
                                const Center(child: Text("No Image Available")),
                          ),
                    const SizedBox(height: 8),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StallScreen(
                        categoryId: categoryId,
                        canteenId: canteen.id,
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
