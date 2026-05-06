// Wardrobe exception sınıfları `core/errors/failure.dart`'a taşınmıştır.
// Dart sealed class constraint'i nedeniyle tüm Failure alt sınıfları
// aynı dosyada tanımlanmalıdır.
//
// Bu dosyayı import etmek yerine direkt kullanın:
//   import 'package:mobile/core/errors/failure.dart';
//
// Mevcut tipler:
//   - StorageUploadFailure
//   - FirestoreWriteFailure
//   - ItemNotFoundFailure
//   - ImageProcessingFailure
//   - PermissionDeniedFailure
//   - UnauthenticatedFailure
//   - WardrobeUnexpectedFailure
export 'package:mobile/core/errors/failure.dart'
    show
        StorageUploadFailure,
        FirestoreWriteFailure,
        ItemNotFoundFailure,
        ImageProcessingFailure,
        PermissionDeniedFailure,
        UnauthenticatedFailure,
        WardrobeUnexpectedFailure;
