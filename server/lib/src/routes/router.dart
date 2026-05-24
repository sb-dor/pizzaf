import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import 'auth_routes.dart';
import 'pizza_routes.dart';
import 'order_routes.dart';
import '../services/auth_service.dart';
import '../services/pizza_service.dart';
import '../services/order_service.dart';

/// Assembles all route handlers into a single top-level router.
Router buildRouter({
  required AuthService authService,
  required PizzaService pizzaService,
  required OrderService orderService,
}) {
  final router = Router();

  // Mount sub-routers
  router.mount('/auth/', AuthRoutes(authService).router.call);
  router.mount('/pizzas/', PizzaRoutes(pizzaService).router.call);
  router.mount('/orders/', OrderRoutes(orderService).router.call);

  // Health check
  router.get('/health', (Request request) {
    return Response.ok(
      '{"status": "ok"}',
      headers: {'Content-Type': 'application/json'},
    );
  });

  return router;
}
