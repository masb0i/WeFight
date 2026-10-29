import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/user_profile.dart';

/// Akses data profil pengguna (`users/{uid}`).
///
/// Dipanggil sekali saat Daftar. Kalau penulisan gagal, pendaftaran tetap
/// dianggap berhasil — akun Auth sudah ada dan aplikasi masih bisa dipakai
/// karena nama dibaca dari `displayName`.
abstract interface class UserRepository {
  Future<void> simpanProfil(UserProfile profil);

  Future<UserProfile?> ambil(String uid);
}

class FirestoreUserRepository implements UserRepository {
  FirestoreUserRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  @override
  Future<void> simpanProfil(UserProfile profil) {
    // merge: true supaya mendaftar ulang / login tidak menghapus field lain.
    return _users.doc(profil.uid).set(profil.toMap(), SetOptions(merge: true));
  }

  @override
  Future<UserProfile?> ambil(String uid) async {
    final snapshot = await _users.doc(uid).get();
    if (!snapshot.exists) return null;
    return UserProfile.fromMap(uid, snapshot.data());
  }
}
