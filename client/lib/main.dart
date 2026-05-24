import 'package:flutter/material.dart';

import 'package:pizzaf/app.dart';
import 'package:pizzaf/core/api/api_client.dart';
import 'package:pizzaf/core/api/token_storage.dart';
import 'package:pizzaf/core/di/app_scope.dart';
import 'package:pizzaf/features/auth/auth_notifier.dart';
import 'package:pizzaf/features/cart/cart_notifier.dart';
import 'package:pizzaf/features/menu/menu_notifier.dart';
import 'package:pizzaf/features/orders/orders_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);
  final authNotifier = AuthNotifier(apiClient: apiClient, tokenStorage: tokenStorage);
  apiClient.onUnauthorized = authNotifier.sessionExpired;
  final menuNotifier = MenuNotifier(apiClient);
  final cartNotifier = CartNotifier();
  final ordersNotifier = OrdersNotifier(apiClient);

  runApp(
    AppScope(
      apiClient: apiClient,
      tokenStorage: tokenStorage,
      authNotifier: authNotifier,
      menuNotifier: menuNotifier,
      cartNotifier: cartNotifier,
      ordersNotifier: ordersNotifier,
      child: const PizzaFApp(),
    ),
  );
}
