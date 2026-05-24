import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

import 'package:pizza_server/server.dart';

/// PizzaF Server Entry Point
///
/// Starts the HTTP server with the full middleware pipeline:
/// Request → CORS → Logging → Auth → Router → Response
void main() async {
  // ── Pure Man's DI: Manual constructor injection ──────────────
  final db = Database();
  final authService = AuthService(db);
  final pizzaService = PizzaService(db);
  final orderService = OrderService(db);

  // ── Build router ──────────────────────────────────────────────
  final router = buildRouter(
    authService: authService,
    pizzaService: pizzaService,
    orderService: orderService,
  );

  // ── Middleware pipeline ───────────────────────────────────────
  final handler = const Pipeline()
      .addMiddleware(corsMiddleware())
      .addMiddleware(loggingMiddleware())
      .addMiddleware(authMiddleware(authService))
      .addHandler(router.call);

  // ── Start server ──────────────────────────────────────────────
  final server = await shelf_io.serve(
    handler,
    ServerConfig.host,
    ServerConfig.port,
  );

  print('');
  print('🍕 PizzaF Server running');
  print('   http://${server.address.host}:${server.port}');
  print('');
  print('   Endpoints:');
  print('   POST /auth/register  — Create account');
  print('   POST /auth/login     — Login');
  print('   POST /auth/refresh   — Refresh tokens');
  print('   POST /auth/logout    — Logout');
  print('   GET  /pizzas         — List pizza types');
  print('   POST /orders         — Place order');
  print('   GET  /orders         — Order history');
  print('   GET  /orders/<id>    — Order details');
  print('   GET  /health         — Health check');
  print('');

  // Handle graceful shutdown
  ProcessSignal.sigint.watch().listen((_) {
    print('\n🛑 Shutting down...');
    server.close();
    exit(0);
  });
}
