import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../features/cart/cart_screen.dart';
import '../features/customizer/customizer_screen.dart';
import '../features/orders/order_history_screen.dart';
import '../features/orders/order_tracking_screen.dart';

class AppRouter {
  static Future<void> openCustomizer(
    BuildContext context, {
    required PizzaInfo pizza,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => CustomizerScreen(initialPizza: pizza)),
    );
  }

  static Future<void> openCart(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const CartScreen()));
  }

  static Future<void> openOrders(BuildContext context) {
    return Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const OrderHistoryScreen()));
  }

  static Future<void> openTracking(BuildContext context, Order order) {
    return Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => OrderTrackingScreen(order: order)),
    );
  }
}
