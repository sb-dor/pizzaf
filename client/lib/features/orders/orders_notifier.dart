import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:pizzaf/core/api/api_client.dart';
import 'package:shared/shared.dart';

class OrdersNotifier extends ChangeNotifier {
  OrdersNotifier(this._apiClient);

  final ApiClient _apiClient;

  List<Order> _orders = const [];
  Order? _trackedOrder;
  Timer? _pollTimer;
  bool _loading = false;
  String? _error;

  List<Order> get orders => _orders;
  Order? get trackedOrder => _trackedOrder;
  bool get loading => _loading;
  String? get error => _error;

  Future<Order?> placeOrder(List<CartPizza> cartItems) async {
    if (cartItems.isEmpty) return null;
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      final request = CreateOrderRequest(
        items: cartItems
            .map(
              (item) => CreateOrderItem(
                leftHalfType: item.leftHalf.type.name,
                rightHalfType: item.rightHalf.type.name,
              ),
            )
            .toList(),
      );
      final order = await _apiClient.createOrder(request);
      _trackedOrder = order;
      await loadOrders();
      startTracking(order.id);
      return order;
    } on Object catch (e) {
      _error = e.toString();
      return null;
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  Future<void> loadOrders() async {
    _loading = true;
    _error = null;
    notifyListeners();

    try {
      _orders = await _apiClient.getOrders();
    } on Object catch (e) {
      _error = e.toString();
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void startTracking(String orderId) {
    _pollTimer?.cancel();
    _poll(orderId);
    _pollTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      _poll(orderId);
    });
  }

  Future<void> _poll(String orderId) async {
    try {
      _trackedOrder = await _apiClient.getOrder(orderId);
      notifyListeners();
      if (_trackedOrder?.status == OrderStatus.delivered) {
        _pollTimer?.cancel();
      }
    } on Object catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _pollTimer?.cancel();
    super.dispose();
  }
}
