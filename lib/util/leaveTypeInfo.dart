import 'package:hrm_attendance_application_test/util/typeItem.dart';

class LeaveTypeInfo {
  final bool success;
  final int code;
  final List<TypeItem> result;

  const LeaveTypeInfo({
    required this.success,
    required this.code,
    required this.result,
  });

  factory LeaveTypeInfo.fromJson(Map<String, dynamic> json) {
    return LeaveTypeInfo(
      success: json['success'],
      code: json['code'],
      result: List<TypeItem>.from(
        json['result'].map(
          (item) => TypeItem.fromJson(item),
        ),
      ),
    );
  }
}
