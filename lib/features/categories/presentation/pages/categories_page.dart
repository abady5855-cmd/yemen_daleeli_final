import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_daleeli/features/categories/presentation/providers/categories_providers.dart';
import 'package:yemen_daleeli/core/widgets/skeleton_widgets.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';

class CategoriesPage extends ConsumerWidget {
  const CategoriesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final categoriesAsync = ref.watch(categoriesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('كافة التصنيفات')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(categoriesProvider),
        child: categoriesAsync.when(
          data: (categories) => categories.isEmpty
              ? const EmptyStateWidget(message: 'لا توجد تصنيفات متاحة حالياً')
              : GridView.builder(
                  padding: const EdgeInsets.all(16),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 1.2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return InkWell(
                      onTap: () => context.push('/services?categoryId=${category.id}&categoryName=${category.nameAr}'),
                      child: Card(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.category, size: 40),
                            const SizedBox(height: 8),
                            Text(category.nameAr, textAlign: TextAlign.center),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16.0),
            child: CategoriesSkeleton(),
          ),
          error: (err, _) => ErrorStateWidget(
            message: 'خطأ في جلب التصنيفات: $err',
            onRetry: () => ref.invalidate(categoriesProvider),
          ),
        ),
      ),
    );
  }
}
