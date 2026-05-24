import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/di/app_scope.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/loading_error.dart';
import '../../core/widgets/price_text.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).ordersNotifier.loadOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).ordersNotifier;

    return Scaffold(
      appBar: AppBar(title: const Text('Orders')),
      body: AppBackground(
        child: AnimatedBuilder(
          animation: orders,
          builder: (context, _) {
            if (orders.loading && orders.orders.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }
            if (orders.error != null && orders.orders.isEmpty) {
              return LoadingError(
                message: orders.error!,
                onRetry: orders.loadOrders,
              );
            }
            if (orders.orders.isEmpty) {
              return const Center(
                child: Text(
                  'No orders yet',
                  style: TextStyle(color: AppTheme.textMuted),
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: orders.loadOrders,
              child: ListView.separated(
                padding: const EdgeInsets.all(16),
                itemCount: orders.orders.length,
                separatorBuilder: (_, _) => const SizedBox(height: 10),
                itemBuilder: (context, index) {
                  final order = orders.orders[index];
                  return _OrderTile(
                    order: order,
                    onTap: () {
                      orders.startTracking(order.id);
                      AppRouter.openTracking(context, order);
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }
}

class _OrderTile extends StatelessWidget {
  final Order order;
  final VoidCallback onTap;

  const _OrderTile({required this.order, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        title: Text('Order ${order.id.substring(0, 8)}'),
        subtitle: Text(
          '${order.items.length} pizza${order.items.length == 1 ? '' : 's'}',
          style: const TextStyle(color: AppTheme.textMuted),
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              order.status.displayName,
              style: const TextStyle(
                color: AppTheme.accentAlt,
                fontWeight: FontWeight.w800,
              ),
            ),
            PriceText(order.totalPrice),
          ],
        ),
      ),
    );
  }
}
