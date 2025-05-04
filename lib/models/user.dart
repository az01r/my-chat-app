import 'dart:typed_data';

class User {
  final String userId;
  final String nickname;
  final String email;
  String? avatarPath;
  Uint8List? avatar;
  
  User({
    required this.userId,
    required this.nickname,
    required this.email,
    this.avatarPath,
    this.avatar
  });
}
