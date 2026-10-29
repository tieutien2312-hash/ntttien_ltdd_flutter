import '../core/network/api_client.dart';
import '../models/attendance_session_model.dart';

class AttendanceSessionService {
  final ApiClient _apiClient = ApiClient();

  Future<AttendanceSessionModel> createAttendanceSession({
    required String classSessionId,
    double? latitude,
    double? longitude,
    double? radiusMeters,
  }) async {
    final response = await _apiClient.post('/api/attendance-sessions', data: {
      'classSessionId': classSessionId,
      'latitude': latitude,
      'longitude': longitude,
      'radiusMeters': radiusMeters ?? 50.0,
    });
    return AttendanceSessionModel.fromJson(response);
  }

  Future<AttendanceSessionModel> refreshQrCode(String sessionId) async {
    final response = await _apiClient.post('/api/attendance-sessions/$sessionId/refresh-qr');
    return AttendanceSessionModel.fromJson(response);
  }

  Future<void> closeSession(String sessionId) async {
    await _apiClient.post('/api/attendance-sessions/$sessionId/close');
  }
}
