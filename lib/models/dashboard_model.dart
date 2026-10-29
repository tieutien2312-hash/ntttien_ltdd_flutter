class DashboardModel {
  final int totalStudents;
  final int totalTeachers;
  final int totalCourses;
  final int totalSessions;
  final double? attendanceRate;

  DashboardModel({
    required this.totalStudents,
    required this.totalTeachers,
    required this.totalCourses,
    required this.totalSessions,
    this.attendanceRate,
  });

  factory DashboardModel.fromJson(Map<String, dynamic> json) {
    return DashboardModel(
      totalStudents: json['totalStudents'] ?? json['studentsCount'] ?? 0,
      totalTeachers: json['totalTeachers'] ?? json['teachersCount'] ?? 0,
      totalCourses: json['totalCourses'] ?? json['coursesCount'] ?? 0,
      totalSessions: json['totalSessions'] ?? json['sessionsCount'] ?? 0,
      attendanceRate: json['attendanceRate'] != null ? double.tryParse(json['attendanceRate'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'totalStudents': totalStudents,
      'totalTeachers': totalTeachers,
      'totalCourses': totalCourses,
      'totalSessions': totalSessions,
      'attendanceRate': attendanceRate,
    };
  }
}
