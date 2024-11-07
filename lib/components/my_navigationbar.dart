import 'package:dip_app_2/components/my_wechat.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/food_finder/food_finder.dart';
import 'package:dip_app_2/screens/home/home.dart';
import 'package:dip_app_2/screens/matching/friend_finder.dart';
import 'package:dip_app_2/screens/profile/profile.dart';
import 'package:flutter/material.dart';

class MyNavigationBar extends StatelessWidget {
  const MyNavigationBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 60,
      color: Theme.of(context).colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: <Widget>[
            IconButton(
              icon: const Icon(
                Icons.home_rounded,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                CustomNavigator.navigateWithNoAnimation(context, HomePage());
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.person_search,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                CustomNavigator.navigateWithNoAnimation(
                    context, FriendFinderPage());
              },
            ),
            WechatIcon(),
            IconButton(
              icon: const Icon(
                Icons.fastfood,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                CustomNavigator.navigateWithNoAnimation(
                    context, CategoryScreen());
              },
            ),
            IconButton(
              icon: const Icon(
                Icons.person_pin_rounded,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                CustomNavigator.navigateWithNoAnimation(context, ProfilePage());
              },
            ),
          ],
        ),
      ),
    );
  }
}
