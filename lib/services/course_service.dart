import '../core/network/api_client.dart';
import '../models/course_model.dart';

class CourseService {
  final ApiClient _apiClient = ApiClient();

  Future<List<CourseModel>> getCourses() async {
    final response = await _apiClient.get('/api/courses');
    if (response is List) {
      return response.map((e) => CourseModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => CourseModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<CourseModel>> getMyEnrolledCourses() async {
    final response = await _apiClient.get('/api/students/me/courses');
    if (response is List) {
      return response.map((e) => CourseModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => CourseModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<CourseModel> getCourseDetail(String courseId) async {
    final response = await _apiClient.get('/api/courses/$courseId');
    return CourseModel.fromJson(response);
  }

  Future<void> createCourse({
    required String code,
    required String name,
    required String description,
    required int credits,
  }) async {
    await _apiClient.post('/api/courses', data: {
      'code': code,
      'name': name,
      'description': description,
      'credits': credits,
    });
  }

  Future<void> updateCourse({
    required String id,
    required String code,
    required String name,
    required String description,
    required int credits,
  }) async {
    try {
      await _apiClient.put('/api/courses/$id', data: {
        'code': code,
        'name': name,
        'description': description,
        'credits': credits,
      });
    } catch (_) {}
  }

  Future<void> deleteCourse(String id) async {
    try {
      await _apiClient.delete('/api/courses/$id');
    } catch (_) {}
  }

  Future<void> enrollStudent(String courseId, String studentId) async {
    await _apiClient.post('/api/courses/$courseId/enroll', data: {'studentId': studentId});
  }
}
