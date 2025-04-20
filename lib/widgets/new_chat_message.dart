import 'package:chat_app/services/socket_service.dart';
import 'package:flutter/material.dart';

class NewChatMessage extends StatefulWidget {
  final String recipientUserId;
  final String recipientNickname;

  const NewChatMessage({
    super.key,
    required this.recipientUserId,
    required this.recipientNickname,
  });

  @override
  State<NewChatMessage> createState() {
    return _NewChatMessageState();
  }
}

class _NewChatMessageState extends State<NewChatMessage> {
  final _messageController = TextEditingController();

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  void _sendMessage() async {
    final enteredMessage = _messageController.text.trim();

    if (enteredMessage.isEmpty) {
      return;
    }

    try {
      socketService.sendPrivateMessage(widget.recipientUserId, enteredMessage);
      FocusScope.of(context)
          .unfocus(); // removes the focus from the input closing the keyboard
      _messageController.clear();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to send the message: $error')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 15,
        right: 1,
        bottom: 14,
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              textCapitalization: TextCapitalization.sentences,
              autocorrect: true,
              enableSuggestions: true,
              decoration:
                  const InputDecoration(label: Text('Send a message...')),
            ),
          ),
          IconButton(
            color: Theme.of(context).colorScheme.primary,
            icon: const Icon(
              Icons.send,
            ),
            onPressed: _sendMessage,
          )
        ],
      ),
    );
  }
}
