class ClassSessionModel {
  final String id;
  final String courseId;
  final String? courseName;
  final String? room;
  final DateTime sessionDate;
  final String? startTime;
  final String? endTime;
  final bool isAttendanceOpen;

  ClassSessionModel({
    required this.id,
    required this.courseId,
    this.courseName,
    this.room,
    required this.sessionDate,
    this.startTime,
    this.endTime,
    this.isAttendanceOpen = false,
  });

  factory ClassSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['sessionDate'] ?? json['date'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return ClassSessionModel(
      id: json['id']?.toString() ?? '',
      courseId: json['courseId']?.toString() ?? '',
      courseName: json['courseName']?.toString() ?? json['course']?.toString(),
      room: json['room']?.toString() ?? json['location']?.toString(),
      sessionDate: parsedDate,
      startTime: json['startTime']?.toString(),
      endTime: json['endTime']?.toString(),
      isAttendanceOpen: json['isAttendanceOpen'] ?? json['isOpen'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'courseId': courseId,
      'courseName': courseName,
      'room': room,
      'sessionDate': sessionDate.toIso8601String(),
      'startTime': startTime,
      'endTime': endTime,
      'isAttendanceOpen': isAttendanceOpen,
    };
  }
}
