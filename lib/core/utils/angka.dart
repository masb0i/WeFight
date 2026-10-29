/// Pemformatan angka untuk tampilan.
///
/// Dipisah dari `date_format.dart` supaya aturan pembulatan hanya ada di satu
/// tempat. Angka disimpan sebagai `double`, tetapi pengguna tidak perlu melihat
/// `.0` pada nilai bulat.
abstract final class Angka {
  /// `71` → `"71"`, `71.5` → `"71.5"`, `73.64` → `"73.6"`.
  static String kg(double nilai) {
    if (nilai == nilai.roundToDouble()) return nilai.toStringAsFixed(0);
    return nilai.toStringAsFixed(1);
  }

  /// Membaca isian pengguna: koma desimal diterima (`73,6` → `73.6`).
  /// Null bila kosong atau bukan angka.
  static double? parseKg(String teks) {
    final bersih = teks.trim().replaceAll(',', '.');
    if (bersih.isEmpty) return null;
    return double.tryParse(bersih);
  }
}
