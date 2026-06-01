import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_item_card.dart';

void main() {
  group('WardrobeItemCard', () {

    final testItem = WardrobeItem(
      id: 'item-1',
      userId: 'user-1',
      brand: 'Zara',
      category: 'top',
      subcategory: 'tshirt',
      size: 'M',
      imageUrl: 'https://example.com/image.jpg',
      isArchived: false,
      isPublic: false,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    testWidgets('Brand ismi görünüyor', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WardrobeItemCard(
                item: testItem,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      expect(find.text('Zara'), findsOneWidget);
    });

    testWidgets('onTap callback çalışıyor', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: WardrobeItemCard(
                item: testItem,
                onTap: () => tapped = true,
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(WardrobeItemCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

  });
}
