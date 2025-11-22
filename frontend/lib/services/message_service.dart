import 'dart:async';
import 'dart:convert';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/services/auth_service.dart';
import 'package:chat_app/utils/global_backend_url.dart';
import 'package:http/http.dart' as http;

class MessageService {
  static Future<List<Message>> getMessagesWith(String theirId) async {
    final token = await authService.getToken();
    if (token == null) {
      throw Exception("Not authenticated.");
    }

    final url = Uri.parse('${GlobalBackendUrl.kBackendUrl}/message/with')
        .replace(queryParameters: {'theirId': theirId});

    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $token',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseBody = json.decode(response.body);
        final messages = responseBody['messages'] as List?;
        if (messages != null) {
          List<Message> result = [];
          for (var message in messages) {
            result.add(Message(
              messageId: message['_id'],
              senderUserId: message['sender'],
              recipientUserId: message['recipient'],
              message: message['content'],
              timestamp: DateTime.parse(message['createdAt']),
              isOwn: message['sender'] == authService.currentState.userId,
            ));
          }
          return result;
        } else {
          throw Exception('Messages data missing in successful response.');
        }
      } else {
        // Handle other errors (400, 401, 500 etc.)
        final responseBody = json.decode(response.body);
        final errorMessage =
            responseBody['message'] ?? 'Failed to load messages';
        throw Exception(
            'Failed to load messages: $errorMessage (${response.statusCode})');
      }
    } on TimeoutException catch (_) {
      throw Exception(
          'Load messages request timed out. Please check your connection.');
    } catch (e) {
      rethrow;
    }
  }
}
