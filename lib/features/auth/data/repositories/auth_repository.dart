import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import 'package:mobile/core/network/firebase_providers.dart';
import 'package:mobile/core/utils/result.dart';
import 'package:mobile/features/auth/data/exceptions/auth_exceptions.dart';
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

  // ── Public API ──────────────────────────────────────────────────────────────

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Firestore'dan AppUser stream — currentUserProvider tarafından kullanılır.
  Stream<AppUser?> watchUser(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) =>
            doc.exists ? AppUser.fromFirestore(doc.data()!, doc.id) : null);
  }

  Future<Result<AppUser, AuthFailure>> signInWithEmailPassword(
    String email,
    String password,
  ) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final appUser = await _ensureUserDocument(credential.user!);
      return Ok(appUser);
    } on FirebaseAuthException catch (e) {
      return Err(mapFirebaseAuthCode(e.code, e.message));
    } catch (_) {
      return const Err(UnknownAuthFailure());
    }
  }

  Future<Result<AppUser, AuthFailure>> signUpWithEmailPassword({
    required String email,
    required String password,
    required String displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      await credential.user!.updateDisplayName(displayName.trim());
      final appUser = await _createUserDocument(
        credential.user!,
        displayName: displayName.trim(),
      );
      return Ok(appUser);
    } on FirebaseAuthException catch (e) {
      return Err(mapFirebaseAuthCode(e.code, e.message));
    } catch (_) {
      return const Err(UnknownAuthFailure());
    }
  }

  Future<Result<AppUser, AuthFailure>> signInWithGoogle() async {
    try {
      final googleUser = await GoogleSignIn.instance.authenticate();
      final googleAuth = googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);
      final appUser = await _ensureUserDocument(userCredential.user!);
      return Ok(appUser);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        return const Err(CancelledAuthFailure());
      }
      return const Err(UnknownAuthFailure());
    } on FirebaseAuthException catch (e) {
      return Err(mapFirebaseAuthCode(e.code, e.message));
    } catch (_) {
      return const Err(UnknownAuthFailure());
    }
  }

  Future<Result<void, AuthFailure>> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return const Ok(null);
    } on FirebaseAuthException catch (e) {
      return Err(mapFirebaseAuthCode(e.code, e.message));
    } catch (_) {
      return const Err(UnknownAuthFailure());
    }
  }

  Future<Result<AppUser, AuthFailure>> updateProfile(AppUser user) async {
    try {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .update(user.toFirestore());
      return Ok(user);
    } catch (_) {
      return const Err(UnknownAuthFailure('Profil güncellenemedi.'));
    }
  }

  Future<void> signOut() async {
    await Future.wait([
      _auth.signOut(),
      GoogleSignIn.instance.signOut(),
    ]);
  }

  // ── Private Helpers ─────────────────────────────────────────────────────────

  /// İlk girişte Firestore document oluşturur, varsa mevcut veriyi döner.
  Future<AppUser> _ensureUserDocument(User firebaseUser) async {
    final docRef = _firestore.collection('users').doc(firebaseUser.uid);
    final doc = await docRef.get();

    if (!doc.exists) {
      return _createUserDocument(firebaseUser);
    }
    return AppUser.fromFirestore(doc.data()!, doc.id);
  }

  Future<AppUser> _createUserDocument(
    User firebaseUser, {
    String? displayName,
  }) async {
    final newUser = AppUser(
      uid: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: displayName ??
          firebaseUser.displayName ??
          firebaseUser.email?.split('@').first ??
          'Kullanıcı',
      photoURL: firebaseUser.photoURL,
      role: UserRole.user,
      createdAt: DateTime.now(),
    );
    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set(newUser.toFirestore());
    return newUser;
  }
}
