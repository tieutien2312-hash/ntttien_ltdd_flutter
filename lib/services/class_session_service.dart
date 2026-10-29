import '../core/network/api_client.dart';
import '../models/class_session_model.dart';

class ClassSessionService {
  final ApiClient _apiClient = ApiClient();

  Future<List<ClassSessionModel>> getClassSessions() async {
    final response = await _apiClient.get('/api/class-sessions');
    if (response is List) {
      return response.map((e) => ClassSessionModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => ClassSessionModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ClassSessionModel>> getStudentSchedule() async {
    final response = await _apiClient.get('/api/students/me/schedule');
    if (response is List) {
      return response.map((e) => ClassSessionModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => ClassSessionModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<ClassSessionModel>> getTeacherSchedule() async {
    final response = await _apiClient.get('/api/teachers/me/schedule');
    if (response is List) {
      return response.map((e) => ClassSessionModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => ClassSessionModel.fromJson(e)).toList();
    }
    return [];
  }
}
