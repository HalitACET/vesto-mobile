import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';

enum VestoAvatarSize { small, medium, large }

/// Kullanıcı avatarı — network image veya initials fallback.
/// Shimmer skeleton ile yükleme süresini gizler (4. hafta hazırlığı).
class VestoAvatar extends StatelessWidget {
  const VestoAvatar({
    super.key,
    this.imageUrl,
    this.initials,
    this.size = VestoAvatarSize.medium,
  });

  final String? imageUrl;
  final String? initials;
  final VestoAvatarSize size;

  double get _dimension => switch (size) {
        VestoAvatarSize.small => 32,
        VestoAvatarSize.medium => 48,
        VestoAvatarSize.large => 80,
      };

  TextStyle get _textStyle => switch (size) {
        VestoAvatarSize.small => AppTypography.labelSmall.copyWith(
            fontFamily: 'Cormorant',
            fontSize: 12,
            color: AppColors.pearl,
          ),
        VestoAvatarSize.medium => AppTypography.titleMedium.copyWith(
            fontFamily: 'Cormorant',
            color: AppColors.pearl,
          ),
        VestoAvatarSize.large => AppTypography.headlineMedium.copyWith(
            color: AppColors.pearl,
          ),
      };

  @override
  Widget build(BuildContext context) {
    final d = _dimension;

    if (imageUrl != null) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: imageUrl!,
          width: d,
          height: d,
          fit: BoxFit.cover,
          placeholder: (_, _) => _shimmer(d),
          errorWidget: (_, _, _) => _placeholder(d),
        ),
      );
    }

    return _placeholder(d);
  }

  Widget _placeholder(double d) {
    return Container(
      width: d,
      height: d,
      decoration: const BoxDecoration(
        color: AppColors.charcoal,
        shape: BoxShape.circle,
      ),
      alignment: Alignment.center,
      child: Text(
        (initials ?? '?').toUpperCase(),
        style: _textStyle,
      ),
    );
  }

  Widget _shimmer(double d) {
    return Shimmer.fromColors(
      baseColor: AppColors.mist,
      highlightColor: AppColors.pearl,
      child: Container(
        width: d,
        height: d,
        decoration: const BoxDecoration(
          color: AppColors.mist,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
