class AuthResponse {
  final String? accessToken;
  final String? refreshToken;
  final Map<String, dynamic> user;

  AuthResponse({
    this.accessToken,
    this.refreshToken,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
      user: json['user'] ?? {},
    );
  }
}