import 'package:hrm_attendance_application_test/util/policyItem.dart';

class AttendancePolicyInfo {
  final bool success;
  final int code;
  final List<PolicyItem> result;

  const AttendancePolicyInfo({
    required this.success,
    required this.code,
    required this.result,
  });

  factory AttendancePolicyInfo.fromJson(Map<String, dynamic> json) {
    return AttendancePolicyInfo(
        success: json['success'],
        code: json['code'],
        result: List<PolicyItem>.from(
            json['result'].map((item) => PolicyItem.fromJson(item))));
  }
}
