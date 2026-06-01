import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';
import 'package:mobile/features/stylist/data/models/outfit_recommendation.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:uuid/uuid.dart';

class StylistRepository {
  final FirebaseFirestore _firestore;

  StylistRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  // ── Stilist Mode Toggle ────────────────────────────────────────────────────

  Future<void> setStylistMode(bool isActive) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;
    await _firestore.collection('users').doc(uid).update({
      'isStylistModeActive': isActive,
    });
  }

  // ── Active Stylists ────────────────────────────────────────────────────────

  /// Takip edilen aktif stilistleri getirir
  Future<List<AppUser>> getFollowedStylists(String currentUserId) async {
    // Takip edilen kullanıcıları çek
    final followSnap = await _firestore
        .collection('userFollows')
        .where('followerId', isEqualTo: currentUserId)
        .get();

    final followingIds = followSnap.docs
        .map((d) => d.data()['followingId'] as String)
        .toList();

    if (followingIds.isEmpty) return [];

    // Aktif stilistleri filtrele
    final stylists = <AppUser>[];
    // Firestore 'in' max 30 eleman, chunk'la
    final chunks = <List<String>>[];
    for (var i = 0; i < followingIds.length; i += 30) {
      chunks.add(followingIds.sublist(
          i, i + 30 > followingIds.length ? followingIds.length : i + 30));
    }

    for (final chunk in chunks) {
      final snap = await _firestore
          .collection('users')
          .where(FieldPath.documentId, whereIn: chunk)
          .where('isStylistModeActive', isEqualTo: true)
          .get();
      stylists.addAll(snap.docs
          .map((d) => AppUser.fromFirestore(d.data(), d.id)));
    }
    return stylists;
  }

  /// Öne çıkan stilistleri getirir (takip edilmeyenler dahil, en çok takipçili)
  Future<List<AppUser>> getFeaturedStylists({int limit = 20}) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;

    final snap = await _firestore
        .collection('users')
        .where('isStylistModeActive', isEqualTo: true)
        .orderBy('followerCount', descending: true)
        .limit(limit)
        .get();

    return snap.docs
        .map((d) => AppUser.fromFirestore(d.data(), d.id))
        .where((u) => u.uid != uid) // kendimizi dışla
        .toList();
  }

  // ── Public Wardrobe for Stylist Editor ────────────────────────────────────

  /// Hedef kullanıcının herkese açık dolabını çeker
  Stream<List<WardrobeItem>> watchPublicWardrobe(String userId) {
    return _firestore
        .collection('wardrobeItems')
        .where('userId', isEqualTo: userId)
        .where('isPublic', isEqualTo: true)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => WardrobeItem.fromFirestore(d as DocumentSnapshot<Map<String, dynamic>>))
            .toList());
  }

  // ── Sending Recommendations ────────────────────────────────────────────────

  Future<void> sendRecommendation(OutfitRecommendation recommendation) async {
    await _firestore
        .collection('outfitRecommendations')
        .add(recommendation.toFirestore());
  }

  // ── Inbox: Incoming Recommendations ──────────────────────────────────────

  Stream<List<OutfitRecommendation>> watchIncomingRecommendations(
      String userId) {
    return _firestore
        .collection('outfitRecommendations')
        .where('targetUserId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OutfitRecommendation.fromFirestore(d)).toList());
  }

  Stream<int> watchPendingCount(String userId) {
    return _firestore
        .collection('outfitRecommendations')
        .where('targetUserId', isEqualTo: userId)
        .where('status', isEqualTo: 'pending')
        .snapshots()
        .map((s) => s.docs.length);
  }

  /// Geçmiş: stilistin gönderdiği öneriler
  Stream<List<OutfitRecommendation>> watchSentRecommendations(
      String stylistId) {
    return _firestore
        .collection('outfitRecommendations')
        .where('stylistId', isEqualTo: stylistId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) =>
            snap.docs.map((d) => OutfitRecommendation.fromFirestore(d)).toList());
  }

  // ── Kabul / Red Akışı ──────────────────────────────────────────────────────

  // Öneri kabul et
  Future<void> acceptRecommendation(OutfitRecommendation rec) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    // 1. Öneriyi outfit olarak kaydet
    final outfitId = const Uuid().v4();
    await _firestore.collection('outfits').doc(outfitId).set({
      'id': outfitId,
      'userId': uid,
      'name': '${rec.stylistDisplayName} önerdi',
      'items': {
        'topId': rec.items.topId,
        'bottomId': rec.items.bottomId,
        'shoesId': rec.items.shoesId,
        'accessoryId': rec.items.accessoryId,
      },
      'tags': ['öneri'],
      'createdAt': FieldValue.serverTimestamp(),
      'lastWorn': null,
      'wearCount': 0,
      'isFavorite': false,
      'isArchived': false,
      'createdBy': 'stylist',  // Bu outfit stilist tarafından oluşturuldu
    });

    // 2. Recommendation status güncelle
    await _firestore
        .collection('outfitRecommendations')
        .doc(rec.id)
        .update({
          'status': 'accepted',
          'respondedAt': FieldValue.serverTimestamp(),
          'acceptedOutfitId': outfitId,
        });
  }

  // Öneri reddet
  Future<void> rejectRecommendation(String recId) async {
    await _firestore
        .collection('outfitRecommendations')
        .doc(recId)
        .update({
          'status': 'rejected',
          'respondedAt': FieldValue.serverTimestamp(),
        });
  }

  // Tüm öneriler (status'a göre)
  Stream<List<OutfitRecommendation>> watchRecommendationsByStatus(
    String status,
  ) {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return const Stream.empty();

    return _firestore
        .collection('outfitRecommendations')
        .where('targetUserId', isEqualTo: uid)
        .where('status', isEqualTo: status)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs
            .map((d) => OutfitRecommendation.fromFirestore(d))
            .toList());
  }

  // Rating ver
  Future<void> rateRecommendation(String recId, int rating) async {
    await _firestore
        .collection('outfitRecommendations')
        .doc(recId)
        .update({'rating': rating});
  }
}

