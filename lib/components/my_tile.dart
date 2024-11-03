import 'package:flutter/material.dart';

class MyTile extends StatelessWidget {
  final String text;
  final String? subtitle;
  final String? imageUrl; // To hold image URL
  final Widget? leading; // New parameter for leading widget (profile image)
  final void Function()? onTap;
  final Widget? trailing;
  final String? timestamp;

  const MyTile({
    super.key,
    required this.text,
    required this.onTap,
    this.subtitle,
    this.imageUrl,
    this.leading,
    this.trailing,
    this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
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
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  if (subtitle != null)
                    Text(
                      subtitle!,
                      style: TextStyle(
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),

            // Column for timestamp and trailing icon
            if (timestamp != null || trailing != null)
              Column(
                children: [
                  if (timestamp != null)
                    Text(
                      timestamp!,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  if (trailing != null) trailing!,
                ],
              ),
          ],
        ),
      ),
    );
  }
}
