import '../core/network/api_client.dart';
import '../models/notification_model.dart';

class NotificationService {
  final ApiClient _apiClient = ApiClient();

  Future<List<NotificationModel>> getNotifications() async {
    final response = await _apiClient.get('/api/notifications');
    if (response is List) {
      return response.map((e) => NotificationModel.fromJson(e)).toList();
    } else if (response is Map && response['items'] is List) {
      return (response['items'] as List).map((e) => NotificationModel.fromJson(e)).toList();
    }
    return [];
  }

  Future<void> markAsRead(String id) async {
    await _apiClient.put('/api/notifications/$id/read');
  }

  Future<void> markAllAsRead() async {
    await _apiClient.put('/api/notifications/read-all');
  }
}
