import 'dart:async';

import 'package:chat_app/models/message.dart';
import 'package:chat_app/utils/global_backend_url.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'auth_service.dart';

final socketService = SocketService();

class SocketService {
  io.Socket? _socket;

  // Stream for incoming messages (broadcast if multiple widgets might listen)
  final StreamController<Message> _messageController =
      StreamController<Message>.broadcast();

  Stream<Message> get incomingMessages => _messageController.stream;

  Future<void> connect() async {
    final token = await authService.getToken();
    if (token == null) {
      return;
    }

    try {
      print("SocketService: Using server URL: ${GlobalBackendUrl.kBackendUrl}");

      _socket = io.io(
        GlobalBackendUrl.kBackendUrl,
        io.OptionBuilder()
            .setTransports(['websocket']) // Use WebSocket transport primarily
            .disableAutoConnect() // Connect manually using connect()
            .setAuth({'token': token}) // Send token for authentication
            .build(),
      );

      _socket!.onConnectError((err) {
        print('SocketService: Connection Error: $err');
        authService.logout(); // Force logout if server rejects token
      });

      _socket!.onError((err) {
        print('SocketService: General Socket Error: $err');
      });

      _socket!.on('receive_private_message', (data) {
        _receivePrivateMessage(data as Map);
      });

      _socket!.connect();
    } catch (e) {
      print("SocketService: Error during connection setup: $e");
    }
  }

  void sendPrivateMessage(String recipientUserId, String message) {
    if (_socket?.connected != true) {
      throw Exception(
          'SocketService: Cannot send message, socket not connected.');
    }

    final payload = {
      'recipientUserId': recipientUserId,
      'message': message,
    };

    _socket!.emitWithAck(
      'private_message',
      payload,
      ack: (Map ackData) {
        final success = ackData['success'] as bool? ?? false;
        final error = ackData['error'] as String?;
        final messageId = ackData['messageId'] as String?;
        final createdAt = ackData['createdAt'] as String?;

        if (!success) {
          throw Exception(
              'SocketService: Server can not send the message: $error');
        }
        if (messageId == null) {
          throw Exception(
              'SocketService: Server didn\'t returned the messageId');
        }
        if (createdAt == null) {
          throw Exception(
              'SocketService: Server didn\'t returned createdAt');
        }

        final currentUserId = authService.currentState.userId;
        if (currentUserId != null) {
          final sentMessage = Message(
            messageId: messageId,
            senderUserId: currentUserId,
            recipientUserId: recipientUserId,
            message: message,
            timestamp: DateTime.parse(createdAt).toLocal(),
            isOwn: true,
          );
          // Add to stream so UI updates immediately
          _messageController.add(sentMessage);
        }
      },
    );
  }

  void disconnect() {
    // _messageController.close();
    _socket?.disconnect();
    _socket?.dispose(); // Clean up resources
    _socket = null;
  }

  void _receivePrivateMessage(Map data) async {
    final userId = await authService.getUserId();
    if (userId == null) {
      return;
    }

    print('SocketService: Received private_message: $data');
    try {
      final message = Message(
        messageId: data['messageId'] as String,
        senderUserId: data['senderUserId'] as String,
        recipientUserId: userId,
        message: data['message'] as String,
        timestamp: DateTime.parse(data['createdAt'] as String)
            .toLocal(), // Parse timestamp
        isOwn: false, // This message is always received from others
      );
      _messageController.add(message);
    } catch (e) {
      print('SocketService: Error parsing received message: $e');
    }
  }
}
