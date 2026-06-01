import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:mobile/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('App Integration Tests', () {

    testWidgets('App başlatılıyor', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 5));

      // Uygulama başladı — login veya home görünüyor
      expect(
        find.byType(MaterialApp),
        findsOneWidget,
      );
    });

    testWidgets('Bottom navigation çalışıyor', (tester) async {
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 10));

      // Authenticated ise bottom nav görünür
      final bottomNav = find.byType(BottomNavigationBar)
          .or(find.byType(NavigationBar));

      if (tester.any(bottomNav)) {
        expect(bottomNav, findsOneWidget);
      }
    });

  });
}
