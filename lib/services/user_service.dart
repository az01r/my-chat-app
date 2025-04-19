import 'dart:async';
import 'dart:convert';

import 'package:chat_app/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/utils/global_backend_url.dart';

class UserService {
  static Future<User?> searchUserByEmail(String email) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final url = Uri.parse('${GlobalBackendUrl.kBackendUrl}/users/findByEmail')
        .replace(queryParameters: {'email': email});

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final userData = responseBody['user'];
        if (userData != null &&
            userData['userId'] != null &&
            userData['nickname'] != null) {
          return User(
            userId: userData['userId'] as String,
            nickname: userData['nickname'] as String,
            email: email,
          );
        } else {
          throw Exception('User data missing in successful response.');
        }
      } else if (response.statusCode == 404) {
        return null; // User not found is not an exception here
      } else {
        // Handle other errors (400, 401, 500 etc.)
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to search user';
        throw Exception(
            'Search failed: $errorMessage (${response.statusCode})');
      }
    } on TimeoutException catch (_) {
      throw Exception(
          'Search request timed out. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }
}
