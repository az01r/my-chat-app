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

    final url = Uri.parse('${GlobalBackendUrl.kBackendUrl}/user/findByEmail')
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

  static Future<User?> searchUserById(String userId) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final url = Uri.parse('${GlobalBackendUrl.kBackendUrl}/user/findById')
        .replace(queryParameters: {'userId': userId});

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
            userData['email'] != null &&
            userData['nickname'] != null) {
          return User(
            userId: userId,
            nickname: userData['nickname'] as String,
            email: userData['email'] as String,
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

  static Future<List<User>> getContacts() async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final url = Uri.parse('${GlobalBackendUrl.kBackendUrl}/user/contacts');

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final contacts = responseBody['contacts'] as List?;
        if (contacts != null) {
          List<User> result = [];
          for (var contact in contacts) {
            result.add(User(
              userId: contact['userId'],
              nickname: contact['nickname'],
              email: contact['email'],
              avatar: contact['avatar'],
            ));
          }
          return result;
        } else {
          throw Exception('User data missing in successful response.');
        }
      } else {
        // Handle other errors (400, 401, 500 etc.)
        final responseBody = json.decode(response.body);
        final errorMessage = responseBody['message'] ?? 'Failed to load contacts';
        throw Exception(
            'Failed to load contacts: $errorMessage (${response.statusCode})');
      }
    } on TimeoutException catch (_) {
      throw Exception(
          'Load contacts request timed out. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }
}
