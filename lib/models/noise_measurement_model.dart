class NoiseMeasurementModel {
  final String id;
  final String classSessionId;
  final double decibelLevel;
  final String? note;
  final DateTime measuredAt;

  NoiseMeasurementModel({
    required this.id,
    required this.classSessionId,
    required this.decibelLevel,
    this.note,
    required this.measuredAt,
  });

  factory NoiseMeasurementModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedDate;
    try {
      parsedDate = DateTime.parse(json['measuredAt'] ?? json['createdAt'] ?? DateTime.now().toIso8601String());
    } catch (_) {
      parsedDate = DateTime.now();
    }

    return NoiseMeasurementModel(
      id: json['id']?.toString() ?? '',
      classSessionId: json['classSessionId']?.toString() ?? '',
      decibelLevel: json['decibelLevel'] != null ? double.parse(json['decibelLevel'].toString()) : 0.0,
      note: json['note']?.toString(),
      measuredAt: parsedDate,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classSessionId': classSessionId,
      'decibelLevel': decibelLevel,
      'note': note,
      'measuredAt': measuredAt.toIso8601String(),
    };
  }
}
