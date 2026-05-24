import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';

import '../services/pizza_service.dart';

/// Pizza menu route handlers.
class PizzaRoutes {
  final PizzaService _pizzaService;

  PizzaRoutes(this._pizzaService);

  Router get router {
    final router = Router();

    router.get('/', _getAll);

    return router;
  }

  /// GET /pizzas
  Future<Response> _getAll(Request request) async {
    final pizzas = _pizzaService.getAllPizzas();

    return Response.ok(
      jsonEncode(pizzas.map((p) => p.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
