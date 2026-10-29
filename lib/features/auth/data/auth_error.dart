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
      'too-many-requests' => 'Terlalu banyak percobaan. Tunggu sebentar.',
      'operation-not-allowed' =>
        'Metode masuk belum diaktifkan di Firebase Console.',
      _ => AppStrings.authUmum,
    };
  }
  return AppStrings.authUmum;
}
