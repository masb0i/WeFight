import '../constants/app_strings.dart';

/// Validator form.
///
/// Aturan validasi berat badan (30–200 kg) sengaja ditaruh di sini sejak awal
/// karena dipakai bersama oleh Catat Berat dan Target Timbang — lihat
/// `docs/PLAN.md` §3 poin 2.
abstract final class Validators {
  static final _emailPattern = RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w.\-]+$');

  static String? email(String? value) {
    final v = value?.trim() ?? '';
    if (v.isEmpty) return AppStrings.validasiEmailKosong;
    if (!_emailPattern.hasMatch(v)) return AppStrings.validasiEmailFormat;
    return null;
  }

  static String? kataSandi(String? value) {
    final v = value ?? '';
    if (v.isEmpty) return AppStrings.validasiSandiKosong;
    if (v.length < 6) return AppStrings.validasiSandiPendek;
    return null;
  }

  static String? nama(String? value) {
    if ((value ?? '').trim().isEmpty) return AppStrings.validasiNamaKosong;
    return null;
  }

  static String? konfirmasiKataSandi(String? value, String asli) {
    if ((value ?? '').isEmpty) return AppStrings.validasiSandiKosong;
    if (value != asli) return AppStrings.validasiSandiBeda;
    return null;
  }
}
