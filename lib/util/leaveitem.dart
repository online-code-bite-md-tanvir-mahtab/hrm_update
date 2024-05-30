class LeaveItem {
  final int id;
  final String leaveType_E;
  final String fromDate;
  final String dayType;
  final double totalLeave;
  final String approval;
  final String employeeId;
  final String empName;
  final String empCode;

  LeaveItem({
    required this.id,
    required this.employeeId,
    required this.empName,
    required this.empCode,
    required this.leaveType_E,
    required this.fromDate,
    required this.dayType,
    required this.totalLeave,
    required this.approval,
  });

  factory LeaveItem.fromJson(Map<String, dynamic> json) {
    return LeaveItem(
      id: json['id'] ?? "",
      employeeId: json['employeeId'] ?? "",
      empName: json['empName'] ?? "",
      empCode: json['empCode'] ?? "",
      leaveType_E: json['leaveType_E'] ?? '',
      fromDate: json['fromDate'] ?? "",
      dayType: json['dayType'] ?? "",
      totalLeave: json['totalLeave'] ?? "",
      approval: json['approval'] ?? "",
    );
  }
}
