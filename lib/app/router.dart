import 'package:flutter/foundation.dart' show kDebugMode;
import 'package:flutter/material.dart';
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
import 'package:mobile/features/profile/presentation/screens/edit_profile_screen.dart';
import 'package:mobile/features/profile/presentation/screens/profile_settings_screen.dart';
import 'package:mobile/features/profile/presentation/screens/public_profile_screen.dart';
import 'package:mobile/features/profile/presentation/screens/follow_list_screen.dart';
import 'package:mobile/features/wardrobe/presentation/screens/add_item/add_item_screen.dart' as mobile_add_item;
import 'package:mobile/features/wardrobe/presentation/screens/item_detail_screen.dart';
import 'package:mobile/features/wardrobe/presentation/screens/wardrobe_screen.dart';
import 'package:mobile/features/outfits/presentation/screens/outfits_screen.dart';
import 'package:mobile/features/today/presentation/screens/today_screen.dart';
import 'package:mobile/features/forum/presentation/screens/forum_feed_screen.dart';
import 'package:mobile/features/forum/presentation/screens/forum_post_detail_screen.dart';
import 'package:mobile/features/forum/presentation/screens/forum_share_screen.dart';
import 'package:mobile/features/forum/presentation/screens/forum_create_post_screen.dart';
import 'package:mobile/features/stylist/presentation/screens/stylist_browse_screen.dart';
import 'package:mobile/features/stylist/presentation/screens/stylist_outfit_editor_screen.dart';
import 'package:mobile/features/stylist/presentation/screens/recommendations_inbox_screen.dart';
import 'package:mobile/features/stylist/presentation/screens/notifications_screen.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';

part 'router.g.dart';

abstract class AppRoutes {
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const profileSetup = '/profile-setup';
  static const wardrobe = '/wardrobe';
  static const outfits = '/outfits';
  static const profile = '/profile';
  static const profileEdit = '/profile/edit';
  static const profileSettings = '/profile/settings';
  static const publicProfile = '/u/:userId';
  static const publicProfileFollowers = '/u/:userId/followers';
  static const publicProfileFollowing = '/u/:userId/following';
  static const today = '/today';
  static const devShowcase = '/dev/showcase';
  static const wardrobeAdd = '/wardrobe/add';
  static const wardrobeItemDetail = '/wardrobe/item/:itemId';
  static const forum = '/forum';
  static const forumPostDetail = '/forum/post/:postId';
  static const forumShare = '/forum/share/:outfitId';
  static const forumCreatePost = '/forum/new';
  static const stylistBrowse = '/stylist/browse';
  static const stylistRecommend = '/stylist/recommend/:targetUserId';
  static const stylistInbox = '/stylist/inbox';
  static const notifications = '/notifications';
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

      final hasSeen = onboardingState.value ?? false;
      final isAuthenticated = authState.value != null;

      if (!hasSeen && location != AppRoutes.onboarding) {
        return AppRoutes.onboarding;
      }

      if (!isAuthenticated) {
        if (_authRoutes.contains(location)) return null;
        return AppRoutes.login;
      }

      if (_authRoutes.contains(location) || location == AppRoutes.splash) {
        final user = ref.read(currentUserProvider).value;
        final profileComplete = user?.isProfileComplete ?? true;
        return profileComplete ? AppRoutes.today : AppRoutes.profileSetup;
      }

      return null;
    },
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.signup,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const SignupScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.forgotPassword,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profileSetup,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ProfileSetupScreen(),
        ),
      ),
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.today,
            pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const TodayScreen(),
        ),
          ),
          GoRoute(
            path: AppRoutes.wardrobe,
            pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const WardrobeScreen(),
        ),
          ),
          GoRoute(
            path: AppRoutes.outfits,
            pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const OutfitsScreen(),
        ),
          ),
          GoRoute(
            path: AppRoutes.forum,
            pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ForumFeedScreen(),
        ),
          ),
          GoRoute(
            path: AppRoutes.profile,
            pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ProfileScreen(),
        ),
          ),
          GoRoute(
            path: AppRoutes.profileEdit,
            pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const EditProfileScreen(),
        ),
          ),
          GoRoute(
            path: AppRoutes.profileSettings,
            pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ProfileSettingsScreen(),
        ),
          ),
        ],
      ),
      GoRoute(
        path: AppRoutes.wardrobeAdd,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const mobile_add_item.AddItemScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.publicProfile,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: PublicProfileScreen(
          userId: state.pathParameters['userId']!,
        ),
        ),
      ),
      GoRoute(
        path: AppRoutes.publicProfileFollowers,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: FollowListScreen(
            userId: state.pathParameters['userId']!,
            showFollowers: true,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.publicProfileFollowing,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: FollowListScreen(
            userId: state.pathParameters['userId']!,
            showFollowers: false,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.wardrobeItemDetail,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: ItemDetailScreen(
          itemId: state.pathParameters['itemId']!,
        ),
        ),
      ),
      GoRoute(
        path: AppRoutes.forumPostDetail,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: ForumPostDetailScreen(
          postId: state.pathParameters['postId']!,
        ),
        ),
      ),
      GoRoute(
        path: AppRoutes.forumShare,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: ForumShareScreen(
          outfitId: state.pathParameters['outfitId']!,
        ),
        ),
      ),
      GoRoute(
        path: AppRoutes.forumCreatePost,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ForumCreatePostScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.stylistBrowse,
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const StylistBrowseScreen(),
        ),
      ),
      GoRoute(
        path: '/stylist/editor/:targetUserId',
        pageBuilder: (context, state) {
          final targetUser = state.extra as AppUser;
          return _slideTransition(context: context, state: state, child: StylistOutfitEditorScreen(targetUser: targetUser));
        },
      ),
      GoRoute(
        path: '/recommendations/inbox',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const RecommendationsInboxScreen(),
        ),
      ),
      GoRoute(
        path: '/notifications',
        pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const NotificationsScreen(),
        ),
      ),
      if (kDebugMode)
        GoRoute(
          path: AppRoutes.devShowcase,
          pageBuilder: (context, state) => _slideTransition(
          context: context,
          state: state,
          child: const ComponentShowcaseScreen(),
        ),
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
CustomTransitionPage<void> _slideTransition({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeInOutCubic;

      final tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

      return SlideTransition(
        position: animation.drive(tween),
        child: child,
      );
    },
    transitionDuration: const Duration(milliseconds: 280),
  );
}

class _AuthChangeNotifier extends ChangeNotifier {
  _AuthChangeNotifier(Ref ref) {
    ref.listen(authStateChangesProvider, (_, _) => notifyListeners());
    ref.listen(hasSeenOnboardingProvider, (_, _) => notifyListeners());
    ref.listen(currentUserProvider, (_, _) => notifyListeners());
  }
}
