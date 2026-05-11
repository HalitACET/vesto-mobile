import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/features/wardrobe/data/models/ai_analysis.dart';

/// Kıyafet detay sayfasında AI analiz sonuçlarını gösteren premium section.
class AiAnalysisSection extends StatelessWidget {
  const AiAnalysisSection({
    super.key,
    this.analysis,
    this.isAnalyzing = false,
  });

  final AiAnalysis? analysis;
  final bool isAnalyzing;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final radius = context.radius;

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(spacing.lg),
      decoration: BoxDecoration(
        color: AppColors.pearl,
        borderRadius: radius.mdBorderRadius,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            children: [
              Text(
                'AI ANALİZ'.toUpperCase(),
                style: AppTypography.labelSmall.copyWith(
                  color: AppColors.mist,
                  letterSpacing: 2.0,
                ),
              ),
              const Spacer(),
              if (isAnalyzing)
                _AnalyzingBadge()
              else if (analysis != null)
                _ConfidenceBadge(confidence: analysis!.confidence),
            ],
          ),
          SizedBox(height: spacing.md),

          if (isAnalyzing || (analysis == null && !isAnalyzing))
            _LoadingState()
          else
            _ContentState(analysis: analysis!),
        ],
      ),
    );
  }
}

// ── Badge Widgets ────────────────────────────────────────────────────────────

class _AnalyzingBadge extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.onyx,
      highlightColor: AppColors.mist,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.auto_awesome, size: 12, color: AppColors.onyx),
          const SizedBox(width: 4),
          Text(
            'Analiz Ediliyor'.toUpperCase(),
            style: AppTypography.labelSmall.copyWith(
              fontSize: 9,
              color: AppColors.onyx,
            ),
          ),
        ],
      ),
    );
  }
}

class _ConfidenceBadge extends StatelessWidget {
  const _ConfidenceBadge({required this.confidence});
  final double confidence;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.onyx.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Text(
        '%${(confidence * 100).toInt()} Güven'.toUpperCase(),
        style: AppTypography.labelSmall.copyWith(fontSize: 8),
      ),
    );
  }
}

// ── States ───────────────────────────────────────────────────────────────────

class _LoadingState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _ShimmerLine(width: 150),
        const SizedBox(height: 12),
        _ShimmerLine(width: 100),
        const SizedBox(height: 12),
        Row(
          children: List.generate(
            3,
            (i) => Padding(
              padding: const EdgeInsets.only(right: 8),
              child: _ShimmerCircle(),
            ),
          ),
        ),
      ],
    );
  }
}

class _ContentState extends StatelessWidget {
  const _ContentState({required this.analysis});
  final AiAnalysis analysis;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Malzeme ve Desen
        Row(
          children: [
            _InfoChip(
              icon: Icons.texture,
              label: analysis.detectedMaterial ?? 'Bilinmeyen Malzeme',
            ),
            const SizedBox(width: 8),
            _InfoChip(
              icon: Icons.grid_view,
              label: _getPatternLabel(analysis.pattern),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Renk Paleti Başlığı
        Text(
          'DOMİNANT RENKLER',
          style: AppTypography.labelSmall.copyWith(
            fontSize: 9,
            color: AppColors.mist,
          ),
        ),
        const SizedBox(height: 12),
        // Renk Noktaları
        Row(
          children: analysis.dominantColors.map((c) => _ColorItem(color: c)).toList(),
        ),
      ],
    );
  }

  String _getPatternLabel(AiPattern pattern) {
    switch (pattern) {
      case AiPattern.solid: return 'Düz / Sade';
      case AiPattern.striped: return 'Çizgili';
      case AiPattern.plaid: return 'Ekoseli';
      case AiPattern.floral: return 'Çiçekli';
      case AiPattern.graphic: return 'Grafik Baskılı';
      case AiPattern.other: return 'Desenli';
    }
  }
}

// ── Components ───────────────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.label});
  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.mist.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.onyx),
          const SizedBox(width: 6),
          Text(
            label,
            style: AppTypography.bodySmall.copyWith(
              color: AppColors.onyx,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _ColorItem extends StatelessWidget {
  const _ColorItem({required this.color});
  final DominantColor color;

  @override
  Widget build(BuildContext context) {
    final hex = color.hex.replaceFirst('#', 'FF');
    final colorVal = Color(int.parse(hex, radix: 16));

    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: colorVal,
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.mist.withValues(alpha: 0.2)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '%${(color.percentage * 100).toInt()}',
            style: AppTypography.labelSmall.copyWith(fontSize: 8),
          ),
        ],
      ),
    );
  }
}

// ── Shimmer Helpers ───────────────────────────────────────────────────────────

class _ShimmerLine extends StatelessWidget {
  const _ShimmerLine({required this.width});
  final double width;

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.white,
      highlightColor: AppColors.pearl,
      child: Container(
        width: width,
        height: 16,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    );
  }
}

class _ShimmerCircle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.white,
      highlightColor: AppColors.pearl,
      child: Container(
        width: 32,
        height: 32,
        decoration: const BoxDecoration(
          color: AppColors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
