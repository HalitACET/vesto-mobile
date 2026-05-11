import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:mobile/features/outfits/data/models/outfit_items.dart';

part 'outfit.freezed.dart';
part 'outfit.g.dart';

@freezed
abstract class Outfit with _$Outfit {
  const factory Outfit({
    required String id,
    required String userId,
    @Default('İsimsiz Kombin') String name,
    required OutfitItems items,
    @Default([]) List<String> tags,
    required DateTime createdAt,
    DateTime? lastWorn,
    @Default(0) int wearCount,
    @Default(false) bool isFavorite,
    @Default(false) bool isArchived,
  }) = _Outfit;

  factory Outfit.fromJson(Map<String, dynamic> json) => _$OutfitFromJson(json);

  // Firestore Timestamp handling
  factory Outfit.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Outfit.fromJson({
      ...data,
      'id': doc.id,
      'createdAt': (data['createdAt'] as Timestamp?)?.toDate().toIso8601String() ?? DateTime.now().toIso8601String(),
      'lastWorn': data['lastWorn'] != null 
          ? (data['lastWorn'] as Timestamp).toDate().toIso8601String()
          : null,
    });
  }
}
