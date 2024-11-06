import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/screens/food_finder/stall.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CanteenScreen extends StatefulWidget {
  final String categoryId;

  const CanteenScreen({super.key, required this.categoryId});

  @override
  State<CanteenScreen> createState() => _CanteenScreenState();
}

class _CanteenScreenState extends State<CanteenScreen> {
  Color greyContainerColor = Color(0xffCAD6DB);
  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    height = height == 0 ? 1 : height;
    width = width == 0 ? 1 : width;
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
        stream: FirebaseFirestore.instance
            .collection('categories')
            .doc(widget.categoryId)
            .collection('canteens')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No canteens available"));
          }

          var canteens = snapshot.data!.docs;

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: (15 / width) * width),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(
                  "assets/images/Residential halls.png",
                  fit: BoxFit.fitWidth,
                ),
                SizedBox(
                  height: height * 0.01,
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: canteens.length,
                    itemBuilder: (context, index) {
                      var canteen = canteens[index];
                      var canteenData = canteen.data() as Map<String, dynamic>;

                      // Access the image URL and name
                      String? imageUrl = canteenData['imageURL'] as String?;
                      imageUrl ??= canteenData['imageUrl'] as String?;

                      String canteenName = canteenData['name'] ?? canteen.id;
                      print(imageUrl);
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => StallScreen(
                                categoryId: widget.categoryId,
                                canteenId: canteen.id,
                                canteenImage: imageUrl ?? "",
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding:
                              EdgeInsets.only(bottom: (5 / height) * height),
                          child: Card(
                              elevation: 4,
                              child: Container(
                                height: (140 / height) * height,
                                width: width,
                                padding: EdgeInsets.symmetric(
                                    vertical: (5 / height) * height,
                                    horizontal: (10 / width) * width),
                                decoration: BoxDecoration(
                                    color: greyContainerColor,
                                    borderRadius:
                                        BorderRadius.circular(height * 0.01)),
                                child: Row(
                                  children: [
                                    imageUrl != null && imageUrl.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                height * 0.02),
                                            child: Image.network(
                                              imageUrl,
                                              height: 120,
                                              width: width * 0.4,
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                return Container(
                                                  width: width * 0.4,
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            height * 0.02),
                                                    color: Colors.grey,
                                                  ),
                                                  child: const Center(
                                                      child: Text(
                                                          "Failed to load image")),
                                                );
                                              },
                                            ),
                                          )
                                        : Container(
                                            height: 120,
                                            width: width * 0.4,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      height * 0.02),
                                              color:
                                                  Colors.grey.withOpacity(0.5),
                                            ),
                                            child: const Center(
                                                child:
                                                    Text("No Image Available")),
                                          ),
                                    SizedBox(
                                      width: width * 0.02,
                                    ),
                                    Container(
                                      height: (95 / height) * height,
                                      width: (180 / width) * width,
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(
                                              height * 0.02)),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: (10 / width) * width,
                                          vertical: (5 / height) * height),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SizedBox(
                                            width: width * 0.4,
                                            child: Text(
                                              canteenName,
                                              style: TextStyle(
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  fontSize:
                                                      (17 / height) * height,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w900),
                                            ),
                                          ),
                                          SizedBox(
                                            height: height * 0.005,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "---",
                                              style: TextStyle(
                                                  fontSize:
                                                      (12 / height) * height,
                                                  fontWeight: FontWeight.w300,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "Operating Hours:",
                                              style: TextStyle(
                                                  fontSize:
                                                      (10 / height) * height,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                          ),
                                          Spacer(),
                                          Padding(
                                            padding: EdgeInsets.only(left: 10),
                                            child: Text(
                                              "Daily, --am to --pm",
                                              style: TextStyle(
                                                  fontSize:
                                                      (10 / height) * height,
                                                  fontWeight: FontWeight.w400,
                                                  color: Colors.black),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              )),
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
