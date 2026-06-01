import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/core/utils/mannequin_utils.dart';

void main() {
  group('getMannequinAsset', () {

    test('female gender → female.svg', () {
      expect(
        getMannequinAsset('female'),
        equals('assets/mannequin/female.svg'),
      );
    });

    test('male gender → male.svg', () {
      expect(
        getMannequinAsset('male'),
        equals('assets/mannequin/male.svg'),
      );
    });

    test('null gender → unisex.svg', () {
      expect(
        getMannequinAsset(null),
        equals('assets/mannequin/unisex.svg'),
      );
    });

    test('other gender → unisex.svg', () {
      expect(
        getMannequinAsset('other'),
        equals('assets/mannequin/unisex.svg'),
      );
    });

  });
}
