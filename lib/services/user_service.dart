import '../core/network/api_client.dart';
import '../models/student_model.dart';
import '../models/teacher_model.dart';

class UserService {
  final ApiClient _apiClient = ApiClient();

  Future<List<StudentModel>> getStudents() async {
    final response = await _apiClient.get('/api/students');
    if (response is List) {
      return response.map((e) => StudentModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => StudentModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<StudentModel> getMyStudentProfile() async {
    final response = await _apiClient.get('/api/students/me');
    return StudentModel.fromJson(response);
  }

  Future<List<TeacherModel>> getTeachers() async {
    final response = await _apiClient.get('/api/teachers');
    if (response is List) {
      return response.map((e) => TeacherModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => TeacherModel.fromJson(e)).toList();
    }
    return [];
  }
}
