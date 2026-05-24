/// Server configuration constants.
class ServerConfig {
  /// JWT signing secret. In production, use environment variable.
  static const String jwtSecret =
      'pizzaf-super-secret-jwt-key-change-in-production-2024';

  /// JWT access token lifetime.
  static const Duration accessTokenLifetime = Duration(hours: 1);

  /// Refresh token lifetime.
  static const Duration refreshTokenLifetime = Duration(days: 14);

  /// Server port.
  static const int port = 8080;

  /// Server host.
  static const String host = '192.168.16.180';

  ServerConfig._();
}
