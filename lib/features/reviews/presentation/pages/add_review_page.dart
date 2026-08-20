import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:yemen_daleeli/features/auth/presentation/providers/auth_providers.dart';
import 'package:yemen_daleeli/features/reviews/presentation/providers/reviews_providers.dart';

class AddReviewPage extends ConsumerStatefulWidget {
  final String serviceId;

  const AddReviewPage({super.key, required this.serviceId});

  @override
  ConsumerState<AddReviewPage> createState() => _AddReviewPageState();
}

class _AddReviewPageState extends ConsumerState<AddReviewPage> {
  double _rating = 5.0;
  final _commentController = TextEditingController();

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final addReviewState = ref.watch(addReviewNotifierProvider);
    final user = ref.watch(authNotifierProvider).value;

    return Scaffold(
      appBar: AppBar(title: const Text('إضافة تقييم')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('ما هو تقييمك للخدمة؟', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) => IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: Colors.amber,
                  size: 40,
                ),
                onPressed: () => setState(() => _rating = index + 1.0),
              )),
            ),
            const SizedBox(height: 24),
            const Text('أضف تعليقك (اختياري)', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            TextField(
              controller: _commentController,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'اكتب تجربتك هنا...',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: addReviewState is AsyncLoading || user == null
                    ? null
                    : () async {
                        await ref.read(addReviewNotifierProvider.notifier).addReview(
                              serviceId: widget.serviceId,
                              userId: user.id,
                              userName: user.fullName,
                              rating: _rating,
                              comment: _commentController.text,
                            );
                        if (mounted && ref.read(addReviewNotifierProvider) is! AsyncError) {
                          context.pop();
                        }
                      },
                child: addReviewState is AsyncLoading
                    ? const CircularProgressIndicator()
                    : const Text('نشر التقييم'),
              ),
            ),
            if (addReviewState is AsyncError)
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: Text(
                  'خطأ: ${(addReviewState as AsyncError).error}',
                  style: const TextStyle(color: Colors.red),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
