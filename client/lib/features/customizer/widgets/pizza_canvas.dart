import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:shared/shared.dart';

import '../../../theme/app_theme.dart';

class PizzaCanvas extends StatelessWidget {
  final PizzaType leftType;
  final PizzaType rightType;
  final HalfSide selectedSide;
  final ValueChanged<HalfSide> onSideSelected;

  const PizzaCanvas({
    super.key,
    required this.leftType,
    required this.rightType,
    required this.selectedSide,
    required this.onSideSelected,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1,
      child: GestureDetector(
        onTapDown: (details) {
          final box = context.findRenderObject() as RenderBox;
          final local = box.globalToLocal(details.globalPosition);
          onSideSelected(
            local.dx < box.size.width / 2 ? HalfSide.left : HalfSide.right,
          );
        },
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 180),
          child: CustomPaint(
            key: ValueKey(
              '${leftType.name}-${rightType.name}-${selectedSide.name}',
            ),
            painter: PizzaCanvasPainter(
              leftType: leftType,
              rightType: rightType,
              selectedSide: selectedSide,
            ),
          ),
        ),
      ),
    );
  }
}

class PizzaCanvasPainter extends CustomPainter {
  final PizzaType leftType;
  final PizzaType rightType;
  final HalfSide selectedSide;

  PizzaCanvasPainter({
    required this.leftType,
    required this.rightType,
    required this.selectedSide,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide * 0.45;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final crust = Paint()..color = const Color(0xFFD18A34);
    final sauce = Paint()..color = const Color(0xFFE85D3F);

    canvas.drawCircle(center, radius, crust);
    canvas.drawCircle(center, radius * 0.88, sauce);

    _drawHalf(canvas, rect, true, leftType);
    _drawHalf(canvas, rect, false, rightType);

    final divider = Paint()
      ..color = AppTheme.background
      ..strokeWidth = 3;
    canvas.drawLine(
      Offset(center.dx, center.dy - radius * 0.86),
      Offset(center.dx, center.dy + radius * 0.86),
      divider,
    );

    final selectedRect = selectedSide == HalfSide.left
        ? Rect.fromLTWH(rect.left, rect.top, radius, rect.height)
        : Rect.fromLTWH(center.dx, rect.top, radius, rect.height);
    canvas.drawArc(
      selectedRect.inflate(6),
      selectedSide == HalfSide.left ? math.pi / 2 : -math.pi / 2,
      math.pi,
      false,
      Paint()
        ..color = AppTheme.accent
        ..strokeWidth = 4
        ..style = PaintingStyle.stroke,
    );
  }

  void _drawHalf(Canvas canvas, Rect rect, bool left, PizzaType type) {
    final start = left ? math.pi / 2 : -math.pi / 2;
    final path = Path()
      ..moveTo(rect.center.dx, rect.center.dy)
      ..arcTo(rect.deflate(rect.width * 0.07), start, math.pi, false)
      ..close();
    canvas.drawPath(path, Paint()..color = const Color(0xFFFFD166));

    final clipPath = Path.from(path);
    canvas.save();
    canvas.clipPath(clipPath);

    final colors = _colorsFor(type);
    final center = rect.center;
    final radius = rect.width / 2;
    final xSign = left ? -1.0 : 1.0;
    final spots = [
      Offset(xSign * radius * 0.22, -radius * 0.38),
      Offset(xSign * radius * 0.42, -radius * 0.06),
      Offset(xSign * radius * 0.25, radius * 0.28),
      Offset(xSign * radius * 0.08, radius * 0.02),
    ];
    for (var i = 0; i < spots.length; i++) {
      canvas.drawCircle(
        center + spots[i],
        radius * 0.09,
        Paint()..color = colors[i % colors.length],
      );
    }
    canvas.restore();
  }

  List<Color> _colorsFor(PizzaType type) {
    return switch (type) {
      PizzaType.margherita => [Colors.white, const Color(0xFF2E8B57)],
      PizzaType.bbqChicken => [
        const Color(0xFF8A4F2A),
        const Color(0xFFFFF1A6),
      ],
      PizzaType.hawaiian => [const Color(0xFFFFD23F), const Color(0xFFD95D39)],
      PizzaType.fourCheese => [Colors.white, const Color(0xFFFFF4B8)],
      PizzaType.veggie => [const Color(0xFF2E8B57), const Color(0xFFC1121F)],
      PizzaType.meatLovers => [
        const Color(0xFF6D2E1F),
        const Color(0xFFC1121F),
      ],
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
