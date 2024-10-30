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
          if (!snapshot.hasData) return CircularProgressIndicator();
          var stalls = snapshot.data!.docs;
          print("stalls:$stalls");

          return ListView.builder(
            itemCount: stalls.length,
            itemBuilder: (context, index) {
              var stall = stalls[index];
              print("stall:$stall");
              String stallId = stall.id;
              Map<String, dynamic>? stallData =
                  stall.data() as Map<String, dynamic>?;

              // Check if the fields exist before trying to access them
              int? thumbsUp =
                  stallData != null && stallData.containsKey('thumbsUp')
                      ? stallData['thumbsUp']
                      : null;
              int? thumbsDown =
                  stallData != null && stallData.containsKey('thumbsDown')
                      ? stallData['thumbsDown']
                      : null;
              String? imageUrl =
                  stallData != null && stallData.containsKey('imageUrl')
                      ? stallData['imageUrl']
                      : null;

              return ListTile(
                title: Text(stallId),
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

                    // Conditionally display thumbs up if the field exists
                    if (thumbsUp != null) Text("Likes: $thumbsUp"),
                    if (thumbsDown != null) Text("Dislikes: $thumbsDown"),
                    Row(
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up),
                          onPressed: () {
                            incrementThumbsUp(categoryId, canteenId, stallId);
                          },
                        ),
                        IconButton(
                          icon: Icon(Icons.thumb_down),
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
