import 'package:flutter/material.dart';

import 'package:pizzaf/core/widgets/app_background.dart';
import 'package:pizzaf/theme/app_theme.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: AppBackground(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _PizzaMark(size: 96),
              SizedBox(height: 20),
              Text('PizzaF', style: TextStyle(fontSize: 34, fontWeight: FontWeight.w900)),
              SizedBox(height: 24),
              CircularProgressIndicator(color: AppTheme.accent),
            ],
          ),
        ),
      ),
    );
  }
}

class _PizzaMark extends StatelessWidget {
  const _PizzaMark({required this.size});
  final double size;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.square(size), painter: _PizzaMarkPainter());
  }
}

class _PizzaMarkPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2;
    canvas.drawCircle(center, radius, Paint()..color = AppTheme.accentAlt);
    canvas.drawCircle(center, radius * 0.86, Paint()..color = const Color(0xFFFFD166));
    canvas.drawCircle(center, radius * 0.16, Paint()..color = AppTheme.accent);
    canvas.drawCircle(
      center + Offset(radius * 0.34, -radius * 0.18),
      radius * 0.13,
      Paint()..color = AppTheme.danger,
    );
    canvas.drawCircle(
      center + Offset(-radius * 0.3, radius * 0.2),
      radius * 0.13,
      Paint()..color = AppTheme.danger,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
