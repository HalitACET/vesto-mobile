import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/app/theme/app_radius.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/presentation/widgets/wardrobe_item_card.dart';

void main() {
  // Keep tests offline: typography uses google_fonts, which would try to download fonts.
  GoogleFonts.config.allowRuntimeFetching = false;

  group('WardrobeItemCard', () {
    final testItem = WardrobeItem(
      id: 'item-1',
      userId: 'user-1',
      imagePath: 'wardrobe/user-1/item-1.jpg',
      brand: 'Zara',
      category: ItemCategory.top,
      subcategory: 'tshirt',
      size: 'M',
      // No imageUrl: the card renders its placeholder instead of a network image.
      userOverrides: const UserOverrides(),
      uploadStatus: UploadStatus.ready,
      createdAt: DateTime(2026, 1, 1),
      updatedAt: DateTime(2026, 1, 1),
    );

    Widget buildCard({VoidCallback? onTap, VoidCallback? onLongPress}) {
      return MaterialApp(
        theme: ThemeData(extensions: const [VestoRadius()]),
        home: Scaffold(
          body: Center(
            child: SizedBox(
              width: 200,
              height: 300,
              child: WardrobeItemCard(
                item: testItem,
                onTap: onTap ?? () {},
                onLongPress: onLongPress ?? () {},
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('Brand ismi görünüyor', (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.text('Zara'), findsOneWidget);
    });

    testWidgets('onTap callback çalışıyor', (tester) async {
      var tapped = false;

      await tester.pumpWidget(buildCard(onTap: () => tapped = true));

      await tester.tap(find.byType(WardrobeItemCard));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onLongPress callback çalışıyor', (tester) async {
      var longPressed = false;

      await tester.pumpWidget(buildCard(onLongPress: () => longPressed = true));

      await tester.longPress(find.byType(WardrobeItemCard));
      await tester.pump();

      expect(longPressed, isTrue);
    });
  });
}
