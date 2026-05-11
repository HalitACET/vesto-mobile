import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/outfits/data/models/outfit.dart';

class OutfitRepository {
  final FirebaseFirestore _firestore;

  OutfitRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference get _outfits => _firestore.collection('outfits');

  // Stream of all outfits for a user
  Stream<List<Outfit>> watchOutfits(String userId) {
    print('DEBUG: watchOutfits starting for $userId');
    return _outfits
        .where('userId', isEqualTo: userId)
        .where('isArchived', isEqualTo: false)
        .snapshots()
        .map((snapshot) {
          print('DEBUG: watchOutfits received snapshot with ${snapshot.docs.length} docs');
          final outfits = snapshot.docs
            .map((doc) => Outfit.fromFirestore(doc))
            .toList();
          
          // Sort in memory instead of requiring a DB index
          outfits.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          return outfits;
        });
  }

  // Create
  Future<void> createOutfit(Outfit outfit) async {
    final data = <String, dynamic>{
      'userId': outfit.userId,
      'name': outfit.name,
      'items': outfit.items.toJson(), // Guarantee Map
      'tags': outfit.tags,
      'wearCount': outfit.wearCount,
      'isFavorite': outfit.isFavorite,
      'isArchived': outfit.isArchived,
      'createdAt': Timestamp.fromDate(outfit.createdAt),
    };

    if (outfit.lastWorn != null) {
      data['lastWorn'] = Timestamp.fromDate(outfit.lastWorn!);
    }

    await _outfits.add(data);
  }

  // Update
  Future<void> updateOutfit(Outfit outfit) async {
    final data = <String, dynamic>{
      'userId': outfit.userId,
      'name': outfit.name,
      'items': outfit.items.toJson(), // Guarantee Map
      'tags': outfit.tags,
      'wearCount': outfit.wearCount,
      'isFavorite': outfit.isFavorite,
      'isArchived': outfit.isArchived,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (outfit.lastWorn != null) {
      data['lastWorn'] = Timestamp.fromDate(outfit.lastWorn!);
    }

    await _outfits.doc(outfit.id).update(data);
  }

  // Delete (Hard delete for now as per instructions)
  Future<void> deleteOutfit(String outfitId) async {
    await _outfits.doc(outfitId).delete();
  }

  // Mark as worn (Updates outfit and all contained items)
  Future<void> markAsWorn(Outfit outfit) async {
    final batch = _firestore.batch();
    
    // Update outfit
    batch.update(_outfits.doc(outfit.id), {
      'wearCount': FieldValue.increment(1),
      'lastWorn': FieldValue.serverTimestamp(),
    });

    // Update items
    final itemIds = [
      outfit.items.topId,
      outfit.items.bottomId,
      outfit.items.shoesId,
      outfit.items.accessoryId,
    ].whereType<String>();

    for (final id in itemIds) {
      batch.update(_firestore.collection('wardrobeItems').doc(id), {
        'usageCount': FieldValue.increment(1),
      });
    }

    await batch.commit();
  }

  // Toggle favorite
  Future<void> toggleFavorite(String outfitId, bool currentStatus) async {
    await _outfits.doc(outfitId).update({
      'isFavorite': !currentStatus,
    });
  }
}
