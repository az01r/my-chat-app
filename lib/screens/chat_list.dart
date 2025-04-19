import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chat App'),
        actions: [
          IconButton(
            onPressed: () {
              authService.logout();
            },
            icon: Icon(
              Icons.exit_to_app,
              color: Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
      body: const Center(
        child: Text(
          'Chat List Screen - Placeholder',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
