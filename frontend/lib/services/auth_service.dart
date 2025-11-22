import 'dart:async';
import 'dart:convert';

import 'package:chat_app/services/socket_service.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:chat_app/utils/global_backend_url.dart';
import 'package:chat_app/models/auth_state.dart';

final authService = AuthService();

class AuthService {
  // BehaviorSubject replay the last state
  final _authStateController =
      BehaviorSubject<AuthState>.seeded(AuthState(userId: null, token: null));

  final _storage = const FlutterSecureStorage();

  Stream<AuthState> get authStateChanges => _authStateController.stream;

  AuthState get currentState => _authStateController.value;

  AuthService() {
    _setAuthState();
  }

  Future<void> _setAuthState() async {
    final token = await getToken();
    if (token == null) return;

    final userId = await getUserId();
    if (userId == null) return;

    _authStateController.add(AuthState(userId: userId, token: token));
  }

  Future<String?> getToken() async {
    final token = await _storage.read(key: 'authToken');
    if (token == null || JwtDecoder.isExpired(token)) {
      await logout();
      return null;
    }
    return token;
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }

  Future<String?> getNickname() async {
    return await _storage.read(key: 'nickname');
  }

  Future<String?> getAvatarPath() async {
    return await _storage.read(key: 'avatarPath');
  }

  Future<void> signup({
    required String nickname,
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${GlobalBackendUrl.kBackendUrl}/auth/signup');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode(
                {'nickname': nickname, 'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 5));

      final responseBody = json.decode(response.body);
      if (response.statusCode == 201) {
        final token = responseBody['jwt'] as String?;
        if (token == null) {
          throw Exception(
              'Signup successful but no token received from server.');
        }

        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['userId'] as String?;

        // Store data & update stream
        await _storage.write(key: 'authToken', value: token);
        await _storage.write(key: 'userId', value: userId);
        await _storage.write(key: 'nickname', value: nickname);
        _authStateController.add(AuthState(userId: userId, token: token));

        socketService.connect();
      } else {
        final errorMessage = responseBody['message'];
        throw Exception('Signup failed: $errorMessage');
      }
    } on TimeoutException catch (_) {
      await logout();
      throw Exception(
          'Signup request timed out. Please check your connection.');
    } catch (error) {
      await logout();
      rethrow;
    }
  }

  Future<void> login({required String email, required String password}) async {
    final url = Uri.parse('${GlobalBackendUrl.kBackendUrl}/auth/login');

    try {
      final response = await http
          .post(
            url,
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 5));

      final responseBody = json.decode(response.body);
      if (response.statusCode == 200) {
        final token = responseBody['jwt'] as String?;
        if (token == null) {
          throw Exception(
              'Login successful but no token received from server.');
        }

        final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        final userId = decodedToken['userId'] as String?;
        final nickname = decodedToken['nickname'] as String?;
        final avatarPath = decodedToken['avatarPath'] as String?;

        // Store data & update stream
        await _storage.write(key: 'authToken', value: token);
        await _storage.write(key: 'userId', value: userId);
        await _storage.write(key: 'nickname', value: nickname);
        await _storage.write(key: 'avatarPath', value: avatarPath);
        _authStateController.add(AuthState(userId: userId, token: token));
        socketService.connect();
      } else {
        final errorMessage = responseBody['message'] ?? 'Unknown error';
        throw Exception('Login failed: $errorMessage');
      }
    } on TimeoutException catch (_) {
      await logout();
      throw Exception('Login request timed out. Please check your connection.');
    } catch (error) {
      await logout();
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      // Delete from storage & update stream
      await _storage.delete(key: 'authToken');
      await _storage.delete(key: 'userId');
      await _storage.delete(key: 'nickname');
      await _storage.delete(key: 'avatarPath');
      _authStateController.add(AuthState(userId: null, token: null));
      socketService.disconnect();
    } catch (error) {
      print('Error occured while logging out: $error');
    }
  }
}
