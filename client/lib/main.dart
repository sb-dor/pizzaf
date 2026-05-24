import 'package:flutter/material.dart';

import 'app.dart';
import 'core/api/api_client.dart';
import 'core/api/token_storage.dart';
import 'core/di/app_scope.dart';
import 'features/auth/auth_notifier.dart';
import 'features/cart/cart_notifier.dart';
import 'features/menu/menu_notifier.dart';
import 'features/orders/orders_notifier.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final tokenStorage = TokenStorage();
  final apiClient = ApiClient(tokenStorage: tokenStorage);
  final authNotifier = AuthNotifier(
    apiClient: apiClient,
    tokenStorage: tokenStorage,
  );
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
