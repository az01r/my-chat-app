import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthService {
  final _backendUrl =
      'http://${dotenv.env['BACKEND_URL']}:${dotenv.env['BACKEND_PORT']}';

  Future<http.Response> login(String email, String password) async {
    final url = Uri.parse('$_backendUrl/auth/login');
    return http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'email': email,
            'password': password,
          }),
        )
        .timeout(const Duration(seconds: 5));
  }

  Future<http.Response> signup(String nickname, String email, String password,
      String confirmPassword) async {
    final url = Uri.parse('$_backendUrl/auth/signup');
    if (confirmPassword != password) {
      throw Exception('Passwords do not match');
    }
    return http
        .post(
          url,
          headers: {'Content-Type': 'application/json'},
          body: json.encode({
            'nickname': nickname,
            'email': email,
            'password': password,
            'confirmPassword': confirmPassword,
          }),
        )
        .timeout(const Duration(seconds: 5));
  }
}

class AuthState {
  final String? userId;
  final String? jwt;

  AuthState(this.userId, this.jwt);

  bool get isAuthenticated => userId != null && jwt != null;
}
