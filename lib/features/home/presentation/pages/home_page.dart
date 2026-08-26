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

  loading: () => _buildFallbackAdvertisement(context),

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
