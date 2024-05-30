
class Token {
  final String access_token;
  final String token_type;
  final int expired_time;

  Token({
    required this.access_token,
    required this.token_type,
    required this.expired_time,
  });

  factory Token.fromJson(Map<String, dynamic> json) {
    return Token(
      access_token: json["access_token"],
      token_type: json["token_type"],
      expired_time: json['expires_in'], // Change 'expire_in' to 'expires_in'
    );
  }
}

