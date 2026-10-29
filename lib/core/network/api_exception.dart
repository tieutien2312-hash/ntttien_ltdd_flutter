import 'package:dio/dio.dart';

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({
    required this.message,
    this.statusCode,
    this.data,
  });

  factory ApiException.fromDioError(DioException error) {
    switch (error.type) {
      case DioExceptionType.cancel:
        return ApiException(message: 'Yêu cầu đã bị hủy.');
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException(message: 'Kết nối mạng quá thời gian (Timeout). Vui lòng kiểm tra lại kết nối.');
      case DioExceptionType.badResponse:
        final response = error.response;
        final statusCode = response?.statusCode;
        String message = 'Đã xảy ra lỗi từ máy chủ (Mã: $statusCode).';
        
        try {
          final resData = response?.data;
          if (resData is Map) {
            final dataMap = resData as Map<String, dynamic>;
            if (dataMap.containsKey('message')) {
              message = dataMap['message'].toString();
            } else if (dataMap.containsKey('title')) {
              message = dataMap['title'].toString();
            } else if (dataMap.containsKey('detail')) {
              message = dataMap['detail'].toString();
            } else if (dataMap.containsKey('errors')) {
              final errors = dataMap['errors'];
              if (errors is Map) {
                final errorMsgs = <String>[];
                errors.forEach((key, value) {
                  if (value is List) {
                    errorMsgs.addAll(value.map((e) => e.toString()));
                  } else {
                    errorMsgs.add(value.toString());
                  }
                });
                if (errorMsgs.isNotEmpty) {
                  message = errorMsgs.join('\n');
                }
              }
            }
          } else if (resData is List) {
            // Handle ASP.NET Core Identity error list e.g. [{"code": "...", "description": "..."}]
            final errorMsgs = <String>[];
            for (var item in resData) {
              if (item is Map && item.containsKey('description')) {
                errorMsgs.add(item['description'].toString());
              } else {
                errorMsgs.add(item.toString());
              }
            }
            if (errorMsgs.isNotEmpty) {
              message = errorMsgs.join('\n');
            }
          } else if (resData is String && resData.isNotEmpty) {
            message = resData;
          }
        } catch (_) {
          // fallback
        }

        switch (statusCode) {
          case 400:
            return ApiException(message: message, statusCode: 400, data: response?.data);
          case 401:
            return ApiException(message: message.isNotEmpty ? message : 'Phiên đăng nhập hết hạn hoặc chưa xác thực (401).', statusCode: 401, data: response?.data);
          case 403:
            return ApiException(message: message.isNotEmpty ? message : 'Bạn không có quyền thực hiện hành động này (403).', statusCode: 403, data: response?.data);
          case 404:
            return ApiException(message: message.isNotEmpty ? message : 'Không tìm thấy tài nguyên yêu cầu (404).', statusCode: 404, data: response?.data);
          case 409:
            return ApiException(message: message.isNotEmpty ? message : 'Xung đột dữ liệu (409).', statusCode: 409, data: response?.data);
          case 429:
            return ApiException(message: message.isNotEmpty ? message : 'Quá nhiều yêu cầu. Vui lòng thử lại sau (429).', statusCode: 429, data: response?.data);
          case 500:
          case 502:
          case 503:
          case 504:
            return ApiException(message: message.contains('Đã xảy ra lỗi') ? 'Lỗi máy chủ ($statusCode). Backend có thể đang gặp sự cố.' : message, statusCode: statusCode, data: response?.data);
          default:
            return ApiException(message: message, statusCode: statusCode, data: response?.data);
        }
      case DioExceptionType.unknown:
        if (error.error != null && error.error.toString().contains('SocketException')) {
          return ApiException(message: 'Không thể kết nối đến máy chủ. Vui lòng kiểm tra lại mạng hoặc Dev Tunnel.');
        }
        return ApiException(message: 'Lỗi kết nối: ${error.message}');
      default:
        return ApiException(message: 'Đã xảy ra lỗi không xác định.');
    }
  }

  @override
  String toString() => message;
}
