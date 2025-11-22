class AuthState {
  final String? userId;
  final String? token; // Keep token for authenticated requests

  AuthState({this.userId, this.token});

  bool get isAuthenticated => userId != null && token != null;
}