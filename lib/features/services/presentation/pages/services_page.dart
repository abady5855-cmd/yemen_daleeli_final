import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_daleeli/features/services/presentation/providers/services_providers.dart';
import 'package:yemen_daleeli/core/widgets/skeleton_widgets.dart';
import 'package:yemen_daleeli/core/widgets/state_widgets.dart';

class ServicesPage extends ConsumerStatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const ServicesPage({super.key, this.categoryId, this.categoryName});

  @override
  ConsumerState<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends ConsumerState<ServicesPage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  String _query = '';
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final params = {
        'categoryId': widget.categoryId,
        'query': _query.isEmpty ? null : _query,
      };
      ref.read(paginatedServicesProvider(params).notifier).fetchMore();
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      setState(() => _query = query);
    });
  }

  @override
  Widget build(BuildContext context) {
    final params = {
      'categoryId': widget.categoryId,
      'query': _query.isEmpty ? null : _query,
    };
    final state = ref.watch(paginatedServicesProvider(params));

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.categoryName ?? 'الخدمات'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'ابحث عن خدمة...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isNotEmpty 
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(30)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.read(paginatedServicesProvider(params).notifier).fetchInitial(),
        child: state.isLoading
            ? const ServicesSkeleton()
            : state.error != null && state.items.isEmpty
                ? (state.error!.contains('network') || state.error!.contains('connection')
                    ? OfflineStateWidget(
                        onRetry: () => ref.read(paginatedServicesProvider(params).notifier).fetchInitial(),
                      )
                    : ErrorStateWidget(
                        message: 'خطأ في جلب الخدمات: ${state.error}',
                        onRetry: () => ref.read(paginatedServicesProvider(params).notifier).fetchInitial(),
                      ))
                : state.items.isEmpty
                    ? const EmptyStateWidget(message: 'لا توجد خدمات تطابق بحثك')
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: state.items.length + (state.hasMore ? 1 : 0),
                        itemBuilder: (context, index) {
                          if (index == state.items.length) {
                            return const Padding(
                              padding: EdgeInsets.symmetric(vertical: 16.0),
                              child: Center(child: CircularProgressIndicator()),
                            );
                          }
                          final service = state.items[index];
                          return ListTile(
                            leading: const CircleAvatar(child: Icon(Icons.business)),
                            title: Text(service.nameAr),
                            subtitle: Text(service.addressAr),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.star, color: Colors.amber, size: 16),
                                Text(service.rating.toString()),
                              ],
                            ),
                            onTap: () => context.push('/service-details/${service.id}'),
                          );
                        },
                      ),
      ),
    );
  }
}
