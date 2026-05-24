import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared/shared.dart';

class TokenStorage {
  static const _accessTokenKey = 'pizzaf.accessToken';
  static const _refreshTokenKey = 'pizzaf.refreshToken';
  static const _userKey = 'pizzaf.user';

  final FlutterSecureStorage _storage;

  TokenStorage({FlutterSecureStorage? storage})
    : _storage = storage ?? const FlutterSecureStorage();

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<User?> readUser() async {
    final raw = await _storage.read(key: _userKey);
    if (raw == null) return null;
    return User.fromJson(jsonDecode(raw) as Map<String, dynamic>);
  }

  Future<void> saveAuth(AuthResponse response) async {
    await saveTokens(response.tokens);
    await _storage.write(
      key: _userKey,
      value: jsonEncode(response.user.toJson()),
    );
  }

  Future<void> saveTokens(AuthTokens tokens) async {
    await _storage.write(key: _accessTokenKey, value: tokens.accessToken);
    await _storage.write(key: _refreshTokenKey, value: tokens.refreshToken);
  }

  Future<void> clear() async {
    await _storage.delete(key: _accessTokenKey);
    await _storage.delete(key: _refreshTokenKey);
    await _storage.delete(key: _userKey);
  }
}
