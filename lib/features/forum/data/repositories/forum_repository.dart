import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/forum/data/models/forum_post.dart';
import 'package:mobile/features/forum/data/models/forum_comment.dart';

class ForumRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  ForumRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _auth = auth ?? FirebaseAuth.instance;

  String? get _currentUserId => _auth.currentUser?.uid;

  // ─── FEED ───────────────────────────────────────────────
  Stream<List<ForumPost>> watchFeed() {
    return _firestore
        .collection('forumPosts')
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ForumPost.fromFirestore(doc)).toList());
  }

  // ─── POST CRUD ──────────────────────────────────────────
  Future<void> createPost(ForumPost post) async {
    await _firestore.collection('forumPosts').doc(post.id).set(post.toFirestore());
  }

  Future<void> deletePost(String postId) async {
    await _firestore.collection('forumPosts').doc(postId).update({'isArchived': true});
  }

  // ─── LIKES ──────────────────────────────────────────────
  Future<bool> isLiked(String postId) async {
    final uid = _currentUserId;
    if (uid == null) return false;
    final doc = await _firestore
        .collection('forumLikes')
        .doc('${postId}_$uid')
        .get();
    return doc.exists;
  }

  Future<void> toggleLike(String postId) async {
    final uid = _currentUserId;
    if (uid == null) return;

    final likeRef = _firestore.collection('forumLikes').doc('${postId}_$uid');
    final postRef = _firestore.collection('forumPosts').doc(postId);

    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      // Unlike
      await likeRef.delete();
      await postRef.update({'likeCount': FieldValue.increment(-1)});
    } else {
      // Like
      await likeRef.set({
        'postId': postId,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await postRef.update({'likeCount': FieldValue.increment(1)});
    }
  }

  // ─── COMMENTS ───────────────────────────────────────────
  Stream<List<ForumComment>> watchComments(String postId) {
    return _firestore
        .collection('forumComments')
        .where('postId', isEqualTo: postId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => ForumComment.fromFirestore(doc)).toList());
  }

  Future<void> addComment({
    required String postId,
    required String text,
    String? commentType,
    Map<String, dynamic>? outfitSuggestion,
    String? parentId,
    String? replyToDisplayName,
  }) async {
    final uid = _currentUserId;
    if (uid == null) return;

    final commentRef = _firestore.collection('forumComments').doc();

    final vestoUser = await _firestore.collection('users').doc(uid).get();
    final displayName = vestoUser.data()?['displayName'] as String? ?? 'Kullanıcı';
    final photoUrl = vestoUser.data()?['photoURL'] as String?; // Note capitalization: photoURL

    await commentRef.set({
      'postId': postId,
      'authorId': uid,
      'authorDisplayName': displayName,
      'authorPhotoUrl': photoUrl,
      'text': text,
      'createdAt': FieldValue.serverTimestamp(),
      'isArchived': false,
      'likeCount': 0,
      if (commentType != null) 'commentType': commentType,
      if (outfitSuggestion != null) 'outfitSuggestion': outfitSuggestion,
      if (parentId != null) 'parentId': parentId,
      if (replyToDisplayName != null) 'replyToDisplayName': replyToDisplayName,
    });

    await _firestore.collection('forumPosts').doc(postId).update({
      'commentCount': FieldValue.increment(1),
    });
  }

  Future<bool> isCommentLiked(String commentId) async {
    final uid = _currentUserId;
    if (uid == null) return false;
    final doc = await _firestore
        .collection('commentLikes')
        .doc('${commentId}_$uid')
        .get();
    return doc.exists;
  }

  Future<void> toggleCommentLike(String commentId) async {
    final uid = _currentUserId;
    if (uid == null) return;

    final likeRef = _firestore.collection('commentLikes').doc('${commentId}_$uid');
    final commentRef = _firestore.collection('forumComments').doc(commentId);

    final likeDoc = await likeRef.get();

    if (likeDoc.exists) {
      // Unlike
      await likeRef.delete();
      await commentRef.update({'likeCount': FieldValue.increment(-1)});
    } else {
      // Like
      await likeRef.set({
        'commentId': commentId,
        'userId': uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await commentRef.update({'likeCount': FieldValue.increment(1)});
    }
  }

  Future<void> deleteComment(String commentId, String postId) async {
    await _firestore.collection('forumComments').doc(commentId).update({
      'isArchived': true,
    });
    await _firestore.collection('forumPosts').doc(postId).update({
      'commentCount': FieldValue.increment(-1),
    });
  }
}
