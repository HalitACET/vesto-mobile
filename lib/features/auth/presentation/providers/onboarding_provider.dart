import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kHasSeenOnboarding = 'hasSeenOnboarding';

/// Kullanıcının onboarding'i görüp görmediğini okur.
/// FutureProvider — build_runner gerektirmez, app başlangıcında bir kez okunur.
final hasSeenOnboardingProvider = FutureProvider<bool>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_kHasSeenOnboarding) ?? false;
});

/// Onboarding tamamlandı işaretle — router yeniden hesaplar.
Future<void> markOnboardingSeen(WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_kHasSeenOnboarding, true);
  ref.invalidate(hasSeenOnboardingProvider);
}
