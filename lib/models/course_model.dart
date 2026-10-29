class CourseModel {
  final String id;
  final String courseCode;
  final String courseName;
  final String? description;
  final int? credits;
  final String? teacherName;

  CourseModel({
    required this.id,
    required this.courseCode,
    required this.courseName,
    this.description,
    this.credits,
    this.teacherName,
  });

  factory CourseModel.fromJson(Map<String, dynamic> json) {
    return CourseModel(
      id: json['id']?.toString() ?? '',
      courseCode: json['courseCode']?.toString() ?? json['code']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? json['name']?.toString() ?? '',
      description: json['description']?.toString(),
      credits: json['credits'] != null ? int.tryParse(json['credits'].toString()) : null,
      teacherName: json['teacherName']?.toString() ?? json['teacher']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseCode': courseCode,
      'courseName': courseName,
      'description': description,
      'credits': credits,
      'teacherName': teacherName,
    };
  }
}
