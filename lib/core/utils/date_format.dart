import 'package:intl/intl.dart';

/// Utilitas tanggal WeFight.
///
/// Keputusan **D4** (`docs/PLAN.md` §5): tanggal disimpan sebagai `String`
/// berformat `yyyy-MM-dd` tanpa komponen jam. Alasannya, aturan bisnis
/// "satu catatan per tanggal" (§3 poin 1) butuh perbandingan yang pasti —
/// `Timestamp` Firestore menyimpan jam sehingga dua catatan di hari yang sama
/// akan dianggap berbeda.
///
/// Karena itu semua perbandingan tanggal di aplikasi memakai *kunci*
/// (`keKunci`) dan bukan `DateTime` mentah.
abstract final class AppDate {
  static final DateFormat _iso = DateFormat('yyyy-MM-dd');

  static const _namaBulan = <String>[
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];

  static const _namaBulanSingkat = <String>[
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Membuang komponen jam/menit/detik.
  static DateTime tanpaJam(DateTime nilai) =>
      DateTime(nilai.year, nilai.month, nilai.day);

  /// Tanggal hari ini tanpa komponen jam.
  static DateTime hariIni() => tanpaJam(DateTime.now());

  /// Kunci penyimpanan Firestore, misalnya `2026-10-29`.
  static String keKunci(DateTime tanggal) => _iso.format(tanpaJam(tanggal));

  /// Membaca kembali kunci `yyyy-MM-dd`. Null bila kosong atau rusak.
  static DateTime? dariKunci(Object? nilai) {
    if (nilai is! String || nilai.isEmpty) return null;
    try {
      return tanpaJam(_iso.parseStrict(nilai));
    } on FormatException {
      return null;
    }
  }

  /// Selisih hari `a - b`, dihitung pada tengah malam UTC supaya bebas
  /// dari pergeseran zona waktu / daylight saving.
  static int selisihHari(DateTime a, DateTime b) => DateTime.utc(a.year, a.month, a.day)
      .difference(DateTime.utc(b.year, b.month, b.day))
      .inDays;

  /// `29 Oktober 2026`
  static String panjang(DateTime tanggal) =>
      '${tanggal.day} ${_namaBulan[tanggal.month - 1]} ${tanggal.year}';

  /// `29 Okt 2026` — untuk label sumbu grafik dan baris riwayat.
  static String pendek(DateTime tanggal) =>
      '${tanggal.day} ${_namaBulanSingkat[tanggal.month - 1]} ${tanggal.year}';

  /// `Hari ini`, `Kemarin`, `Besok`, atau tanggal pendek.
  ///
  /// Selisih dihitung `tanggal - acuan`, jadi tanggal kemarin menghasilkan
  /// **-1** dan besok **+1**.
  static String relatif(DateTime tanggal, {DateTime? acuan}) {
    final selisih = selisihHari(tanggal, acuan ?? hariIni());
    return switch (selisih) {
      0 => 'Hari ini',
      -1 => 'Kemarin',
      1 => 'Besok',
      _ => pendek(tanggal),
    };
  }
}
