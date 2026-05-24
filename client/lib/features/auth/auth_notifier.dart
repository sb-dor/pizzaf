import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pizzaf/core/api/api_client.dart';
import 'package:pizzaf/core/api/token_storage.dart';
import 'package:shared/shared.dart';

enum AuthStatus { checking, authenticated, unauthenticated }

class AuthNotifier extends ChangeNotifier {
  AuthNotifier({required ApiClient apiClient, required TokenStorage tokenStorage})
    : _apiClient = apiClient,
      _tokenStorage = tokenStorage;

  final ApiClient _apiClient;
  final TokenStorage _tokenStorage;

  AuthStatus _status = AuthStatus.checking;
  User? _user;
  String? _error;
  bool _busy = false;

  AuthStatus get status => _status;
  User? get user => _user;
  String? get error => _error;
  bool get busy => _busy;

  Future<void> restoreSession() async {
    _status = AuthStatus.checking;
    notifyListeners();

    final accessToken = await _tokenStorage.readAccessToken();
    final user = await _tokenStorage.readUser();
    if (accessToken != null && user != null) {
      _user = user;
      _status = AuthStatus.authenticated;
    } else {
      _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    await _authenticate(() => _apiClient.login(LoginRequest(email: email, password: password)));
  }

  Future<void> register(String name, String email, String password) async {
    await _authenticate(
      () => _apiClient.register(RegisterRequest(name: name, email: email, password: password)),
    );
  }

  Future<void> logout() async {
    _busy = true;
    notifyListeners();
    try {
      await _apiClient.logout();
    } on Object {
      // Local logout should still succeed if the server is unavailable.
    }
    await _tokenStorage.clear();
    _user = null;
    _error = null;
    _busy = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  void sessionExpired() {
    unawaited(_tokenStorage.clear());
    _user = null;
    _error = 'Your session expired. Please log in again.';
    _busy = false;
    _status = AuthStatus.unauthenticated;
    notifyListeners();
  }

  Future<void> _authenticate(Future<AuthResponse> Function() action) async {
    _busy = true;
    _error = null;
    notifyListeners();

    try {
      final response = await action();
      await _tokenStorage.saveAuth(response);
      _user = response.user;
      _status = AuthStatus.authenticated;
    } on Object catch (e) {
      _error = e.toString();
      _status = AuthStatus.unauthenticated;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }
}
