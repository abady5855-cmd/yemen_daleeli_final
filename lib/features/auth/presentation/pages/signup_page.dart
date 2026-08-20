import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';

class SignupPage extends ConsumerStatefulWidget {
  const SignupPage({super.key});

  @override
  ConsumerState<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends ConsumerState<SignupPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('إنشاء حساب')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'الاسم الكامل'),
            ),
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
                  ref.read(authNotifierProvider.notifier).signUpWithEmail(
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                      );
                },
                child: const Text('إنشاء الحساب'),
              ),
              loading: () => const LoadingStateWidget(),
              error: (error, _) => ErrorStateWidget(
                message: error.toString(),
                onRetry: () {
                  ref.read(authNotifierProvider.notifier).signUpWithEmail(
                        _emailController.text,
                        _passwordController.text,
                        _nameController.text,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
