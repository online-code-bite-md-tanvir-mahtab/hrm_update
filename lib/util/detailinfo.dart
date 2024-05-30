import 'package:hrm_attendance_application_test/util/detailitem.dart';

class DetailInfo {
  final bool success;
  final int code;
  final List<DetailItem> result;

  const DetailInfo({
    required this.success,
    required this.code,
    required this.result,
  });

  factory DetailInfo.fromJson(Map<String, dynamic> json) {
    return DetailInfo(
      success: json['success'],
      code: json['code'],
      result: List<DetailItem>.from(
        json['result'].map(
          (item) => DetailItem.fromJson(item),
        ),
      ),
    );
  }
}
