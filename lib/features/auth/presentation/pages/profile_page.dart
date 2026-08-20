import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(authNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('الملف الشخصي')),
      body: userAsync.when(
        data: (user) => user == null
            ? const Center(child: Text('الرجاء تسجيل الدخول لعرض الملف الشخصي'))
            : ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const Center(
                    child: CircleAvatar(
                      radius: 50,
                      child: Icon(Icons.person, size: 50),
                    ),
                  ),
                  const SizedBox(height: 24),
                  _buildProfileItem(Icons.person_outline, 'الاسم الكامل', user.fullName),
                  _buildProfileItem(Icons.email_outlined, 'البريد الإلكتروني', user.email),
                  _buildProfileItem(Icons.phone_outlined, 'رقم الهاتف', user.phoneNumber ?? 'غير محدد'),
                  const Divider(height: 40),
                  ListTile(
                    leading: const Icon(Icons.edit, color: Colors.blue),
                    title: const Text('تعديل البيانات الشخصية'),
                    onTap: () {
                      // سيتم إضافة شاشة التعديل لاحقاً
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.lock_outline, color: Colors.orange),
                    title: const Text('تغيير كلمة المرور'),
                    onTap: () {
                      // سيتم إضافة تغيير كلمة المرور لاحقاً
                    },
                  ),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text('تسجيل الخروج'),
                    onTap: () => ref.read(authNotifierProvider.notifier).signOut(),
                  ),
                ],
              ),
        loading: () => const ServicesSkeleton(),
        error: (err, _) => ErrorStateWidget(
          message: 'خطأ في جلب البيانات: $err',
          onRetry: () => ref.invalidate(authNotifierProvider),
        ),
      ),
    );
  }

  Widget _buildProfileItem(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          const SizedBox(width: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            ],
          ),
        ],
      ),
    );
  }
}
