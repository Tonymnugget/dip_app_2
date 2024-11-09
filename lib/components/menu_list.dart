import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class MenuList extends StatelessWidget {
  final String categoryId;
  final String canteenId;
  final String stallId;
  final double height;
  final double width;

  const MenuList({
    super.key,
    required this.categoryId,
    required this.canteenId,
    required this.stallId,
    required this.height,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
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
        // Handle the snapshot as before
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

            return Padding(
              padding: EdgeInsets.only(
                bottom: height * 0.015,
              ),
              child: Container(
                width: width,
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  border: Border.all(
                    width: height * 0.001,
                    color: Theme.of(context).colorScheme.onSecondaryContainer,
                  ),
                ),
                child: ListTile(
                  title: Text(
                    itemName,
                    style: TextStyle(
                      fontSize: (17 / height) * height,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  trailing: SizedBox(
                    width: width * 0.3, // Adjust as needed
                    child: Text(
                      itemPrice,
                      textAlign: TextAlign.end,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: (17 / height) * height,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Description:",
                        style: TextStyle(
                          fontSize: (12 / height) * height,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        "Contains:",
                        style: TextStyle(
                          fontSize: (12 / height) * height,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
