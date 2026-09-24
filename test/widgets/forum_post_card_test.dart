import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mobile/features/forum/data/models/forum_post.dart';
import 'package:mobile/features/forum/presentation/widgets/forum_post_card.dart';

void main() {
  group('ForumPostCard', () {

    final testPost = ForumPost(
      id: 'test-post-1',
      authorId: 'user-1',
      authorDisplayName: 'Test Kullanıcı',
      authorPhotoUrl: null,
      outfitId: 'outfit-1',
      caption: 'Bu benim test kombinim',
      likeCount: 5,
      commentCount: 2,
      createdAt: DateTime.now(),
      isModerated: false,
      isArchived: false,
    );

    testWidgets('Author ismi görünüyor', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ForumPostCard(post: testPost),
            ),
          ),
        ),
      );

      expect(find.text('Test Kullanıcı'), findsOneWidget);
    });

    testWidgets('Caption görünüyor', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ForumPostCard(post: testPost),
            ),
          ),
        ),
      );

      expect(find.text('Bu benim test kombinim'), findsOneWidget);
    });

    testWidgets('Like count görünüyor', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ForumPostCard(post: testPost),
            ),
          ),
        ),
      );

      expect(find.text('5'), findsOneWidget);
    });

  },
      // ForumPostCard reads FirebaseAuth.instance directly in build() and watches
      // Firestore-backed providers, so it can't render without a Firebase app.
      // Re-enable once the card gets the current user via a provider that tests
      // can override.
      skip: 'ForumPostCard depends on FirebaseAuth.instance; needs provider injection');
}
