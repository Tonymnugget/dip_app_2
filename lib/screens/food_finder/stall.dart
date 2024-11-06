import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/screens/food_finder/food.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/svg.dart';

class StallScreen extends StatefulWidget {
  final String categoryId;
  final String canteenId;
  final String canteenImage;

  const StallScreen(
      {super.key,
      required this.categoryId,
      required this.canteenId,
      required this.canteenImage});

  @override
  State<StallScreen> createState() => _StallScreenState();
}

class _StallScreenState extends State<StallScreen> {
  Color greyContainerColor = Color(0xffCAD6DB);
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
      bottomNavigationBar: MyNavigationBar(),
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
          // print("stalls:$stalls"); // For debugging

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
                      widget.canteenImage,
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
                          widget.canteenId,
                          style: TextStyle(
                              fontSize: (30 / height) * height,
                              color: Colors.white,
                              fontWeight: FontWeight.w900),
                        ),
                        Text(
                          "operating Hours:",
                          style: TextStyle(
                              fontSize: (18 / height) * height,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
                        Text(
                          "Daily, --am to --pm",
                          style: TextStyle(
                              fontSize: (18 / height) * height,
                              color: Colors.white,
                              fontWeight: FontWeight.w500),
                        ),
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
                      // print("stall:$stall"); // For debugging
                      String stallId = stall.id;
                      Map<String, dynamic> stallData =
                          stall.data() as Map<String, dynamic>;

                      // Access the imageUrl directly
                      String? imageUrl = stallData['imageUrl'] as String?;
                      // If 'imageUrl' is null, try 'imageURL'
                      imageUrl ??= stallData['imageURL'] as String?;

                      // Access thumbsUp and thumbsDown
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
                              ),
                            ),
                          );
                        },
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 10),
                          child: Card(
                            elevation: 4,
                            child: Container(
                              height: (200 / height) * height,
                              width: width,
                              padding: EdgeInsets.all(height * 0.01),
                              decoration: BoxDecoration(
                                color: greyContainerColor,
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
                                            height: (130 / height) * height,
                                            width: double.infinity,
                                            fit: BoxFit.cover,
                                            errorBuilder:
                                                (context, error, stackTrace) {
                                              return Container(
                                                height: 100,
                                                color: Colors.grey,
                                                child: const Center(
                                                    child: Text(
                                                        "Failed to load image")),
                                              );
                                            },
                                          ),
                                        )
                                      : Container(
                                          height: 100,
                                          color: Colors.grey,
                                          child: const Center(
                                              child:
                                                  Text("No Image Available")),
                                        ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Text(
                                    stallId,
                                    style: TextStyle(
                                        fontSize: (17 / height) * height,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.black.withOpacity(0.8)),
                                  ),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Row(
                                    children: [
                                      Text(
                                        "---, ----",
                                        style: TextStyle(
                                            fontSize: (12 / height) * height,
                                            fontWeight: FontWeight.w400,
                                            color:
                                                Colors.black.withOpacity(0.8)),
                                      ),
                                      Spacer(),
                                      SvgPicture.asset(
                                        "assets/images/dislike.svg",
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      Text(
                                        thumbsUp != null
                                            ? thumbsUp
                                                .toString()
                                                .padLeft(2, "0")
                                            : "00",
                                        style: TextStyle(
                                            fontSize: height * 0.012,
                                            color: Colors.black),
                                      ),
                                      SizedBox(
                                        width: width * 0.02,
                                      ),
                                      SvgPicture.asset(
                                          "assets/images/like.svg"),
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
                                            fontSize: height * 0.012,
                                            color: Colors.black),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );

                      // ListTile(
                      //   title: Text(
                      //     stallId,
                      //     style: const TextStyle(fontWeight: FontWeight.bold),
                      //   ),
                      //   subtitle: Column(
                      //     crossAxisAlignment: CrossAxisAlignment.start,
                      //     children: [
                      //       const SizedBox(height: 8),
                      // imageUrl != null && imageUrl.isNotEmpty
                      //     ? Image.network(
                      //         imageUrl,
                      //         height: 100,
                      //         width: double.infinity,
                      //         fit: BoxFit.cover,
                      //         errorBuilder: (context, error, stackTrace) {
                      //           return Container(
                      //             height: 100,
                      //             color: Colors.grey,
                      //             child: const Center(
                      //                 child:
                      //                     Text("Failed to load image")),
                      //           );
                      //         },
                      //       )
                      //     : Container(
                      //         height: 100,
                      //         color: Colors.grey,
                      //         child: const Center(
                      //             child: Text("No Image Available")),
                      //       ),
                      //       const SizedBox(height: 8),
                      //       if (thumbsUp != null) Text("Likes: $thumbsUp"),
                      //       if (thumbsDown != null)
                      //         Text("Dislikes: $thumbsDown"),
                      //       Row(
                      //         children: [
                      //           IconButton(
                      //             icon: const Icon(Icons.thumb_up),
                      //             onPressed: () {
                      //               incrementThumbsUp(
                      //                   categoryId, canteenId, stallId);
                      //             },
                      //           ),
                      //           IconButton(
                      //             icon: const Icon(Icons.thumb_down),
                      //             onPressed: () {
                      //               incrementThumbsDown(
                      //                   categoryId, canteenId, stallId);
                      //             },
                      //           ),
                      //         ],
                      //       ),
                      //     ],
                      //   ),
                      //   onTap: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => FoodScreen(
                      //       categoryId: categoryId,
                      //       canteenId: canteenId,
                      //       stallId: stallId,
                      //     ),
                      //   ),
                      // );
                      //   },
                      // );
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

  void voteThumbsUp(String categoryId, String canteenId, String stallId,
      String userId) async {
    // Reference to the specific vote document for the user
    DocumentReference voteDoc = FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId)
        .collection('votes')
        .doc(userId);

    // Check if the user has already voted
    DocumentSnapshot docSnapshot = await voteDoc.get();

    if (docSnapshot.exists) {
      Map<String, dynamic> existingData =
          docSnapshot.data() as Map<String, dynamic>;

      // If user has already liked, do nothing; if disliked, update to like
      if (existingData['vote'] == 'thumbsUp') return;
      if (existingData['vote'] == 'thumbsDown') {
        FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('canteens')
            .doc(canteenId)
            .collection('stalls')
            .doc(stallId)
            .update({
          'thumbsUp': FieldValue.increment(1),
          'thumbsDown': FieldValue.increment(-1),
        });
        await voteDoc.update({'vote': 'thumbsUp'});
      }
    } else {
      // If no previous vote exists, register a thumbs up
      FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('canteens')
          .doc(canteenId)
          .collection('stalls')
          .doc(stallId)
          .update({'thumbsUp': FieldValue.increment(1)});
      await voteDoc.set({'vote': 'thumbsUp'});
    }
  }

  void voteThumbsDown(String categoryId, String canteenId, String stallId,
      String userId) async {
    DocumentReference voteDoc = FirebaseFirestore.instance
        .collection('categories')
        .doc(categoryId)
        .collection('canteens')
        .doc(canteenId)
        .collection('stalls')
        .doc(stallId)
        .collection('votes')
        .doc(userId);

    DocumentSnapshot docSnapshot = await voteDoc.get();

    if (docSnapshot.exists) {
      Map<String, dynamic> existingData =
          docSnapshot.data() as Map<String, dynamic>;

      // If user has already disliked, do nothing; if liked, update to dislike
      if (existingData['vote'] == 'thumbsDown') return;
      if (existingData['vote'] == 'thumbsUp') {
        FirebaseFirestore.instance
            .collection('categories')
            .doc(categoryId)
            .collection('canteens')
            .doc(canteenId)
            .collection('stalls')
            .doc(stallId)
            .update({
          'thumbsUp': FieldValue.increment(-1),
          'thumbsDown': FieldValue.increment(1),
        });
        await voteDoc.update({'vote': 'thumbsDown'});
      }
    } else {
      FirebaseFirestore.instance
          .collection('categories')
          .doc(categoryId)
          .collection('canteens')
          .doc(canteenId)
          .collection('stalls')
          .doc(stallId)
          .update({'thumbsDown': FieldValue.increment(1)});
      await voteDoc.set({'vote': 'thumbsDown'});
    }
  }
}
