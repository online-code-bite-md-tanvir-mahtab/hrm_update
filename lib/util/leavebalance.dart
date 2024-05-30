import 'package:hrm_attendance_application_test/util/leavebalanceItem.dart';

class LeaveBalanceInfo {
  final bool success;
  final int code;
  final List<LeaveBalanceItem> result;

  const LeaveBalanceInfo({
    required this.success,
    required this.code,
    required this.result,
  });

  factory LeaveBalanceInfo.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceInfo(
      success: json['success'],
      code: json['code'],
      result: List<LeaveBalanceItem>.from((json['result'] as List<dynamic>)
          .map((item) => LeaveBalanceItem.fromJson(item))),
    );
  }
}
