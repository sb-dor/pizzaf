import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/di/app_scope.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/price_text.dart';
import '../../theme/app_theme.dart';

class OrderTrackingScreen extends StatefulWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).ordersNotifier.startTracking(widget.order.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final orders = AppScope.of(context).ordersNotifier;

    return Scaffold(
      appBar: AppBar(title: const Text('Order tracking')),
      body: AppBackground(
        child: AnimatedBuilder(
          animation: orders,
          builder: (context, _) {
            final order = orders.trackedOrder?.id == widget.order.id
                ? orders.trackedOrder!
                : widget.order;
            final currentIndex = OrderStatus.values.indexOf(order.status);

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order ${order.id.substring(0, 8)}',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          order.status.description,
                          style: const TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Text('${order.items.length} item(s)'),
                            const Spacer(),
                            PriceText(
                              order.totalPrice,
                              style: const TextStyle(
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                for (var i = 0; i < OrderStatus.values.length; i++)
                  _StatusStep(
                    status: OrderStatus.values[i],
                    completed: i <= currentIndex,
                    last: i == OrderStatus.values.length - 1,
                  ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _StatusStep extends StatelessWidget {
  final OrderStatus status;
  final bool completed;
  final bool last;

  const _StatusStep({
    required this.status,
    required this.completed,
    required this.last,
  });

  @override
  Widget build(BuildContext context) {
    final color = completed ? AppTheme.accent : Colors.white24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            CircleAvatar(
              radius: 16,
              backgroundColor: color,
              child: Icon(
                completed ? Icons.check : Icons.circle_outlined,
                size: 18,
                color: Colors.white,
              ),
            ),
            if (!last) Container(width: 2, height: 42, color: color),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  status.displayName,
                  style: const TextStyle(fontWeight: FontWeight.w900),
                ),
                const SizedBox(height: 2),
                Text(
                  status.description,
                  style: const TextStyle(color: AppTheme.textMuted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
