class TeacherModel {
  final String id;
  final String userId;
  final String teacherCode;
  final String fullName;
  final String email;
  final String? department;

  TeacherModel({
    required this.id,
    required this.userId,
    required this.teacherCode,
    required this.fullName,
    required this.email,
    this.department,
  });

  factory TeacherModel.fromJson(Map<String, dynamic> json) {
    return TeacherModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      teacherCode: json['teacherCode']?.toString() ?? json['code']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      department: json['department']?.toString() ?? json['faculty']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'teacherCode': teacherCode,
      'fullName': fullName,
      'email': email,
      'department': department,
    };
  }
}
