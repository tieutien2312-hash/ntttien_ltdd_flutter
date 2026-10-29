import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  static const _secureStorage = FlutterSecureStorage();

  static const String _keyAccessToken = 'access_token';
  static const String _keyRefreshToken = 'refresh_token';
  static const String _keyUserId = 'user_id';
  static const String _keyEmail = 'email';
  static const String _keyFullName = 'full_name';
  static const String _keyRoles = 'roles';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await _secureStorage.write(key: _keyAccessToken, value: accessToken);
    await _secureStorage.write(key: _keyRefreshToken, value: refreshToken);
  }

  Future<void> saveUserInfo({
    required String userId,
    required String email,
    required String fullName,
    required List<String> roles,
  }) async {
    await _secureStorage.write(key: _keyUserId, value: userId);
    await _secureStorage.write(key: _keyEmail, value: email);
    await _secureStorage.write(key: _keyFullName, value: fullName);
    await _secureStorage.write(key: _keyRoles, value: roles.join(','));
  }

  Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: _keyAccessToken);
  }

  Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: _keyRefreshToken);
  }

  Future<String?> getUserId() async {
    return await _secureStorage.read(key: _keyUserId);
  }

  Future<String?> getEmail() async {
    return await _secureStorage.read(key: _keyEmail);
  }

  Future<String?> getFullName() async {
    return await _secureStorage.read(key: _keyFullName);
  }

  Future<List<String>> getRoles() async {
    final rolesStr = await _secureStorage.read(key: _keyRoles);
    if (rolesStr == null || rolesStr.isEmpty) return [];
    return rolesStr.split(',');
  }

  Future<void> clearAll() async {
    await _secureStorage.deleteAll();
  }
}
