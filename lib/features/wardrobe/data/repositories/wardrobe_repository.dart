import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';

part 'wardrobe_repository.g.dart';

/// Wardrobe repository — UI katmanı Firestore/Storage'a direkt erişmez.
/// Tüm okuma/yazma işlemleri bu sınıf üzerinden geçer.
class WardrobeRepository {
  WardrobeRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required FirebaseAuth auth,
  })  : _firestore = firestore,
        _storage = storage,
        _auth = auth;

  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;
  final FirebaseAuth _auth;

  static const _collection = 'wardrobeItems';

  // ── Kimlik doğrulama yardımcısı ───────────────────────────────────────────

  String? get _currentUserId => _auth.currentUser?.uid;

  // ── Yeni item document oluştur (status: uploading) ────────────────────────

  /// Önce Firestore'a document yaz (imageUrl null, status: uploading).
  /// Upload Race condition yönetimi için kritik sıralama:
  /// 1. Firestore doc oluştur
  /// 2. Storage'a yükle
  /// 3. Firestore doc güncelle (imageUrl + status: ready)
  Future<(WardrobeItem?, Failure?)> createItem(WardrobeItem item) async {
    try {
      final docRef = _firestore.collection(_collection).doc(item.id);
      await docRef.set(item.toFirestore());

      // Dönen item'ın createdAt/updatedAt'i server timestamp olmadığından
      // client-side DateTime.now() kullanan orijinal item'ı döndürürüz.
      return (item, null);
    } on FirebaseException catch (e) {
      return (
        null,
        FirestoreWriteFailure('Kayıt oluşturulamadı: ${e.message}')
      );
    } catch (_) {
      return (null, const FirestoreWriteFailure());
    }
  }

  // ── Firestore doc güncelle (upload tamamlandı) ────────────────────────────

  Future<Failure?> updateItemAfterUpload({
    required String itemId,
    required String imageUrl,
    required String thumbnailUrl,
    required UploadStatus status,
  }) async {
    try {
      await _firestore.collection(_collection).doc(itemId).update({
        'imageUrl': imageUrl,
        'thumbnailUrl': thumbnailUrl,
        'uploadStatus': status.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      return FirestoreWriteFailure(
          'Güncelleme başarısız: ${e.message}');
    } catch (_) {
      return const FirestoreWriteFailure();
    }
  }

  // ── Upload başarısız → status: failed ────────────────────────────────────

  Future<void> markItemAsFailed(String itemId) async {
    try {
      await _firestore.collection(_collection).doc(itemId).update({
        'uploadStatus': UploadStatus.failed.value,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (_) {
      // Sessizce başarısız ol — zaten hata durumundayız
    }
  }

  // ── Kullanıcının tüm item'larını stream olarak izle ───────────────────────
  // Hafta 5 gardırop görünümü için hazır, bu hafta da provider'da kullanılır.

  Stream<List<WardrobeItem>> watchUserItems(String userId, {
    ItemCategory? categoryFilter,
    bool includeArchived = false,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: includeArchived)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (categoryFilter != null) {
      query = query.where('category', isEqualTo: categoryFilter.name);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => WardrobeItem.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
              .toList(),
        );
  }

  Stream<List<WardrobeItem>> watchUserItemsPaginated(
    String userId, {
    DateTime? after,
    int limit = 20,
  }) {
    Query query = _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(limit);

    if (after != null) {
      query = query.startAfter([Timestamp.fromDate(after)]);
    }

    return query.snapshots().map(
          (snapshot) => snapshot.docs
              .map((doc) => WardrobeItem.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
              .toList(),
        );
  }

  // ── Tek item getir ────────────────────────────────────────────────────────

  Future<(WardrobeItem?, Failure?)> getItem(String itemId) async {
    try {
      final doc = await _firestore.collection(_collection).doc(itemId).get();
      if (!doc.exists) return (null, const ItemNotFoundFailure());
      return (WardrobeItem.fromFirestore(doc), null);
    } on FirebaseException catch (e) {
      return (null, NetworkFailure('Kıyafet yüklenemedi: ${e.message}'));
    } catch (_) {
      return (null, const WardrobeUnexpectedFailure());
    }
  }

  // ── Item arşivle (soft delete) ────────────────────────────────────────────

  Future<Failure?> archiveItem(String itemId) async {
    final userId = _currentUserId;
    if (userId == null) return const UnauthenticatedFailure();
    try {
      await _firestore.collection(_collection).doc(itemId).update({
        'isArchived': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseException catch (e) {
      return FirestoreWriteFailure('Arşivleme başarısız: ${e.message}');
    } catch (_) {
      return const WardrobeUnexpectedFailure();
    }
  }

  // ── Storage upload reference ───────────────────────────────────────────────

  /// Storage path: /wardrobe/{userId}/{itemId}/original.jpg
  Reference getOriginalRef(String userId, String itemId) =>
      _storage.ref('wardrobe/$userId/$itemId/original.jpg');

  /// Storage path: /wardrobe/{userId}/{itemId}/thumbnail.jpg
  Reference getThumbnailRef(String userId, String itemId) =>
      _storage.ref('wardrobe/$userId/$itemId/thumbnail.jpg');
}

// ── Riverpod Provider ─────────────────────────────────────────────────────────

@riverpod
WardrobeRepository wardrobeRepository(Ref ref) {
  return WardrobeRepository(
    firestore: ref.watch(firestoreProvider),
    storage: ref.watch(firebaseStorageProvider),
    auth: ref.watch(firebaseAuthProvider),
  );
}
