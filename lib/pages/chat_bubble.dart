import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;

  const ChatBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        vertical: 5.0,
        horizontal: isCurrentUser ? 10.0 : 20.0,
      ),
      padding: EdgeInsets.all(10.0),
      decoration: BoxDecoration(
        color: isCurrentUser ? Colors.blueAccent : Colors.green[300],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(15.0),
          topRight: Radius.circular(15.0),
          bottomLeft: isCurrentUser ? Radius.circular(15.0) : Radius.zero,
          bottomRight: isCurrentUser ? Radius.zero : Radius.circular(15.0),
        ),
      ),
      child: Text(
        message,
        style: TextStyle(color: isCurrentUser ? Colors.white : Colors.black87),
      ),
    );
  }
}
