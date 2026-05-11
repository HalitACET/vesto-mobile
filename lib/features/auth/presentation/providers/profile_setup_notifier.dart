import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';

part 'profile_setup_notifier.g.dart';

// ── State ─────────────────────────────────────────────────────────────────────

class ProfileSetupState extends Equatable {
  const ProfileSetupState({
    this.displayName,
    this.gender,
    this.birthYear,
    this.heightCm,
    this.weightKg,
    this.city,
    this.lat,
    this.lng,
    this.aesthetics = const [],
    this.occasions = const [],
    this.currentStep = ProfileSetupStep.basicInfo,
    this.isSubmitting = false,
    this.failure,
    this.isCompleted = false,
  });

  final String? displayName;
  final Gender? gender;
  final int? birthYear;
  final int? heightCm;
  final int? weightKg;
  final String? city;
  final double? lat;
  final double? lng;
  final List<Aesthetic> aesthetics;
  final List<Occasion> occasions;
  final ProfileSetupStep currentStep;
  final bool isSubmitting;
  final AuthFailure? failure;
  final bool isCompleted;

  ProfileSetupState copyWith({
    String? displayName,
    Gender? gender,
    int? birthYear,
    int? heightCm,
    int? weightKg,
    String? city,
    double? lat,
    double? lng,
    List<Aesthetic>? aesthetics,
    List<Occasion>? occasions,
    ProfileSetupStep? currentStep,
    bool? isSubmitting,
    AuthFailure? failure,
    bool? isCompleted,
    bool clearFailure = false,
  }) {
    return ProfileSetupState(
      displayName: displayName ?? this.displayName,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      city: city ?? this.city,
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      aesthetics: aesthetics ?? this.aesthetics,
      occasions: occasions ?? this.occasions,
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      failure: clearFailure ? null : (failure ?? this.failure),
      isCompleted: isCompleted ?? this.isCompleted,
    );
  }

  @override
  List<Object?> get props => [
        displayName,
        gender,
        birthYear,
        heightCm,
        weightKg,
        city,
        lat,
        lng,
        aesthetics,
        occasions,
        currentStep,
        isSubmitting,
        failure,
        isCompleted,
      ];
}

// ── Notifier ──────────────────────────────────────────────────────────────────

@riverpod
class ProfileSetupNotifier extends _$ProfileSetupNotifier {
  @override
  ProfileSetupState build() {
    // Yarım kalmış wizard'ı kaldığı adımdan devam ettir
    final user = ref.watch(currentUserProvider).value;
    return ProfileSetupState(
      displayName: user?.displayName,
      currentStep: _resumeStep(user?.lastCompletedStep),
    );
  }

  // ── Step Navigation ─────────────────────────────────────────────────────────

  void nextStep() {
    final next = switch (state.currentStep) {
      ProfileSetupStep.basicInfo => ProfileSetupStep.physical,
      ProfileSetupStep.physical => ProfileSetupStep.location,
      ProfileSetupStep.location => ProfileSetupStep.stylePreferences,
      _ => state.currentStep,
    };
    state = state.copyWith(currentStep: next, clearFailure: true);
  }

  void previousStep() {
    final prev = switch (state.currentStep) {
      ProfileSetupStep.physical => ProfileSetupStep.basicInfo,
      ProfileSetupStep.location => ProfileSetupStep.physical,
      ProfileSetupStep.stylePreferences => ProfileSetupStep.location,
      _ => state.currentStep,
    };
    state = state.copyWith(currentStep: prev, clearFailure: true);
  }

  // ── Data Updates (her step kendi metodunu çağırır) ──────────────────────────

  void updateBasicInfo({String? displayName, Gender? gender, int? birthYear}) {
    state = state.copyWith(
      displayName: displayName,
      gender: gender,
      birthYear: birthYear,
    );
  }

  void updatePhysical({int? heightCm, int? weightKg}) {
    state = state.copyWith(heightCm: heightCm, weightKg: weightKg);
  }

  void updateLocation({required String city, double? lat, double? lng}) {
    state = state.copyWith(city: city, lat: lat, lng: lng);
  }

  void toggleAesthetic(Aesthetic aesthetic) {
    final updated = List<Aesthetic>.from(state.aesthetics);
    if (updated.contains(aesthetic)) {
      updated.remove(aesthetic);
    } else {
      updated.add(aesthetic);
    }
    state = state.copyWith(aesthetics: updated);
  }

  void toggleOccasion(Occasion occasion) {
    final updated = List<Occasion>.from(state.occasions);
    if (updated.contains(occasion)) {
      updated.remove(occasion);
    } else {
      updated.add(occasion);
    }
    state = state.copyWith(occasions: updated);
  }

  // ── Final Submit — tüm veriyi toplu Firestore'a yazar ──────────────────────

  Future<void> complete() async {
    state = state.copyWith(isSubmitting: true, clearFailure: true);

    final currentUser = ref.read(currentUserProvider).value;
    if (currentUser == null) {
      state = state.copyWith(
        isSubmitting: false,
        failure: const UnknownAuthFailure('Oturum bulunamadı.'),
      );
      return;
    }

    final location = state.city != null && state.city!.isNotEmpty
        ? UserLocation(city: state.city!, lat: state.lat, lng: state.lng)
        : null;

    final updatedUser = currentUser.copyWith(
      displayName: state.displayName ?? currentUser.displayName,
      gender: state.gender,
      birthYear: state.birthYear,
      heightCm: state.heightCm,
      weightKg: state.weightKg,
      location: location,
      stylePreferences: StylePreferences(
        aesthetics: state.aesthetics,
        occasions: state.occasions,
      ),
      isProfileComplete: true,
      lastCompletedStep: ProfileSetupStep.completed,
    );

    final result =
        await ref.read(authRepositoryProvider).updateProfile(updatedUser);

    state = result.when(
      ok: (_) => state.copyWith(isSubmitting: false, isCompleted: true),
      err: (f) => state.copyWith(isSubmitting: false, failure: f),
    );
  }

  // ── Private ─────────────────────────────────────────────────────────────────

  /// Kaldığı adımdan bir sonrakine atla — completed ise basicInfo'dan başla (yeniden düzenleme).
  static ProfileSetupStep _resumeStep(ProfileSetupStep? lastCompleted) {
    return switch (lastCompleted) {
      null => ProfileSetupStep.basicInfo,
      ProfileSetupStep.basicInfo => ProfileSetupStep.physical,
      ProfileSetupStep.physical => ProfileSetupStep.location,
      ProfileSetupStep.location => ProfileSetupStep.stylePreferences,
      _ => ProfileSetupStep.basicInfo,
    };
  }
}
