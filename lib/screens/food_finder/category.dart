import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/screens/food_finder/canteens.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CategoryScreen extends StatefulWidget {
  const CategoryScreen({super.key});

  @override
  State<CategoryScreen> createState() => _CategoryScreenState();
}

class _CategoryScreenState extends State<CategoryScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: Text(
          'Food Finder',
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
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('categories').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return CircularProgressIndicator();
          var categories = snapshot.data!.docs;

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 5 / 4.2,
                crossAxisSpacing: 8, // Space between columns
                mainAxisSpacing: 8, // Space between rows
              ),
              itemCount: categories.length,
              itemBuilder: (context, index) {
                var category = categories[index];
                Map<String, dynamic>? categoryData =
                    category.data() as Map<String, dynamic>?;

                // Retrieve the image URL from the category document
                String? imageUrl = categoryData?['imageURL'];

                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CanteenScreen(
                          categoryId: category.id,
                          categoryImageUrl: categoryData?['imageURL'],
                        ),
                      ),
                    );
                  },
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Stack(
                      fit: StackFit
                          .expand, // Ensure the Stack fills the container
                      children: [
                        // Display image from Firestore if URL exists, otherwise use a placeholder
                        imageUrl != null && imageUrl.isNotEmpty
                            ? Image.network(
                                imageUrl,
                                fit: BoxFit.cover,
                              )
                            : Container(
                                color: Colors.grey[300],
                                child: const Icon(Icons.image_not_supported),
                              ),
                        // Dark overlay to darken the image
                        Container(
                          color: Colors.black.withOpacity(0.5),
                        ),
                        // Display category name overlay
                        Center(
                          child: Text(
                            category.id.toString().toUpperCase(),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
