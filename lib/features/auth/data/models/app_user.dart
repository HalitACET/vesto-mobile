import 'package:equatable/equatable.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

enum UserRole {
  user('user'),
  verifiedStylist('verified_stylist'),
  admin('admin');

  const UserRole(this.value);
  final String value;

  static UserRole fromString(String? value) => UserRole.values.firstWhere(
        (r) => r.value == value,
        orElse: () => UserRole.user,
      );
}

enum Gender {
  male('male'),
  female('female'),
  unisex('unisex'),
  preferNotSay('prefer_not_say');

  const Gender(this.value);
  final String value;

  static Gender? fromString(String? value) {
    if (value == null) return null;
    for (final g in Gender.values) {
      if (g.value == value) return g;
    }
    return null;
  }

  String get displayLabel => switch (this) {
        Gender.male => 'Erkek',
        Gender.female => 'Kadın',
        Gender.unisex => 'Unisex',
        Gender.preferNotSay => 'Belirtmek istemiyorum',
      };
}

enum ProfileSetupStep {
  basicInfo('basic_info'),
  physical('physical'),
  location('location'),
  stylePreferences('style_preferences'),
  completed('completed');

  const ProfileSetupStep(this.value);
  final String value;

  static ProfileSetupStep? fromString(String? value) {
    if (value == null) return null;
    for (final s in ProfileSetupStep.values) {
      if (s.value == value) return s;
    }
    return null;
  }
}

enum Aesthetic {
  minimalist('minimalist'),
  streetwear('streetwear'),
  classic('classic'),
  bohemian('bohemian'),
  sporty('sporty');

  const Aesthetic(this.value);
  final String value;

  static Aesthetic? fromString(String? value) {
    if (value == null) return null;
    for (final a in Aesthetic.values) {
      if (a.value == value) return a;
    }
    return null;
  }

  String get displayLabel => switch (this) {
        Aesthetic.minimalist => 'Minimalist',
        Aesthetic.streetwear => 'Streetwear',
        Aesthetic.classic => 'Klasik',
        Aesthetic.bohemian => 'Bohem',
        Aesthetic.sporty => 'Sportif',
      };
}

enum Occasion {
  work('work'),
  casual('casual'),
  formal('formal'),
  sport('sport'),
  date('date');

  const Occasion(this.value);
  final String value;

  static Occasion? fromString(String? value) {
    if (value == null) return null;
    for (final o in Occasion.values) {
      if (o.value == value) return o;
    }
    return null;
  }

  String get displayLabel => switch (this) {
        Occasion.work => 'İş',
        Occasion.casual => 'Günlük',
        Occasion.formal => 'Resmi',
        Occasion.sport => 'Spor',
        Occasion.date => 'Randevu',
      };
}

// ── Value Objects ─────────────────────────────────────────────────────────────

class UserLocation extends Equatable {
  const UserLocation({
    required this.city,
    this.country = 'TR',
    this.lat,
    this.lng,
  });

  final String city;
  final String country;
  final double? lat;
  final double? lng;

  factory UserLocation.fromMap(Map<String, dynamic> map) => UserLocation(
        city: map['city'] as String? ?? '',
        country: map['country'] as String? ?? 'TR',
        lat: (map['lat'] as num?)?.toDouble(),
        lng: (map['lng'] as num?)?.toDouble(),
      );

  Map<String, dynamic> toMap() => {
        'city': city,
        'country': country,
        if (lat != null) 'lat': lat,
        if (lng != null) 'lng': lng,
      };

  @override
  List<Object?> get props => [city, country, lat, lng];
}

class StylePreferences extends Equatable {
  const StylePreferences({
    this.aesthetics = const [],
    this.favoriteColors = const [],
    this.occasions = const [],
  });

  final List<Aesthetic> aesthetics;
  final List<String> favoriteColors;
  final List<Occasion> occasions;

  factory StylePreferences.fromMap(Map<String, dynamic> map) {
    final aestheticValues = (map['aesthetics'] as List<dynamic>?)
            ?.map((e) => Aesthetic.fromString(e as String?))
            .whereType<Aesthetic>()
            .toList() ??
        [];
    final occasionValues = (map['occasions'] as List<dynamic>?)
            ?.map((e) => Occasion.fromString(e as String?))
            .whereType<Occasion>()
            .toList() ??
        [];
    return StylePreferences(
      aesthetics: aestheticValues,
      favoriteColors: List<String>.from(map['favoriteColors'] as List? ?? []),
      occasions: occasionValues,
    );
  }

  Map<String, dynamic> toMap() => {
        'aesthetics': aesthetics.map((a) => a.value).toList(),
        'favoriteColors': favoriteColors,
        'occasions': occasions.map((o) => o.value).toList(),
      };

  @override
  List<Object?> get props => [aesthetics, favoriteColors, occasions];
}

// ── AppUser ───────────────────────────────────────────────────────────────────

class AppUser extends Equatable {
  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    required this.createdAt,
    this.photoURL,
    this.gender,
    this.birthYear,
    this.heightCm,
    this.weightKg,
    this.location,
    this.stylePreferences,
    this.isProfileComplete = false,
    this.lastCompletedStep,
  });

  final String uid;
  final String email;
  final String displayName;
  final String? photoURL;
  final UserRole role;
  final DateTime createdAt;

  final Gender? gender;
  final int? birthYear;
  final int? heightCm;
  final int? weightKg;
  final UserLocation? location;
  final StylePreferences? stylePreferences;
  final bool isProfileComplete;
  final ProfileSetupStep? lastCompletedStep;

  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    final locationData = data['location'] as Map<String, dynamic>?;
    final styleData = data['stylePreferences'] as Map<String, dynamic>?;

    return AppUser(
      uid: uid,
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? 'Kullanıcı',
      photoURL: data['photoURL'] as String?,
      role: UserRole.fromString(data['role'] as String?),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate() as DateTime
          : DateTime.now(),
      gender: Gender.fromString(data['gender'] as String?),
      birthYear: data['birthYear'] as int?,
      heightCm: data['heightCm'] as int?,
      weightKg: data['weightKg'] as int?,
      location:
          locationData != null ? UserLocation.fromMap(locationData) : null,
      stylePreferences:
          styleData != null ? StylePreferences.fromMap(styleData) : null,
      isProfileComplete: data['isProfileComplete'] as bool? ?? false,
      lastCompletedStep:
          ProfileSetupStep.fromString(data['lastCompletedStep'] as String?),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'uid': uid,
        'email': email,
        'displayName': displayName,
        if (photoURL != null) 'photoURL': photoURL,
        'role': role.value,
        'createdAt': createdAt,
        if (gender != null) 'gender': gender!.value,
        if (birthYear != null) 'birthYear': birthYear,
        if (heightCm != null) 'heightCm': heightCm,
        if (weightKg != null) 'weightKg': weightKg,
        if (location != null) 'location': location!.toMap(),
        if (stylePreferences != null)
          'stylePreferences': stylePreferences!.toMap(),
        'isProfileComplete': isProfileComplete,
        if (lastCompletedStep != null)
          'lastCompletedStep': lastCompletedStep!.value,
      };

  AppUser copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
    UserRole? role,
    DateTime? createdAt,
    Gender? gender,
    int? birthYear,
    int? heightCm,
    int? weightKg,
    UserLocation? location,
    StylePreferences? stylePreferences,
    bool? isProfileComplete,
    ProfileSetupStep? lastCompletedStep,
  }) {
    return AppUser(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      role: role ?? this.role,
      createdAt: createdAt ?? this.createdAt,
      gender: gender ?? this.gender,
      birthYear: birthYear ?? this.birthYear,
      heightCm: heightCm ?? this.heightCm,
      weightKg: weightKg ?? this.weightKg,
      location: location ?? this.location,
      stylePreferences: stylePreferences ?? this.stylePreferences,
      isProfileComplete: isProfileComplete ?? this.isProfileComplete,
      lastCompletedStep: lastCompletedStep ?? this.lastCompletedStep,
    );
  }

  @override
  List<Object?> get props => [
        uid,
        email,
        displayName,
        photoURL,
        role,
        createdAt,
        gender,
        birthYear,
        heightCm,
        weightKg,
        location,
        stylePreferences,
        isProfileComplete,
        lastCompletedStep,
      ];
}
