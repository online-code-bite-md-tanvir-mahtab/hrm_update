import 'ResponseItem.dart';

class ReasonList {
  final bool success;
  final int code;
  final List<ResponseItem> result;

  const ReasonList({
    required this.success,
    required this.code,
    required this.result,
  });

  factory ReasonList.fromJson(Map<String, dynamic> json) {
    return ReasonList(
      success: json['success'],
      code: json['code'],
      result: List<ResponseItem>.from(
        json['result'].map(
          (item) => ResponseItem.fromJson(item),
        ),
      ),
    );
  }
}
