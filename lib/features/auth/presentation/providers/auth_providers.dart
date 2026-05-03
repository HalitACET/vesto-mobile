import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
  final uid = authState.valueOrNull?.uid;
  if (uid == null) return const Stream.empty();
  return ref.watch(authRepositoryProvider).userStream(uid);
}

/// Anonim giriş aksiyonu — UI'dan tetiklenir.
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signInAnonymously() async {
    state = const AsyncLoading();
    final (_, failure) = await ref.read(authRepositoryProvider).signInAnonymously();
    state = failure != null ? AsyncError(failure, StackTrace.current) : const AsyncData(null);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    await ref.read(authRepositoryProvider).signOut();
    state = const AsyncData(null);
  }
}
