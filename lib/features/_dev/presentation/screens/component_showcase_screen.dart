import 'package:flutter/material.dart';

import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/widgets/atoms/vesto_avatar.dart';
import 'package:mobile/core/widgets/atoms/vesto_badge.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/core/widgets/atoms/vesto_card.dart';
import 'package:mobile/core/widgets/atoms/vesto_chip.dart';
import 'package:mobile/core/widgets/atoms/vesto_divider.dart';
import 'package:mobile/core/widgets/atoms/vesto_empty_state.dart';
import 'package:mobile/core/widgets/atoms/vesto_loading_indicator.dart';
import 'package:mobile/core/widgets/atoms/vesto_text_field.dart';
import 'package:mobile/core/widgets/molecules/vesto_app_bar.dart';
import 'package:mobile/core/widgets/molecules/vesto_bottom_nav.dart';
import 'package:mobile/core/widgets/molecules/vesto_list_tile.dart';
import 'package:mobile/core/widgets/molecules/vesto_snack_bar.dart';

/// DEBUG ONLY — tüm component varyantlarını tek ekranda gösterir.
/// Login ekranında VESTO logosuna 5x tap ile açılır.
class ComponentShowcaseScreen extends StatefulWidget {
  const ComponentShowcaseScreen({super.key});

  @override
  State<ComponentShowcaseScreen> createState() =>
      _ComponentShowcaseScreenState();
}

class _ComponentShowcaseScreenState extends State<ComponentShowcaseScreen> {
  int _selectedChip = 0;
  int _selectedNav = 0;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Scaffold(
      appBar: const VestoAppBar(title: 'Component Showcase'),
      bottomNavigationBar: VestoBottomNav(
        selectedIndex: _selectedNav,
        onTap: (i) => setState(() => _selectedNav = i),
        items: const [
          VestoBottomNavItem(label: 'Home', icon: Icons.home_outlined),
          VestoBottomNavItem(label: 'Wardrobe', icon: Icons.checkroom_outlined),
          VestoBottomNavItem(label: 'Outfits', icon: Icons.style_outlined),
          VestoBottomNavItem(label: 'Forum', icon: Icons.forum_outlined),
          VestoBottomNavItem(label: 'Profile', icon: Icons.person_outlined),
        ],
      ),
      body: ListView(
        padding: EdgeInsets.symmetric(
          horizontal: spacing.pagePadding,
          vertical: spacing.xl,
        ),
        children: [
          _section('BUTTONS'),
          SizedBox(height: spacing.md),
          VestoButton(
            label: 'Primary Button',
            onPressed: () {},
          ),
          SizedBox(height: spacing.sm),
          VestoButton(
            label: 'Secondary Button',
            variant: VestoButtonVariant.secondary,
            onPressed: () {},
          ),
          SizedBox(height: spacing.sm),
          VestoButton(
            label: 'Ghost Button',
            variant: VestoButtonVariant.ghost,
            onPressed: () {},
          ),
          SizedBox(height: spacing.sm),
          VestoButton(
            label: 'Destructive',
            variant: VestoButtonVariant.destructive,
            onPressed: () {},
          ),
          SizedBox(height: spacing.sm),
          const VestoButton(
            label: 'Disabled',
            onPressed: null,
          ),
          SizedBox(height: spacing.sm),
          VestoButton(
            label: 'Loading',
            isLoading: true,
            onPressed: () {},
          ),
          SizedBox(height: spacing.sm),
          Row(
            children: [
              Expanded(
                child: VestoButton(
                  label: 'Small',
                  size: VestoButtonSize.small,
                  onPressed: () {},
                ),
              ),
              SizedBox(width: spacing.sm),
              Expanded(
                child: VestoButton(
                  label: 'Medium',
                  size: VestoButtonSize.medium,
                  onPressed: () {},
                ),
              ),
            ],
          ),
          SizedBox(height: spacing.sm),
          VestoButton(
            label: 'With Icon',
            icon: Icons.add,
            onPressed: () {},
          ),
          SizedBox(height: spacing.xl),

          _section('INPUTS'),
          SizedBox(height: spacing.md),
          const VestoTextField(label: 'E-posta', hint: 'ornek@vesto.app'),
          SizedBox(height: spacing.md),
          const VestoTextField(
            label: 'Şifre',
            obscureText: true,
          ),
          SizedBox(height: spacing.md),
          const VestoTextField(
            label: 'Hatalı Alan',
            errorText: 'Bu alan zorunludur',
          ),
          SizedBox(height: spacing.md),
          const VestoTextField(
            label: 'Devre Dışı',
            enabled: false,
          ),
          SizedBox(height: spacing.xl),

          _section('CARDS'),
          SizedBox(height: spacing.md),
          VestoCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Kart Başlığı', style: AppTypography.titleLarge),
                SizedBox(height: spacing.sm),
                Text(
                  'Flat kart — gölge yok, sadece 1px border. İçerik öne çıkar.',
                  style: AppTypography.bodyMedium
                      .copyWith(color: AppColors.stone),
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.sm),
          VestoCard(
            onTap: () {},
            child: Text('Tıklanabilir Kart', style: AppTypography.bodyMedium),
          ),
          SizedBox(height: spacing.xl),

          _section('AVATARS'),
          SizedBox(height: spacing.md),
          Row(
            children: [
              const VestoAvatar(
                  initials: 'HT', size: VestoAvatarSize.small),
              SizedBox(width: spacing.md),
              const VestoAvatar(initials: 'HT'),
              SizedBox(width: spacing.md),
              const VestoAvatar(
                  initials: 'HT', size: VestoAvatarSize.large),
            ],
          ),
          SizedBox(height: spacing.xl),

          _section('CHIPS'),
          SizedBox(height: spacing.md),
          Wrap(
            spacing: spacing.sm,
            runSpacing: spacing.sm,
            children: ['Tümü', 'Üst', 'Alt', 'Dış Giyim', 'Aksesuar']
                .asMap()
                .entries
                .map(
                  (e) => VestoChip(
                    label: e.value,
                    selected: _selectedChip == e.key,
                    onTap: () => setState(() => _selectedChip = e.key),
                  ),
                )
                .toList(),
          ),
          SizedBox(height: spacing.xl),

          _section('BADGES'),
          SizedBox(height: spacing.md),
          Row(
            children: [
              const VestoBadge(dot: true),
              SizedBox(width: spacing.md),
              const VestoBadge(count: 3),
              SizedBox(width: spacing.md),
              const VestoBadge(count: 99),
              SizedBox(width: spacing.md),
              const VestoBadge(count: 150),
              SizedBox(width: spacing.md),
              const VestoBadge(label: 'YENİ'),
            ],
          ),
          SizedBox(height: spacing.xl),

          _section('LOADING'),
          SizedBox(height: spacing.md),
          Row(
            children: [
              const VestoLoadingIndicator(size: 16),
              SizedBox(width: spacing.md),
              const VestoLoadingIndicator(size: 24),
              SizedBox(width: spacing.md),
              const VestoLoadingIndicator(size: 36),
            ],
          ),
          SizedBox(height: spacing.xl),

          _section('DIVIDERS'),
          SizedBox(height: spacing.md),
          const VestoDivider(),
          SizedBox(height: spacing.md),
          SizedBox(
            height: 40,
            child: Row(
              children: [
                Text('Sol', style: AppTypography.bodySmall),
                SizedBox(width: spacing.md),
                const VestoDivider(vertical: true),
                SizedBox(width: spacing.md),
                Text('Sağ', style: AppTypography.bodySmall),
              ],
            ),
          ),
          SizedBox(height: spacing.xl),

          _section('LIST TILES'),
          SizedBox(height: spacing.md),
          VestoCard(
            noPadding: true,
            child: Column(
              children: [
                VestoListTile(
                  title: 'Profil Ayarları',
                  subtitle: 'Ad, fotoğraf, biyografi',
                  leading: const Icon(Icons.person_outline, size: 20),
                  trailing: const Icon(Icons.chevron_right, size: 18,
                      color: AppColors.stone),
                  onTap: () {},
                ),
                const VestoDivider(),
                VestoListTile(
                  title: 'Bildirimler',
                  leading: const Icon(Icons.notifications_none, size: 20),
                  trailing: const VestoBadge(count: 5),
                  onTap: () {},
                ),
                const VestoDivider(),
                VestoListTile(
                  title: 'Çıkış Yap',
                  leading: const Icon(Icons.logout, size: 20,
                      color: AppColors.stone),
                  onTap: () {},
                ),
              ],
            ),
          ),
          SizedBox(height: spacing.xl),

          _section('SNACK BARS'),
          SizedBox(height: spacing.md),
          VestoButton(
            label: 'Info Snackbar',
            variant: VestoButtonVariant.secondary,
            onPressed: () => VestoSnackBar.show(context,
                message: 'Değişiklikler kaydedildi.'),
          ),
          SizedBox(height: spacing.sm),
          VestoButton(
            label: 'Success Snackbar',
            variant: VestoButtonVariant.secondary,
            onPressed: () => VestoSnackBar.show(
              context,
              message: 'Kombin başarıyla oluşturuldu.',
              type: VestoSnackBarType.success,
            ),
          ),
          SizedBox(height: spacing.sm),
          VestoButton(
            label: 'Error Snackbar',
            variant: VestoButtonVariant.secondary,
            onPressed: () => VestoSnackBar.show(
              context,
              message: 'Bir hata oluştu. Tekrar dene.',
              type: VestoSnackBarType.error,
              actionLabel: 'Yenile',
            ),
          ),
          SizedBox(height: spacing.xl),

          _section('EMPTY STATE'),
          SizedBox(height: spacing.md),
          VestoEmptyState(
            icon: Icons.checkroom_outlined,
            title: 'Dolabın boş',
            description:
                'İlk kıyafetini ekleyerek dijital dolabını oluşturmaya başla.',
            actionLabel: 'Kıyafet Ekle',
            onAction: () {},
          ),
          SizedBox(height: spacing.xxl),
        ],
      ),
    );
  }

  Widget _section(String label) {
    return Text(
      label,
      style: AppTypography.labelMedium.copyWith(color: AppColors.stone),
    );
  }
}
