class AttenInfo {
  final bool success;
  final int code;
  final String message;

  const AttenInfo({
    required this.success,
    required this.code,
    required this.message,
  });

  factory AttenInfo.fromJson(Map<String, dynamic> json) {
    return AttenInfo(
      success: json['success'],
      code: json['code'],
      message: json['message'],
    );
  }
}
