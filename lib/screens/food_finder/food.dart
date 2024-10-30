import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FoodScreen extends StatelessWidget {
  final String categoryId;
  final String canteenId;
  final String stallId;

  const FoodScreen({
    super.key,
    required this.categoryId,
    required this.canteenId,
    required this.stallId,
  });

  @override
  Widget build(BuildContext context) {
    print('Navigated to FoodScreen');
    print(
        'categoryId: $categoryId, canteenId: $canteenId, stallId: $stallId'); // Debugging

    return Scaffold(
      appBar: AppBar(title: Text('Menu for $stallId')),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('canteens')
            .doc(canteenId)
            .collection('stalls')
            .doc(stallId)
            .collection('menu')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text("No menu items available."));
          }

          var menuItems = snapshot.data!.docs;

          return ListView.builder(
            itemCount: menuItems.length,
            itemBuilder: (context, index) {
              var menuItem = menuItems[index];
              String itemName = menuItem['Item'] ?? 'Unknown Item';
              String itemPrice = menuItem['Price'] ?? 'N/A';

              return ListTile(
                title: Text(itemName),
                subtitle: Text("Price: $itemPrice"),
              );
            },
          );
        },
      ),
    );
  }
}
