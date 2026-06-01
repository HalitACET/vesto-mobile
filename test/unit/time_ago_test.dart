import 'package:flutter_test/flutter_test.dart';

// TimeAgo utility'si varsa test et
void main() {
  group('timeAgo', () {

    test('1 dakika önce', () {
      final dt = DateTime.now().subtract(const Duration(minutes: 1));
      // expect(timeAgo(dt), contains('dk'));
    });

    test('1 saat önce', () {
      final dt = DateTime.now().subtract(const Duration(hours: 1));
      // expect(timeAgo(dt), contains('sa'));
    });

  });
}
