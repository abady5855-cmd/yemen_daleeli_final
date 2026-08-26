import 'dart:developer' as developer;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:yemen_daleeli/core/widgets/skeleton_widgets.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/categories/presentation/providers/categories_providers.dart';
import 'package:yemen_daleeli/features/home/presentation/providers/home_providers.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  static const String _fallbackAdImage = 'assets/images/ad_test.png';

  // ============================================================
  // تشخيص الإعلانات من Firestore
  // ============================================================
  Future<void> debugFetchAds() async {
    try {
      developer.log(
        '========== START ADS DEBUG ==========',
        name: 'YEMEN_DALEELI',
      );

      final snap = await FirebaseFirestore.instance
          .collection('advertisements')
          .get();

      developer.log(
        'DEBUG ads count = ${snap.docs.length}',
        name: 'YEMEN_DALEELI',
      );

      if (snap.docs.isEmpty) {
        developer.log(
          'DEBUG: لا توجد مستندات داخل advertisements',
          name: 'YEMEN_DALEELI',
        );
      }

      for (final doc in snap.docs) {
        final data = doc.data();

        developer.log(
          'DEBUG document ID = ${doc.id}',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG document data = $data',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG id = ${data['id']}',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG title_ar = ${data['title_ar']}',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG image = ${data['image']}',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG isActive = ${data['isActive']}',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG isDeleted = ${data['isDeleted']}',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG startDate = ${data['startDate']}',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG endDate = ${data['endDate']}',
          name: 'YEMEN_DALEELI',
        );

        developer.log(
          'DEBUG createdAt = ${data['createdAt']}',
          name: 'YEMEN_DALEELI',
        );
      }

      developer.log(
        '========== END ADS DEBUG ==========',
        name: 'YEMEN_DALEELI',
      );
    } catch (e, stackTrace) {
      developer.log(
        'DEBUG fetch ads ERROR = $e',
        name: 'YEMEN_DALEELI',
        error: e,
        stackTrace: stackTrace,
      );
    }
  }

  // ============================================================
  // صورة الإعلان
  // ============================================================
  Widget _buildAdvertisementImage({
    required BuildContext context,
    required String imageUrl,
  }) {
    final cleanUrl = imageUrl.trim();

    if (cleanUrl.isEmpty) {
      return Image.asset(
        _fallbackAdImage,
        fit: BoxFit.cover,
      );
    }

    return Image.network(
      cleanUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) {
          return child;
        }

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _fallbackAdImage,
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.08),
              child: const Center(
                child: SizedBox(
                  width: 28,
                  height: 28,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                  ),
                ),
              ),
            ),
          ],
        );
      },
      errorBuilder: (context, error, stackTrace) {
        developer.log(
          'Advertisement image failed: $cleanUrl',
          name: 'YEMEN_DALEELI',
          error: error,
          stackTrace: stackTrace,
        );

        return Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              _fallbackAdImage,
              fit: BoxFit.cover,
            ),
            Container(
              color: Colors.black.withOpacity(0.12),
              alignment: Alignment.bottomCenter,
              padding: const EdgeInsets.only(bottom: 6),
              child: const Text(
                'الصورة الأصلية غير متاحة',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      offset: Offset(0, 1),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // بطاقة إعلان تجريبية محلية
  // ============================================================
  Widget _buildFallbackAdvertisement(BuildContext context) {
    return SizedBox(
      height: 190,
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: 3,
        child: SizedBox(
          width: double.infinity,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: Image.asset(
                  _fallbackAdImage,
                  fit: BoxFit.cover,
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 8,
                ),
                child: Text(
                  'إعلان تجريبي',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // بطاقة الإعلان الحقيقي
  // ============================================================
  Widget _buildAdvertisementCard(
    BuildContext context,
    dynamic ad,
  ) {
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(right: 12),
      elevation: 3,
      child: SizedBox(
        width: 300,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 115,
              width: double.infinity,
              child: _buildAdvertisementImage(
                context: context,
                imageUrl: ad.imageUrl,
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
              child: Text(
                ad.titleAr.trim().isEmpty ? 'إعلان' : ad.titleAr,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // الإعلانات
  // ============================================================
  Widget _buildAdvertisements(
    BuildContext context,
    AsyncValue adsAsync,
    WidgetRef ref,
  ) {
    return adsAsync.when(
      data: (ads) {
        if (ads.isEmpty) {
          return _buildFallbackAdvertisement(context);
        }

        return SizedBox(
          height: 190,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: ads.length,
            itemBuilder: (context, index) {
              final ad = ads[index];
              return _buildAdvertisementCard(context, ad);
            },
          ),
        );
      },
      loading: () => const AdsSkeleton(),
      error: (error, stackTrace) {
        developer.log(
          'Home advertisements error',
          name: 'YEMEN_DALEELI',
          error: error,
          stackTrace: stackTrace,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildFallbackAdvertisement(context),
            const SizedBox(height: 8),
            TextButton.icon(
              onPressed: () {
                ref.invalidate(activeAdvertisementsProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة تحميل الإعلانات'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // التصنيفات
  // ============================================================
  Widget _buildCategories(
    BuildContext context,
    AsyncValue categoriesAsync,
    WidgetRef ref,
  ) {
    return categoriesAsync.when(
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
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: categories.length > 6 ? 6 : categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];

            return InkWell(
              borderRadius: BorderRadius.circular(12),
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
                    const Icon(
                      Icons.category,
                      size: 32,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 4,
                      ),
                      child: Text(
                        category.nameAr,
                        textAlign: TextAlign.center,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
      loading: () => const CategoriesSkeleton(),
      error: (error, stackTrace) {
        developer.log(
          'Home categories error',
          name: 'YEMEN_DALEELI',
          error: error,
          stackTrace: stackTrace,
        );

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const ErrorStateWidget(
              message: 'تعذر تحميل التصنيفات',
            ),
            TextButton.icon(
              onPressed: () {
                ref.invalidate(categoriesProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('إعادة تحميل التصنيفات'),
            ),
          ],
        );
      },
    );
  }

  // ============================================================
  // Build
  // ============================================================
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
            icon: const Icon(Icons.bug_report),
            tooltip: 'تشخيص الإعلانات',
            onPressed: () async {
              await debugFetchAds();

              if (!context.mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text(
                    'تم تنفيذ تشخيص الإعلانات. راجع Debug Console.',
                  ),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'البحث',
            onPressed: () => context.go('/services'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'تسجيل الخروج',
            onPressed: () async {
              await ref
                  .read(authNotifierProvider.notifier)
                  .signOut();
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          try {
            ref.invalidate(activeAdvertisementsProvider);
            ref.invalidate(categoriesProvider);

            await Future.wait([
              ref.read(activeAdvertisementsProvider.future),
              ref.read(categoriesProvider.future),
            ]);
          } catch (e, stackTrace) {
            developer.log(
              'Home refresh error',
              name: 'YEMEN_DALEELI',
              error: e,
              stackTrace: stackTrace,
            );
          }
        },
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            Text(
              'مرحباً، ${user?.fullName ?? 'ضيف'}',
              style: Theme.of(context)
                  .textTheme
                  .headlineSmall,
            ),

            const SizedBox(height: 20),

            const Text(
              'أبرز العروض',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 10),

            _buildAdvertisements(
              context,
              adsAsync,
              ref,
            ),

            const SizedBox(height: 24),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'التصنيفات',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      context.go('/categories'),
                  child: const Text('عرض الكل'),
                ),
              ],
            ),

            const SizedBox(height: 10),

            _buildCategories(
              context,
              categoriesAsync,
              ref,
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
      bottomNavigationBar:
          BottomNavigationBar(
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
