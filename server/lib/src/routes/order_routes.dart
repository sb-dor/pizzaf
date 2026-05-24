import 'dart:convert';
import 'dart:io';

import 'package:shelf/shelf.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shared/shared.dart';

import '../middleware/auth_middleware.dart';
import '../services/order_service.dart';

/// Order management route handlers.
class OrderRoutes {
  final OrderService _orderService;

  OrderRoutes(this._orderService);

  Router get router {
    final router = Router();

    router.post('/', _create);
    router.get('/', _getAll);
    router.get('/<id>', _getById);

    return router;
  }

  /// POST /orders — Place a new order
  Future<Response> _create(Request request) async {
    try {
      final userId = getUserId(request);
      final body = await request.readAsString();
      final json = jsonDecode(body) as Map<String, dynamic>;
      final req = CreateOrderRequest.fromJson(json);

      final order = _orderService.placeOrder(userId, req);

      return Response(
        HttpStatus.created,
        body: jsonEncode(order.toJson()),
        headers: {'Content-Type': 'application/json'},
      );
    } on OrderException catch (e) {
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

  /// GET /orders — Get all orders for the authenticated user
  Future<Response> _getAll(Request request) async {
    final userId = getUserId(request);
    final orders = _orderService.getOrdersForUser(userId);

    return Response.ok(
      jsonEncode(orders.map((o) => o.toJson()).toList()),
      headers: {'Content-Type': 'application/json'},
    );
  }

  /// GET `/orders/<id>` - Get a specific order.
  Future<Response> _getById(Request request, String id) async {
    final userId = getUserId(request);
    final order = _orderService.getOrder(id);

    if (order == null || order.userId != userId) {
      return Response(
        HttpStatus.notFound,
        body: jsonEncode({'error': 'Order not found'}),
        headers: {'Content-Type': 'application/json'},
      );
    }

    return Response.ok(
      jsonEncode(order.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
