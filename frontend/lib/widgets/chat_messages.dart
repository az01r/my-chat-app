import 'dart:async';
import 'dart:typed_data';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/message_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/widgets/message_bubble.dart';
import 'package:flutter/material.dart';

class ChatMessages extends StatefulWidget {
  final String recipientUserId;
  final String recipientNickname;
  final Uint8List? recipientAvatar;
  final Uint8List? avatar;
  final String nickname;

  const ChatMessages({
    super.key,
    required this.recipientUserId,
    required this.recipientNickname,
    this.recipientAvatar,
    required this.nickname,
    this.avatar,
  });

  @override
  State<ChatMessages> createState() => _ChatMessagesState();
}

class _ChatMessagesState extends State<ChatMessages> {
  StreamSubscription? _messageSubscription;
  List<Message> _messages = []; // Store messages for this chat
  late Future<List<Message>> _messagesFuture; // Future to hold messages

  @override
  void initState() {
    super.initState();
    _messagesFuture = MessageService.getMessagesWith(widget.recipientUserId);

    // Listen to incoming messages
    _messageSubscription = socketService.incomingMessages.listen((message) {
      if (message.senderUserId == widget.recipientUserId ||
          message.recipientUserId == widget.recipientUserId) {
        if (mounted) {
          setState(() {
            _messages.insert(
                0, message); // Add to beginning for ListView.builder reverse
          });
        }
      }
      // else {
      //   print("ChatScreen: Received message for different chat, ignoring.");
      // }
    });
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Message>>(
      future: _messagesFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}')); // Show error message
        } else if (snapshot.hasData) {
          _messages = snapshot.data!; // Assign the loaded messages
          return ListView.builder(
            reverse: true,
            itemCount: _messages.length,
            itemBuilder: (ctx, index) {
              final msg = _messages[index];
              final nextMsg =
                  index + 1 < _messages.length ? _messages[index + 1] : null;
              final nextUserIsSame = msg.senderUserId == nextMsg?.senderUserId;
              if (nextUserIsSame) {
                return MessageBubble.next(
                  message: msg.message,
                  timestamp: msg.timestamp,
                  isMe: msg.isOwn,
                );
              }
              return MessageBubble.first(
                avatar: msg.isOwn ? widget.avatar : widget.recipientAvatar,
                nickname: msg.isOwn ? widget.nickname : widget.recipientNickname,
                message: msg.message,
                timestamp: msg.timestamp,
                isMe: msg.isOwn,
              );
            },
          );
        } else {
          return const Center(
              child: Text('No messages found.')); // Handle empty data
        }
      },
    );
  }
}
