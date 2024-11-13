import 'package:dip_app_2/components/my_button_3.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/screens/food_finder/stall.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CanteenScreen extends StatefulWidget {
  final String categoryId;
  final String categoryImageUrl;

  const CanteenScreen({
    super.key,
    required this.categoryId,
    required this.categoryImageUrl,
  });

  @override
  State<CanteenScreen> createState() => _CanteenScreenState();
}

class _CanteenScreenState extends State<CanteenScreen> {
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    return Scaffold(
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
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection('canteens')
            .snapshots(),
        builder: (context, snapshot) {
          // Add null checks and error handling
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData ||
              snapshot.data == null ||
              snapshot.data!.docs.isEmpty) {
            return const Center(child: Text('No canteens available'));
          }

          var canteens = snapshot.data!.docs;

          // Build the list of canteen widgets
          List<Widget> canteenWidgets = canteens.map((canteen) {
            var canteenData = canteen.data() as Map<String, dynamic>;

            // Access the image URL, name, address, and opening hours
            String? imageUrl = canteenData['imageUrl'] as String?;
            imageUrl ??= canteenData['imageURL'] as String?;
            String canteenName = canteenData['name'] ?? canteen.id;
            String? address = canteenData['Address'] as String?;

            // Handle Opening Hours as a List or a String
            List<String> openingHoursList;
            if (canteenData['Opening Hours'] is List) {
              openingHoursList = List<String>.from(
                  canteenData['Opening Hours'] as List<dynamic>);
            } else if (canteenData['Opening Hours'] is String) {
              openingHoursList = [canteenData['Opening Hours']];
            } else {
              openingHoursList = []; // Default to empty list if neither
            }

            return Padding(
              padding: EdgeInsets.only(bottom: height * 0.005),
              child: Card(
                elevation: 4,
                child: Container(
                  width: width,
                  padding: EdgeInsets.symmetric(
                    vertical: height * 0.005,
                    horizontal: width * 0.02,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondary,
                    borderRadius: BorderRadius.circular(height * 0.01),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Wrap image with GestureDetector for navigation
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StallScreen(
                                categoryId: widget.categoryId,
                                canteenId: canteen.id,
                                canteenImage: imageUrl ?? "",
                                canteenOpeningHours: openingHoursList,
                              ),
                            ),
                          );
                        },
                        child: imageUrl != null && imageUrl.isNotEmpty
                            ? ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(height * 0.02),
                                child: Image.network(
                                  imageUrl,
                                  height: height * 0.18,
                                  width: width * 0.4,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      width: width * 0.4,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            height * 0.02),
                                        color: Colors.grey,
                                      ),
                                      child: const Center(
                                          child: Text("Failed to load image")),
                                    );
                                  },
                                ),
                              )
                            : Container(
                                height: height * 0.18,
                                width: width * 0.4,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(height * 0.02),
                                  color: Colors.grey.withOpacity(0.5),
                                ),
                                child: const Center(
                                    child: Text("No Image Available")),
                              ),
                      ),
                      SizedBox(
                        width: width * 0.02,
                      ),
                      // Wrap text container with GestureDetector for dialog
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            // Show full information in a dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: Text(canteenName),
                                content: SingleChildScrollView(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      if (address != null && address.isNotEmpty)
                                        Text(
                                          'Address:',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        ),
                                      if (address != null && address.isNotEmpty)
                                        Text(
                                          address,
                                          style: const TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      SizedBox(height: 8),
                                      if (openingHoursList.isNotEmpty)
                                        Text(
                                          "Operating Hours:",
                                          style: const TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ...openingHoursList.map((hour) => Text(
                                            hour,
                                            style: const TextStyle(
                                              fontSize: 16,
                                            ),
                                          )),
                                    ],
                                  ),
                                ),
                                actions: [
                                  MyButton3(
                                    color: Colors.white,
                                    onTap: () {
                                      Navigator.of(context)
                                          .pop(); // Close the dialog without action
                                    },
                                    text: "Close",
                                  ),
                                ],
                              ),
                            );
                          },
                          child: Container(
                            height: height * 0.18,
                            width: width * 0.4,
                            decoration: BoxDecoration(
                              color: Theme.of(context)
                                  .colorScheme
                                  .tertiaryContainer,
                              borderRadius:
                                  BorderRadius.circular(height * 0.02),
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: width * 0.02,
                              vertical: height * 0.005,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  canteenName,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontSize: height * 0.025,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                SizedBox(
                                  height: height * 0.005,
                                ),
                                // Address with wrapping
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.location_on,
                                      size: height * 0.02,
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        address ?? "",
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                        style: TextStyle(
                                          fontSize: height * 0.015,
                                          fontWeight: FontWeight.w300,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: height * 0.005),
                                // Opening Hours as a list
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.access_time_filled,
                                      size: height * 0.02,
                                    ),
                                    SizedBox(width: 4),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: openingHoursList
                                            .take(3)
                                            .map((hour) => Text(
                                                  hour,
                                                  style: TextStyle(
                                                    fontSize: height * 0.015,
                                                    fontWeight: FontWeight.w400,
                                                  ),
                                                ))
                                            .toList(),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList();

          // Return a Column with the category image and scrollable list
          return Column(
            children: [
              // Display the category image
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal: width * 0.04, vertical: 10),
                child: Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.categoryImageUrl,
                        fit: BoxFit.cover,
                        width: width,
                        height: height * 0.2,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: height * 0.2,
                            color: Colors.grey,
                            child: const Center(
                              child: Text("Failed to load image"),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      width: width,
                      height: height * 0.2,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.black.withOpacity(0.5),
                      ),
                    ),
                    SizedBox(
                      width: width,
                      height: height * 0.2,
                      child: Align(
                        alignment: Alignment.bottomRight,
                        child: Text(
                          '${widget.categoryId} ',
                          style: TextStyle(
                            fontSize: (30 / height) * height,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: height * 0.01,
              ),
              // Add the scrollable list of canteen widgets
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: width * 0.04),
                  child: ListView(
                    children: canteenWidgets,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
