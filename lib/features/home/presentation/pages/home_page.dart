import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/home/presentation/providers/home_providers.dart';
import 'package:yemen_daleeli/features/categories/presentation/providers/categories_providers.dart';
import 'package:yemen_daleeli/core/widgets/skeleton_widgets.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adsAsync = ref.watch(activeAdvertisementsProvider);
    final categoriesAsync = ref.watch(categoriesProvider);
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('يمن دليلي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'البحث',
            onPressed: () => context.go('/services'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeAdvertisementsProvider);
          ref.invalidate(categoriesProvider);

          await Future.wait([
            ref.read(activeAdvertisementsProvider.future),
            ref.read(categoriesProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'مرحباً، ${user?.fullName ?? 'ضيف'}',
              style: Theme.of(context).textTheme.headlineSmall,
            ),

            const SizedBox(height: 20),

            // قسم الإعلانات
            const Text(
              'أبرز العروض',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            adsAsync.when(
              data: (ads) {
                if (ads.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'لا توجد إعلانات حالياً',
                  );
                }

                return SizedBox(
                  height: 150,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: ads.length,
                    itemBuilder: (context, index) {
                      final ad = ads[index];

                      return Card(
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                ad.titleAr,
                                textAlign: TextAlign.center,
                              ),
                              const Spacer(),
                              const Icon(
                                Icons.image,
                                size: 50,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
              loading: () => const AdsSkeleton(),
              error: (err, _) {
                if (err.toString().toLowerCase().contains('network')) {
                  return OfflineStateWidget(
                    onRetry: () {
                      ref.invalidate(activeAdvertisementsProvider);
                    },
                  );
                }

                return ErrorStateWidget(
                  message: 'خطأ في جلب الإعلانات: $err',
                  onRetry: () {
                    ref.invalidate(activeAdvertisementsProvider);
                  },
                );
              },
            ),

            const SizedBox(height: 20),

            // قسم التصنيفات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'التصنيفات',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () => context.go('/categories'),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            categoriesAsync.when(
              data: (categories) {
                if (categories.isEmpty) {
                  return const EmptyStateWidget(
                    message: 'لا توجد تصنيفات حالياً',
                  );
                }

                return GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate:
                      const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    childAspectRatio: 1,
                  ),
                  itemCount:
                      categories.length > 6 ? 6 : categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];

                    return InkWell(
                      onTap: () {
                        final categoryName =
                            Uri.encodeComponent(category.nameAr);

                        context.push(
                          '/services'
                          '?categoryId=${category.id}'
                          '&categoryName=$categoryName',
                        );
                      },
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.category),
                            const SizedBox(height: 8),
                            Text(
                              category.nameAr,
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
              loading: () => const CategoriesSkeleton(),
              error: (err, _) {
                if (err.toString().toLowerCase().contains('network')) {
                  return OfflineStateWidget(
                    onRetry: () {
                      ref.invalidate(categoriesProvider);
                    },
                  );
                }

                return ErrorStateWidget(
                  message: 'خطأ في جلب التصنيفات: $err',
                  onRetry: () {
                    ref.invalidate(categoriesProvider);
                  },
                );
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),

      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.category),
            label: 'التصنيفات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.favorite),
            label: 'المفضلة',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'حسابي',
          ),
        ],
        onTap: (index) {
          switch (index) {
            case 0:
              context.go('/home');
              break;

            case 1:
              context.go('/categories');
              break;

            case 2:
              context.go('/favorites');
              break;

            case 3:
              context.go('/profile');
              break;
          }
        },
      ),
    );
  }
}
