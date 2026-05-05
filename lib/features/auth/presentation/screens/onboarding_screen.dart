import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/app/router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/constants/app_strings.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/features/auth/presentation/providers/onboarding_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final _controller = PageController();
  int _currentPage = 0;

  static const _slides = [
    _OnboardingSlide(
      icon: Icons.checkroom_outlined,
      title: AppStrings.onboarding1Title,
      body: AppStrings.onboarding1Body,
    ),
    _OnboardingSlide(
      icon: Icons.auto_awesome_outlined,
      title: AppStrings.onboarding2Title,
      body: AppStrings.onboarding2Body,
    ),
    _OnboardingSlide(
      icon: Icons.people_outline,
      title: AppStrings.onboarding3Title,
      body: AppStrings.onboarding3Body,
    ),
  ];

  Future<void> _finish() async {
    await markOnboardingSeen(ref);
    if (mounted) context.go(AppRoutes.login);
  }

  void _next() {
    if (_currentPage < _slides.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finish();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    final isLast = _currentPage == _slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Column(
          children: [
            // Skip butonu
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: EdgeInsets.only(top: spacing.md, right: spacing.pagePadding),
                child: GestureDetector(
                  onTap: _finish,
                  child: Text(
                    AppStrings.onboardingSkip,
                    style: AppTypography.labelMedium.copyWith(
                      color: AppColors.stone,
                    ),
                  ),
                ),
              ),
            ),

            // Slides
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _slides.length,
                onPageChanged: (i) => setState(() => _currentPage = i),
                itemBuilder: (_, i) => _SlideContent(slide: _slides[i]),
              ),
            ),

            // Dot indicator
            _DotIndicator(count: _slides.length, current: _currentPage),
            SizedBox(height: spacing.xl),

            // CTA butonu
            Padding(
              padding: EdgeInsets.symmetric(horizontal: spacing.pagePadding),
              child: VestoButton(
                label: isLast
                    ? AppStrings.onboardingGetStarted
                    : 'DEVAM',
                onPressed: _next,
              ),
            ),
            SizedBox(height: spacing.xxl),
          ],
        ),
      ),
    );
  }
}

// ── Alt Bileşenler ────────────────────────────────────────────────────────────

class _OnboardingSlide {
  const _OnboardingSlide({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;
}

class _SlideContent extends StatelessWidget {
  const _SlideContent({required this.slide});

  final _OnboardingSlide slide;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: spacing.pagePadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Görsel — ileride gerçek asset ile değiştirilebilir
          Container(
            width: double.infinity,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.pearl,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              slide.icon,
              size: 64,
              color: AppColors.graphite,
            ),
          ),
          SizedBox(height: spacing.xxl),
          Text(slide.title, style: AppTypography.headlineLarge),
          SizedBox(height: spacing.md),
          Text(
            slide.body,
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.stone,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotIndicator extends StatelessWidget {
  const _DotIndicator({required this.count, required this.current});

  final int count;
  final int current;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final isActive = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          width: isActive ? 24 : 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 3),
          decoration: BoxDecoration(
            color: isActive ? AppColors.onyx : AppColors.mist,
            borderRadius: BorderRadius.circular(4),
          ),
        );
      }),
    );
  }
}
