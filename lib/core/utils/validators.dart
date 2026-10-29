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

  /// Berat badan: wajib, angka, 30–200 kg (asumsi yang ditandai di worksheet,
  /// PLAN §3 poin 2).
  ///
  /// Koma desimal diterima karena pengguna Indonesia mengetik `71,5`.
  static String? berat(String? value) {
    final teks = (value ?? '').trim().replaceAll(',', '.');
    if (teks.isEmpty) return AppStrings.validasiBeratKosong;

    final angka = double.tryParse(teks);
    if (angka == null) return AppStrings.validasiBeratAngka;
    if (angka < 30 || angka > 200) return AppStrings.validasiBeratRentang;
    return null;
  }

  /// Batas berat target: **boleh kosong** (PLAN §3 poin 3). Kalau diisi,
  /// aturannya sama dengan berat badan — target adalah berat juga.
  static String? batasBeratOpsional(String? value) {
    if ((value ?? '').trim().isEmpty) return null;
    return berat(value);
  }
}
