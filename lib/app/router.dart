import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/features/_dev/presentation/screens/component_showcase_screen.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/auth/presentation/providers/onboarding_provider.dart';
import 'package:mobile/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:mobile/features/auth/presentation/screens/login_screen.dart';
import 'package:mobile/features/auth/presentation/screens/onboarding_screen.dart';
import 'package:mobile/features/auth/presentation/screens/profile_setup_screen.dart';
import 'package:mobile/features/auth/presentation/screens/signup_screen.dart';
import 'package:mobile/features/auth/presentation/screens/splash_screen.dart';
import 'package:mobile/app/main_shell.dart';
import 'package:mobile/features/profile/presentation/screens/profile_screen.dart';
import 'package:mobile/features/wardrobe/presentation/screens/add_item/add_item_screen.dart' as mobile_add_item;
import 'package:mobile/features/wardrobe/presentation/screens/item_detail_screen.dart';
import 'package:mobile/features/wardrobe/presentation/screens/wardrobe_screen.dart';

part 'router.g.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const profileSetup = '/profile-setup';
  static const wardrobe = '/wardrobe';
  static const profile = '/profile';
  static const devShowcase = '/dev/showcase';
  static const wardrobeAdd = '/wardrobe/add';
  static const wardrobeItemDetail = '/wardrobe/item/:itemId';
}

const _authRoutes = {
  AppRoutes.login,
  AppRoutes.signup,
  AppRoutes.forgotPassword,
  AppRoutes.onboarding,
};

@riverpod
GoRouter appRouter(Ref ref) {
  // Router bir kez oluşturulur — ref.watch YOK.
  // Redirect, refreshListenable tetiklenince yeniden çalışır.
  // ref.read ile anlık değerler okunur.
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: _AuthChangeNotifier(ref),
    redirect: (context, state) {
      final location = state.matchedLocation;

      if (kDebugMode && location.startsWith('/dev/')) return null;

      final authState = ref.read(authStateChangesProvider);
      final onboardingState = ref.read(hasSeenOnboardingProvider);

      final authLoading = authState.isLoading || onboardingState.isLoading;
      if (authLoading) return location == AppRoutes.splash ? null : AppRoutes.splash;

      final hasSeen = onboardingState.valueOrNull ?? false;
      final isAuthenticated = authState.valueOrNull != null;

      if (!hasSeen && location != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      if (!isAuthenticated) {
        if (_authRoutes.contains(location)) return null;
        return AppRoutes.login;
      }

      if (_authRoutes.contains(location) || location == AppRoutes.splash) {
        final user = ref.read(currentUserProvider).valueOrNull;
        final profileComplete = user?.isProfileComplete ?? true;
        return profileComplete ? AppRoutes.wardrobe : AppRoutes.profileSetup;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signup,
        builder: (context, state) => const SignupScreen(),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        builder: (context, state) => const ProfileSetupScreen(),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.wardrobe,
            builder: (context, state) => const WardrobeScreen(),
          ),
          GoRoute(
            path: AppRoutes.profile,
            builder: (context, state) => const ProfileScreen(),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.wardrobeAdd,
        builder: (context, state) => const mobile_add_item.AddItemScreen(),
      ),
      GoRoute(
        path: AppRoutes.wardrobeItemDetail,
        builder: (context, state) => ItemDetailScreen(
          itemId: state.pathParameters['itemId']!,
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.devShowcase,
          builder: (context, state) => const ComponentShowcaseScreen(),
        ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Sayfa bulunamadı: ${state.error}'),
      ),
    ),
  );
}

/// GoRouter'ı Riverpod auth + onboarding state değişikliklerine karşı reaktif yapan köprü.
class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateChangesProvider, (_, __) => notifyListeners());
    ref.listen(hasSeenOnboardingProvider, (_, __) => notifyListeners());
    ref.listen(currentUserProvider, (_, __) => notifyListeners());
  }
}
