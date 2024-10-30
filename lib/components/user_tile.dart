import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final void Function()? onTap;
  final Widget? trailing; // New trailing widget for icons or buttons

  const UserTile({
    super.key,
    required this.text,
    required this.onTap,
    this.trailing, // Optional trailing widget
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            // User icon
            const Icon(Icons.person),
            const SizedBox(width: 20),

            // Username text
            Expanded(
              child: Text(text),
            ),

            // Trailing widget (optional), e.g., message button
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
