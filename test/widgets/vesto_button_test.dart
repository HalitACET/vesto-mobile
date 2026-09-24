import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:mobile/app/theme/app_radius.dart';
import 'package:mobile/core/widgets/atoms/vesto_button.dart';
import 'package:mobile/core/widgets/atoms/vesto_loading_indicator.dart';

void main() {
  // Keep tests offline: typography uses google_fonts, which would try to download fonts.
  GoogleFonts.config.allowRuntimeFetching = false;

  // Lets the 150ms flutter_animate fade-in finish so no timer is left pending.
  const fadeIn = Duration(milliseconds: 200);

  Widget wrap(Widget child) => MaterialApp(
        theme: ThemeData(extensions: const [VestoRadius()]),
        home: Scaffold(body: child),
      );

  group('VestoButton', () {
    testWidgets('Label büyük harfle gösteriliyor', (tester) async {
      await tester.pumpWidget(
        wrap(VestoButton(label: 'Test Butonu', onPressed: () {})),
      );
      await tester.pump(fadeIn);

      expect(find.text('TEST BUTONU'), findsOneWidget);
    });

    testWidgets('onPressed callback çalışıyor', (tester) async {
      var pressed = false;

      await tester.pumpWidget(
        wrap(VestoButton(label: 'Tıkla', onPressed: () => pressed = true)),
      );
      await tester.pump(fadeIn);

      await tester.tap(find.byType(VestoButton));
      await tester.pump(fadeIn);

      expect(pressed, isTrue);
    });

    testWidgets('Loading state gösteriliyor', (tester) async {
      await tester.pumpWidget(
        wrap(VestoButton(label: 'Yükle', onPressed: () {}, isLoading: true)),
      );
      await tester.pump(fadeIn);

      expect(find.byType(VestoLoadingIndicator), findsOneWidget);
      expect(find.text('YÜKLE'), findsNothing);
    });

    testWidgets('Disabled state tıklamayı yok sayıyor', (tester) async {
      await tester.pumpWidget(
        wrap(const VestoButton(label: 'Disabled', onPressed: null)),
      );
      await tester.pump(fadeIn);

      // No callback to fire; tapping must not throw and the label stays visible.
      await tester.tap(find.byType(VestoButton));
      await tester.pump(fadeIn);

      expect(find.text('DISABLED'), findsOneWidget);
      final detector = tester.widget<GestureDetector>(
        find.descendant(
          of: find.byType(VestoButton),
          matching: find.byType(GestureDetector),
        ).first,
      );
      expect(detector.onTapUp, isNull);
    });
  });
}
