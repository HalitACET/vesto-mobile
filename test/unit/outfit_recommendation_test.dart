import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/stylist/data/models/outfit_recommendation.dart';
import 'package:mobile/features/outfits/data/models/outfit_items.dart';

void main() {
  group('OutfitRecommendation', () {

    test('toFirestore doğru map üretiyor', () {
      final rec = OutfitRecommendation(
        id: 'rec-1',
        stylistId: 'stylist-1',
        stylistDisplayName: 'Ahmet',
        targetUserId: 'user-1',
        items: const OutfitItems(
          topId: 'top-1',
          bottomId: 'bottom-1',
          shoesId: null,
          accessoryId: null,
        ),
        note: 'Harika bir kombin',
        status: 'pending',
        createdAt: DateTime(2026, 1, 1),
      );

      final map = rec.toFirestore();

      expect(map['stylistId'], equals('stylist-1'));
      expect(map['targetUserId'], equals('user-1'));
      expect(map['status'], equals('pending'));
      expect(map['items']['topId'], equals('top-1'));
      expect(map['items']['shoesId'], isNull);
    });

  });
}
