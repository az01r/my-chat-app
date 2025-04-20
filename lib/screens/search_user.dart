import 'package:chat_app/models/user.dart';
import 'package:chat_app/screens/chat.dart';
import 'package:chat_app/services/user_service.dart';
import 'package:flutter/material.dart';

class SearchUserScreen extends StatefulWidget {
  const SearchUserScreen({super.key});

  @override
  State<SearchUserScreen> createState() => _SearchUserScreenState();
}

class _SearchUserScreenState extends State<SearchUserScreen> {
  final _form = GlobalKey<FormState>();

  var _enteredEmail = '';

  var _isFetching = false;

  User? _fetchedUser;

  void _fetchUserByEmail() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) {
      return;
    }
    _form.currentState!.save();

    try {
      setState(() {
        _isFetching = true;
      });
      User? user = await UserService.searchUserByEmail(_enteredEmail);
      setState(() {
        _isFetching = false;
        _fetchedUser = user;
      });
    } catch (error) {
      setState(() {
        _isFetching = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).clearSnackBars();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$error'),
            duration: const Duration(seconds: 5),
          ),
        );
      }
    }
  }

  void _navigateToChat({
    required String userId,
    required String nickname,
    required String email,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (ctx) => ChatScreen(
                recipientUserId: userId,
                recipientNickname: nickname,
              )),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/chat.png',
              fit: BoxFit.cover,
            ),
          ),
          Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Card(
                    margin: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Form(
                          key: _form,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                decoration: const InputDecoration(
                                  labelText: 'Email address',
                                ),
                                keyboardType: TextInputType.emailAddress,
                                autocorrect: false,
                                textCapitalization: TextCapitalization.none,
                                validator: (value) => (value == null ||
                                        value.trim().isEmpty ||
                                        !RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
                                            .hasMatch(value))
                                    ? 'Please enter a valid email address'
                                    : null,
                                onSaved: (value) {
                                  _enteredEmail = value!;
                                },
                              ),
                              const SizedBox(height: 12),
                              if (_isFetching)
                                const CircularProgressIndicator(),
                              if (!_isFetching)
                                ElevatedButton(
                                  onPressed: _fetchUserByEmail,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Theme.of(context)
                                        .colorScheme
                                        .primaryContainer,
                                  ),
                                  child: const Text('Search'),
                                ),
                              if (_fetchedUser != null)
                                ListTile(
                                  leading: CircleAvatar(
                                    // Placeholder avatar
                                    child: Text(_fetchedUser!.nickname
                                        .substring(0, 1)
                                        .toUpperCase()),
                                  ),
                                  title: Text(_fetchedUser!.nickname),
                                  onTap: () => _navigateToChat(
                                    userId: _fetchedUser!.userId,
                                    nickname: _fetchedUser!.nickname,
                                    email: _fetchedUser!.email,
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
