import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';

class SplashPage extends ConsumerWidget {
  const SplashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // سنضع شعار التطبيق هنا لاحقاً
            Icon(Icons.map_outlined, size: 100, color: Colors.blue),
            SizedBox(height: 20),
            Text(
              'يمن دليلي',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            LoadingStateWidget(),
          ],
        ),
      ),
    );
  }
}
