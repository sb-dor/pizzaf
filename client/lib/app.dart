import 'package:flutter/material.dart';

import 'core/di/app_scope.dart';
import 'features/auth/auth_notifier.dart';
import 'features/auth/login_screen.dart';
import 'features/menu/menu_screen.dart';
import 'features/splash/splash_screen.dart';
import 'theme/app_theme.dart';

class PizzaFApp extends StatefulWidget {
  const PizzaFApp({super.key});

  @override
  State<PizzaFApp> createState() => _PizzaFAppState();
}

class _PizzaFAppState extends State<PizzaFApp> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      AppScope.of(context).authNotifier.restoreSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).authNotifier;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PizzaF',
      theme: AppTheme.dark(),
      home: AnimatedBuilder(
        animation: auth,
        builder: (context, _) {
          return switch (auth.status) {
            AuthStatus.checking => const SplashScreen(),
            AuthStatus.authenticated => const MenuScreen(),
            AuthStatus.unauthenticated => const LoginScreen(),
          };
        },
      ),
    );
  }
}
