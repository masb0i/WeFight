import '../constants/app_strings.dart';
import 'angka.dart';
import 'date_format.dart';

/// Perhitungan Dashboard — dipisah dari widget supaya bisa diuji tanpa
/// membangun UI (M12-1, M15-1).
///
/// Semua aturan di sini berasal dari `docs/PLAN.md` §3:
///  * poin 4 — selisih = berat terakhir − batas berat, dengan tiga label
///  * poin 5 — hitung mundur = tanggal timbang − hari ini
///
/// Aplikasi **hanya menampilkan angka** (poin 9). Tidak ada kata seperti
/// "bagus", "terlalu berat", atau saran apa pun di sini.
abstract final class WeightMath {
  /// Selisih dibulatkan ke satu desimal karena berat dicatat dengan satu
  /// desimal — tanpa ini `73,6 − 71` menghasilkan `2.599999999999994`.
  static double _bulat1(double nilai) => (nilai * 10).roundToDouble() / 10;

  /// `berat terakhir − batas berat` (PLAN §3 poin 4).
  ///
  /// Positif berarti masih di atas batas, negatif berarti sudah di bawah.
  static double hitungSelisih({
    required double beratTerakhir,
    required double batasBerat,
  }) {
    return _bulat1(beratTerakhir - batasBerat);
  }

  /// Label selisih: `0,4 kg di atas batas` / `Tepat di batas` /
  /// `0,4 kg di bawah batas`.
  static String labelSelisih(double selisih) {
    final nilai = _bulat1(selisih);
    if (nilai == 0) return AppStrings.selisihTepat;

    final teks = Angka.kg(nilai.abs());
    return nilai > 0
        ? AppStrings.selisihAtas(teks)
        : AppStrings.selisihBawah(teks);
  }

  /// `tanggal timbang − hari ini` dalam hari (PLAN §3 poin 5).
  ///
  /// 0 = hari ini, negatif = sudah lewat.
  static int hitungSisaHari(DateTime tanggalTimbang, {DateTime? hariIni}) {
    return AppDate.selisihHari(tanggalTimbang, hariIni ?? AppDate.hariIni());
  }

  /// `Hari ini hari timbang` / `Hari timbang terlewat 3 hari` / `12 hari lagi`.
  static String labelHitungMundur(int sisaHari) {
    if (sisaHari == 0) return AppStrings.hitungMundurHariIni;
    if (sisaHari < 0) return AppStrings.hitungMundurLewat(-sisaHari);
    return AppStrings.hitungMundurLagi(sisaHari);
  }

  /// `berat catatan ini − berat catatan sebelumnya` (kolom "Perubahan").
  ///
  /// Positif berarti naik. Untuk catatan paling awal tidak ada pembanding,
  /// jadi hasilnya null dan kolomnya dikosongkan.
  static double hitungPerubahan({
    required double berat,
    required double beratSebelumnya,
  }) {
    return _bulat1(berat - beratSebelumnya);
  }

  /// `+0,4 kg` / `-0,4 kg` / `Tetap`. Tandanya selalu ikut ditulis supaya
  /// arah perubahan tidak bergantung pada warna saja (PLAN §3 poin 10).
  static String labelPerubahan(double perubahan) {
    final nilai = _bulat1(perubahan);
    if (nilai == 0) return AppStrings.perubahanTetap;

    final teks = Angka.kg(nilai.abs());
    return nilai > 0
        ? AppStrings.perubahanNaik(teks)
        : AppStrings.perubahanTurun(teks);
  }
}
