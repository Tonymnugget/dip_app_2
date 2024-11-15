import 'package:dip_app_2/models/unread_requests.dart';
import 'package:dip_app_2/screens/notifications/notifcations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dip_app_2/helper/navigator_animation.dart';

class WechatIcon extends StatelessWidget {
  const WechatIcon({super.key});
  @override
  Widget build(BuildContext context) {
    final unreadCount = context.watch<UnreadRequestsModel>().unreadCount;
    print('Notification Icon built with unreadCount: $unreadCount');

    return Stack(
      children: [
        IconButton(
          icon: const Icon(
            Icons.favorite,
            color: Colors.white,
          ),
          onPressed: () {
            Navigator.push(
                context, CustomNavigator.createSlideRoute(NotificationPage()));
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
