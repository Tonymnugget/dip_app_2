import 'package:dip_app_2/screens/food_finder/canteens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryScreen extends StatelessWidget {
  const CategoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var categories = snapshot.data!.docs;

          return ListView.builder(
            itemCount: categories.length,
            itemBuilder: (context, index) {
              var category = categories[index];
              Map<String, dynamic>? categoryData =
                  category.data() as Map<String, dynamic>?;

              // Check if the imageUrl field exists in the category data
              String? imageUrl =
                  categoryData != null && categoryData.containsKey('imageUrl')
                      ? categoryData['imageUrl']
                      : null;

              // String categoryId = category.id;
              return ListTile(
                title: Text(category.id),
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
                      builder: (context) =>
                          CanteenScreen(categoryId: category.id),
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
