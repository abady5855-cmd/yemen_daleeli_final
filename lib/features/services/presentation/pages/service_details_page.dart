import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_daleeli/features/services/presentation/providers/services_providers.dart';
import 'package:yemen_daleeli/features/reviews/presentation/providers/reviews_providers.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';

class ServiceDetailsPage extends ConsumerWidget {
  final String serviceId;

  const ServiceDetailsPage({super.key, required this.serviceId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final serviceAsync = ref.watch(serviceDetailProvider(serviceId));
    final reviewsAsync = ref.watch(serviceReviewsProvider(serviceId));
    final favorites = ref.watch(favoriteNotifierProvider);
    final isFavorite = favorites.contains(serviceId);

    return Scaffold(
      appBar: AppBar(title: const Text('تفاصيل الخدمة')),
      body: serviceAsync.when(
        data: (service) => ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // صورة الخدمة
            Container(
              height: 200,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(Icons.business, size: 100, color: Colors.grey),
            ),
            const SizedBox(height: 16),
            
            // معلومات الخدمة
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(service.nameAr, style: Theme.of(context).textTheme.headlineSmall),
                ),
                IconButton(
                  icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: Colors.red),
                  onPressed: () {
                    ref.read(favoriteNotifierProvider.notifier).toggleFavorite(serviceId, isFavorite);
                  },
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(service.descriptionAr),
            const Divider(height: 32),
            
            // الموقع والاتصال
            const Text('معلومات التواصل', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            ListTile(
              leading: const Icon(Icons.location_on),
              title: Text(service.addressAr),
            ),
            ListTile(
              leading: const Icon(Icons.phone),
              title: Text(service.phone),
            ),
            const Divider(height: 32),
            
            // التقييمات
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('التقييمات والتعليقات', style: TextStyle(fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () => context.push('/add-review/$serviceId'),
                  child: const Text('إضافة تقييم'),
                ),
              ],
            ),
            const SizedBox(height: 8),
            reviewsAsync.when(
              data: (reviews) => reviews.isEmpty
                  ? const EmptyStateWidget(message: 'لا توجد تقييمات بعد', icon: Icons.rate_review_outlined)
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          child: ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.person)),
                            title: Row(
                              children: List.generate(5, (i) => Icon(
                                Icons.star, 
                                size: 14, 
                                color: i < review.rating ? Colors.amber : Colors.grey
                              )),
                            ),
                            subtitle: Text(review.commentAr ?? ''),
                          ),
                        );
                      },
                    ),
              loading: () => const ServicesSkeleton(),
              error: (err, _) => err.toString().contains('network')
                ? OfflineStateWidget(onRetry: () => ref.invalidate(serviceReviewsProvider(serviceId)))
                : ErrorStateWidget(
                    message: 'خطأ في جلب التقييمات: $err',
                    onRetry: () => ref.invalidate(serviceReviewsProvider(serviceId)),
                  ),
            ),
          ],
        ),
        loading: () => const ServicesSkeleton(),
        error: (err, _) => err.toString().contains('network')
          ? OfflineStateWidget(onRetry: () => ref.invalidate(serviceDetailProvider(serviceId)))
          : ErrorStateWidget(
              message: 'خطأ في جلب التفاصيل: $err',
              onRetry: () => ref.invalidate(serviceDetailProvider(serviceId)),
            ),
      ),
    );
  }
}
