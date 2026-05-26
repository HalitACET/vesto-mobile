import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

part 'forum_comment.freezed.dart';

@freezed
abstract class OutfitSuggestion with _$OutfitSuggestion {
  const factory OutfitSuggestion({
    String? topId,
    String? bottomId,
    String? shoesId,
    String? accessoryId,
    String? note,
  }) = _OutfitSuggestion;

  factory OutfitSuggestion.fromMap(Map<String, dynamic> map) => OutfitSuggestion(
        topId: map['topId'] as String?,
        bottomId: map['bottomId'] as String?,
        shoesId: map['shoesId'] as String?,
        accessoryId: map['accessoryId'] as String?,
        note: map['note'] as String?,
      );
}

@freezed
abstract class ForumComment with _$ForumComment {
  const ForumComment._(); // Required for custom methods/getters

  const factory ForumComment({
    required String id,
    required String postId,
    required String authorId,
    required String authorDisplayName,
    String? authorPhotoUrl,
    required String text,
    required DateTime createdAt,
    @Default(false) bool isArchived,
    String? commentType,
    OutfitSuggestion? outfitSuggestion,
    String? parentId,
    String? replyToDisplayName,
    @Default(0) int likeCount,
  }) = _ForumComment;

  factory ForumComment.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final sugMap = data['outfitSuggestion'] as Map<String, dynamic>?;

    return ForumComment(
      id: doc.id,
      postId: data['postId'] as String? ?? '',
      authorId: data['authorId'] as String? ?? '',
      authorDisplayName: data['authorDisplayName'] as String? ?? 'Kullanıcı',
      authorPhotoUrl: data['authorPhotoUrl'] as String?,
      text: data['text'] as String? ?? '',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      isArchived: data['isArchived'] as bool? ?? false,
      commentType: data['commentType'] as String?,
      outfitSuggestion: sugMap != null ? OutfitSuggestion.fromMap(sugMap) : null,
      parentId: data['parentId'] as String?,
      replyToDisplayName: data['replyToDisplayName'] as String?,
      likeCount: data['likeCount'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'postId': postId,
        'authorId': authorId,
        'authorDisplayName': authorDisplayName,
        'authorPhotoUrl': authorPhotoUrl,
        'text': text,
        'createdAt': FieldValue.serverTimestamp(),
        'isArchived': isArchived,
        if (commentType != null) 'commentType': commentType,
        if (outfitSuggestion != null)
          'outfitSuggestion': {
            'topId': outfitSuggestion!.topId,
            'bottomId': outfitSuggestion!.bottomId,
            'shoesId': outfitSuggestion!.shoesId,
            'accessoryId': outfitSuggestion!.accessoryId,
            'note': outfitSuggestion!.note,
          },
        if (parentId != null) 'parentId': parentId,
        if (replyToDisplayName != null) 'replyToDisplayName': replyToDisplayName,
        'likeCount': likeCount,
      };
}
