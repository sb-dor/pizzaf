import 'package:flutter/widgets.dart';
import 'package:pizzaf/core/api/api_client.dart';
import 'package:pizzaf/core/api/token_storage.dart';
import 'package:pizzaf/features/auth/auth_notifier.dart';
import 'package:pizzaf/features/cart/cart_notifier.dart';
import 'package:pizzaf/features/menu/menu_notifier.dart';
import 'package:pizzaf/features/orders/orders_notifier.dart';

class AppScope extends InheritedWidget {
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
  final ApiClient apiClient;
  final TokenStorage tokenStorage;
  final AuthNotifier authNotifier;
  final MenuNotifier menuNotifier;
  final CartNotifier cartNotifier;
  final OrdersNotifier ordersNotifier;

  static AppScope of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppScope>();
    assert(scope != null, 'AppScope is missing from the widget tree');
    return scope!;
  }

  @override
  bool updateShouldNotify(AppScope oldWidget) => false;
}
