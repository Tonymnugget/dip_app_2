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
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;
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

          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Expanded(
                child: GridView.builder(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      childAspectRatio: 5 / 4.2,
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 20),
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
                            builder: (context) =>
                                CanteenScreen(categoryId: category.id),
                          ),
                        );
                      },
                      child: Stack(
                        children: [
                          // Display image from Firestore if URL exists, otherwise use a placeholder
                          imageUrl != null && imageUrl.isNotEmpty
                              ? Image.network(
                                  imageUrl,
                                  fit: BoxFit.cover,
                                  width: width,
                                  height: height,
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  width: width,
                                  height: height,
                                  child: Icon(Icons.image_not_supported),
                                ),
                          // Display category name overlay
                          Padding(
                            padding: EdgeInsets.only(top: height * 0.07),
                            child: Center(
                              child: Text(
                                category.id.toString().toUpperCase(),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: height * 0.03,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              SizedBox(
                height: height * 0.02,
              )
            ],
          );
        },
      ),
    );
  }
}
