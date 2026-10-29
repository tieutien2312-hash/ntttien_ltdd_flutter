class StudentModel {
  final String id;
  final String userId;
  final String studentCode;
  final String fullName;
  final String email;
  final String? className;
  final String? faculty;

  StudentModel({
    required this.id,
    required this.userId,
    required this.studentCode,
    required this.fullName,
    required this.email,
    this.className,
    this.faculty,
  });

  factory StudentModel.fromJson(Map<String, dynamic> json) {
    return StudentModel(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      studentCode: json['studentCode']?.toString() ?? json['code']?.toString() ?? '',
      fullName: json['fullName']?.toString() ?? json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      className: json['className']?.toString() ?? json['class']?.toString(),
      faculty: json['faculty']?.toString() ?? json['department']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'studentCode': studentCode,
      'fullName': fullName,
      'email': email,
      'className': className,
      'faculty': faculty,
    };
  }
}
