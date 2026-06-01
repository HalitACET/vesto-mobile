import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/forum/data/models/forum_post.dart';
import 'package:mobile/features/forum/data/models/forum_comment.dart';
import 'package:mobile/features/forum/data/repositories/forum_repository.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/profile/presentation/providers/profile_providers.dart';

part 'forum_providers.g.dart';

@riverpod
ForumRepository forumRepository(Ref ref) {
  return ForumRepository(
    firestore: ref.watch(firestoreProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
}

@riverpod
Stream<List<ForumPost>> forumFeed(Ref ref) {
  return ref.watch(forumRepositoryProvider).watchFeed();
}

@riverpod
Stream<List<ForumComment>> postComments(Ref ref, String postId) {
  return ref.watch(forumRepositoryProvider).watchComments(postId);
}

@riverpod
class ForumShareNotifier extends _$ForumShareNotifier {
  @override
  AsyncValue<void> build() => const AsyncData(null);

  Future<void> shareOutfit({
    String? outfitId,
    required String caption,
  }) async {
    state = const AsyncLoading();

    try {
      final user = ref.read(firebaseAuthProvider).currentUser!;
      final userDoc = await ref.read(firestoreProvider)
          .collection('users').doc(user.uid).get();

      final post = ForumPost(
        id: const Uuid().v4(),
        authorId: user.uid,
        authorDisplayName: userDoc.data()?['displayName'] ?? 'Kullanıcı',
        authorPhotoUrl: userDoc.data()?['photoURL'] as String?, // Uppercase URL in DB
        outfitId: outfitId,
        caption: caption,
        createdAt: DateTime.now(),
      );

      await ref.read(forumRepositoryProvider).createPost(post);
      state = const AsyncData(null);
    } catch (e, st) {
      state = AsyncError(e, st);
    }
  }
}

@riverpod
Future<List<AppUser>> userSearch(
  Ref ref,
  String query,
) async {
  if (query.length < 2) return [];
  return ref.read(userRepositoryProvider).searchUsers(query);
}

@riverpod
Future<List<AppUser>> topStylists(Ref ref) async {
  return ref.read(userRepositoryProvider).getTopStylists();
}

@riverpod
Future<List<AppUser>> featuredUsers(Ref ref) async {
  return ref.read(userRepositoryProvider).getFeaturedUsers();
}

@riverpod
Future<List<AppUser>> newUsers(Ref ref) async {
  return ref.read(userRepositoryProvider).getNewUsers();
}

@riverpod
Stream<ForumPost?> forumPostStream(Ref ref, String postId) {
  return ref.watch(firestoreProvider)
      .collection('forumPosts')
      .doc(postId)
      .snapshots()
      .map((doc) => doc.exists ? ForumPost.fromFirestore(doc) : null);
}
