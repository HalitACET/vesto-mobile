import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/core/errors/app_exception.dart';
import 'package:mobile/core/errors/failure.dart';
import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/features/auth/data/models/app_user.dart';

part 'auth_repository.g.dart';

@riverpod
AuthRepository authRepository(Ref ref) {
  return AuthRepository(
    auth: ref.watch(firebaseAuthProvider),
    firestore: ref.watch(firestoreProvider),
  );
}

class AuthRepository {
  const AuthRepository({
    required FirebaseAuth auth,
    required FirebaseFirestore firestore,
  })  : _auth = auth,
        _firestore = firestore;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Firestore'dan AppUser stream'i — auth değiştiğinde otomatik güncellenir.
  Stream<AppUser?> userStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? AppUser.fromFirestore(doc.data()!, doc.id) : null);
  }

  /// Anonim giriş (Hafta 1 için). Gerçek auth Hafta 3'te gelecek.
  Future<(AppUser?, Failure?)> signInAnonymously() async {
    try {
      final credential = await _auth.signInAnonymously();
      final user = credential.user;
      if (user == null) return (null, const AuthFailure('Kullanıcı oluşturulamadı.'));

      final appUser = await _ensureUserDocument(user);
      return (appUser, null);
    } on FirebaseAuthException catch (e) {
      return (null, AuthFailure(e.message ?? 'Kimlik doğrulama hatası.'));
    } on AppException catch (e) {
      return (null, ServerFailure(e.message));
    } catch (_) {
      return (null, const UnexpectedFailure());
    }
  }

  Future<void> signOut() async {
    await _auth.signOut();
  }

  /// Kullanıcı ilk girişinde Firestore'da document oluşturur, varsa dokunmaz.
  Future<AppUser> _ensureUserDocument(User firebaseUser) async {
    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      final newUser = AppUser(
        uid: firebaseUser.uid,
        email: firebaseUser.email ?? '',
        displayName: firebaseUser.displayName ?? 'Kullanıcı',
        photoURL: firebaseUser.photoURL,
        role: UserRole.user,
        createdAt: DateTime.now(),
      );
      await docRef.set(newUser.toFirestore());
      return newUser;
    }

    return AppUser.fromFirestore(doc.data()!, doc.id);
  }
}
