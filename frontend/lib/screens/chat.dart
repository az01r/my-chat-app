import 'dart:typed_data';

import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/widgets/chat_messages.dart';
import 'package:chat_app/widgets/new_chat_message.dart';
import 'package:flutter/material.dart';

class ChatScreen extends StatefulWidget {
  final String recipientUserId;
  final String recipientNickname;
  final Uint8List? avatar;
  final Uint8List? recipientAvatar;

  const ChatScreen({
    super.key,
    required this.recipientUserId,
    required this.recipientNickname,
    this.avatar,
    this.recipientAvatar,
  });

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  late Future<String?> _nicknameFuture;
  String? _nickname;

  @override
  void initState() {
    super.initState();
    _nicknameFuture = authService.getNickname();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: _nicknameFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
              child: CircularProgressIndicator()); // Show loading indicator
        } else if (snapshot.hasError) {
          return Center(
              child: Text('Error: ${snapshot.error}')); // Show error message
        } else if (snapshot.hasData) {
          _nickname = snapshot.data;
          return Scaffold(
            appBar: AppBar(
              title: Text(widget.recipientNickname),
            ),
            body: Column(
              children: [
                Expanded(
                  child: ChatMessages(
                    nickname: _nickname ?? "?",
                    avatar: widget.avatar,
                    recipientUserId: widget.recipientUserId,
                    recipientNickname: widget.recipientNickname,
                    recipientAvatar: widget.recipientAvatar,
                  ),
                ),
                NewChatMessage(
                  recipientUserId: widget.recipientUserId,
                  recipientNickname: widget.recipientNickname,
                ),
              ],
            ),
          );
        } else {
          return const Center(
              child: Text('Error: nickname not found'));
        }
      },
    );
  }
}
