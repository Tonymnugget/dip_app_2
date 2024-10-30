import 'package:dip_app_2/screens/food_finder/stall.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CanteenScreen extends StatelessWidget {
  final String categoryId;

  const CanteenScreen({super.key, required this.categoryId});

  @override
  Widget build(BuildContext context) {
    print("category:$categoryId:");
    return Scaffold(
      appBar: AppBar(title: Text('Canteens')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('canteens')
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var canteens = snapshot.data!.docs;

          return ListView.builder(
            itemCount: canteens.length,
            itemBuilder: (context, index) {
              var canteen = canteens[index];
              Map<String, dynamic>? canteenData =
                  canteen.data() as Map<String, dynamic>?;

              // Check if the imageUrl field exists
              String? imageUrl =
                  canteenData != null && canteenData.containsKey('imageUrl')
                      ? canteenData['imageUrl']
                      : null;

              return ListTile(
                title: Text(canteen.id),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Conditionally display image if the URL is not null or empty
                    imageUrl != null && imageUrl.isNotEmpty
                        ? Image.network(imageUrl, height: 100)
                        : Container(
                            height: 100,
                            color: Colors.grey,
                            child: Center(child: Text("No Image Available")),
                          ), // Placeholder for missing image
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
