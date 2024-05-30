class PolicyItem {
  final String inTime;
  final String outTime;
  final String inGraceMin;
  final String lunchTimeMin;
  final String lunchBreakMin;

  const PolicyItem({
    required this.inTime,
    required this.outTime,
    required this.inGraceMin,
    required this.lunchTimeMin,
    required this.lunchBreakMin,
  });

  factory PolicyItem.fromJson(Map<String, dynamic> json) {
    return PolicyItem(
      inTime: json['inTime'],
      outTime: json['outTime'],
      inGraceMin: json['inGraceMin'],
      lunchTimeMin: json['lunchTimeMin'],
      lunchBreakMin: json['lunchBreakMin'],
    );
  }
}
