import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shared/shared.dart';

import '../services/auth_service.dart';

/// Authentication route handlers.
class AuthRoutes {
  final AuthService _authService;

  AuthRoutes(this._authService);

  Router get router {
    final router = Router();

    router.post('/login', _login);
    router.post('/register', _register);
    router.post('/refresh', _refresh);
    router.post('/logout', _logout);

    return router;
  }

  /// POST /auth/register
  Future<Response> _register(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = RegisterRequest.fromJson(json);

      final result = _authService.register(req);

      return Response(
        HttpStatus.created,
        body: jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on AuthException catch (e) {
      return Response(
        HttpStatus.badRequest,
        body: jsonEncode({'error': e.message}),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException {
      return Response(
        HttpStatus.badRequest,
        body: jsonEncode({'error': 'Invalid request body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /auth/login
  Future<Response> _login(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = LoginRequest.fromJson(json);

      final result = _authService.login(req);

      return Response.ok(
        jsonEncode(result.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on AuthException catch (e) {
      return Response(
        HttpStatus.unauthorized,
        body: jsonEncode({'error': e.message}),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException {
      return Response(
        HttpStatus.badRequest,
        body: jsonEncode({'error': 'Invalid request body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /auth/refresh
  Future<Response> _refresh(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final refreshToken = json['refreshToken'] as String?;

      if (refreshToken == null || refreshToken.isEmpty) {
        return Response(
          HttpStatus.badRequest,
          body: jsonEncode({'error': 'refreshToken is required'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final tokens = _authService.refresh(refreshToken);

      return Response.ok(
        jsonEncode(tokens.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on AuthException catch (e) {
      return Response(
        HttpStatus.unauthorized,
        body: jsonEncode({'error': e.message}),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException {
      return Response(
        HttpStatus.badRequest,
        body: jsonEncode({'error': 'Invalid request body'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }

  /// POST /auth/logout
  Future<Response> _logout(Request request) async {
    try {
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final refreshToken = json['refreshToken'] as String?;

      if (refreshToken != null) {
        _authService.logout(refreshToken);
      }

      return Response.ok(
        jsonEncode({'message': 'Logged out successfully'}),
        headers: {'Content-Type': 'application/json'},
      );
    } on FormatException {
      return Response.ok(
        jsonEncode({'message': 'Logged out'}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  }
}
