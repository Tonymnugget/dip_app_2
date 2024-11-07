import 'package:flutter/material.dart';

class MyProfileButton extends StatelessWidget {
  final String? profileImageUrl;
  final void Function()? onTap;

  const MyProfileButton({
    super.key,
    required this.profileImageUrl,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: profileImageUrl != ''
          ? CircleAvatar(
              radius: 20,
              foregroundImage: NetworkImage(profileImageUrl!),
            )
          : CircleAvatar(
              backgroundColor: Colors.grey,
              radius: 20,
              child: Icon(Icons.person, size: 20),
            ),
    );
  }
}
