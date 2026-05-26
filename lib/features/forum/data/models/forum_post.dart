import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'forum_post.freezed.dart';

@freezed
abstract class ForumPost with _$ForumPost {
  const ForumPost._(); // Required for custom methods/getters

  const factory ForumPost({
    required String id,
    required String authorId,
    required String authorDisplayName,
    String? authorPhotoUrl,
    String? outfitId,
    required String caption,
    @Default(0) int likeCount,
    @Default(0) int commentCount,
    required DateTime createdAt,
    @Default(false) bool isModerated,
    @Default(false) bool isArchived,

    // Client-side computed (Firestore'dan gelmiyor)
    @Default(false) bool isLikedByMe,
  }) = _ForumPost;

  factory ForumPost.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ForumPost(
      id: doc.id,
      authorId: data['authorId'] as String? ?? '',
      authorDisplayName: data['authorDisplayName'] as String? ?? 'Kullanıcı',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      outfitId: data['outfitId'] as String? ?? '',
      caption: data['caption'] as String? ?? '',
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isModerated: data['isModerated'] as bool? ?? false,
      isArchived: data['isArchived'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toFirestore() => {
    'authorId': authorId,
    'authorDisplayName': authorDisplayName,
    'authorPhotoUrl': ?authorPhotoUrl,
    'outfitId': ?outfitId,
    'caption': caption,
    'likeCount': likeCount,
    'commentCount': commentCount,
    'createdAt': FieldValue.serverTimestamp(),
    'isModerated': isModerated,
    'isArchived': isArchived,
  };
}
