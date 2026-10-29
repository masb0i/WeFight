import 'package:cloud_firestore/cloud_firestore.dart';

/// Profil pengguna — isi dokumen `users/{uid}` (PLAN §1.3).
///
/// Nama untuk sapaan Dashboard tetap dibaca dari `displayName` Firebase Auth
/// (tanpa pembacaan Firestore tambahan). Dokumen ini ditulis sekali saat
/// Daftar supaya skema data sesuai worksheet dan aturan keamanan punya
/// contoh koleksi milik pengguna.
class UserProfile {
  const UserProfile({
    required this.uid,
    required this.nama,
    required this.email,
    this.dibuatPada,
  });

  final String uid;
  final String nama;
  final String email;
  final DateTime? dibuatPada;

  factory UserProfile.fromMap(String uid, Map<String, dynamic>? data) {
    return UserProfile(
      uid: uid,
      nama: (data?['nama'] as String?)?.trim() ?? '',
      email: (data?['email'] as String?)?.trim() ?? '',
      dibuatPada: switch (data?['dibuatPada']) {
        final Timestamp t => t.toDate(),
        final DateTime d => d,
        _ => null,
      },
    );
  }

  Map<String, dynamic> toMap() => {
        'uid': uid,
        'nama': nama,
        'email': email,
        'dibuatPada': dibuatPada == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(dibuatPada!),
      };
}
