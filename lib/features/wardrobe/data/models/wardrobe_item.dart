import 'package:equatable/equatable.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mobile/features/wardrobe/data/models/ai_analysis.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';

// ── Enums ────────────────────────────────────────────────────────────────────

/// Kıyafet yükleme durumu.
/// uploading → storage'a yükleme devam ediyor
/// ready     → imageUrl mevcut, görüntülenebilir
/// failed    → yükleme başarısız, retry gerekli
enum UploadStatus {
  uploading('uploading'),
  ready('ready'),
  failed('failed');

  const UploadStatus(this.value);
  final String value;

  static UploadStatus fromString(String? value) =>
      UploadStatus.values.firstWhere(
        (s) => s.value == value,
        orElse: () => UploadStatus.uploading,
      );
}

// ── UserOverrides ─────────────────────────────────────────────────────────────

/// Kullanıcının AI analizini geçersiz kılabileceği manuel alanlar.
/// Tüm alanlar opsiyonel — kullanıcı doldurmak zorunda değil.
class UserOverrides extends Equatable {
  const UserOverrides({
    this.color,
    this.material,
    this.pattern,
  });

  final String? color;
  final String? material;
  final String? pattern;

  static const UserOverrides empty = UserOverrides();

  bool get isEmpty => color == null && material == null && pattern == null;

  factory UserOverrides.fromMap(Map<String, dynamic> map) => UserOverrides(
        color: map['color'] as String?,
        material: map['material'] as String?,
        pattern: map['pattern'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (color != null) 'color': color,
        if (material != null) 'material': material,
        if (pattern != null) 'pattern': pattern,
      };

  UserOverrides copyWith({
    String? color,
    String? material,
    String? pattern,
  }) =>
      UserOverrides(
        color: color ?? this.color,
        material: material ?? this.material,
        pattern: pattern ?? this.pattern,
      );

  @override
  List<Object?> get props => [color, material, pattern];
}

// ── WardrobeItem ──────────────────────────────────────────────────────────────

/// Gardırop öğesi ana modeli.
/// CLAUDE.md Firestore schema'sı ile birebir uyumlu.
/// Web'in `adminReview` field'ı nullable olarak okunabilir (mobile yazmaz).
class WardrobeItem extends Equatable {
  const WardrobeItem({
    required this.id,
    required this.userId,
    required this.imagePath,
    required this.category,
    required this.subcategory,
    required this.userOverrides,
    required this.createdAt,
    required this.updatedAt,
    required this.uploadStatus,
    this.imageUrl,
    this.thumbnailUrl,
    this.bgRemovedUrl,
    this.aiAnalysis,
    this.brand,
    this.size,
    this.purchaseDate,
    this.notes,
    this.isArchived = false,
    this.usageCount = 0,
    this.isPublic = false,
    this.adminReview, // web tarafının yazdığı alan, mobile sadece okur
  });

  // ── Görsel ────────────────────────────────────────────────────────────────
  final String? imageUrl;        // upload bitene kadar null
  final String? thumbnailUrl;    // Cloud Function üretene kadar null (Hafta 6)
  final String? bgRemovedUrl;    // Cloud Function tarafından yazılır (PNG, transparent BG)
  final String imagePath;        // storage path — silme işlemi için

  // ── Kimlik ────────────────────────────────────────────────────────────────
  final String id;
  final String userId;

  // ── Sınıflandırma ─────────────────────────────────────────────────────────
  final ItemCategory category;
  final String subcategory;

  // ── AI (Hafta 6) ──────────────────────────────────────────────────────────
  final AiAnalysis? aiAnalysis;

  // ── Kullanıcı Override ────────────────────────────────────────────────────
  final UserOverrides userOverrides;

  // ── Metadata ──────────────────────────────────────────────────────────────
  final String? brand;
  final String? size;
  final DateTime? purchaseDate;
  final String? notes;

  // ── Sistem ────────────────────────────────────────────────────────────────
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool isArchived;
  final bool isPublic;
  final UploadStatus uploadStatus;
  final int usageCount; // Hafta 8 outfit editöründe artar

  // ── Web-only — mobile sadece okur, yazmaz ─────────────────────────────────
  final Map<String, dynamic>? adminReview;

  // ── Factory ───────────────────────────────────────────────────────────────

  factory WardrobeItem.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data()!;
    return WardrobeItem._fromMap(data, doc.id);
  }

  factory WardrobeItem._fromMap(Map<String, dynamic> data, String id) {
    final aiData = data['aiAnalysis'] as Map<String, dynamic>?;
    final overridesData = data['userOverrides'] as Map<String, dynamic>?;

    return WardrobeItem(
      id: id,
      userId: data['userId'] as String? ?? '',
      imageUrl: data['imageUrl'] as String?,
      thumbnailUrl: data['thumbnailUrl'] as String?,
      bgRemovedUrl: data['bgRemovedUrl'] as String?,
      imagePath: data['imagePath'] as String? ?? '',
      category:
          ItemCategory.fromString(data['category'] as String?) ??
              ItemCategory.top,
      subcategory: data['subcategory'] as String? ?? '',
      aiAnalysis:
          aiData != null ? AiAnalysis.fromMap(aiData) : null,
      userOverrides: overridesData != null
          ? UserOverrides.fromMap(overridesData)
          : UserOverrides.empty,
      brand: data['brand'] as String?,
      size: data['size'] as String?,
      purchaseDate: data['purchaseDate'] != null
          ? (data['purchaseDate'] as Timestamp).toDate()
          : null,
      notes: data['notes'] as String?,
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as Timestamp).toDate()
          : DateTime.now(),
      updatedAt: data['updatedAt'] != null
          ? (data['updatedAt'] as Timestamp).toDate()
          : DateTime.now(),
      isArchived: data['isArchived'] as bool? ?? false,
      isPublic: data['isPublic'] as bool? ?? false,
      uploadStatus:
          UploadStatus.fromString(data['uploadStatus'] as String?),
      usageCount: data['usageCount'] as int? ?? 0,
      adminReview: data['adminReview'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toFirestore() => {
        'userId': userId,
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'imagePath': imagePath,
        'category': category.value,
        'subcategory': subcategory,
        // aiAnalysis: mobile yazmaz, null bırakır — Hafta 6 Cloud Function yazar
        if (!userOverrides.isEmpty)
          'userOverrides': userOverrides.toMap(),
        if (brand != null) 'brand': brand,
        if (size != null) 'size': size,
        if (purchaseDate != null)
          'purchaseDate': Timestamp.fromDate(purchaseDate!),
        if (notes != null) 'notes': notes,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'isArchived': isArchived,
        'isPublic': isPublic,
        'uploadStatus': uploadStatus.value,
        'usageCount': usageCount,
        // adminReview: mobile yazmaz
      };

  /// Firestore güncelleme için (tüm alanları değil, sadece değişenleri yazar).
  Map<String, dynamic> toFirestoreUpdate() => {
        if (imageUrl != null) 'imageUrl': imageUrl,
        if (thumbnailUrl != null) 'thumbnailUrl': thumbnailUrl,
        'uploadStatus': uploadStatus.value,
        'updatedAt': FieldValue.serverTimestamp(),
      };

  // ── CopyWith ──────────────────────────────────────────────────────────────

  WardrobeItem copyWith({
    String? id,
    String? userId,
    String? imageUrl,
    String? thumbnailUrl,
    String? bgRemovedUrl,
    String? imagePath,
    ItemCategory? category,
    String? subcategory,
    AiAnalysis? aiAnalysis,
    UserOverrides? userOverrides,
    String? brand,
    String? size,
    DateTime? purchaseDate,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isArchived,
    bool? isPublic,
    UploadStatus? uploadStatus,
    int? usageCount,
    Map<String, dynamic>? adminReview,
  }) =>
      WardrobeItem(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        imageUrl: imageUrl ?? this.imageUrl,
        thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
        bgRemovedUrl: bgRemovedUrl ?? this.bgRemovedUrl,
        imagePath: imagePath ?? this.imagePath,
        category: category ?? this.category,
        subcategory: subcategory ?? this.subcategory,
        aiAnalysis: aiAnalysis ?? this.aiAnalysis,
        userOverrides: userOverrides ?? this.userOverrides,
        brand: brand ?? this.brand,
        size: size ?? this.size,
        purchaseDate: purchaseDate ?? this.purchaseDate,
        notes: notes ?? this.notes,
        createdAt: createdAt ?? this.createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
        isArchived: isArchived ?? this.isArchived,
        isPublic: isPublic ?? this.isPublic,
        uploadStatus: uploadStatus ?? this.uploadStatus,
        usageCount: usageCount ?? this.usageCount,
        adminReview: adminReview ?? this.adminReview,
      );

  @override
  List<Object?> get props => [
        id,
        userId,
        imageUrl,
        thumbnailUrl,
        bgRemovedUrl,
        imagePath,
        category,
        subcategory,
        aiAnalysis,
        userOverrides,
        brand,
        size,
        purchaseDate,
        notes,
        createdAt,
        updatedAt,
        isArchived,
        isPublic,
        uploadStatus,
        usageCount,
      ];
}
