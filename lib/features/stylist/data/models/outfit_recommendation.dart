import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/outfits/data/models/outfit_items.dart';

class OutfitRecommendation {
  final String id;
  final String stylistId;
  final String stylistDisplayName;
  final String? stylistPhotoUrl;
  final String targetUserId;
  final OutfitItems items;
  final String note;
  final String status; // 'pending' | 'accepted' | 'rejected'
  final DateTime createdAt;
  final DateTime? respondedAt;
  final String? acceptedOutfitId;
  final int? rating; // 1-5, sadece accepted sonrası

  const OutfitRecommendation({
    required this.id,
    required this.stylistId,
    required this.stylistDisplayName,
    this.stylistPhotoUrl,
    required this.targetUserId,
    required this.items,
    this.note = '',
    this.status = 'pending',
    required this.createdAt,
    this.respondedAt,
    this.acceptedOutfitId,
    this.rating,
  });

  factory OutfitRecommendation.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    final itemsData = data['items'] as Map<String, dynamic>? ?? {};
    return OutfitRecommendation(
      id: doc.id,
      stylistId: data['stylistId'] as String? ?? '',
      stylistDisplayName: data['stylistDisplayName'] as String? ?? '',
      stylistPhotoUrl: data['stylistPhotoUrl'] as String?,
      targetUserId: data['targetUserId'] as String? ?? '',
      items: OutfitItems(
        topId: itemsData['topId'] as String?,
        bottomId: itemsData['bottomId'] as String?,
        shoesId: itemsData['shoesId'] as String?,
        accessoryId: itemsData['accessoryId'] as String?,
      ),
      note: data['note'] as String? ?? '',
      status: data['status'] as String? ?? 'pending',
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      respondedAt: data['respondedAt'] != null
          ? (data['respondedAt'] as Timestamp).toDate()
          : null,
      acceptedOutfitId: data['acceptedOutfitId'] as String?,
      rating: data['rating'] as int?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'stylistId': stylistId,
        'stylistDisplayName': stylistDisplayName,
        'stylistPhotoUrl': stylistPhotoUrl,
        'targetUserId': targetUserId,
        'items': {
          'topId': items.topId,
          'bottomId': items.bottomId,
          'shoesId': items.shoesId,
          'accessoryId': items.accessoryId,
        },
        'note': note,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'respondedAt': null,
        if (acceptedOutfitId != null) 'acceptedOutfitId': acceptedOutfitId,
      };
}
