import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/core/utils/result.dart';

part 'upload_service.g.dart';



/// Firebase Storage yükleme servisi.
/// İlerlemeyi Stream<double> olarak sağlar ve hata durumlarını `Failure` ile sarmalar.
class UploadService {
  const UploadService();

  /// Verilen dosyayı belirtilen Storage referansına yükler ve URL'sini döndürür.
  /// `onProgress` callback'i ile %0-100 arası (0.0 - 1.0) ilerleme izlenebilir.
  Future<Result<String, Failure>> uploadFile({
    required File file,
    required Reference storageRef,
    void Function(double progress)? onProgress,
  }) async {
    try {
      final uploadTask = storageRef.putFile(
        file,
        SettableMetadata(
          contentType: 'image/jpeg',
          customMetadata: {'uploaded_via': 'vesto_mobile_app'},
        ),
      );

      if (onProgress != null) {
        uploadTask.snapshotEvents.listen((TaskSnapshot snapshot) {
          final progress = snapshot.totalBytes > 0
              ? snapshot.bytesTransferred / snapshot.totalBytes
              : 0.0;
          onProgress(progress.clamp(0.0, 1.0));
        }, onError: (Object e) {
          // Stream error - catch bloğu ana hatayı yakalayacak
        });
      }

      // Upload'ın bitmesini bekle
      await uploadTask;

      // Başarılı yükleme sonrası URL'yi al
      final downloadUrl = await storageRef.getDownloadURL();
      return Ok(downloadUrl);
    } on FirebaseException catch (e) {
      return Err(_mapFirebaseError(e));
    } catch (_) {
      return const Err(StorageUploadFailure());
    }
  }

  Failure _mapFirebaseError(FirebaseException e) {
    switch (e.code) {
      case 'quota-exceeded':
        return const StorageUploadFailure('Depolama kotası doldu.');
      case 'unauthorized':
      case 'unauthenticated':
        return const PermissionDeniedFailure('Bu işlem için izniniz yok.');
      case 'network-request-failed':
        return const NetworkFailure('İnternet bağlantınızı kontrol edin.');
      case 'retry-limit-exceeded':
      case 'timeout':
        return const NetworkFailure('Bağlantı zaman aşımına uğradı.');
      case 'canceled':
        return const StorageUploadFailure('Yükleme iptal edildi.');
      default:
        return const StorageUploadFailure();
    }
  }
}

@riverpod
UploadService uploadService(Ref ref) {
  return const UploadService();
}
