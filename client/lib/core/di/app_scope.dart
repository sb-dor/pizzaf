import 'package:flutter/widgets.dart';

import '../../features/auth/auth_notifier.dart';
import '../../features/cart/cart_notifier.dart';
import '../../features/menu/menu_notifier.dart';
import '../../features/orders/orders_notifier.dart';
import '../api/api_client.dart';
import '../api/token_storage.dart';

class AppScope extends InheritedWidget {
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final AuthNotifier authNotifier;
  final MenuNotifier menuNotifier;
  final CartNotifier cartNotifier;
  final OrdersNotifier ordersNotifier;

  const AppScope({
    super.key,
    required this.apiClient,
    required this.tokenStorage,
    required this.authNotifier,
    required this.menuNotifier,
    required this.cartNotifier,
    required this.ordersNotifier,
    required super.child,
  });

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
