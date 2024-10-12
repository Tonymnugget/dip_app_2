import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({super.key, required this.message, required this.isCurrentUser,});

  @override
  build(BuildContext context) {
    // change this part when integrating with frontend's chat page design
    return Container(
      decoration: BoxDecoration(
        // if isCurrentUser chat buble = green if not chat bubble = grey
        color: isCurrentUser ? Colors.green : Colors.grey.shade500, 
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
      child: Text(
        message,
        style: TextStyle(color: Colors.white),
      ), 
    );
  }
}