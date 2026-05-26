import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'image_service.g.dart';

/// Fotoğraf sıkıştırma ve thumbnail üretme servisi.
/// image_picker ve image_cropper'dan dönen ham dosyayı işler.
///
/// Compression stratejisi:
///   Original  : max 1920x1920px, JPEG quality 85 → ~400-600KB
///   Thumbnail : 200x200px, JPEG quality 80 → ~20-40KB
///
/// TODO(Hafta 6): Move thumbnail generation to Cloud Function
/// for consistency and to offload client work. Currently done client-side
/// as a placeholder until Cloud Function is wired up.
class ImageService {
  const ImageService();

  // ── Sabitler ──────────────────────────────────────────────────────────────

  static const int _originalMaxDimension = 1920;
  static const int _originalQuality = 85;
  static const int _thumbnailDimension = 200;
  static const int _thumbnailQuality = 80;

  // ── Original sıkıştırma ───────────────────────────────────────────────────

  /// Orijinal fotoğrafı max 1920x1920px'e küçültüp JPEG quality 85 ile sıkıştırır.
  /// Dönen [File] geçici dizindedir — upload sonrası silinebilir.
  ///
  /// Throws [ImageProcessingException] kaynak okunursa (caller yakalar).
  Future<File?> compressOriginal(File source) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/vesto_original_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      targetPath,
      minWidth: _originalMaxDimension,
      minHeight: _originalMaxDimension,
      quality: _originalQuality,
      format: CompressFormat.jpeg,
      keepExif: false, // EXIF verisi temizle — GPS metadata sızdırma
    );

    if (result == null) return null;
    return File(result.path);
  }

  // ── Thumbnail üretme ──────────────────────────────────────────────────────

  /// 200x200px kare thumbnail üretir (center crop, JPEG quality 80).
  ///
  /// TODO(Hafta 6): Bu işlemi Cloud Function'a taşı.
  /// Client-side thumbnail oluşturma şimdilik kabul edilebilir,
  /// ama production'da server-side daha tutarlı sonuç verir.
  Future<File?> generateThumbnail(File source) async {
    final tempDir = await getTemporaryDirectory();
    final targetPath = '${tempDir.path}/vesto_thumb_${DateTime.now().millisecondsSinceEpoch}.jpg';

    final result = await FlutterImageCompress.compressAndGetFile(
      source.absolute.path,
      targetPath,
      minWidth: _thumbnailDimension,
      minHeight: _thumbnailDimension,
      quality: _thumbnailQuality,
      format: CompressFormat.jpeg,
      keepExif: false,
    );

    if (result == null) return null;
    return File(result.path);
  }

  // ── Dosya boyutu yardımcısı ───────────────────────────────────────────────

  /// Dosya boyutunu MB cinsinden döndürür — debug ve logging için.
  double fileSizeMb(File file) =>
      file.lengthSync() / (1024 * 1024);

  // ── Geçici dosyaları temizle ──────────────────────────────────────────────

  /// Upload tamamlandıktan sonra geçici sıkıştırılmış dosyaları sil.
  /// Her bir dosyayı bağımsız sil — biri başarısız olsa diğerlerine devam et.
  Future<void> cleanupTempFiles(List<File> files) async {
    for (final file in files) {
      try {
        if (await file.exists()) {
          await file.delete();
        }
      } catch (_) {
        // Temizlik hataları sessizce geçer — upload zaten bitti
      }
    }
  }
}

@riverpod
ImageService imageService(Ref ref) {
  return const ImageService();
}
