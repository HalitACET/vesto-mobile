import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/features/auth/data/repositories/auth_repository.dart';

part 'forgot_password_notifier.g.dart';

@riverpod
class ForgotPasswordNotifier extends _$ForgotPasswordNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> sendResetEmail(String email) async {
    state = const AsyncLoading();
    final result =
        await ref.read(authRepositoryProvider).sendPasswordResetEmail(email);
    state = result.when(
      ok: (_) => const AsyncData(null),
      err: (f) => AsyncError(f, StackTrace.current),
    );
  }

  void reset() => state = const AsyncData(null);
}
