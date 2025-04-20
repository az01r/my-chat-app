import 'dart:async';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  final String recipientUserId;
  final String recipientNickname;

  const ChatMessages({
    super.key,
    required this.recipientUserId,
    required this.recipientNickname,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  StreamSubscription? _messageSubscription;
  final List<Message> _messages = []; // Store messages for this chat

  @override
  void initState() {
    super.initState();
    // Listen to incoming messages
    _messageSubscription = socketService.incomingMessages.listen((message) {
      // TODO: Filter messages meant for THIS specific chat screen
      // For now, adding all received messages for simplicity in example
      if (message.senderUserId == widget.recipientUserId ||
          message.recipientUserId == widget.recipientUserId) {
        print("ChatScreen: Received message relevant to this chat.");
        if (mounted) {
          setState(() {
            _messages.insert(
                0, message); // Add to beginning for ListView.builder reverse
          });
        }
      } else {
        print("ChatScreen: Received message for different chat, ignoring.");
      }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      reverse: true,
      itemCount: _messages.length,
      itemBuilder: (ctx, index) {
        final msg = _messages[index];
        // TODO: Build message bubbles (align left/right based on msg.isOwn)
        return ListTile(
          title: Text(msg.message),
          subtitle: Text('${msg.senderUserId} @ ${msg.timestamp.toLocal()}'),
          leading: msg.isOwn
              ? null
              : const Icon(Icons.person), // Example alignment hint
          trailing: msg.isOwn
              ? const Icon(Icons.person)
              : null, // Example alignment hint
        );
      },
    );

    // return ListView.builder(
    //   padding: const EdgeInsets.only(
    //     bottom: 40,
    //     left: 13,
    //     right: 13,
    //   ),
    //   reverse: true, // reverse the list order
    //   itemCount: loadedMessages.length,
    //   itemBuilder: (ctx, index) {
    //     final chatMessage = loadedMessages[index];
    //     final nextChatMessage = index + 1 < loadedMessages.length
    //         ? loadedMessages[index + 1]
    //         : null;
    //     final currentMessageUserId = chatMessage.senderUserId;
    //     final nextMessageUserId = nextChatMessage?.senderUserId;
    //     final nextUserIsSame = nextMessageUserId == currentMessageUserId;

    //     if (nextUserIsSame) {
    //       return MessageBubble.next(
    //           message: chatMessage.message,
    //           isMe: chatMessage.isOwn);
    //     }
    //     return MessageBubble.first(
    //         // userImage: chatMessage['userImage'],
    //         message: chatMessage.message,
    //         isMe: chatMessage.isOwn);
    //   },
    // );
  }
}
