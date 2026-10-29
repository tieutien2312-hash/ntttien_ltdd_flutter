import '../core/network/api_client.dart';
import '../models/noise_measurement_model.dart';

class NoiseMeasurementService {
  final ApiClient _apiClient = ApiClient();

  Future<void> submitMeasurement({
    required String classSessionId,
    required double decibelLevel,
    String? note,
  }) async {
    await _apiClient.post('/api/noise-measurements', data: {
      'attendanceSessionId': classSessionId,
      'decibels': decibelLevel,
      'note': note,
    });
  }

  Future<List<NoiseMeasurementModel>> getSessionMeasurements(String classSessionId) async {
    final response = await _apiClient.get('/api/noise-measurements/session/$classSessionId');
    if (response is List) {
      return response.map((e) => NoiseMeasurementModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => NoiseMeasurementModel.fromJson(e)).toList();
    }
    return [];
  }
}
