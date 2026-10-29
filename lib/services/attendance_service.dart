import '../core/network/api_client.dart';
import '../models/attendance_record_model.dart';

class AttendanceService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> scanQr({
    required String qrToken,
    double? latitude,
    double? longitude,
  }) async {
    final response = await _apiClient.post('/api/attendance/scan-qr', data: {
      'qrCode': qrToken,
      'latitude': latitude,
      'longitude': longitude,
    });
    return response is Map<String, dynamic> ? response : {'message': 'Điểm danh thành công'};
  }

  Future<List<AttendanceRecordModel>> getMyAttendanceHistory() async {
    final response = await _apiClient.get('/api/students/me/attendance');
    if (response is List) {
      return response.map((e) => AttendanceRecordModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => AttendanceRecordModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<AttendanceRecordModel>> getSessionRecords(String classSessionId) async {
    final response = await _apiClient.get('/api/attendance/session/$classSessionId');
    if (response is List) {
      return response.map((e) => AttendanceRecordModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => AttendanceRecordModel.fromJson(e)).toList();
    }
    return [];
  }
}
