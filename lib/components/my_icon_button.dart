import 'package:flutter/material.dart';

class MyIconButton extends StatelessWidget {
  final IconData icon;
  final void Function()? onTap;
  final double size;

  const MyIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    required this.size,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12), // Rounded square
        ),
        padding: const EdgeInsets.all(25),
        child: Center(
          child: Icon(
            icon,
            size: size,
            color: Colors.white, // Customize the icon color
          ),
        ),
      ),
    );
  }
}
