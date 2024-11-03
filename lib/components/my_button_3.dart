import 'package:flutter/material.dart';

class MyButton3 extends StatelessWidget {
  final String? text;
  final void Function()? onTap;
  final Color color;
  final Icon? icon;

  const MyButton3({
    super.key,
    this.text,
    required this.onTap,
    required this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: IntrinsicWidth(
        child: Container(
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(30),
          ),
          padding: const EdgeInsets.all(10),
          child: Center(
            child: text != null
                ? Text(
                    text!,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: Colors.black,
                    ),
                  )
                : icon != null
                    ? icon!
                    : const SizedBox(), // Fallback to empty box if neither is provided
          ),
        ),
      ),
    );
  }
}
