import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_chat_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String recipientUserId;
  final String recipientNickname;

  const ChatScreen({
    super.key,
    required this.recipientUserId,
    required this.recipientNickname,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.recipientNickname),
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatMessages(
                recipientUserId: widget.recipientUserId,
                recipientNickname: widget.recipientNickname,
            ),
          ),
          NewChatMessage(
            recipientUserId: widget.recipientUserId,
            recipientNickname: widget.recipientNickname,
          ),
        ],
      ),
    );
  }
}
