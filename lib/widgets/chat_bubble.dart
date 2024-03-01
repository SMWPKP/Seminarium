import 'package:flutter/material.dart';

class ChatBubble extends StatelessWidget{
  final String message;
  const ChatBubble({super.key, required this.message});


@override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12.0),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Text(message, style: const TextStyle(color: Colors.white, fontSize: 16) ,),
    );
  }


}