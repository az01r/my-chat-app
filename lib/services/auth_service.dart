import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:rxdart/rxdart.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

final authService = AuthService();

// Simple class to hold auth state (could be more complex)
class AuthState {
  final String? userId;
  final String? token; // Keep token for authenticated requests

  AuthState({this.userId, this.token});

  bool get isAuthenticated => userId != null && token != null;
}

class AuthService {
  // Use BehaviorSubject to replay the last state
  final _authStateController = BehaviorSubject<AuthState>.seeded(
      AuthState(userId: null, token: null)); // Start unauthenticated
  final _storage = const FlutterSecureStorage();
  final String _backendUrl =
      '${dotenv.env['BACKEND_URL']}:${dotenv.env['BACKEND_PORT']}';

  // Public stream for UI consumption
  Stream<AuthState> get authStateChanges => _authStateController.stream;

  // Get current state synchronously (use with caution)
  AuthState get currentState => _authStateController.value;

  AuthService() {
    _initialize(); // Check initial state when service is created
  }

  // Check storage on startup
  Future<void> _initialize() async {
    final token = await _storage.read(key: 'authToken');
    final userId = await _storage.read(key: 'userId');

    if (token != null && userId != null) {
      // Optional but recommended: Check if token is expired client-side
      // Note: Server verification is the *only* truly secure way
      if (JwtDecoder.isExpired(token)) {
        print("Stored token is expired. Logging out.");
        await logout(); // Clear expired token
      } else {
        print("Found valid token. User is logged in.");
        _authStateController.add(AuthState(userId: userId, token: token));
      }
    } else {
      print("No stored token found. User is logged out.");
      _authStateController.add(AuthState(userId: null, token: null));
    }
  }

  Future<void> signup({
    required String nickname,
    required String email,
    required String password,
    required String confirmPassword,
    required File profileImage,
  }) async {
    final url = Uri.parse('$_backendUrl/auth/signup');

    try {
      final response = await http
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

      _handleAuthResponse(response, isSignup: true);
    } on TimeoutException catch (_) {
      throw Exception(
          'Signup request timed out. Please check your connection.');
    } catch (e) {
      print("Signup Error (catch): $e");
      throw Exception('An unexpected error occurred during signup.');
    }
  }

  Future<void> login({required String email, required String password}) async {
    final url = Uri.parse('$_backendUrl/auth/login');

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

      await _handleAuthResponse(response);
    } on TimeoutException catch (_) {
      throw Exception('Login request timed out. Please check your connection.');
    } catch (e) {
      print("Login Error (catch): $e");
      throw Exception('An unexpected error occurred during login.');
    }
  }

  // Common response handling logic
  Future<void> _handleAuthResponse(http.Response response,
      {bool isSignup = false}) async {
    final responseBody = json.decode(response.body);

    if ((isSignup && response.statusCode == 201) ||
        (!isSignup && response.statusCode == 200)) {
      print('${isSignup ? 'Signup' : 'Login'} successful');

      if (isSignup) {
        // If signup doesn't return a token, you might need to call login immediately after
        // Or adjust your backend signup to return a token directly
        print(
            'Signup successful. User ID: ${responseBody['userId']}. Please login.');
        // Optionally, trigger login here or guide user
        return; // Don't proceed to token handling if signup doesn't provide one
      }

      // --- Handle Login Success (or Signup if it returns token) ---
      final token = responseBody['jwt'] as String?;
      if (token == null) {
        throw Exception('Login successful but no token received from server.');
      }

      // Decode USER ID from token (basic client-side decode)
      final Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
      final userId = decodedToken['userId'] as String?;

      if (userId == null) {
        throw Exception(
            'Login successful but could not extract userId from token.');
      }

      // Store securely
      await _storage.write(key: 'authToken', value: token);
      await _storage.write(key: 'userId', value: userId);

      // Update stream
      _authStateController.add(AuthState(userId: userId, token: token));
    } else {
      // Handle Errors
      final errorMessage = responseBody['message'] ??
          (responseBody['errors'] as List?)?.join(', ') ??
          'Unknown error';
      print(
          '${isSignup ? 'Signup' : 'Login'} failed (${response.statusCode}): $errorMessage');
      throw Exception('${isSignup ? 'Signup' : 'Login'} failed: $errorMessage');
    }
  }

  Future<void> logout() async {
    // Delete from storage
    await _storage.delete(key: 'authToken');
    await _storage.delete(key: 'userId');
    // Update stream
    _authStateController.add(AuthState(userId: null, token: null));
    print("User logged out.");
  }

  // Method to get the current token for authenticated requests (like Socket.IO)
  Future<String?> getToken() async {
    // Optionally add expiry check here too before returning
    final token = await _storage.read(key: 'authToken');
    if (token != null && JwtDecoder.isExpired(token)) {
      await logout(); // Log out if token is expired when trying to use it
      return null;
    }
    return token;
  }
}
