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
            onPressed: () => context.push('/services'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => ref.read(authNotifierProvider.notifier).signOut(),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(activeAdvertisementsProvider);
          ref.invalidate(categoriesProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Text('مرحباً، ${user?.fullName ?? 'ضيف'}', 
              style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 20),
            
            // قسم الإعلانات
            const Text('أبرز العروض', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            adsAsync.when(
              data: (ads) => ads.isEmpty 
                ? const EmptyStateWidget(message: 'لا توجد إعلانات حالياً')
                : SizedBox(
                    height: 150,
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: ads.length,
                      itemBuilder: (context, index) => Card(
                        child: Container(
                          width: 300,
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            children: [
                              Text(ads[index].titleAr),
                              const Spacer(),
                              const Icon(Icons.image, size: 50),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
              loading: () => const AdsSkeleton(),
              error: (err, _) => err.toString().contains('network') 
                ? OfflineStateWidget(onRetry: () => ref.invalidate(activeAdvertisementsProvider))
                : ErrorStateWidget(
                    message: 'خطأ في جلب الإعلانات: $err',
                    onRetry: () => ref.invalidate(activeAdvertisementsProvider),
                  ),
            ),
            
            const SizedBox(height: 20),
            
            // قسم التصنيفات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('التصنيفات', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/categories'),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),
            const SizedBox(height: 10),
            categoriesAsync.when(
              data: (categories) => categories.isEmpty
                ? const EmptyStateWidget(message: 'لا توجد تصنيفات حالياً')
                : GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      childAspectRatio: 1,
                    ),
                    itemCount: categories.length > 6 ? 6 : categories.length,
                    itemBuilder: (context, index) {
                      final category = categories[index];
                      return InkWell(
                        onTap: () => context.push('/services?categoryId=${category.id}&categoryName=${category.nameAr}'),
                        child: Card(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.category),
                              Text(category.nameAr, textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              loading: () => const CategoriesSkeleton(),
              error: (err, _) => err.toString().contains('network')
                ? OfflineStateWidget(onRetry: () => ref.invalidate(categoriesProvider))
                : ErrorStateWidget(
                    message: 'خطأ في جلب التصنيفات: $err',
                    onRetry: () => ref.invalidate(categoriesProvider),
                  ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'الرئيسية'),
          BottomNavigationBarItem(icon: Icon(Icons.category), label: 'التصنيفات'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'المفضلة'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'حسابي'),
        ],
        onTap: (index) {
          switch (index) {
            case 0: break; // نحن بالفعل في الرئيسية
            case 1: context.push('/categories'); break;
            case 2: context.push('/favorites'); break;
            case 3: context.push('/profile'); break;
          }
        },
      ),
    );
  }
}
