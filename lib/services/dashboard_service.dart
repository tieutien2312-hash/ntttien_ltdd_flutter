import '../core/network/api_client.dart';
import '../models/dashboard_model.dart';

class DashboardService {
  final ApiClient _apiClient = ApiClient();

  Future<DashboardModel> getAdminDashboardStats() async {
    final response = await _apiClient.get('/api/admin/dashboard-stats');
    if (response is Map<String, dynamic>) {
      return DashboardModel.fromJson(response);
    }
    return DashboardModel(totalStudents: 0, totalTeachers: 0, totalCourses: 0, totalSessions: 0);
  }
}
