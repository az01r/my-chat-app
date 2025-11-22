import 'dart:io';

class Message {
  final String messageId;
  final String senderUserId;
  final String recipientUserId;
  final String message;
  final DateTime timestamp;
  final bool isOwn; // Helper flag for UI
  final File? avatar;

  Message({
    required this.messageId,
    required this.senderUserId,
    required this.recipientUserId,
    required this.message,
    required this.timestamp,
    required this.isOwn,
    this.avatar
  });
}
