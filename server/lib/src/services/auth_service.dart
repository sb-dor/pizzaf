import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:dart_jsonwebtoken/dart_jsonwebtoken.dart';
import 'package:uuid/uuid.dart';

import 'package:shared/shared.dart';
import '../config/env.dart';
import '../db/database.dart';

/// Handles authentication: registration, login, JWT, and refresh tokens.
class AuthService {
  final Database _db;
  final _uuid = const Uuid();

  AuthService(this._db);

  /// Register a new user.
  /// Returns [AuthResponse] on success, throws on duplicate email.
  AuthResponse register(RegisterRequest request) {
    // Check if email already exists
    if (_db.getUserByEmail(request.email) != null) {
      throw AuthException('Email already registered');
    }

    // Validate inputs
    if (request.name.trim().isEmpty) {
      throw AuthException('Name is required');
    }
    if (request.email.trim().isEmpty || !request.email.contains('@')) {
      throw AuthException('Valid email is required');
    }
    if (request.password.length < 6) {
      throw AuthException('Password must be at least 6 characters');
    }

    // Create user with hashed password
    final salt = _uuid.v4();
    final passwordHash = _hashPassword(request.password, salt);

    final user = UserRecord(
      id: _uuid.v4(),
      name: request.name.trim(),
      email: request.email.trim().toLowerCase(),
      passwordHash: passwordHash,
      salt: salt,
      createdAt: DateTime.now(),
    );

    _db.addUser(user);

    // Generate tokens
    final tokens = _generateTokenPair(user.id);

    return AuthResponse(user: user.toUser(), tokens: tokens);
  }

  /// Login with email and password.
  /// Returns [AuthResponse] on success, throws on invalid credentials.
  AuthResponse login(LoginRequest request) {
    final user = _db.getUserByEmail(request.email.trim().toLowerCase());
    if (user == null) {
      throw AuthException('Invalid email or password');
    }

    final passwordHash = _hashPassword(request.password, user.salt);
    if (passwordHash != user.passwordHash) {
      throw AuthException('Invalid email or password');
    }

    final tokens = _generateTokenPair(user.id);

    return AuthResponse(user: user.toUser(), tokens: tokens);
  }

  /// Refresh tokens using a valid refresh token.
  /// Implements token rotation: old token is invalidated, new pair issued.
  AuthTokens refresh(String refreshToken) {
    final record = _db.getRefreshToken(refreshToken);
    if (record == null) {
      throw AuthException('Invalid refresh token');
    }

    if (record.isExpired) {
      _db.deleteRefreshToken(refreshToken);
      throw AuthException('Refresh token expired');
    }

    // Rotate: delete old token and issue new pair
    _db.deleteRefreshToken(refreshToken);

    return _generateTokenPair(record.userId);
  }

  /// Logout: invalidate the refresh token.
  void logout(String refreshToken) {
    _db.deleteRefreshToken(refreshToken);
  }

  /// Verify a JWT access token and return the userId.
  /// Returns null if the token is invalid or expired.
  String? verifyAccessToken(String token) {
    try {
      final jwt = JWT.verify(token, SecretKey(ServerConfig.jwtSecret));
      return jwt.payload['sub'] as String?;
    } on JWTExpiredException {
      return null;
    } on JWTException {
      return null;
    }
  }

  // ── Private Helpers ─────────────────────────────────────────────

  /// Generate a JWT access token + opaque refresh token pair.
  AuthTokens _generateTokenPair(String userId) {
    // Access token: JWT with userId as subject
    final jwt = JWT({'sub': userId}, issuer: 'pizzaf-server');
    final accessToken = jwt.sign(
      SecretKey(ServerConfig.jwtSecret),
      expiresIn: ServerConfig.accessTokenLifetime,
    );

    // Refresh token: opaque UUID, stored in DB
    final refreshToken = _uuid.v4();
    _db.addRefreshToken(
      RefreshTokenRecord(
        token: refreshToken,
        userId: userId,
        expiresAt: DateTime.now().add(ServerConfig.refreshTokenLifetime),
      ),
    );

    return AuthTokens(accessToken: accessToken, refreshToken: refreshToken);
  }

  /// Hash a password with a salt using SHA-256.
  String _hashPassword(String password, String salt) {
    final bytes = utf8.encode('$salt:$password');
    return sha256.convert(bytes).toString();
  }
}

/// Custom exception for authentication errors.
class AuthException implements Exception {
  final String message;
  const AuthException(this.message);

  @override
  String toString() => 'AuthException: $message';
}
