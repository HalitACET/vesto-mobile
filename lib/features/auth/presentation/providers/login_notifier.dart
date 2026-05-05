import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/features/auth/data/exceptions/auth_exceptions.dart';
import 'package:mobile/features/auth/data/repositories/auth_repository.dart';

part 'login_notifier.g.dart';

@riverpod
class LoginNotifier extends _$LoginNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> login(String email, String password) async {
    state = const AsyncLoading();
    final result = await ref
        .read(authRepositoryProvider)
        .signInWithEmailPassword(email, password);
    state = result.when(
      ok: (_) => const AsyncData(null),
      err: (f) => AsyncError(f, StackTrace.current),
    );
  }

  Future<void> signInWithGoogle() async {
    state = const AsyncLoading();
    final result = await ref.read(authRepositoryProvider).signInWithGoogle();
    state = result.when(
      ok: (_) => const AsyncData(null),
      err: (f) {
        // Kullanıcı popup'ı kapattıysa sessizce iptal et
        if (f is CancelledAuthFailure) return const AsyncData(null);
        return AsyncError(f, StackTrace.current);
      },
    );
  }

  void reset() => state = const AsyncData(null);
}
