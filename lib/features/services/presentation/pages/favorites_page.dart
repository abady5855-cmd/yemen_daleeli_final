import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_daleeli/features/services/presentation/providers/services_providers.dart';
import 'package:yemen_daleeli/core/widgets/skeleton_widgets.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';

class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final favoritesAsync = ref.watch(favoriteServicesProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('المفضلة')),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(favoriteServicesProvider),
        child: favoritesAsync.when(
          data: (services) => services.isEmpty
              ? const EmptyStateWidget(
                  message: 'لا توجد خدمات في المفضلة حالياً',
                  icon: Icons.favorite_border,
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: const CircleAvatar(child: Icon(Icons.business)),
                        title: Text(service.nameAr),
                        subtitle: Text(service.addressAr),
                        trailing: IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            ref.read(favoriteNotifierProvider.notifier).toggleFavorite(service.id, true);
                          },
                        ),
                        onTap: () => context.push('/service-details/${service.id}'),
                      ),
                    );
                  },
                ),
          loading: () => const ServicesSkeleton(),
          error: (err, _) => ErrorStateWidget(
            message: 'خطأ في جلب المفضلة: $err',
            onRetry: () => ref.invalidate(favoriteServicesProvider),
          ),
        ),
      ),
    );
  }
}
