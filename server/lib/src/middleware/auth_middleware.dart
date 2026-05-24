import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';

import '../services/auth_service.dart';

/// Key used to store the authenticated userId in request context.
const String userIdContextKey = 'userId';

/// Routes that do not require authentication.
const _publicPaths = {'/auth/login', '/auth/register', '/auth/refresh'};

/// Authentication middleware that verifies JWT access tokens.
///
/// - Public routes (login, register, refresh) are passed through.
/// - All other routes require a valid `Authorization: Bearer <token>` header.
/// - On success, the userId is attached to the request context.
/// - On failure, returns 401 Unauthorized.
Middleware authMiddleware(AuthService authService) {
  return (Handler innerHandler) {
    return (Request request) async {
      // Skip auth for public routes
      final path = request.requestedUri.path;
      if (_publicPaths.contains(path)) {
        return innerHandler(request);
      }

      // Skip auth for OPTIONS (preflight)
      if (request.method == 'OPTIONS') {
        return innerHandler(request);
      }

      // Extract Bearer token
      final authHeader = request.headers['authorization'];
      if (authHeader == null || !authHeader.startsWith('Bearer ')) {
        return Response(
          HttpStatus.unauthorized,
          body: jsonEncode({
            'error': 'Missing or invalid Authorization header',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      final token = authHeader.substring(7); // Remove "Bearer "

      // Verify JWT
      final userId = authService.verifyAccessToken(token);
      if (userId == null) {
        return Response(
          HttpStatus.unauthorized,
          body: jsonEncode({'error': 'Invalid or expired access token'}),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Attach userId to request context and proceed
      final updatedRequest = request.change(
        context: {userIdContextKey: userId},
      );
      return innerHandler(updatedRequest);
    };
  };
}

/// Extract the authenticated userId from a request.
/// Should only be called on authenticated routes.
String getUserId(Request request) {
  final userId = request.context[userIdContextKey] as String?;
  if (userId == null) {
    throw StateError(
      'userId not found in request context. '
      'Is the auth middleware applied?',
    );
  }
  return userId;
}
