// ignore_for_file: cascade_invocations

import 'package:flutter/material.dart';
import 'package:pizzaf/core/widgets/price_text.dart';
import 'package:pizzaf/theme/app_theme.dart';
import 'package:shared/shared.dart';

class PizzaCard extends StatelessWidget {
  const PizzaCard({super.key, required this.pizza, required this.onCustomize});
  final PizzaInfo pizza;
  final VoidCallback onCustomize;

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onCustomize,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Image.network(
                        pizza.imageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return ColoredBox(
                            color: AppTheme.surfaceHigh,
                            child: Center(child: PizzaPreview(typeName: pizza.id, size: 116)),
                          );
                        },
                        loadingBuilder: (context, child, loadingProgress) {
                          if (loadingProgress == null) return child;
                          return ColoredBox(
                            color: AppTheme.surfaceHigh,
                            child: Center(child: PizzaPreview(typeName: pizza.id, size: 116)),
                          );
                        },
                      ),
                      DecoratedBox(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Colors.transparent, Colors.black.withValues(alpha: 0.18)],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                pizza.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 4),
              Text(
                pizza.description,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: AppTheme.textMuted, fontSize: 12),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  PriceText(
                    pizza.halfPrice,
                    style: const TextStyle(color: AppTheme.accentAlt, fontWeight: FontWeight.w900),
                  ),
                  const Text(' / half', style: TextStyle(color: AppTheme.textMuted)),
                  const Spacer(),
                  const Icon(Icons.tune, color: AppTheme.accent),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class PizzaPreview extends StatelessWidget {
  const PizzaPreview({super.key, required this.typeName, required this.size});
  final String typeName;
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: PizzaPreviewPainter(typeName));
  }
}

class PizzaPreviewPainter extends CustomPainter {
  PizzaPreviewPainter(this.typeName);
  final String typeName;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    final crust = Paint()..color = const Color(0xFFD18A34);
    final cheese = Paint()..color = const Color(0xFFFFD166);
    final sauce = Paint()..color = const Color(0xFFE85D3F);

    canvas.drawCircle(center, radius, crust);
    canvas.drawCircle(center, radius * 0.86, sauce);
    canvas.drawCircle(center, radius * 0.78, cheese);

    final toppingPaints = _colorsFor(
      typeName,
    ).map((color) => Paint()..color = color).toList(growable: false);
    final spots = [
      const Offset(-0.34, -0.2),
      const Offset(0.22, -0.28),
      const Offset(0.36, 0.18),
      const Offset(-0.2, 0.32),
      const Offset(0.02, 0.02),
    ];
    for (var i = 0; i < spots.length; i++) {
      final offset = Offset(spots[i].dx * radius, spots[i].dy * radius);
      canvas.drawCircle(
        center + offset,
        radius * (i.isEven ? 0.12 : 0.09),
        toppingPaints[i % toppingPaints.length],
      );
    }
  }

  List<Color> _colorsFor(String id) {
    return switch (id) {
      'margherita' => [Colors.white, const Color(0xFF2E8B57)],
      'bbqChicken' => [const Color(0xFF8A4F2A), const Color(0xFFFFF1A6)],
      'hawaiian' => [const Color(0xFFFFD23F), const Color(0xFFD95D39)],
      'fourCheese' => [Colors.white, const Color(0xFFFFF4B8)],
      'veggie' => [const Color(0xFF2E8B57), const Color(0xFFC1121F)],
      'meatLovers' => [const Color(0xFF6D2E1F), const Color(0xFFC1121F)],
      'buffalo' => [const Color(0xFFFF7A1A), const Color(0xFF70A9A1)],
      _ => [const Color(0xFFC1121F), const Color(0xFF6D2E1F)],
    };
  }

  @override
  bool shouldRepaint(covariant PizzaPreviewPainter oldDelegate) {
    return oldDelegate.typeName != typeName;
  }
}
