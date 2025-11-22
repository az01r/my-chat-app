import 'dart:async';
import 'dart:typed_data';

import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/screens/search_user.dart';
import 'package:chat_app/services/image_service.dart';
import 'package:chat_app/services/socket_service.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:chat_app/utils/global_backend_url.dart';
import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  StreamSubscription? _messageSubscription;
  List<User> _contacts = [];
  late Uint8List _avatar;

  void _navigateToSearchUser() {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => SearchUserScreen(onTabFetchedUser: navigateToChat)),
    );
  }

  bool _containsUserWithId(List<User> contacts, String userId) {
    for (var user in contacts) {
      if (user.userId == userId) {
        return true;
      }
    }
    return false;
  }

  void navigateToChat({
    required String userId,
    required String nickname,
    required String email,
    Uint8List? avatar,
    Uint8List? theirAvatar,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (ctx) => ChatScreen(
          recipientUserId: userId,
          recipientNickname: nickname,
          avatar: avatar,
          recipientAvatar: theirAvatar,
        ),
      ),
    );
  }

  void _loadContacts() async {
    _contacts = await UserService.getContacts();
    // Listen to incoming messages
    _messageSubscription =
        socketService.incomingMessages.listen((message) async {
      if (!_containsUserWithId(_contacts, message.senderUserId)) {
        User? user = await UserService.searchUserById(message.senderUserId);
        print("ContacsScreen: Received message from a new contact.");
        if (mounted && user != null) {
          setState(() {
            _contacts.insert(
                0, user); // Add to beginning for ListView.builder reverse
          });
        }
      } else {
        print("ChatScreen: Received message for different chat, ignoring.");
      }
    });
  }

  void _loadAvatar() async {
    String? path = await authService.getAvatarPath();
    if (path == null) {
      String? userId = await authService.getUserId();
      if (userId == null) return;
      User? user = await UserService.searchUserById(userId);
      if (user == null || user.avatarPath == null) return;
      path = user.avatarPath;
    }
    _avatar = await ImageService.fetchImage("${GlobalBackendUrl.kBackendUrl}/$path");
  }

  @override
  void dispose() {
    _messageSubscription?.cancel();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadContacts();
    _loadAvatar();
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
      body: FutureBuilder<List<User>>(
        future: UserService.getContacts(),
        builder: (BuildContext context, AsyncSnapshot<List<User>> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator()); // Show loading indicator
          } else if (snapshot.hasError) {
            return Center(
                child: Text('Error: ${snapshot.error}')); // Show error message
          } else if (snapshot.hasData) {
            _contacts =
                snapshot.data!; // Update _contacts with the fetched data
            return Center(
              child: ListView.builder(
                itemCount: _contacts.length,
                itemBuilder: (ctx, index) {
                  final contact = _contacts[index];
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: contact.avatar != null
                          ? MemoryImage(contact.avatar!)
                          : null,
                      child: contact.avatar == null
                          ? Text(contact.nickname.substring(0, 1).toUpperCase())
                          : null,
                    ),
                    title: Text(contact.nickname),
                    subtitle: Text(contact.email),
                    onTap: () => navigateToChat(
                        userId: contact.userId,
                        nickname: contact.nickname,
                        email: contact.email,
                        avatar: _avatar,
                        theirAvatar: contact.avatar),
                  );
                },
              ),
            );
          } else {
            return const Center(
                child: Text('No contacts found.')); // Handle empty data
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToSearchUser,
        tooltip: 'New Chat',
        child: const Icon(Icons.add),
      ),
    );
  }
}
