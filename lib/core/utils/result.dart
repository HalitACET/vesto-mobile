/// Dart 3 sealed class tabanlı Result tipi — dartz bağımlılığı olmadan Either pattern.
/// Repository katmanı her zaman Result<S, F> döner, exception fırlatmaz.
///
/// Kullanım:
///   final result = await repo.login(email, password);
///   result.when(ok: (user) => ..., err: (f) => ...);
sealed class Result<S, F> {
  const Result();

  T when<T>({
    required T Function(S value) ok,
    required T Function(F error) err,
  }) {
    return switch (this) {
      Ok<S, F>(:final value) => ok(value),
      Err<S, F>(:final error) => err(error),
    };
  }

  bool get isOk => this is Ok<S, F>;
  bool get isErr => this is Err<S, F>;

  S? get valueOrNull => isOk ? (this as Ok<S, F>).value : null;
  F? get errorOrNull => isErr ? (this as Err<S, F>).error : null;
}

final class Ok<S, F> extends Result<S, F> {
  const Ok(this.value);
  final S value;
}

final class Err<S, F> extends Result<S, F> {
  const Err(this.error);
  final F error;
}
