import 'package:flutter/material.dart';

// Helper method to create interest chips

class MyChip extends StatelessWidget {
  final String label;
  const MyChip({super.key, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey),
        borderRadius: BorderRadius.circular(6),
        color: Theme.of(context).colorScheme.inversePrimary,
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'Poppins',
          fontSize: 12,
          color: Colors.black,
        ),
      ),
    );
  }
}
