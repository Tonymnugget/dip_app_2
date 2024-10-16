import 'package:flutter/material.dart';

class MyTile extends StatelessWidget {
  final String text;
  final String? subtitle;
  final String? imageUrl; // To hold image URL
  final Widget? leading; // New parameter for leading widget (profile image)
  final void Function()? onTap;
  final Widget? trailing;

  const MyTile({
    super.key,
    required this.text,
    required this.onTap,
    this.subtitle,
    this.imageUrl,
    this.leading,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 25),
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            // Leading widget (profile image)
            if (leading != null) leading!,
            const SizedBox(width: 20),

            // Username and subtitle aligned left
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    text,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.inversePrimary,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            // Trailing widget (optional)
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }
}
