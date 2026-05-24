import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../core/di/app_scope.dart';
import '../../core/widgets/app_background.dart';
import '../../core/widgets/price_text.dart';
import '../../theme/app_theme.dart';
import 'customizer_notifier.dart';
import 'widgets/half_selector.dart';
import 'widgets/pizza_canvas.dart';

class CustomizerScreen extends StatefulWidget {
  final PizzaInfo initialPizza;

  const CustomizerScreen({super.key, required this.initialPizza});

  @override
  State<CustomizerScreen> createState() => _CustomizerScreenState();
}

class _CustomizerScreenState extends State<CustomizerScreen> {
  late final CustomizerNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = CustomizerNotifier(
      PizzaType.values.byName(widget.initialPizza.id),
    );
  }

  @override
  void dispose() {
    _notifier.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final pizzas = AppScope.of(context).menuNotifier.pizzas;

    return Scaffold(
      appBar: AppBar(title: const Text('Build your pizza')),
      body: AppBackground(
        child: SafeArea(
          top: false,
          child: AnimatedBuilder(
            animation: _notifier,
            builder: (context, _) {
              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 380),
                      child: PizzaCanvas(
                        leftType: _notifier.leftType,
                        rightType: _notifier.rightType,
                        selectedSide: _notifier.selectedSide,
                        onSideSelected: _notifier.selectSide,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: HalfSelector(
                      selectedSide: _notifier.selectedSide,
                      onChanged: _notifier.selectSide,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Choose flavor',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final pizza in pizzas)
                        ChoiceChip(
                          label: Text(pizza.name),
                          selected: _isSelected(pizza.id),
                          selectedColor: AppTheme.accent,
                          onSelected: (_) {
                            _notifier.applyType(
                              PizzaType.values.byName(pizza.id),
                            );
                          },
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Left',
                            name: _notifier.leftType.displayName,
                            price: _notifier.leftType.halfPrice,
                          ),
                          const Divider(height: 20),
                          _SummaryRow(
                            label: 'Right',
                            name: _notifier.rightType.displayName,
                            price: _notifier.rightType.halfPrice,
                          ),
                          const Divider(height: 24),
                          Row(
                            children: [
                              const Text(
                                'Total',
                                style: TextStyle(fontWeight: FontWeight.w900),
                              ),
                              const Spacer(),
                              PriceText(
                                _notifier.price,
                                style: Theme.of(context).textTheme.titleLarge
                                    ?.copyWith(color: AppTheme.accentAlt),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () {
                      AppScope.of(
                        context,
                      ).cartNotifier.add(_notifier.cartPizza);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Added to cart')),
                      );
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to cart'),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  bool _isSelected(String pizzaId) {
    final selected = _notifier.selectedSide == HalfSide.left
        ? _notifier.leftType
        : _notifier.rightType;
    return selected.name == pizzaId;
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String name;
  final double price;

  const _SummaryRow({
    required this.label,
    required this.name,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 54,
          child: Text(label, style: const TextStyle(color: AppTheme.textMuted)),
        ),
        Expanded(child: Text(name, overflow: TextOverflow.ellipsis)),
        PriceText(price),
      ],
    );
  }
}
