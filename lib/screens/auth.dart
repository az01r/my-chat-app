import 'package:flutter/material.dart';
import 'package:chat_app/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<StatefulWidget> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final _form = GlobalKey<FormState>();

  var _isLogin = true;
  var _enteredNickname = '';
  var _enteredEmail = '';
  var _enteredPassword = '';
  var _enteredConfirmPassword = '';

  void _submit() async {
    final isValid = _form.currentState!.validate();
    if (!isValid) return;

    _form.currentState!.save();

    try {
      if (_isLogin) {
        await kAuthService.login(
            email: _enteredEmail, password: _enteredPassword);
      } else {
        await kAuthService.signup(
            nickname: _enteredNickname,
            email: _enteredEmail,
            password: _enteredPassword,
            confirmPassword: _enteredConfirmPassword);
      }
    } catch (error) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.primary,
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                margin: const EdgeInsets.only(
                  top: 30,
                  bottom: 20,
                  left: 20,
                  right: 20,
                ),
                width: 200,
                child: Image.asset('assets/images/chat.png'),
              ),
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
                              labelText: 'Nickname',
                            ),
                            keyboardType: TextInputType.name,
                            textCapitalization: TextCapitalization.none,
                            validator: (value) =>
                                (value == null || value.trim().isEmpty)
                                    ? 'Please enter a nickname'
                                    : null,
                            onSaved: (value) {
                              _enteredNickname = value!;
                            },
                          ),
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
                          TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Password',
                            ),
                            obscureText: true,
                            validator: (value) => (value == null ||
                                    value.trim().isEmpty ||
                                    value.length < 8)
                                ? 'Password must be at least 8 characters long'
                                : null,
                            onSaved: (value) {
                              _enteredPassword = value!;
                            },
                          ),
                          if (!_isLogin)
                            TextFormField(
                              decoration: const InputDecoration(
                                labelText: 'Confirm Password',
                              ),
                              obscureText: true,
                              validator: (value) => (value == null ||
                                      value.trim().isEmpty ||
                                      value.length < 8)
                                  ? 'Password must be at least 8 characters long'
                                  : null,
                              onSaved: (value) {
                                _enteredConfirmPassword = value!;
                              },
                            ),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: _submit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                            ),
                            child: Text(_isLogin ? 'Login' : 'Signup'),
                          ),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                _isLogin = !_isLogin;
                              });
                            },
                            child: Text(_isLogin
                                ? 'Create an account'
                                : 'I already have an account'),
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
    );
  }
}
