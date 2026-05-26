import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/profile/data/repositories/user_repository.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/data/repositories/wardrobe_repository.dart';

part 'profile_providers.g.dart';

@riverpod
UserRepository userRepository(Ref ref) {
  return UserRepository(
    firestore: ref.watch(firestoreProvider),
  );
}

@riverpod
Future<AppUser?> userProfile(Ref ref, String userId) {
  return ref.read(userRepositoryProvider).getUserProfile(userId);
}

@riverpod
Stream<List<WardrobeItem>> publicWardrobe(Ref ref, String userId) {
  return ref.read(wardrobeRepositoryProvider).watchPublicItems(userId);
}

@riverpod
Stream<int> userPostCount(Ref ref, String userId) {
  return ref.watch(firestoreProvider)
      .collection('forumPosts')
      .where('authorId', isEqualTo: userId)
      .where('isArchived', isEqualTo: false)
      .snapshots()
      .map((snap) => snap.docs.length);
}

@riverpod
Future<bool> isFollowing(Ref ref, String targetUserId) {
  return ref.watch(userRepositoryProvider).isFollowing(targetUserId);
}
