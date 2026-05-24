import 'package:flutter/material.dart';
import 'package:pizzaf/core/di/app_scope.dart';
import 'package:pizzaf/core/widgets/app_background.dart';
import 'package:pizzaf/features/auth/auth_notifier.dart';
import 'package:pizzaf/theme/app_theme.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _registerMode = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final auth = AppScope.of(context).authNotifier;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 430),
                child: AnimatedBuilder(
                  animation: auth,
                  builder: (context, _) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text('PizzaF', style: Theme.of(context).textTheme.headlineLarge),
                        const SizedBox(height: 8),
                        const Text(
                          'Build half-and-half pizzas and track every order.',
                          style: TextStyle(color: AppTheme.textMuted),
                        ),
                        const SizedBox(height: 28),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(18),
                            child: Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Text(
                                    _registerMode ? 'Create account' : 'Welcome back',
                                    style: Theme.of(context).textTheme.titleLarge,
                                  ),
                                  const SizedBox(height: 16),
                                  if (_registerMode) ...[
                                    TextFormField(
                                      controller: _nameController,
                                      textInputAction: TextInputAction.next,
                                      decoration: const InputDecoration(labelText: 'Name'),
                                      validator: (value) => value == null || value.trim().isEmpty
                                          ? 'Enter your name'
                                          : null,
                                    ),
                                    const SizedBox(height: 12),
                                  ],
                                  TextFormField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.next,
                                    decoration: const InputDecoration(labelText: 'Email'),
                                    validator: (value) => value == null || !value.contains('@')
                                        ? 'Enter a valid email'
                                        : null,
                                  ),
                                  const SizedBox(height: 12),
                                  TextFormField(
                                    controller: _passwordController,
                                    obscureText: true,
                                    decoration: const InputDecoration(labelText: 'Password'),
                                    validator: (value) => value == null || value.length < 6
                                        ? 'Use at least 6 characters'
                                        : null,
                                    onFieldSubmitted: (_) => _submit(auth),
                                  ),
                                  if (auth.error != null) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      auth.error!,
                                      style: const TextStyle(color: AppTheme.danger),
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                  FilledButton(
                                    onPressed: auth.busy ? null : () => _submit(auth),
                                    child: auth.busy
                                        ? const SizedBox.square(
                                            dimension: 18,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(_registerMode ? 'Register' : 'Log in'),
                                  ),
                                  TextButton(
                                    onPressed: auth.busy
                                        ? null
                                        : () => setState(() {
                                            _registerMode = !_registerMode;
                                          }),
                                    child: Text(
                                      _registerMode
                                          ? 'Already have an account? Log in'
                                          : 'New here? Create an account',
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _submit(AuthNotifier auth) {
    if (!_formKey.currentState!.validate()) return;
    if (_registerMode) {
      auth.register(
        _nameController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );
    } else {
      auth.login(_emailController.text.trim(), _passwordController.text);
    }
  }
}
