import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/features/auth/data/repositories/auth_repository.dart';

part 'signup_notifier.g.dart';

@riverpod
class SignupNotifier extends _$SignupNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> signup({
    required String email,
    required String password,
    required String displayName,
  }) async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).signUpWithEmailPassword(
              email: email,
              password: password,
              displayName: displayName,
            );
    state = result.when(
      ok: (_) => const AsyncData(null),
      err: (f) => AsyncError(f, StackTrace.current),
    );
  }

  void reset() => state = const AsyncData(null);
}
