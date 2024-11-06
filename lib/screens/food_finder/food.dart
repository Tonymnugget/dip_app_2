import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';

class FoodScreen extends StatefulWidget {
  final String categoryId;
  final String canteenId;
  final String stallId;
  final String stallImage;
  const FoodScreen({
    super.key,
    required this.categoryId,
    required this.canteenId,
    required this.stallId,
    required this.stallImage,
  });

  @override
  State<FoodScreen> createState() => _FoodScreenState();
}

class _FoodScreenState extends State<FoodScreen> {
  Color greyContainerColor = Color(0xffCAD6DB);
  bool like = false;
  bool dislike = false;
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

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;
    print('Navigated to FoodScreen');
    print(
        'categoryId: ${widget.categoryId}, canteenId: ${widget.canteenId}, stallId: ${widget.stallId}'); // Debugging

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
            .doc(widget.canteenId)
            .collection('stalls')
            .doc(widget.stallId)
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

          return Padding(
            padding: EdgeInsets.symmetric(horizontal: (15 / width) * width),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: height * 0.015,
                ),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.network(
                      widget.stallImage,
                      fit: BoxFit.cover,
                      height: height * 0.2,
                      width: width,
                    ),
                    Container(
                      width: width,
                      height: height * 0.2,
                      color: Colors.grey.withOpacity(
                          0.5), // Adjust opacity to control dullness
                    ),
                    Column(
                      children: [
                        Text(
                          widget.stallId,
                          style: TextStyle(
                              fontSize: (30 / height) * height,
                              color: Colors.white,
                              fontWeight: FontWeight.w900),
                        ),
                        Text(
                          "---, ---",
                          style: TextStyle(
                              fontSize: (16 / height) * height,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "operating Hours:",
                          style: TextStyle(
                              fontSize: (13 / height) * height,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                        Text(
                          "Daily, 7am to 8pm",
                          style: TextStyle(
                              fontSize: (13 / height) * height,
                              color: Colors.white,
                              fontWeight: FontWeight.w400),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(
                  height: height * 0.015,
                ),
                Card(
                  elevation: 4,
                  color: greyContainerColor,
                  child: Container(
                    height: (90 / height) * height,
                    width: width * 0.6,
                    decoration: BoxDecoration(
                        color: greyContainerColor,
                        borderRadius: BorderRadius.circular(height * 0.02)),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              like = true;
                              dislike = false;
                            });
                            incrementThumbsUp(widget.categoryId,
                                widget.canteenId, widget.stallId);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/images/dislike.svg",
                                height: height * 0.04,
                                width: width * 0.3,
                                color: like ? Colors.green : null,
                              ),
                              Text(
                                "Like",
                                style: TextStyle(
                                    fontSize: (15 / height) * height,
                                    color: like ? Colors.green : Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              dislike = true;
                              like = false;
                            });
                            incrementThumbsDown(widget.categoryId,
                                widget.canteenId, widget.stallId);
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SvgPicture.asset(
                                "assets/images/like.svg",
                                height: height * 0.04,
                                width: width * 0.3,
                                color: dislike ? Colors.red : null,
                              ),
                              Text(
                                "DisLike",
                                style: TextStyle(
                                    fontSize: (15 / height) * height,
                                    color: dislike ? Colors.red : Colors.black),
                              ),
                            ],
                          ),
                        ),
                        Spacer(),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: height * 0.015,
                ),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                        color: greyContainerColor,
                        borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(height * 0.02),
                            topRight: Radius.circular(height * 0.02))),
                    padding: EdgeInsets.symmetric(
                        vertical: (10 / height) * height,
                        horizontal: (13 / width) * width),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Menu:",
                          style: TextStyle(
                              fontSize: (25 / height) * height,
                              color: Colors.black.withOpacity(0.8),
                              fontWeight: FontWeight.w900),
                        ),
                        Divider(
                          thickness: height * 0.0013,
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Expanded(
                          child: ListView.builder(
                            itemCount: menuItems.length,
                            itemBuilder: (context, index) {
                              var menuItem = menuItems[index];
                              String itemName =
                                  menuItem['Item'] ?? 'Unknown Item';
                              String itemPrice = menuItem['Price'] ?? 'N/A';

                              return Padding(
                                padding: EdgeInsets.only(
                                  bottom: height * 0.015,
                                ),
                                child: Container(
                                  //height: (60 / height) * height,
                                  width: width,
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          width: height * 0.001,
                                          color: Colors.black)),
                                  // padding: EdgeInsets.all(height * 0.004),
                                  child: ListTile(
                                    title: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                            width: width * 0.6,
                                            child: Text(
                                              itemName,
                                              style: TextStyle(
                                                  fontSize:
                                                      (17 / height) * height,
                                                  color: Colors.black,
                                                  fontWeight: FontWeight.w800),
                                            )),
                                        Spacer(),
                                        Text(
                                          "$itemPrice",
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                              fontSize: (17 / height) * height,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w800),
                                        ),
                                      ],
                                    ),
                                    // trailing:
                                    subtitle: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Description:",
                                          style: TextStyle(
                                              fontSize: (12 / height) * height,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                        Text(
                                          "Contains:",
                                          style: TextStyle(
                                              fontSize: (12 / height) * height,
                                              color: Colors.black,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
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
