import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:mobile/app/router.dart';
import 'package:mobile/app/theme/app_colors.dart';
import 'package:mobile/app/theme/app_typography.dart';
import 'package:mobile/app/theme/theme_extensions.dart';
import 'package:mobile/core/constants/app_strings.dart';
import 'package:mobile/core/utils/validators.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/core/widgets/atoms/vesto_text_field.dart';
import 'package:mobile/core/widgets/molecules/vesto_snack_bar.dart';
import 'package:mobile/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/auth/presentation/providers/profile_setup_notifier.dart';

class ProfileSetupScreen extends ConsumerStatefulWidget {
  const ProfileSetupScreen({super.key});

  @override
  ConsumerState<ProfileSetupScreen> createState() => _ProfileSetupScreenState();
}

class _ProfileSetupScreenState extends ConsumerState<ProfileSetupScreen> {
  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;

    ref.listen(profileSetupNotifierProvider, (_, next) {
      if (next.failure != null) {
        final msg = next.failure is AuthFailure
            ? (next.failure as AuthFailure).toUserMessage()
            : AppStrings.genericError;
        if (msg.isNotEmpty) {
          VestoSnackBar.show(context, message: msg, type: VestoSnackBarType.error);
        }
      }
      if (next.isCompleted) {
        context.go(AppRoutes.home);
      }
    });

    final state = ref.watch(profileSetupNotifierProvider);
    final notifier = ref.read(profileSetupNotifierProvider.notifier);
    final isFirstStep = state.currentStep == ProfileSetupStep.basicInfo;

    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: isFirstStep
            ? null
            : IconButton(
                icon: const Icon(Icons.arrow_back, color: AppColors.onyx, size: 20),
                onPressed: notifier.previousStep,
              ),
        actions: [
          if (!isFirstStep)
            TextButton(
              onPressed: notifier.nextStep,
              child: Text(
                AppStrings.profileSetupSkipStep,
                style: AppTypography.labelSmall.copyWith(color: AppColors.stone),
              ),
            ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            _StepProgressBar(step: state.currentStep),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: spacing.pagePadding),
                child: _stepContent(state, notifier),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _stepContent(ProfileSetupState state, ProfileSetupNotifier notifier) {
    return switch (state.currentStep) {
      ProfileSetupStep.basicInfo => _BasicInfoStep(
          initialName: state.displayName,
          initialGender: state.gender,
          initialBirthYear: state.birthYear,
          onNext: (name, gender, birthYear) {
            notifier.updateBasicInfo(
              displayName: name,
              gender: gender,
              birthYear: birthYear,
            );
            notifier.nextStep();
          },
        ),
      ProfileSetupStep.physical => _PhysicalStep(
          initialHeight: state.heightCm,
          initialWeight: state.weightKg,
          onNext: (h, w) {
            notifier.updatePhysical(heightCm: h, weightKg: w);
            notifier.nextStep();
          },
        ),
      ProfileSetupStep.location => _LocationStep(
          initialCity: state.city,
          onNext: (city) {
            if (city != null && city.isNotEmpty) {
              notifier.updateLocation(city: city);
            }
            notifier.nextStep();
          },
        ),
      ProfileSetupStep.stylePreferences => _StyleStep(
          aesthetics: state.aesthetics,
          occasions: state.occasions,
          isSubmitting: state.isSubmitting,
          onToggleAesthetic: notifier.toggleAesthetic,
          onToggleOccasion: notifier.toggleOccasion,
          onComplete: notifier.complete,
        ),
      _ => const SizedBox.shrink(),
    };
  }
}

// ── Step Progress Bar ─────────────────────────────────────────────────────────

class _StepProgressBar extends StatelessWidget {
  const _StepProgressBar({required this.step});

  final ProfileSetupStep step;

  int get _index => switch (step) {
        ProfileSetupStep.basicInfo => 0,
        ProfileSetupStep.physical => 1,
        ProfileSetupStep.location => 2,
        ProfileSetupStep.stylePreferences => 3,
        _ => 3,
      };

  @override
  Widget build(BuildContext context) {
    const total = 4;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      child: Row(
        children: List.generate(total, (i) {
          final filled = i <= _index;
          return Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              height: 2,
              margin: EdgeInsets.only(right: i < total - 1 ? 4 : 0),
              decoration: BoxDecoration(
                color: filled ? AppColors.onyx : AppColors.mist,
                borderRadius: BorderRadius.circular(1),
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ── Step 1 — Basic Info ───────────────────────────────────────────────────────

class _BasicInfoStep extends StatefulWidget {
  const _BasicInfoStep({
    this.initialName,
    this.initialGender,
    this.initialBirthYear,
    required this.onNext,
  });

  final String? initialName;
  final Gender? initialGender;
  final int? initialBirthYear;
  final void Function(String name, Gender? gender, int? birthYear) onNext;

  @override
  State<_BasicInfoStep> createState() => _BasicInfoStepState();
}

class _BasicInfoStepState extends State<_BasicInfoStep> {
  late final _nameController = TextEditingController(text: widget.initialName);
  Gender? _gender;
  late final _yearController = TextEditingController(
    text: widget.initialBirthYear?.toString(),
  );
  String? _nameError;
  String? _yearError;

  @override
  void initState() {
    super.initState();
    _gender = widget.initialGender;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  void _submit() {
    final nameErr = Validators.displayName(_nameController.text);
    int? year;
    String? yearErr;
    if (_yearController.text.isNotEmpty) {
      yearErr = Validators.year(_yearController.text);
      if (yearErr == null) year = int.tryParse(_yearController.text);
    }
    setState(() {
      _nameError = nameErr;
      _yearError = yearErr;
    });
    if (nameErr != null || yearErr != null) return;
    widget.onNext(_nameController.text.trim(), _gender, year);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing.lg),
        Text(AppStrings.profileSetupStep1Title, style: AppTypography.displayMedium),
        SizedBox(height: spacing.xl),
        VestoTextField(
          controller: _nameController,
          label: AppStrings.displayNameLabel,
          errorText: _nameError,
          textInputAction: TextInputAction.next,
          onChanged: (_) => setState(() => _nameError = null),
        ),
        SizedBox(height: spacing.md),
        _GenderSelector(
          selected: _gender,
          onChanged: (g) => setState(() => _gender = g),
        ),
        SizedBox(height: spacing.md),
        VestoTextField(
          controller: _yearController,
          label: AppStrings.birthYearLabel,
          hint: '1995',
          errorText: _yearError,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() => _yearError = null),
          onSubmitted: (_) => _submit(),
        ),
        SizedBox(height: spacing.xl),
        VestoButton(label: AppStrings.profileSetupContinue, onPressed: _submit),
        SizedBox(height: spacing.xxl),
      ],
    );
  }
}

// ── Step 2 — Physical ─────────────────────────────────────────────────────────

class _PhysicalStep extends StatefulWidget {
  const _PhysicalStep({
    this.initialHeight,
    this.initialWeight,
    required this.onNext,
  });

  final int? initialHeight;
  final int? initialWeight;
  final void Function(int? height, int? weight) onNext;

  @override
  State<_PhysicalStep> createState() => _PhysicalStepState();
}

class _PhysicalStepState extends State<_PhysicalStep> {
  late final _heightController = TextEditingController(
    text: widget.initialHeight?.toString(),
  );
  late final _weightController = TextEditingController(
    text: widget.initialWeight?.toString(),
  );
  String? _heightError;
  String? _weightError;

  @override
  void dispose() {
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  void _submit() {
    String? hErr;
    String? wErr;
    int? h;
    int? w;

    if (_heightController.text.isNotEmpty) {
      hErr = Validators.cm(_heightController.text);
      if (hErr == null) h = int.tryParse(_heightController.text);
    }
    if (_weightController.text.isNotEmpty) {
      wErr = Validators.kg(_weightController.text);
      if (wErr == null) w = int.tryParse(_weightController.text);
    }
    setState(() {
      _heightError = hErr;
      _weightError = wErr;
    });
    if (hErr != null || wErr != null) return;
    widget.onNext(h, w);
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing.lg),
        Text(AppStrings.profileSetupStep2Title, style: AppTypography.displayMedium),
        SizedBox(height: spacing.sm),
        Text(
          AppStrings.profileSetupStep2Subtitle,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
        ),
        SizedBox(height: spacing.xl),
        VestoTextField(
          controller: _heightController,
          label: AppStrings.heightLabel,
          hint: '170',
          errorText: _heightError,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.next,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() => _heightError = null),
        ),
        SizedBox(height: spacing.md),
        VestoTextField(
          controller: _weightController,
          label: AppStrings.weightLabel,
          hint: '65',
          errorText: _weightError,
          keyboardType: TextInputType.number,
          textInputAction: TextInputAction.done,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          onChanged: (_) => setState(() => _weightError = null),
          onSubmitted: (_) => _submit(),
        ),
        SizedBox(height: spacing.xl),
        VestoButton(label: AppStrings.profileSetupContinue, onPressed: _submit),
        SizedBox(height: spacing.xxl),
      ],
    );
  }
}

// ── Step 3 — Location ─────────────────────────────────────────────────────────

class _LocationStep extends StatefulWidget {
  const _LocationStep({this.initialCity, required this.onNext});

  final String? initialCity;
  final void Function(String? city) onNext;

  @override
  State<_LocationStep> createState() => _LocationStepState();
}

class _LocationStepState extends State<_LocationStep> {
  late final _cityController = TextEditingController(text: widget.initialCity);

  @override
  void dispose() {
    _cityController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing.lg),
        Text(AppStrings.profileSetupStep3Title, style: AppTypography.displayMedium),
        SizedBox(height: spacing.sm),
        Text(
          AppStrings.profileSetupStep3Subtitle,
          style: AppTypography.bodyMedium.copyWith(color: AppColors.stone),
        ),
        SizedBox(height: spacing.xl),
        VestoTextField(
          controller: _cityController,
          label: AppStrings.cityLabel,
          hint: 'İstanbul',
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onNext(_cityController.text.trim()),
        ),
        SizedBox(height: spacing.xl),
        VestoButton(
          label: AppStrings.profileSetupContinue,
          onPressed: () => widget.onNext(_cityController.text.trim()),
        ),
        SizedBox(height: spacing.xxl),
      ],
    );
  }
}

// ── Step 4 — Style Preferences ────────────────────────────────────────────────

class _StyleStep extends StatelessWidget {
  const _StyleStep({
    required this.aesthetics,
    required this.occasions,
    required this.isSubmitting,
    required this.onToggleAesthetic,
    required this.onToggleOccasion,
    required this.onComplete,
  });

  final List<Aesthetic> aesthetics;
  final List<Occasion> occasions;
  final bool isSubmitting;
  final void Function(Aesthetic) onToggleAesthetic;
  final void Function(Occasion) onToggleOccasion;
  final Future<void> Function() onComplete;

  @override
  Widget build(BuildContext context) {
    final spacing = context.spacing;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: spacing.lg),
        Text(AppStrings.profileSetupStep4Title, style: AppTypography.displayMedium),
        SizedBox(height: spacing.xl),
        Text(AppStrings.aestheticsLabel,
            style: AppTypography.labelMedium.copyWith(color: AppColors.stone)),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Aesthetic.values.map((a) {
            final selected = aesthetics.contains(a);
            return _Chip(
              label: a.displayLabel,
              selected: selected,
              onTap: () => onToggleAesthetic(a),
            );
          }).toList(),
        ),
        SizedBox(height: spacing.lg),
        Text(AppStrings.occasionsLabel,
            style: AppTypography.labelMedium.copyWith(color: AppColors.stone)),
        SizedBox(height: spacing.sm),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Occasion.values.map((o) {
            final selected = occasions.contains(o);
            return _Chip(
              label: o.displayLabel,
              selected: selected,
              onTap: () => onToggleOccasion(o),
            );
          }).toList(),
        ),
        SizedBox(height: spacing.xl),
        VestoButton(
          label: AppStrings.profileSetupComplete,
          onPressed: isSubmitting ? null : onComplete,
          isLoading: isSubmitting,
        ),
        SizedBox(height: spacing.xxl),
      ],
    );
  }
}

// ── Shared Widgets ────────────────────────────────────────────────────────────

class _GenderSelector extends StatelessWidget {
  const _GenderSelector({required this.selected, required this.onChanged});

  final Gender? selected;
  final void Function(Gender?) onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.genderLabel,
          style: AppTypography.labelSmall.copyWith(color: AppColors.stone),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: Gender.values.map((g) {
            final isSelected = selected == g;
            return _Chip(
              label: g.displayLabel,
              selected: isSelected,
              onTap: () => onChanged(isSelected ? null : g),
            );
          }).toList(),
        ),
      ],
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final radius = context.radius;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: selected ? AppColors.onyx : Colors.transparent,
          borderRadius: BorderRadius.circular(radius.full),
          border: Border.all(
            color: selected ? AppColors.onyx : AppColors.mist,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.labelSmall.copyWith(
            color: selected ? AppColors.white : AppColors.stone,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }
}
