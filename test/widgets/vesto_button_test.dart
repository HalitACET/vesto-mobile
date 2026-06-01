import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';

void main() {
  group('VestoButton', () {

    testWidgets('Label doğru gösteriliyor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VestoButton(
              label: 'Test Butonu',
              onPressed: () {},
            ),
          ),
        ),
      );

      expect(find.text('Test Butonu'), findsOneWidget);
    });

    testWidgets('onPressed callback çalışıyor', (tester) async {
      bool pressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VestoButton(
              label: 'Tıkla',
              onPressed: () => pressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Tıkla'));
      await tester.pump();

      expect(pressed, isTrue);
    });

    testWidgets('Loading state gösteriliyor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VestoButton(
              label: 'Yükleniyor',
              onPressed: null,
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('Disabled state çalışıyor', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: VestoButton(
              label: 'Disabled',
              onPressed: null,
            ),
          ),
        ),
      );

      final button = tester.widget<ElevatedButton>(
        find.byType(ElevatedButton),
      );
      expect(button.onPressed, isNull);
    });

  });
}
