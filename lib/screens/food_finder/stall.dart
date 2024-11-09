import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/screens/food_finder/food.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';

class StallScreen extends StatefulWidget {
  final String categoryId;
  final String canteenId;
  final String canteenImage;
  final List<String> canteenOpeningHours;

  const StallScreen({
    super.key,
    required this.categoryId,
    required this.canteenId,
    required this.canteenImage,
    required this.canteenOpeningHours,
  });

  @override
  State<StallScreen> createState() => _StallScreenState();
}

class _StallScreenState extends State<StallScreen> {
  List<String> stallOpeningHoursList = [];

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

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
      bottomNavigationBar: const MyNavigationBar(),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection('canteens')
            .doc(widget.canteenId)
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

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: width * 0.04),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height * 0.015,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        widget.canteenImage,
                        fit: BoxFit.cover,
                        height: height * 0.2,
                        width: width,
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
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          widget.canteenId,
                          style: TextStyle(
                            fontSize: (30 / height) * height,
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        Text(
                          "Operating Hours:",
                          style: TextStyle(
                            fontSize: (14 / height) * height,
                            color: Colors.white,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        ...widget.canteenOpeningHours.map((hour) => Text(
                              hour,
                              style: TextStyle(
                                fontSize: (14 / height) * height,
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            )),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.02,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: stalls.length,
                    itemBuilder: (context, index) {
                      var stall = stalls[index];
                      String stallId = stall.id;
                      Map<String, dynamic> stallData =
                          stall.data() as Map<String, dynamic>;

                      // Access the imageUrl
                      String? imageUrl = stallData['imageUrl'] as String?;
                      imageUrl ??= stallData['imageURL'] as String?;

                      // Handle Stall Opening Hours
                      String stallOpeningHours;
                      if (stallData['Opening Hours'] is List) {
                        stallOpeningHours =
                            (stallData['Opening Hours'] as List<dynamic>)
                                .join(", ");
                        stallOpeningHoursList = List<String>.from(
                            stallData['Opening Hours'] as List<dynamic>);
                      } else if (stallData['Opening Hours'] is String) {
                        stallOpeningHours = stallData['Opening Hours'];
                      } else {
                        stallOpeningHours = "---";
                      }

                      int? thumbsUp = stallData['thumbsUp'] as int?;
                      int? thumbsDown = stallData['thumbsDown'] as int?;

                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => FoodScreen(
                                categoryId: widget.categoryId,
                                canteenId: widget.canteenId,
                                stallId: stallId,
                                stallImage: imageUrl ?? "",
                                stallOpeningHours: stallOpeningHoursList,
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Card(
                            elevation: 4,
                            child: Container(
                              width: width,
                              padding: EdgeInsets.all(height * 0.01),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.secondary,
                                borderRadius: BorderRadius.circular(0.05),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  imageUrl != null && imageUrl.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              height * 0.02),
                                          child: Image.network(
                                            imageUrl,
                                            height: height * 0.2,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: height * 0.2,
                                                color: Colors.grey,
                                                child: const Center(
                                                  child: Text(
                                                      "Failed to load image"),
                                                ),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(
                                          height: height * 0.2,
                                          color: Colors.grey,
                                          child: const Center(
                                              child:
                                                  Text("No Image Available")),
                                        ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    stallId,
                                    style: TextStyle(
                                      fontSize: (17 / height) * height,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    stallOpeningHours,
                                    style: TextStyle(
                                      fontSize: (14 / height) * height,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      SvgPicture.asset(
                                        "assets/images/like.svg",
                                        height: height * 0.02,
                                      ),
                                      SizedBox(
                                        width: width * 0.018,
                                      ),
                                      Text(
                                        thumbsUp != null
                                            ? thumbsUp
                                                .toString()
                                                .padLeft(2, "0")
                                            : "00",
                                        style: TextStyle(
                                          fontSize: height * 0.018,
                                        ),
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      SvgPicture.asset(
                                        "assets/images/dislike.svg",
                                        height: height * 0.018,
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      Text(
                                        thumbsDown != null
                                            ? thumbsDown
                                                .toString()
                                                .padLeft(2, "0")
                                            : "00",
                                        style: TextStyle(
                                          fontSize: height * 0.018,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
