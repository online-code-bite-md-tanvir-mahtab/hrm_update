import 'package:hrm_attendance_application_test/util/result.dart';

class UserInfo {
  final bool success;
  final int code;
  final Result result;

  const UserInfo({
    required this.success,
    required this.code,
    required this.result,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      success: json['success'] ?? '',
      code: json['code'] ?? '',
      result: Result.formJson(json['result']),
    );
  }
}
