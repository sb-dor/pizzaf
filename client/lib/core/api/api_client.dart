import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared/shared.dart';

import 'token_storage.dart';

class ApiClient {
  ApiClient({
    required TokenStorage tokenStorage,
    http.Client? httpClient,
    String? baseUrl,
  }) : _tokenStorage = tokenStorage,
       _httpClient = httpClient ?? http.Client(),
       baseUrl = (baseUrl ?? _defaultBaseUrl()).replaceAll(RegExp(r'/$'), '');

  final TokenStorage _tokenStorage;
  final http.Client _httpClient;
  final String baseUrl;
  VoidCallback? onUnauthorized;

  static String _defaultBaseUrl() {
    const configured = String.fromEnvironment('PIZZAF_API_BASE_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8080';
    }
    return 'http://localhost:8080';
  }

  Future<AuthResponse> register(RegisterRequest request) async {
    final json = await _sendJson(
      'POST',
      '/auth/register',
      body: request.toJson(),
      authenticated: false,
    );
    return AuthResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<AuthResponse> login(LoginRequest request) async {
    final json = await _sendJson(
      'POST',
      '/auth/login',
      body: request.toJson(),
      authenticated: false,
    );
    return AuthResponse.fromJson(json as Map<String, dynamic>);
  }

  Future<void> logout() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return;
    await _sendJson(
      'POST',
      '/auth/logout',
      body: {'refreshToken': refreshToken},
    );
  }

  Future<List<PizzaInfo>> getPizzas() async {
    final json = await _sendJson('GET', '/pizzas/');
    return (json as List)
        .map((item) => PizzaInfo.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Order> createOrder(CreateOrderRequest request) async {
    final json = await _sendJson('POST', '/orders/', body: request.toJson());
    return Order.fromJson(json as Map<String, dynamic>);
  }

  Future<List<Order>> getOrders() async {
    final json = await _sendJson('GET', '/orders/');
    return (json as List)
        .map((item) => Order.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<Order> getOrder(String id) async {
    final json = await _sendJson('GET', '/orders/$id');
    return Order.fromJson(json as Map<String, dynamic>);
  }

  Future<Object?> _sendJson(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    bool retryOnUnauthorized = true,
  }) async {
    final response = await _rawRequest(
      method,
      path,
      body: body,
      authenticated: authenticated,
    );

    if (response.statusCode == 401 && authenticated && retryOnUnauthorized) {
      final refreshed = await _refreshTokens();
      if (refreshed) {
        return _sendJson(
          method,
          path,
          body: body,
          authenticated: authenticated,
          retryOnUnauthorized: false,
        );
      }
      onUnauthorized?.call();
    }

    final decoded = response.body.isEmpty ? null : jsonDecode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map<String, dynamic>
        ? decoded['error'] as String? ?? 'Request failed'
        : 'Request failed with status ${response.statusCode}';
    throw ApiException(message, statusCode: response.statusCode);
  }

  Future<http.Response> _rawRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
    required bool authenticated,
  }) async {
    final headers = {'Content-Type': 'application/json'};
    if (authenticated) {
      final accessToken = await _tokenStorage.readAccessToken();
      if (accessToken != null) {
        headers['Authorization'] = 'Bearer $accessToken';
      }
    }

    final uri = Uri.parse('$baseUrl$path');
    final encodedBody = body == null ? null : jsonEncode(body);
    return switch (method) {
      'GET' => _httpClient.get(uri, headers: headers),
      'POST' => _httpClient.post(uri, headers: headers, body: encodedBody),
      _ => throw UnsupportedError('Unsupported method $method'),
    };
  }

  Future<bool> _refreshTokens() async {
    final refreshToken = await _tokenStorage.readRefreshToken();
    if (refreshToken == null) return false;

    try {
      final json = await _sendJson(
        'POST',
        '/auth/refresh',
        body: {'refreshToken': refreshToken},
        authenticated: false,
        retryOnUnauthorized: false,
      );
      final tokens = AuthTokens.fromJson(json as Map<String, dynamic>);
      await _tokenStorage.saveTokens(tokens);
      return true;
    } on Object {
      await _tokenStorage.clear();
      return false;
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;

  const ApiException(this.message, {this.statusCode});

  @override
  String toString() => message;
}
