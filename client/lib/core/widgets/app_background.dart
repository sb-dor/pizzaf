import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class AppBackground extends StatelessWidget {
  final Widget child;

  const AppBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppTheme.background, Color(0xFF17151D), Color(0xFF201A17)],
        ),
      ),
      child: child,
    );
  }
}
