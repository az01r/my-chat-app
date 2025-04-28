class User {
  final String userId;
  final String nickname;
  final String email;
  String? avatar;
  User({
    required this.userId,
    required this.nickname,
    required this.email,
    this.avatar
  });
}
