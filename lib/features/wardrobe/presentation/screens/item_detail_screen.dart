import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/data/repositories/wardrobe_repository.dart';
import 'package:mobile/features/wardrobe/presentation/providers/wardrobe_providers.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/ai_analysis_section.dart';

/// Kıyafet detay ekranı — read-only (Hafta 5).
/// Hero animasyonu ile tam ekran fotoğraf geçişi + bilgi kartı.
class ItemDetailScreen extends ConsumerWidget {
  const ItemDetailScreen({super.key, required this.itemId});

  final String itemId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final itemAsync = ref.watch(wardrobeItemStreamProvider(itemId));

    return Scaffold(
      backgroundColor: AppColors.pearl,
      body: itemAsync.when(
        data: (item) {
          if (item == null) return const _ErrorView(message: 'Kıyafet bulunamadı');
          return _DetailView(item: item);
        },
        error: (e, st) => _ErrorView(message: 'Hata: ${e.toString()}'),
        loading: () => const _LoadingView(),
      ),
    );
  }
}

// ── Detail View ───────────────────────────────────────────────────────────────

class _DetailView extends ConsumerWidget {
  const _DetailView({required this.item});
  final WardrobeItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imageUrl = item.imageUrl ?? item.thumbnailUrl;

    return CustomScrollView(
      slivers: [
        // Hero animasyonlu büyük fotoğraf
        SliverAppBar(
          expandedHeight: MediaQuery.of(context).size.width,
          pinned: true,
          backgroundColor: AppColors.onyx,
          leading: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.onyxWithOpacity(0.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: AppColors.pearl,
                size: 18,
              ),
            ),
          ),
          actions: [
            Tooltip(
              message: 'Düzenleme Hafta 6\'da geliyor',
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(
                  Icons.edit_outlined,
                  color: AppColors.pearl.withValues(alpha: 0.4),
                  size: 22,
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Hero(
              tag: 'wardrobe_item_${item.id}',
              child: imageUrl != null
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, _) => Shimmer.fromColors(
                        baseColor: AppColors.charcoal,
                        highlightColor: AppColors.graphite,
                        child: Container(color: AppColors.charcoal),
                      ),
                      errorWidget: (_, _, _) => Container(
                        color: AppColors.charcoal,
                        child: const Center(
                          child: Icon(
                            Icons.broken_image_outlined,
                            color: AppColors.stone,
                            size: 48,
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: AppColors.charcoal,
                      child: const Center(
                        child: Icon(
                          Icons.checkroom_outlined,
                          color: AppColors.stone,
                          size: 64,
                        ),
                      ),
                    ),
            ),
          ),
        ),

        // Bilgi kartı
        SliverToBoxAdapter(
          child: _InfoCard(item: item),
        ),

        // AI Analiz Bölümü
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: AiAnalysisSection(
              analysis: item.aiAnalysis,
              isAnalyzing: item.uploadStatus == UploadStatus.ready &&
                  item.aiAnalysis == null,
            ),
          ),
        ),

        // Boşluk
        const SliverToBoxAdapter(
          child: SizedBox(height: 32),
        ),
      ],
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends ConsumerWidget {
  const _InfoCard({required this.item});
  final WardrobeItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final createdAgo = _timeAgo(item.createdAt);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.onyxWithOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Kategori başlık
          Text(
            '${item.category.displayLabel} · ${item.subcategory}'.toUpperCase(),
            style: AppTypography.labelSmall,
          ),
          if (item.brand != null) ...[
            const SizedBox(height: 4),
            Text(item.brand!, style: AppTypography.headlineSmall),
          ],
          const SizedBox(height: 20),
          // Detay satırları
          if (item.size != null)
            _InfoRow(label: 'Beden', value: item.size!),
          if (item.notes != null && item.notes!.isNotEmpty)
            _InfoRow(label: 'Notlar', value: item.notes!),
          _InfoRow(label: 'Eklenme', value: createdAgo),
          _InfoRow(label: 'Kullanım', value: '${item.usageCount} kez'),
          
          const SizedBox(height: 8),
          const Divider(color: AppColors.mist, height: 1),
          const SizedBox(height: 8),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Herkese Açık',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.onyx,
              ),
            ),
            subtitle: const Text(
              'Bu kıyafeti profilinde herkese açık göster',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 12,
                color: AppColors.stone,
              ),
            ),
            value: item.isPublic,
            activeThumbColor: AppColors.onyx,
            onChanged: (value) async {
              await ref.read(wardrobeRepositoryProvider).toggleItemPublic(item.id, value);
            },
          ),
          
          // Upload status badge
          if (item.uploadStatus != UploadStatus.ready) ...[
            const SizedBox(height: 8),
            _StatusBadge(status: item.uploadStatus),
          ],
        ],
      ),
    );
  }

  String _timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays == 0) return 'Bugün';
    if (diff.inDays == 1) return 'Dün';
    if (diff.inDays < 7) return '${diff.inDays} gün önce';
    if (diff.inDays < 30) return '${(diff.inDays / 7).floor()} hafta önce';
    final months = ['Oca','Şub','Mar','Nis','May','Haz','Tem','Ağu','Eyl','Eki','Kas','Ara'];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: AppTypography.bodySmall,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  const _StatusBadge({required this.status});
  final UploadStatus status;

  @override
  Widget build(BuildContext context) {
    final isUploading = status == UploadStatus.uploading;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: isUploading
            ? AppColors.onyxWithOpacity(0.08)
            : AppColors.error.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        isUploading ? 'Fotoğraf yükleniyor...' : 'Yükleme başarısız',
        style: AppTypography.labelSmall.copyWith(
          color: isUploading ? AppColors.stone : AppColors.error,
        ),
      ),
    );
  }
}

// ── Loading & Error ───────────────────────────────────────────────────────────

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: AppBar(
        backgroundColor: AppColors.pearl,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: const Center(
        child: CircularProgressIndicator(color: AppColors.onyx),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.pearl,
      appBar: AppBar(
        backgroundColor: AppColors.pearl,
        elevation: 0,
        leading: const BackButton(),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.stone,
                size: 48,
              ),
              const SizedBox(height: 16),
              Text(
                message,
                style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
