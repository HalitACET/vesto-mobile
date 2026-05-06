import 'dart:io';
import 'package:equatable/equatable.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/core/services/image_service.dart';
import 'package:mobile/core/services/upload_service.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/auth/presentation/providers/auth_providers.dart';
import 'package:mobile/features/wardrobe/data/models/item_category.dart';
import 'package:mobile/features/wardrobe/data/models/wardrobe_item.dart';
import 'package:mobile/features/wardrobe/data/repositories/wardrobe_repository.dart';

part 'add_item_notifier.g.dart';

/// Kıyafet ekleme akışının state modeli.
class AddItemState extends Equatable {
  const AddItemState({
    this.croppedPhoto,
    this.category,
    this.subcategory,
    this.brand,
    this.size,
    this.notes,
    this.uploadProgress,
  });

  const AddItemState.initial()
      : croppedPhoto = null,
        category = null,
        subcategory = null,
        brand = null,
        size = null,
        notes = null,
        uploadProgress = null;

  final File? croppedPhoto;
  final ItemCategory? category;
  final String? subcategory;
  final String? brand;
  final String? size;
  final String? notes;
  final double? uploadProgress;

  bool get isValid => croppedPhoto != null && category != null && subcategory != null;

  AddItemState copyWith({
    File? croppedPhoto,
    ItemCategory? category,
    String? subcategory,
    String? brand,
    String? size,
    String? notes,
    double? uploadProgress,
    bool resetSubcategory = false,
  }) {
    return AddItemState(
      croppedPhoto: croppedPhoto ?? this.croppedPhoto,
      category: category ?? this.category,
      subcategory: resetSubcategory ? null : (subcategory ?? this.subcategory),
      brand: brand ?? this.brand,
      size: size ?? this.size,
      notes: notes ?? this.notes,
      uploadProgress: uploadProgress ?? this.uploadProgress,
    );
  }

  @override
  List<Object?> get props => [
        croppedPhoto,
        category,
        subcategory,
        brand,
        size,
        notes,
        uploadProgress,
      ];
}

@riverpod
class AddItemNotifier extends _$AddItemNotifier {
  @override
  AddItemState build() => const AddItemState.initial();

  // ── Step 1: Photo ─────────────────────────────────────────────────────────

  void setCroppedPhoto(File photo) {
    state = state.copyWith(croppedPhoto: photo);
  }

  // ── Step 2: Category ──────────────────────────────────────────────────────

  void setCategory(ItemCategory category) {
    // Kategori değişirse alt kategoriyi temizle
    state = state.copyWith(category: category, resetSubcategory: true);
  }

  void setSubcategory(String subcategory) {
    state = state.copyWith(subcategory: subcategory);
  }

  // ── Step 3: Metadata ──────────────────────────────────────────────────────

  void setBrand(String? brand) {
    state = state.copyWith(brand: brand?.trim().isEmpty == true ? null : brand?.trim());
  }

  void setSize(String? size) {
    state = state.copyWith(size: size?.trim().isEmpty == true ? null : size?.trim());
  }

  void setNotes(String? notes) {
    state = state.copyWith(notes: notes?.trim().isEmpty == true ? null : notes?.trim());
  }

  // ── Step 4: Save (Optimistic UI) ──────────────────────────────────────────

  Future<Result<WardrobeItem, Failure>> save() async {
    if (!state.isValid) {
      return const Err(FirestoreWriteFailure('Eksik bilgi girdiniz.'));
    }

    final user = ref.read(currentUserProvider).valueOrNull;
    if (user == null) {
      return const Err(UnauthenticatedFailure());
    }

    final repo = ref.read(wardrobeRepositoryProvider);
    final itemId = const Uuid().v4();
    final now = DateTime.now();

    // 1. Optimistic WardrobeItem oluştur
    final newItem = WardrobeItem(
      id: itemId,
      userId: user.uid,
      imagePath: 'wardrobe/${user.uid}/$itemId/original.jpg',
      category: state.category!,
      subcategory: state.subcategory!,
      userOverrides: UserOverrides.empty,
      brand: state.brand,
      size: state.size,
      notes: state.notes,
      createdAt: now,
      updatedAt: now,
      uploadStatus: UploadStatus.uploading,
    );

    // 2. Firestore'a hemen yaz (status: uploading, imageUrl: null)
    final (createdItem, error) = await repo.createItem(newItem);
    if (error != null) {
      return Err(error);
    }

    // 3. Background'da upload işlemini başlat (await etmiyoruz!)
    // Referansları memory sızıntısı yapmaması için kopyalıyoruz
    final photoToUpload = state.croppedPhoto!;
    _performBackgroundUpload(photoToUpload, newItem);

    // Başarılı optimistic save sonrası hemen dön
    return Ok(createdItem!);
  }

  // ── Background Upload Process ─────────────────────────────────────────────

  Future<void> _performBackgroundUpload(File sourcePhoto, WardrobeItem item) async {
    final imageService = ref.read(imageServiceProvider);
    final uploadService = ref.read(uploadServiceProvider);
    final repo = ref.read(wardrobeRepositoryProvider);

    try {
      // 1. Orijinal fotoğrafı sıkıştır
      final originalCompressed = await imageService.compressOriginal(sourcePhoto);
      if (originalCompressed == null) throw Exception('Compression failed');

      // 2. Thumbnail üret
      final thumbnail = await imageService.generateThumbnail(sourcePhoto);
      if (thumbnail == null) throw Exception('Thumbnail generation failed');

      // 3. Storage'a Original yükle
      final originalRef = repo.getOriginalRef(item.userId, item.id);
      final originalResult = await uploadService.uploadFile(
        file: originalCompressed,
        storageRef: originalRef,
        onProgress: (p) {
          // İstersek state.uploadProgress = p şeklinde güncelleyebiliriz
          // Ama UI'ı çoktan kapattığımız için state update'i gereksiz olabilir.
        },
      );

      if (originalResult.isErr) throw originalResult.errorOrNull!;
      final originalUrl = originalResult.valueOrNull!;

      // 4. Storage'a Thumbnail yükle
      final thumbnailRef = repo.getThumbnailRef(item.userId, item.id);
      final thumbnailResult = await uploadService.uploadFile(
        file: thumbnail,
        storageRef: thumbnailRef,
      );

      if (thumbnailResult.isErr) throw thumbnailResult.errorOrNull!;
      final thumbnailUrl = thumbnailResult.valueOrNull!;

      // 5. Her şey tamam, Firestore doc'u güncelle (status: ready)
      // imageUrl ve thumbnailUrl set edilecek
      await repo.updateItemAfterUpload(
        itemId: item.id,
        imageUrl: originalUrl,
        thumbnailUrl: thumbnailUrl,
        status: UploadStatus.ready,
      );

      // Not: thumbnailUrl de güncellenmeli ama updateItemAfterUpload sadece imageUrl alıyor.
      // repo sınıfını modifiye etmemiz gerekebilir. Şimdilik updateItemAfterUpload methodunu güncelleyeceğiz.

      // Geçici dosyaları temizle
      await imageService.cleanupTempFiles([originalCompressed, thumbnail]);
      
    } catch (e) {
      // 6. Hata durumunda Firestore'da status'ü failed yap
      await repo.markItemAsFailed(item.id);
      
      // Not: Kullanıcıya VestoSnackBar göstermek ideal olur.
      // Background context'inde context.showSnackBar zor, genelde bir Notification/Toaster servisi olur.
      // Şimdilik Firestore doc'u failed state'ine çekildi, UI'da retry çıkarılacak (Hafta 5'te).
    }
  }

  // ── Reset ─────────────────────────────────────────────────────────────────

  void reset() {
    state = const AddItemState.initial();
  }
}
