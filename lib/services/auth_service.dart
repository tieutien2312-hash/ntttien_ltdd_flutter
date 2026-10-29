import '../core/network/api_client.dart';
import '../core/storage/token_storage.dart';
import '../models/user_model.dart';

class AuthService {
  final ApiClient _apiClient = ApiClient();
  final TokenStorage _tokenStorage = TokenStorage();

  Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    String? username,
  }) async {
    final response = await _apiClient.post('/api/auth/register', data: {
      'fullName': fullName,
      'email': email,
      'username': username ?? email,
      'password': password,
    });
    return response is Map<String, dynamic> ? response : {'message': 'Đăng ký thành công'};
  }

  Future<Map<String, dynamic>> verifyEmail({
    required String email,
    required String otp,
  }) async {
    return {'message': 'Bỏ qua xác thực OTP'};
  }

  Future<UserModel> login({
    required String emailOrUsername,
    required String password,
  }) async {
    final response = await _apiClient.post('/api/auth/login', data: {
      'emailOrUsername': emailOrUsername,
      'password': password,
    });

    if (response is Map<String, dynamic>) {
      final accessToken = response['accessToken']?.toString() ?? response['token']?.toString() ?? '';
      final refreshToken = response['refreshToken']?.toString() ?? '';
      
      if (accessToken.isNotEmpty) {
        await _tokenStorage.saveTokens(accessToken: accessToken, refreshToken: refreshToken);
      }
    }

    // Fetch current user details & roles from /api/auth/me using the saved access token
    final user = await getCurrentUser();
    await _tokenStorage.saveUserInfo(
      userId: user.id,
      email: user.email,
      fullName: user.fullName,
      roles: user.roles,
    );

    return user;
  }

  Future<UserModel> verifyLoginOtp({
    required String challengeId,
    required String otp,
  }) async {
    throw UnimplementedError();
  }

  Future<UserModel> getCurrentUser() async {
    final response = await _apiClient.get('/api/auth/me');
    if (response is Map<String, dynamic>) {
      return UserModel.fromJson(response);
    }
    throw Exception('Không thể lấy thông tin người dùng');
  }

  Future<void> logout() async {
    try {
      await _apiClient.post('/api/auth/logout');
    } catch (_) {}
    await _tokenStorage.clearAll();
  }
}
