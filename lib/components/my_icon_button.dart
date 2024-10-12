import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final void Function()? onTap;

  const MyIconButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.primary,
          borderRadius: BorderRadius.circular(12), // Rounded square
        ),
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Icon(
            icon,
            size: 36.0,
            color: Colors.white, // Customize the icon color
          ),
        ),
      ),
    );
  }
}
