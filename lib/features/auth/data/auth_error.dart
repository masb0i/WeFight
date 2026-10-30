import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/app_strings.dart';

/// Menerjemahkan kode galat Firebase menjadi kalimat yang bisa dimengerti
/// pengguna. Jangan pernah menampilkan `e.toString()` mentah ke layar.
String authErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'invalid-credential' ||
      'wrong-password' ||
      'user-not-found' ||
      'invalid-login-credentials' =>
        AppStrings.authEmailSalah,
      'email-already-in-use' => AppStrings.authEmailTerdaftar,
      'weak-password' => AppStrings.authSandiLemah,
      'invalid-email' => AppStrings.validasiEmailFormat,
      'network-request-failed' => AppStrings.authJaringan,
      'too-many-requests' => AppStrings.authTerlaluBanyak,
      'operation-not-allowed' =>
        'Metode masuk belum diaktifkan di Firebase Console.',
      _ => AppStrings.authUmum,
    };
  }
  return AppStrings.authUmum;
}

/// Pesan galat khusus pengiriman tautan atur ulang kata sandi (K8).
///
/// Dipisahkan dari [authErrorMessage] karena `user-not-found` di sini berarti
/// "email belum terdaftar", bukan "email atau kata sandi salah" — pada alur
/// ini tidak ada kata sandi yang sedang diperiksa.
///
/// Catatan: pesan ini memberi tahu apakah sebuah email terdaftar atau tidak.
/// Untuk aplikasi ini risikonya dapat diterima (aplikasi pribadi, satu peran,
/// tanpa data orang lain yang bisa diekspos). Bila kelak dibutuhkan, Firebase
/// punya opsi "Email enumeration protection" yang membuat Firebase sendiri
/// membalas sukses tanpa memberi tahu apakah email itu ada.
String passwordResetErrorMessage(Object error) {
  if (error is FirebaseAuthException) {
    return switch (error.code) {
      'user-not-found' => AppStrings.resetEmailBelumTerdaftar,
      'invalid-email' => AppStrings.validasiEmailFormat,
      'network-request-failed' => AppStrings.authJaringan,
      'too-many-requests' => AppStrings.authTerlaluBanyak,
      _ => AppStrings.authUmum,
    };
  }
  return AppStrings.authUmum;
}
