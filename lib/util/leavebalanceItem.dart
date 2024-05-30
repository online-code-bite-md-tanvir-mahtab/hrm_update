class LeaveBalanceItem {
  final String leaveType;
  final String total;
  final String used;
  final String have;

  const LeaveBalanceItem({
    required this.leaveType,
    required this.total,
    required this.used,
    required this.have,
  });

  factory LeaveBalanceItem.fromJson(Map<String, dynamic> json) {
    return LeaveBalanceItem(
      leaveType: json['leaveType'],
      total: json['total'],
      used: json['used'],
      have: json['have'],
    );
  }
}
