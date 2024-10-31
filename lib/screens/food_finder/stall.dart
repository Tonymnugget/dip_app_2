import 'package:dip_app_2/screens/food_finder/food.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StallScreen extends StatelessWidget {
  final String categoryId;
  final String canteenId;

  const StallScreen(
      {super.key, required this.categoryId, required this.canteenId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Stalls in $canteenId')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('canteens')
            .doc(canteenId)
            .collection('stalls')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No stalls available"));
          }

          var stalls = snapshot.data!.docs;
          // print("stalls:$stalls"); // For debugging

          return ListView.builder(
            itemCount: stalls.length,
            itemBuilder: (context, index) {
              var stall = stalls[index];
              // print("stall:$stall"); // For debugging
              String stallId = stall.id;
              Map<String, dynamic> stallData =
                  stall.data() as Map<String, dynamic>;

              // Access the imageUrl directly
              String? imageUrl = stallData['imageUrl'] as String?;
              // If 'imageUrl' is null, try 'imageURL'
              imageUrl ??= stallData['imageURL'] as String?;

              // Access thumbsUp and thumbsDown
              int? thumbsUp = stallData['thumbsUp'] as int?;
              int? thumbsDown = stallData['thumbsDown'] as int?;

              return ListTile(
                title: Text(
                  stallId,
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
                    if (thumbsUp != null) Text("Likes: $thumbsUp"),
                    if (thumbsDown != null) Text("Dislikes: $thumbsDown"),
                    Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.thumb_up),
                          onPressed: () {
                            incrementThumbsUp(categoryId, canteenId, stallId);
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.thumb_down),
                          onPressed: () {
                            incrementThumbsDown(categoryId, canteenId, stallId);
                          },
                        ),
                      ],
                    ),
                  ],
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodScreen(
                        categoryId: categoryId,
                        canteenId: canteenId,
                        stallId: stallId,
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

  void incrementThumbsUp(String categoryId, String canteenId, String stallId) {
    FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId)
        .update({'thumbsUp': FieldValue.increment(1)});
  }

  void incrementThumbsDown(
      String categoryId, String canteenId, String stallId) {
    FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId)
        .update({'thumbsDown': FieldValue.increment(1)});
  }
}
