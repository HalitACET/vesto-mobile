import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';

class UsernameAlreadyTakenException implements Exception {
  final String message;
  const UsernameAlreadyTakenException([this.message = 'Bu kullanıcı adı zaten alınmış']);
  @override
  String toString() => message;
}

class UserRepository {
  final FirebaseFirestore _firestore;

  UserRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  // Profil güncelle
  Future<void> updateProfile({
    required String uid,
    String? displayName,
    String? bio,
    String? photoUrl,
    String? username,
  }) async {
    final updates = <String, dynamic>{
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (displayName != null) updates['displayName'] = displayName;
    if (bio != null) updates['bio'] = bio;
    if (photoUrl != null) updates['photoURL'] = photoUrl; // Note: Database has photoURL, model maps from photoURL

    if (username != null && username.isNotEmpty) {
      // Username unique kontrolü
      final existing = await _firestore
          .collection('usernames')
          .doc(username)
          .get();

      if (existing.exists && existing.data()?['uid'] != uid) {
        throw const UsernameAlreadyTakenException();
      }

      // Eski username'i sil
      final user = await _firestore.collection('users').doc(uid).get();
      final oldUsername = user.data()?['username'] as String?;
      if (oldUsername != null && oldUsername != username) {
        await _firestore.collection('usernames').doc(oldUsername).delete();
      }

      // Yeni username'i kaydet
      await _firestore.collection('usernames').doc(username).set({'uid': uid});
      updates['username'] = username;
    }

    await _firestore.collection('users').doc(uid).update(updates);
  }

  // Public profil getir
  Future<AppUser?> getUserProfile(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists || doc.data() == null) return null;
    return AppUser.fromFirestore(doc.data()!, doc.id);
  }

  // Bulk wardrobe visibility
  Future<void> setWardrobePublic(String userId, bool isPublic) async {
    final batch = _firestore.batch();

    final items = await _firestore
        .collection('wardrobeItems')
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .get();

    for (final doc in items.docs) {
      batch.update(doc.reference, {'isPublic': isPublic});
    }

    await _firestore.collection('users').doc(userId).update({
      'wardrobePublic': isPublic,
    });

    await batch.commit();
  }

  // --- Takip Sistemi Metotları ---

  Future<bool> isFollowing(String targetUserId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    final doc = await _firestore
        .collection('userFollows')
        .doc('${uid}_$targetUserId')
        .get();
    return doc.exists;
  }

  Future<void> toggleFollow(String targetUserId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    final followRef = _firestore
        .collection('userFollows')
        .doc('${uid}_$targetUserId');
    final myRef = _firestore.collection('users').doc(uid);
    final targetRef = _firestore.collection('users').doc(targetUserId);

    final followDoc = await followRef.get();

    if (followDoc.exists) {
      // Unfollow
      await followRef.delete();
      await myRef.update({'followingCount': FieldValue.increment(-1)});
      await targetRef.update({'followerCount': FieldValue.increment(-1)});
    } else {
      // Follow
      await followRef.set({
        'followerId': uid,
        'followingId': targetUserId,
        'createdAt': FieldValue.serverTimestamp(),
      });
      await myRef.update({'followingCount': FieldValue.increment(1)});
      await targetRef.update({'followerCount': FieldValue.increment(1)});
    }
  }

  Stream<List<String>> watchFollowing(String userId) {
    return _firestore
        .collection('userFollows')
        .where('followerId', isEqualTo: userId)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => d.data()['followingId'] as String)
            .toList());
  }

  Future<List<AppUser>> getFollowers(String userId) async {
    final snap = await _firestore
        .collection('userFollows')
        .where('followingId', isEqualTo: userId)
        .get();

    final followerIds = snap.docs
        .map((d) => d.data()['followerId'] as String)
        .toList();

    if (followerIds.isEmpty) return [];

    final users = await Future.wait(
      followerIds.map((id) => getUserProfile(id)),
    );

    return users.whereType<AppUser>().toList();
  }

  Future<List<AppUser>> getFollowing(String userId) async {
    final snap = await _firestore
        .collection('userFollows')
        .where('followerId', isEqualTo: userId)
        .get();

    final followingIds = snap.docs
        .map((d) => d.data()['followingId'] as String)
        .toList();

    if (followingIds.isEmpty) return [];

    final users = await Future.wait(
      followingIds.map((id) => getUserProfile(id)),
    );

    return users.whereType<AppUser>().toList();
  }

  // Kullanıcı arama
  Future<List<AppUser>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];

    final queryLower = query.toLowerCase().trim();

    // displayName ile ara
    final nameSnap = await _firestore
        .collection('users')
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThan: '$query\uf8ff')
        .limit(10)
        .get();

    // username ile ara
    final usernameSnap = await _firestore
        .collection('users')
        .where('username', isGreaterThanOrEqualTo: queryLower)
        .where('username', isLessThan: '$queryLower\uf8ff')
        .limit(10)
        .get();

    // Birleştir, duplicate çıkar
    final allUsers = [
      ...nameSnap.docs.map((d) => AppUser.fromFirestore(d.data(), d.id)),
      ...usernameSnap.docs.map((d) => AppUser.fromFirestore(d.data(), d.id)),
    ];

    // Duplicate'leri temizle
    final seen = <String>{};
    return allUsers.where((u) => seen.add(u.uid)).toList();
  }

  // Keşfet — Stilistler
  Future<List<AppUser>> getTopStylists({int limit = 10}) async {
    final snap = await _firestore
        .collection('users')
        .where('isStylistModeActive', isEqualTo: true)
        .orderBy('followerCount', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => AppUser.fromFirestore(d.data(), d.id)).toList();
  }

  // Keşfet — Yeni Katılanlar
  Future<List<AppUser>> getNewUsers({int limit = 10}) async {
    final snap = await _firestore
        .collection('users')
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => AppUser.fromFirestore(d.data(), d.id)).toList();
  }

  // Keşfet — Öne Çıkanlar (en çok follower)
  Future<List<AppUser>> getFeaturedUsers({int limit = 10}) async {
    final snap = await _firestore
        .collection('users')
        .orderBy('followerCount', descending: true)
        .limit(limit)
        .get();
    return snap.docs.map((d) => AppUser.fromFirestore(d.data(), d.id)).toList();
  }
}
