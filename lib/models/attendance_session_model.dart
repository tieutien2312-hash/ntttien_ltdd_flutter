class AttendanceSessionModel {
  final String id;
  final String classSessionId;
  final String qrCodeToken;
  final DateTime expiresAt;
  final bool isActive;
  final double? latitude;
  final double? longitude;
  final double? radiusMeters;

  AttendanceSessionModel({
    required this.id,
    required this.classSessionId,
    required this.qrCodeToken,
    required this.expiresAt,
    required this.isActive,
    this.latitude,
    this.longitude,
    this.radiusMeters,
  });

  factory AttendanceSessionModel.fromJson(Map<String, dynamic> json) {
    DateTime parsedExpires;
    try {
      parsedExpires = DateTime.parse(json['expiresAt'] ?? DateTime.now().add(const Duration(seconds: 60)).toIso8601String());
    } catch (_) {
      parsedExpires = DateTime.now().add(const Duration(seconds: 60));
    }

    return AttendanceSessionModel(
      id: json['id']?.toString() ?? '',
      classSessionId: json['classSessionId']?.toString() ?? '',
      qrCodeToken: json['qrCodeToken']?.toString() ?? json['token']?.toString() ?? '',
      expiresAt: parsedExpires,
      isActive: json['isActive'] ?? json['active'] ?? true,
      latitude: json['latitude'] != null ? double.tryParse(json['latitude'].toString()) : null,
      longitude: json['longitude'] != null ? double.tryParse(json['longitude'].toString()) : null,
      radiusMeters: json['radiusMeters'] != null ? double.tryParse(json['radiusMeters'].toString()) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'classSessionId': classSessionId,
      'qrCodeToken': qrCodeToken,
      'expiresAt': expiresAt.toIso8601String(),
      'isActive': isActive,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters,
    };
  }
}
