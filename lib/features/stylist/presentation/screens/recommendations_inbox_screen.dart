import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/features/stylist/data/models/outfit_recommendation.dart';
import 'package:mobile/features/stylist/presentation/providers/stylist_providers.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';
import 'package:mobile/core/widgets/organisms/vesto_error_view.dart';

class RecommendationsInboxScreen extends ConsumerStatefulWidget {
  const RecommendationsInboxScreen({super.key});

  @override
  ConsumerState<RecommendationsInboxScreen> createState() =>
      _RecommendationsInboxScreenState();
}

class _RecommendationsInboxScreenState
    extends ConsumerState<RecommendationsInboxScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: AppBar(
        backgroundColor: AppColors.pearl,
        elevation: 0,
        title: const Text(
          'Kombin Önerileri',
          style: TextStyle(
            fontFamily: 'Cormorant', // Vesto app uses Cormorant mostly for titles
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.onyx,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.onyx,
          unselectedLabelColor: AppColors.stone,
          indicatorColor: AppColors.onyx,
          indicatorWeight: 1.5,
          labelStyle: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
          tabs: const [
            Tab(text: 'BEKLEYEN'),
            Tab(text: 'KABUL'),
            Tab(text: 'RED'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: const [
          _RecommendationList(status: 'pending'),
          _RecommendationList(status: 'accepted'),
          _RecommendationList(status: 'rejected'),
        ],
      ),
    );
  }
}

class _RecommendationList extends ConsumerWidget {
  final String status;
  const _RecommendationList({required this.status});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recsAsync = ref.watch(recommendationsByStatusProvider(status));

    return recsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => VestoErrorView(
        message: 'Öneriler yüklenemedi',
        onRetry: () => ref.invalidate(recommendationsByStatusProvider(status)),
      ),
      data: (recs) {
        if (recs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  status == 'pending'
                      ? Icons.inbox_outlined
                      : status == 'accepted'
                          ? Icons.check_circle_outline
                          : Icons.cancel_outlined,
                  size: 40,
                  color: AppColors.stone,
                ),
                const SizedBox(height: 12),
                Text(
                  status == 'pending'
                      ? 'Bekleyen öneri yok'
                      : status == 'accepted'
                          ? 'Kabul edilen öneri yok'
                          : 'Reddedilen öneri yok',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    color: AppColors.stone,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: recs.length,
          separatorBuilder: (_, _) => const SizedBox(height: 12),
          itemBuilder: (context, index) => _RecommendationCard(
            recommendation: recs[index],
            showActions: status == 'pending',
          ),
        );
      },
    );
  }
}

class _RecommendationCard extends ConsumerWidget {
  final OutfitRecommendation recommendation;
  final bool showActions;

  const _RecommendationCard({
    required this.recommendation,
    required this.showActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final actionState = ref.watch(recommendationActionProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mist),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stilist bilgisi
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.mist,
                backgroundImage: recommendation.stylistPhotoUrl != null
                    ? CachedNetworkImageProvider(
                        recommendation.stylistPhotoUrl!)
                    : null,
                child: recommendation.stylistPhotoUrl == null
                    ? Text(recommendation.stylistDisplayName
                        .substring(0, 1)
                        .toUpperCase())
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      recommendation.stylistDisplayName,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                        color: AppColors.onyx,
                      ),
                    ),
                    const Text(
                      'kombin önerdi',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.stone,
                      ),
                    ),
                  ],
                ),
              ),
              // Status badge
              if (!showActions)
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: recommendation.status == 'accepted'
                        ? Colors.green.shade50
                        : Colors.red.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    recommendation.status == 'accepted'
                        ? 'Kabul Edildi'
                        : 'Reddedildi',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: recommendation.status == 'accepted'
                          ? Colors.green.shade700
                          : Colors.red.shade700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),

          // Outfit preview (2x2 grid)
          AspectRatio(
            aspectRatio: 2,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: GridView.count(
                crossAxisCount: 2,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  _ItemThumb(itemId: recommendation.items.topId),
                  _ItemThumb(itemId: recommendation.items.bottomId),
                  _ItemThumb(itemId: recommendation.items.shoesId),
                  _ItemThumb(itemId: recommendation.items.accessoryId),
                ],
              ),
            ),
          ),

          // Not
          if (recommendation.note.isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              '"${recommendation.note}"',
              style: const TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: AppColors.onyx,
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
            ),
          ],

          // Kabul/Red butonları
          if (showActions) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: actionState.isLoading
                        ? null
                        : () => _accept(context, ref),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.onyx,
                      foregroundColor: AppColors.pearl,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: actionState.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: AppColors.pearl,
                            ),
                          )
                        : const Text(
                            'Kabul Et',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: OutlinedButton(
                    onPressed: actionState.isLoading
                        ? null
                        : () => _reject(context, ref),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.stone,
                      side: const BorderSide(color: AppColors.mist),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Reddet',
                      style: TextStyle(fontFamily: 'Inter'),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _accept(BuildContext context, WidgetRef ref) async {
    await ref
        .read(recommendationActionProvider.notifier)
        .accept(recommendation);

    if (!context.mounted) return;

    // Kabul sonrası rating sor
    final rating = await showDialog<int>(
      context: context,
      builder: (_) => _RatingDialog(
        stylistName: recommendation.stylistDisplayName,
      ),
    );

    if (!context.mounted) return;
    final messenger = ScaffoldMessenger.of(context);

    if (rating != null) {
      await ref
          .read(stylistRepositoryProvider)
          .rateRecommendation(recommendation.id, rating);
      messenger.showSnackBar(
        SnackBar(content: Text('$rating ⭐ verildi! Kombin eklendi.')),
      );
    } else {
      messenger.showSnackBar(
        const SnackBar(content: Text('🎉 Kombin kabul edildi ve dolabına eklendi!')),
      );
    }
  }


  Future<void> _reject(BuildContext context, WidgetRef ref) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text(
          'Reddet',
          style: TextStyle(fontFamily: 'Cormorant', fontSize: 22, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Bu öneriyi reddetmek istediğinden emin misin?',
          style: TextStyle(fontFamily: 'Inter'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Reddet',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await ref
          .read(recommendationActionProvider.notifier)
          .reject(recommendation.id);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Öneri reddedildi')),
        );
      }
    }
  }
}

class _ItemThumb extends ConsumerWidget {
  final String? itemId;
  const _ItemThumb({this.itemId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (itemId == null) {
      return Container(color: AppColors.mist);
    }

    final String nonNullItemId = itemId!;
    final itemAsync = ref.watch(wardrobeItemStreamProvider(nonNullItemId));
    return itemAsync.when(
      loading: () => Container(color: AppColors.mist),
      error: (_, _) => Container(color: AppColors.mist),
      data: (item) {
        if (item == null) return Container(color: AppColors.mist);
        return CachedNetworkImage(
          imageUrl: item.bgRemovedUrl ?? item.imageUrl ?? '',
          fit: BoxFit.cover,
          placeholder: (_, _) => Container(color: AppColors.mist),
          errorWidget: (_, _, _) => Container(color: AppColors.mist),
        );
      },
    );
  }
}

// ── Rating Dialog ─────────────────────────────────────────────────────────────

class _RatingDialog extends StatefulWidget {
  final String stylistName;
  const _RatingDialog({required this.stylistName});

  @override
  State<_RatingDialog> createState() => _RatingDialogState();
}

class _RatingDialogState extends State<_RatingDialog> {
  int _rating = 0;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.pearl,
      title: Text(
        '${widget.stylistName} için puan ver',
        style: const TextStyle(
          fontFamily: 'Cormorant',
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onyx,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Bu öneriden ne kadar memnun kaldın?',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              color: AppColors.stone,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (index) {
              return IconButton(
                icon: Icon(
                  index < _rating ? Icons.star : Icons.star_border,
                  color: index < _rating ? Colors.amber : AppColors.stone,
                  size: 32,
                ),
                onPressed: () => setState(() => _rating = index + 1),
              );
            }),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Geç',
            style: TextStyle(fontFamily: 'Inter', color: AppColors.stone),
          ),
        ),
        TextButton(
          onPressed: _rating > 0
              ? () => Navigator.pop(context, _rating)
              : null,
          child: Text(
            'Gönder',
            style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w600,
              color: _rating > 0 ? AppColors.onyx : AppColors.mist,
            ),
          ),
        ),
      ],
    );
  }
}

