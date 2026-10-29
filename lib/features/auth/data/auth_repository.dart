import 'package:firebase_auth/firebase_auth.dart';

/// Kontrak autentikasi.
///
/// Dibuat sebagai interface supaya layar dan guard router bisa diuji tanpa
/// Firebase. Implementasi nyata: [FirebaseAuthRepository].
abstract interface class AuthRepository {
  /// Perubahan status sesi (masuk / keluar).
  Stream<User?> get authStateChanges;

  /// Status saat ini, dibaca sinkron oleh guard router.
  bool get isSignedIn;

  /// uid pengguna yang sedang masuk, null bila belum masuk.
  String? get currentUid;

  Future<void> signIn({required String email, required String password});

  Future<void> signUp({
    required String nama,
    required String email,
    required String password,
  });

  Future<void> signOut();

  /// Untuk fitur Should "lupa kata sandi" (K8).
  Future<void> sendPasswordReset(String email);
}

/// Implementasi memakai Firebase Authentication.
class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(this._auth);

  final FirebaseAuth _auth;

  @override
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  @override
  bool get isSignedIn => _auth.currentUser != null;

  @override
  String? get currentUid => _auth.currentUser?.uid;

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  @override
  Future<void> signUp({
    required String nama,
    required String email,
    required String password,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
    // Nama disimpan di profil Auth; dokumen users/{uid} ditulis oleh layar
    // Daftar lewat UserRepository (lihat M8 di docs/PLAN.md §8).
    final trimmedName = nama.trim();
    if (trimmedName.isNotEmpty) {
      await credential.user?.updateDisplayName(trimmedName);
      await credential.user?.reload();
    }
  }

  @override
  Future<void> signOut() => _auth.signOut();

  @override
  Future<void> sendPasswordReset(String email) {
    return _auth.sendPasswordResetEmail(email: email.trim());
  }
}
