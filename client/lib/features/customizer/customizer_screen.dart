import 'package:flutter/material.dart';
import 'package:pizzaf/core/di/app_scope.dart';
import 'package:pizzaf/core/widgets/app_background.dart';
import 'package:pizzaf/core/widgets/price_text.dart';
import 'package:pizzaf/features/customizer/customizer_notifier.dart';
import 'package:pizzaf/features/customizer/widgets/half_selector.dart';
import 'package:pizzaf/features/customizer/widgets/pizza_canvas.dart';
import 'package:pizzaf/features/menu/widgets/pizza_card.dart';
import 'package:pizzaf/theme/app_theme.dart';
import 'package:shared/shared.dart';

class CustomizerScreen extends StatefulWidget {
  const CustomizerScreen({super.key, required this.initialPizza});
  final PizzaInfo initialPizza;

  @override
  State<CustomizerScreen> createState() => _CustomizerScreenState();
}

class _CustomizerScreenState extends State<CustomizerScreen> {
  late final CustomizerNotifier _notifier;

  @override
  void initState() {
    super.initState();
    _notifier = CustomizerNotifier(PizzaType.values.byName(widget.initialPizza.id));
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
                    child: SizedBox(
                      width: _pizzaCanvasSize(context),
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
                  Text('Choose flavor', style: Theme.of(context).textTheme.titleLarge),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final pizza in pizzas)
                        _PizzaChoiceChip(
                          pizza: pizza,
                          selected: _isSelected(pizza.id),
                          onSelected: () {
                            _notifier.applyType(PizzaType.values.byName(pizza.id));
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
                              const Text('Total', style: TextStyle(fontWeight: FontWeight.w900)),
                              const Spacer(),
                              PriceText(
                                _notifier.price,
                                style: Theme.of(
                                  context,
                                ).textTheme.titleLarge?.copyWith(color: AppTheme.accentAlt),
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
                      AppScope.of(context).cartNotifier.add(_notifier.cartPizza);
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(const SnackBar(content: Text('Added to cart')));
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

  double _pizzaCanvasSize(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width - 32;
    return width.clamp(260.0, 380.0);
  }
}

class _PizzaChoiceChip extends StatelessWidget {
  const _PizzaChoiceChip({required this.pizza, required this.selected, required this.onSelected});
  final PizzaInfo pizza;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return ChoiceChip(
      selected: selected,
      selectedColor: AppTheme.accent,
      onSelected: (_) => onSelected(),
      avatar: CircleAvatar(
        backgroundColor: AppTheme.surfaceHigh,
        child: PizzaPreview(typeName: pizza.id, size: 24),
      ),
      label: Text(pizza.name),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({required this.label, required this.name, required this.price});
  final String label;
  final String name;
  final double price;

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
