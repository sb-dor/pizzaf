import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:pizzaf/theme/app_theme.dart';
import 'package:shared/shared.dart';

class PizzaCanvas extends StatelessWidget {
  const PizzaCanvas({
    super.key,
    required this.leftType,
    required this.rightType,
    required this.selectedSide,
    required this.onSideSelected,
  });
  final PizzaType leftType;
  final PizzaType rightType;
  final HalfSide selectedSide;
  final ValueChanged<HalfSide> onSideSelected;

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTapDown: (details) {
          final box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(details.globalPosition);
          onSideSelected(local.dx < box.size.width / 2 ? HalfSide.left : HalfSide.right);
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: CustomPaint(
            key: ValueKey('${leftType.name}-${rightType.name}-${selectedSide.name}'),
            painter: PizzaCanvasPainter(
              leftType: leftType,
              rightType: rightType,
              selectedSide: selectedSide,
            ),
            child: const SizedBox.expand(),
          ),
        ),
      ),
    );
  }
}

class PizzaCanvasPainter extends CustomPainter {
  PizzaCanvasPainter({required this.leftType, required this.rightType, required this.selectedSide});
  final PizzaType leftType;
  final PizzaType rightType;
  final HalfSide selectedSide;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.48;
    final innerRadius = radius * 0.86;
    final rect = Rect.fromCircle(center: center, radius: innerRadius);

    canvas.drawCircle(center, radius, Paint()..color = const Color(0xFFD18A34));
    canvas.drawCircle(center, innerRadius, Paint()..color = const Color(0xFFE85D3F));

    _drawHalf(canvas, rect, HalfSide.left, leftType);
    _drawHalf(canvas, rect, HalfSide.right, rightType);

    canvas.drawLine(
      Offset(center.dx, center.dy - innerRadius),
      Offset(center.dx, center.dy + innerRadius),
      Paint()
        ..color = AppTheme.background.withValues(alpha: 0.9)
        ..strokeWidth = 4
        ..strokeCap = StrokeCap.round,
    );

    canvas.drawCircle(
      center,
      radius - 2,
      Paint()
        ..color = const Color(0xFFE0A14C)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 8,
    );

    final selectedStart = selectedSide == HalfSide.left ? math.pi / 2 : -math.pi / 2;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 5),
      selectedStart,
      math.pi,
      false,
      Paint()
        ..color = AppTheme.accent
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawHalf(Canvas canvas, Rect rect, HalfSide side, PizzaType type) {
    final start = side == HalfSide.left ? math.pi / 2 : -math.pi / 2;
    final path = Path()
      ..moveTo(rect.center.dx, rect.center.dy)
      ..arcTo(rect, start, math.pi, false)
      ..close();

    canvas.save();
    canvas.clipPath(path);

    canvas.drawCircle(rect.center, rect.width / 2, Paint()..color = const Color(0xFFFFD166));

    final colors = _colorsFor(type);
    final radius = rect.width / 2;
    final xSign = side == HalfSide.left ? -1.0 : 1.0;
    final spots = [
      Offset(xSign * radius * 0.22, -radius * 0.42),
      Offset(xSign * radius * 0.44, -radius * 0.12),
      Offset(xSign * radius * 0.28, radius * 0.24),
      Offset(xSign * radius * 0.08, radius * 0.04),
      Offset(xSign * radius * 0.36, radius * 0.42),
      Offset(xSign * radius * 0.12, -radius * 0.18),
    ];

    for (var i = 0; i < spots.length; i++) {
      canvas.drawCircle(
        rect.center + spots[i],
        radius * (i.isEven ? 0.105 : 0.075),
        Paint()..color = colors[i % colors.length],
      );
    }

    canvas.restore();
  }

  List<Color> _colorsFor(PizzaType type) {
    return switch (type) {
      PizzaType.margherita => [Colors.white, const Color(0xFF2E8B57)],
      PizzaType.bbqChicken => [const Color(0xFF8A4F2A), const Color(0xFFFFF1A6)],
      PizzaType.hawaiian => [const Color(0xFFFFD23F), const Color(0xFFD95D39)],
      PizzaType.fourCheese => [Colors.white, const Color(0xFFFFF4B8)],
      PizzaType.veggie => [const Color(0xFF2E8B57), const Color(0xFFC1121F)],
      PizzaType.meatLovers => [const Color(0xFF6D2E1F), const Color(0xFFC1121F)],
      PizzaType.buffalo => [const Color(0xFFFF7A1A), const Color(0xFF70A9A1)],
      PizzaType.pepperoni => [const Color(0xFFC1121F), const Color(0xFF6D2E1F)],
    };
  }

  @override
  bool shouldRepaint(covariant PizzaCanvasPainter oldDelegate) {
    return oldDelegate.leftType != leftType ||
        oldDelegate.rightType != rightType ||
        oldDelegate.selectedSide != selectedSide;
  }
}
