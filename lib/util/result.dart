class Result {
  final String fullName;
  final String logId;
  final String employeeId;
  final String designationName;
  final String sectionName;
  final String departmentName;
  final String joinDate;
  final String projectName;
  final String photoName;
  final String isAdmin;
  // final String employeType;

  const Result(
      {required this.fullName,
      required this.logId,
      required this.employeeId,
      required this.designationName,
      required this.sectionName,
      required this.departmentName,
      required this.joinDate,
      required this.projectName,
      required this.photoName,
      required this.isAdmin
      // required this.employeType,
      });

  factory Result.formJson(Map<String, dynamic> json) {
    return Result(
      fullName: json['fullName'] ?? '',
      logId: json['logId'] ?? '',
      employeeId: json['employeeId'] ?? '',
      designationName: json['designationName'] ?? '',
      sectionName: json['sectionName'] ?? '',
      departmentName: json['departmentName'] ?? '',
      joinDate: json['joinDate'] ?? '',
      projectName: json['projectName'] ?? '',
      photoName: json['photoName'] ?? '',
      isAdmin: json['isAdmin'] ?? '',
    );
  }
}
