import 'package:dip_app_2/components/like_dislike_buttons.dart';
import 'package:dip_app_2/components/menu_list.dart';
import 'package:dip_app_2/components/my_navigationbar.dart';
import 'package:dip_app_2/services/auth/auth_service.dart';
import 'package:flutter/material.dart';

class FoodScreen extends StatelessWidget {
  final String categoryId;
  final String canteenId;
  final String stallId;
  final String stallImage;
  final List<String> stallOpeningHours;

  const FoodScreen({
    super.key,
    required this.categoryId,
    required this.canteenId,
    required this.stallId,
    required this.stallImage,
    required this.stallOpeningHours,
  });

  @override
  Widget build(BuildContext context) {
    // Use MediaQuery inside build method
    double height = MediaQuery.of(context).size.height;
    double width = MediaQuery.of(context).size.width;

    final AuthService authService = AuthService();
    final currentUserId = authService.getCurrentUser()!.uid;

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
      body: Padding(
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
                    stallImage,
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
                  children: [
                    Text(
                      stallId,
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
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    ...stallOpeningHours.map((hour) => Text(
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
              height: height * 0.015,
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.secondary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(height * 0.02),
                    topRight: Radius.circular(height * 0.02),
                  ),
                ),
                padding: EdgeInsets.symmetric(
                  vertical: height * 0.01,
                  horizontal: width * 0.03,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Use the LikeDislikeButtons widget
                    LikeDislikeButtons(
                      categoryId: categoryId,
                      canteenId: canteenId,
                      stallId: stallId,
                      currentUserId: currentUserId,
                    ),
                    Divider(
                      thickness: height * 0.0013,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    // Menu Items List
                    Expanded(
                      child: MenuList(
                        categoryId: categoryId,
                        canteenId: canteenId,
                        stallId: stallId,
                        height: height,
                        width: width,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
