import 'package:dip_app_2/models/unread_messages.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';
import 'package:dip_app_2/screens/friends/friends.dart';

class WechatIcon extends StatelessWidget {
  const WechatIcon({super.key});
  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<UnreadMessagesModel>().unreadCount;
    print('WechatIcon built with unreadCount: $unreadCount');

    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.wechat_rounded,
            color: Colors.white,
            size: 30,
          ),
          onPressed: () {
            // Navigate to FriendsPage
            CustomNavigator.navigateWithNoAnimation(context, FriendsPage());
          },
        ),
        if (unreadCount > 0)
          Positioned(
            top: 6,
            right: 6,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$unreadCount',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 10,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
