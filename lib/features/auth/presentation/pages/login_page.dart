import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('تسجيل الدخول')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
            ),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'كلمة المرور'),
              obscureText: true,
            ),
            const SizedBox(height: 20),
            authState.when(
              data: (_) => ElevatedButton(
                onPressed: () {
                  ref.read(authNotifierProvider.notifier).signInWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                },
                child: const Text('دخول'),
              ),
              loading: () => const LoadingStateWidget(),
              error: (error, _) => ErrorStateWidget(
                message: error.toString(),
                onRetry: () {
                  ref.read(authNotifierProvider.notifier).signInWithEmail(
                        _emailController.text,
                        _passwordController.text,
                      );
                },
              ),
            ),
            TextButton(
              onPressed: () => context.push('/signup'),
              child: const Text('إنشاء حساب جديد'),
            ),
            TextButton(
              onPressed: () {
                ref.read(authNotifierProvider.notifier).signInAsGuest();
              },
              child: const Text('الدخول كضيف'),
            ),
          ],
        ),
      ),
    );
  }
}
