import 'package:hrm_attendance_application_test/util/attendanceitem.dart';

class AttendanceInfo {
  final bool success;
  final int code;
  final List<AttendanceItem> result;

  const AttendanceInfo({
    required this.success,
    required this.code,
    required this.result,
  });

  factory AttendanceInfo.fromJson(Map<String, dynamic> json) {
    return AttendanceInfo(
      success: json['success'],
      code: json['code'],
      result: List<AttendanceItem>.from(
        json['result'].map(
          (item) => AttendanceItem.fromJson(item),
        ),
      ),
    );
  }
}
