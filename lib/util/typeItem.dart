class TypeItem {
  final String leaveType_E;

  const TypeItem({
    required this.leaveType_E,
  });

  factory TypeItem.fromJson(Map<String, dynamic> json) {
    return TypeItem(
      leaveType_E: json['leaveType_E'],
    );
  }
}
