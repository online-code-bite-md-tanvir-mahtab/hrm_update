class AttendanceItem {
  final String dailyDate;
  final String inTime;
  final String outTime;
  final int lateInMin;
  final String attnStatus;
  final String code;
  final String empName;

  const AttendanceItem(
      {required this.dailyDate,
      required this.code,
      required this.empName,
      required this.inTime,
      required this.outTime,
      required this.lateInMin,
      required this.attnStatus});

  factory AttendanceItem.fromJson(Map<String, dynamic> json) {
    return AttendanceItem(
      dailyDate: json['dailyDate'] ?? '',
      empName: json['empName'] ?? '',
      code: json['code'] ?? 'No Data',
      inTime: json['inTime'] ?? 'none',
      outTime: json['outTime'] ?? 'none',
      lateInMin: json['lateInMin'] ?? 'none',
      attnStatus: json['attnStatus'] ?? 'none',
    );
  }
}
