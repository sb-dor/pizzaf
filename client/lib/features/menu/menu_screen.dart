import 'package:flutter/material.dart';

import '../../core/di/app_scope.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/loading_error.dart';
import '../../navigation/app_router.dart';
import '../../theme/app_theme.dart';
import 'widgets/pizza_card.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({super.key});

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).menuNotifier.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final scope = AppScope.of(context);
    final menu = scope.menuNotifier;
    final cart = scope.cartNotifier;
    final auth = scope.authNotifier;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('PizzaF'),
                    Text(
                      auth.user?.name ?? 'Half-and-half pizza',
                      style: const TextStyle(
                        color: AppTheme.textMuted,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
                actions: [
                  IconButton(
                    tooltip: 'Orders',
                    onPressed: () => AppRouter.openOrders(context),
                    icon: const Icon(Icons.receipt_long),
                  ),
                  AnimatedBuilder(
                    animation: cart,
                    builder: (context, _) {
                      return Badge(
                        isLabelVisible: cart.count > 0,
                        label: Text('${cart.count}'),
                        child: IconButton(
                          tooltip: 'Cart',
                          onPressed: () => AppRouter.openCart(context),
                          icon: const Icon(Icons.shopping_bag_outlined),
                        ),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'Logout',
                    onPressed: auth.logout,
                    icon: const Icon(Icons.logout),
                  ),
                ],
              ),
              SliverPadding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
                sliver: AnimatedBuilder(
                  animation: menu,
                  builder: (context, _) {
                    if (menu.loading && menu.pizzas.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(child: CircularProgressIndicator()),
                      );
                    }
                    if (menu.error != null && menu.pizzas.isEmpty) {
                      return SliverFillRemaining(
                        child: LoadingError(
                          message: menu.error!,
                          onRetry: menu.load,
                        ),
                      );
                    }
                    return SliverGrid.builder(
                      gridDelegate:
                          const SliverGridDelegateWithMaxCrossAxisExtent(
                            maxCrossAxisExtent: 260,
                            mainAxisExtent: 300,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12,
                          ),
                      itemCount: menu.pizzas.length,
                      itemBuilder: (context, index) {
                        final pizza = menu.pizzas[index];
                        return PizzaCard(
                          pizza: pizza,
                          onCustomize: () =>
                              AppRouter.openCustomizer(context, pizza: pizza),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
