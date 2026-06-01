import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/stylist/data/models/outfit_recommendation.dart';
import 'package:mobile/features/stylist/data/repositories/stylist_repository.dart';

part 'stylist_providers.g.dart';

@riverpod
StylistRepository stylistRepository(Ref ref) {
  return StylistRepository(firestore: ref.watch(firestoreProvider));
}

@riverpod
Future<List<AppUser>> followedStylists(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Future.value([]);
  return ref.read(stylistRepositoryProvider).getFollowedStylists(uid);
}

@riverpod
Future<List<AppUser>> featuredStylists(Ref ref) {
  return ref.read(stylistRepositoryProvider).getFeaturedStylists();
}

@riverpod
Stream<List<OutfitRecommendation>> incomingRecommendations(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref
      .read(stylistRepositoryProvider)
      .watchIncomingRecommendations(uid);
}

@riverpod
Stream<int> pendingRecommendationCount(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return Stream.value(0);
  return ref.read(stylistRepositoryProvider).watchPendingCount(uid);
}

@riverpod
Stream<List<OutfitRecommendation>> sentRecommendations(Ref ref) {
  final uid = ref.watch(authStateChangesProvider).value?.uid;
  if (uid == null) return const Stream.empty();
  return ref
      .read(stylistRepositoryProvider)
      .watchSentRecommendations(uid);
}

@riverpod
Stream<List<OutfitRecommendation>> recommendationsByStatus(
  Ref ref,
  String status,
) {
  return ref.read(stylistRepositoryProvider)
      .watchRecommendationsByStatus(status);
}

@Riverpod(keepAlive: true)
class RecommendationActionNotifier extends _$RecommendationActionNotifier {
  bool _mounted = true;

  @override
  AsyncValue<void> build() {
    ref.onDispose(() => _mounted = false);
    return const AsyncData(null);
  }

  Future<void> accept(OutfitRecommendation rec) async {
    state = const AsyncLoading();
    try {
      await ref.read(stylistRepositoryProvider).acceptRecommendation(rec);
      if (!_mounted) return;
      state = const AsyncData(null);
    } catch (e, st) {
      if (!_mounted) return;
      state = AsyncError(e, st);
    }
  }

  Future<void> reject(String recId) async {
    state = const AsyncLoading();
    try {
      await ref.read(stylistRepositoryProvider).rejectRecommendation(recId);
      if (!_mounted) return;
      state = const AsyncData(null);
    } catch (e, st) {
      if (!_mounted) return;
      state = AsyncError(e, st);
    }
  }
}
