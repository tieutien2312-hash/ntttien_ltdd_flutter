class AttendanceRecordModel {
  final String id;
  final String classSessionId;
  final String studentId;
  final String? studentName;
  final String? studentCode;
  final String status; // Present, Late, Absent, Excused
  final DateTime checkInTime;
  final String? remarks;

  AttendanceRecordModel({
    required this.id,
    required this.classSessionId,
    required this.studentId,
    this.studentName,
    this.studentCode,
    required this.status,
    required this.checkInTime,
    this.remarks,
  });

  factory AttendanceRecordModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedTime;
    try {
      parsedTime = DateTime.parse(json['checkInTime'] ?? json['createdAt'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      parsedTime = DateTime.now();
    }

    return AttendanceRecordModel(
      id: json['id']?.toString() ?? '',
      classSessionId: json['classSessionId']?.toString() ?? '',
      studentId: json['studentId']?.toString() ?? '',
      studentName: json['studentName']?.toString() ?? json['studentFullName']?.toString(),
      studentCode: json['studentCode']?.toString(),
      status: json['status']?.toString() ?? 'Present',
      checkInTime: parsedTime,
      remarks: json['remarks']?.toString() ?? json['note']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classSessionId': classSessionId,
      'studentId': studentId,
      'studentName': studentName,
      'studentCode': studentCode,
      'status': status,
      'checkInTime': checkInTime.toIso8601String(),
      'remarks': remarks,
    };
  }
}
