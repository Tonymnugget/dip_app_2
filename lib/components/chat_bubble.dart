import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String timestamp;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.timestamp,
  });

  @override
  build(BuildContext context) {
    // TODO: fix the darkmode for the chatbubbles
    // Get screen width
    double maxBubbleWidth = MediaQuery.of(context).size.width * 0.75;
    return Align(
      alignment: isCurrentUser ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxBubbleWidth),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            // if isCurrentUser chat bubble = blue? if not chat bubble = white
            color: isCurrentUser
                ? const Color.fromARGB(255, 46, 180, 234)
                : Theme.of(context).colorScheme.secondaryFixed,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(12),
              topRight: const Radius.circular(12),
              bottomLeft:
                  isCurrentUser ? const Radius.circular(12) : Radius.zero,
              bottomRight:
                  isCurrentUser ? Radius.zero : const Radius.circular(12),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Flexible(
                child: Text(
                  message,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                timestamp,
                style: TextStyle(fontSize: 12),
              )
            ],
          ),
        ),
      ),
    );
  }
}

/*
return Container(
      decoration: BoxDecoration(
        // if isCurrentUser chat buble = green if not chat bubble = white
        color: isCurrentUser
            ? const Color.fromARGB(255, 46, 180, 234)
            : Theme.of(context).colorScheme.tertiary,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      margin: EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
      child: RichText(
        text: TextSpan(
          children: [
            TextSpan(
                text: remainingMessage.isNotEmpty ? "$remainingMessage " : "",
                style: TextStyle(
                  color: Colors.black,
                )),
            TextSpan(text: lastWord),
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(left: 4.0),
                child: Text(
                  timestamp,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 10,
                  ),
                ),
              ),
              alignment: PlaceholderAlignment.top,
            ),
          ],
        ),
      ),
    );
    */
