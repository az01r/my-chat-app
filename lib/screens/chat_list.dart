import 'package:chat_app/screens/search_user.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  void _navigateToSearchUser() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (ctx) => const SearchUserScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Chat App'),
        actions: [
          IconButton(
            onPressed: authService.logout,
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
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSearchUser,
        tooltip: 'New Chat',
        child: const Icon(Icons.add),
      ),
    );
  }
}
