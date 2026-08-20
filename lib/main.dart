import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:yemen_daleeli/core/providers/core_providers.dart';
import 'package:yemen_daleeli/core/routing/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // تهيئة Firebase (ستحتاج لملفات google-services.json للعمل الفعلي)
  // try {
  //   await Firebase.initializeApp();
  // } catch (e) {
  //   print('Firebase initialization failed: $e');
  // }

  final sharedPreferences = await SharedPreferences.getInstance();

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(sharedPreferences),
      ],
      child: const YemenDaleeliApp(),
    ),
  );
}

class YemenDaleeliApp extends ConsumerWidget {
  const YemenDaleeliApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'يمن دليلي',
      debugShowCheckedModeBanner: false,
      locale: const Locale('ar'),
      theme: ThemeData(
        primarySwatch: Colors.blue,
        fontFamily: 'Cairo', // نفترض استخدام خط القاهرة للعربية
        useMaterial3: true,
      ),
      routerConfig: router,
    );
  }
}
