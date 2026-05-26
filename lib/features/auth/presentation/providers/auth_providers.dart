import 'package:firebase_auth/firebase_auth.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart';

part 'auth_providers.g.dart';

/// Firebase raw auth stream — router redirect için kullanılır.
@riverpod
Stream<User?> authStateChanges(Ref ref) {
  return ref.watch(firebaseAuthProvider).authStateChanges();
}

/// Firestore'dan AppUser stream — UI ve iş mantığı için kullanılır.
@riverpod
Stream<AppUser?> currentUser(Ref ref) {
  final authState = ref.watch(authStateChangesProvider);
  // Loading durumunda: henüz event gelmediyse boş bir stream değil,
  // null user emit edip bekliyoruz — böylece UI loading state'inde kalır.
  return authState.when(
    loading: () => const Stream.empty(),
    error: (error, stackTrace) => Stream.value(null),
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(authRepositoryProvider).watchUser(user.uid);
    },
  );
}

/// Genel auth aksiyonları (signOut). Login/Signup ayrı notifier'larda.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
