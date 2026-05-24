import 'package:flutter/material.dart';
import 'package:pizzaf/core/di/app_scope.dart';
import 'package:pizzaf/core/widgets/app_background.dart';
import 'package:pizzaf/core/widgets/price_text.dart';
import 'package:pizzaf/features/cart/widgets/cart_item_tile.dart';
import 'package:pizzaf/navigation/app_router.dart';
import 'package:pizzaf/theme/app_theme.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final cart = scope.cartNotifier;
    final orders = scope.ordersNotifier;

    return Scaffold(
      appBar: AppBar(title: const Text('Cart')),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: Listenable.merge([cart, orders]),
            builder: (context, _) {
              if (cart.isEmpty) {
                return const Center(
                  child: Text('Your cart is empty', style: TextStyle(color: AppTheme.textMuted)),
                );
              }

              return Column(
                children: [
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: cart.items.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        return Dismissible(
                          key: ValueKey('${cart.items[index].displayName}-$index'),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 18),
                            color: AppTheme.danger,
                            child: const Icon(Icons.delete_outline),
                          ),
                          onDismissed: (_) => cart.removeAt(index),
                          child: CartItemTile(
                            item: cart.items[index],
                            onRemove: () => cart.removeAt(index),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.surface,
                      border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.08))),
                    ),
                    child: SafeArea(
                      top: false,
                      child: Row(
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Text('Total', style: TextStyle(color: AppTheme.textMuted)),
                              PriceText(cart.total, style: Theme.of(context).textTheme.titleLarge),
                            ],
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: FilledButton.icon(
                              onPressed: orders.loading
                                  ? null
                                  : () async {
                                      final order = await orders.placeOrder(cart.items);
                                      if (!context.mounted || order == null) {
                                        return;
                                      }
                                      cart.clear();
                                      Navigator.of(context).pop();
                                      AppRouter.openTracking(context, order);
                                    },
                              icon: orders.loading
                                  ? const SizedBox.square(
                                      dimension: 18,
                                      child: CircularProgressIndicator(strokeWidth: 2),
                                    )
                                  : const Icon(Icons.local_shipping_outlined),
                              label: const Text('Place order'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
