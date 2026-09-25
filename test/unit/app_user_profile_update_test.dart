import 'package:flutter_test/flutter_test.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';

// Mirrors ownerEditableUserFields() in firebase/rules/firestore.rules.
const _ownerEditableFields = {
  'displayName', 'username', 'bio', 'photoURL', 'photoUrl',
  'gender', 'birthYear', 'heightCm', 'weightKg', 'location',
  'stylePreferences', 'isProfileComplete', 'lastCompletedStep',
  'profileSetupCompleted', 'wardrobePublic', 'isStylistModeActive',
  'fcmToken', 'fcmTokenWeb', 'lastLogin', 'updatedAt',
};

void main() {
  test('toProfileUpdate only writes owner-editable fields', () {
    final user = AppUser(
      uid: 'u1',
      email: 'u1@example.com',
      displayName: 'U',
      photoURL: 'https://x/y.jpg',
      role: UserRole.admin,
      createdAt: DateTime(2026),
      gender: Gender.female,
      birthYear: 1999,
      heightCm: 170,
      weightKg: 60,
      location: const UserLocation(city: 'Istanbul'),
      stylePreferences: const StylePreferences(),
      isProfileComplete: true,
      lastCompletedStep: ProfileSetupStep.completed,
      followerCount: 10,
      averageRating: 4.5,
    );

    final keys = user.toProfileUpdate().keys.toSet();

    expect(keys.difference(_ownerEditableFields), isEmpty);
    expect(keys, containsAll(['displayName', 'gender', 'isProfileComplete']));
  });
}
