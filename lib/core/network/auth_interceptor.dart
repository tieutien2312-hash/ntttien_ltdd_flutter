import 'package:dio/dio.dart';
import '../storage/token_storage.dart';
import '../config/api_config.dart';

class AuthInterceptor extends Interceptor {
  final TokenStorage _tokenStorage = TokenStorage();
  final Dio _dio;
  bool _isRefreshing = false;
  final List<void Function(String)> _refreshSubscribers = [];

  AuthInterceptor(this._dio);

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    // Skip token for auth public endpoints
    final path = options.path;
    final isPublicEndpoint = path.contains('/api/auth/login') ||
        path.contains('/api/auth/register') ||
        path.contains('/api/auth/verify-email') ||
        path.contains('/api/auth/verify-login-otp') ||
        path.contains('/api/auth/refresh-token') ||
        path.contains('/api/auth/resend-verification');

    if (!isPublicEndpoint) {
      final token = await _tokenStorage.getAccessToken();
      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }

    options.headers['Content-Type'] = 'application/json';
    options.headers['Accept'] = 'application/json';
    super.onRequest(options, handler);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode == 401) {
      final requestOptions = err.requestOptions;
      
      // Prevent infinite loop if refresh token request itself returns 401
      if (requestOptions.path.contains('/api/auth/refresh-token') ||
          requestOptions.path.contains('/api/auth/login')) {
        await _tokenStorage.clearAll();
        return super.onError(err, handler);
      }

      if (_isRefreshing) {
        // Queue the request until refresh is done
        try {
          final newToken = await _waitForRefresh();
          requestOptions.headers['Authorization'] = 'Bearer $newToken';
          final response = await _dio.fetch(requestOptions);
          return handler.resolve(response);
        } catch (e) {
          return super.onError(err, handler);
        }
      }

      _isRefreshing = true;
      try {
        final refreshToken = await _tokenStorage.getRefreshToken();
        if (refreshToken == null || refreshToken.isEmpty) {
          _isRefreshing = false;
          await _tokenStorage.clearAll();
          return super.onError(err, handler);
        }

        // Call refresh token endpoint
        // According to backend contract, request DTO for refresh token
        final refreshDio = Dio(BaseOptions(
          baseUrl: ApiConfig.baseUrl,
          connectTimeout: const Duration(milliseconds: ApiConfig.connectTimeout),
          receiveTimeout: const Duration(milliseconds: ApiConfig.receiveTimeout),
        ));

        final response = await refreshDio.post(
          '/api/auth/refresh-token',
          data: {'refreshToken': refreshToken},
        );

        if (response.statusCode == 200 && response.data != null) {
          final data = response.data;
          // Expecting accessToken and refreshToken in response
          final newAccessToken = data['accessToken']?.toString() ?? data['token']?.toString();
          final newRefreshToken = data['refreshToken']?.toString();

          if (newAccessToken != null && newAccessToken.isNotEmpty) {
            await _tokenStorage.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken ?? refreshToken,
            );

            _isRefreshing = false;
            _notifySubscribers(newAccessToken);
            _refreshSubscribers.clear();

            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
            final retryResponse = await _dio.fetch(requestOptions);
            return handler.resolve(retryResponse);
          }
        }

        _isRefreshing = false;
        _tokenStorage.clearAll();
        return super.onError(err, handler);
      } catch (e) {
        _isRefreshing = false;
        _tokenStorage.clearAll();
        return super.onError(err, handler);
      }
    }

    super.onError(err, handler);
  }

  Future<String> _waitForRefresh() async {
    return await Future.delayed(const Duration(milliseconds: 500), () async {
      final token = await _tokenStorage.getAccessToken();
      return token ?? '';
    });
  }

  void _notifySubscribers(String newToken) {
    for (var callback in _refreshSubscribers) {
      callback(newToken);
    }
  }
}
