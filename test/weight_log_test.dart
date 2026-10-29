import 'package:flutter_test/flutter_test.dart';

import 'package:wefight/features/weight_log/data/weight_log_repository.dart';
import 'package:wefight/features/weight_log/models/weight_log.dart';

/// Unit test pengurutan catatan (D24).
///
/// Sejak query Firestore tidak lagi memakai `orderBy('tanggal')` — kombinasi
/// `where('uid') + orderBy('tanggal')` menuntut indeks komposit yang harus
/// dibuat manual dan kegagalannya tampil sebagai "tidak ada koneksi" — urutan
/// daftar sepenuhnya ditentukan oleh `urutkanTerbaruDulu`. Fungsi inilah yang
/// harus dijaga, karena Dashboard mengambil `logs.first` sebagai "berat
/// terakhir" dan grafik tren menggambar dari urutan yang sama.
void main() {
  WeightLog log({
    required String id,
    required String tanggal,
    double berat = 70,
  }) {
    return WeightLog(id: id, tanggal: DateTime.parse(tanggal), berat: berat);
  }

  group('urutkanTerbaruDulu', () {
    test('daftar kosong tetap kosong', () {
      expect(urutkanTerbaruDulu(const <WeightLog>[]), isEmpty);
    });

    test('satu catatan tidak berubah', () {
      final satu = log(id: 'a', tanggal: '2026-10-29');
      expect(urutkanTerbaruDulu([satu]).single.id, 'a');
    });

    test('tanggal terbaru berada di depan', () {
      final hasil = urutkanTerbaruDulu([
        log(id: 'a', tanggal: '2026-10-01'),
        log(id: 'b', tanggal: '2026-10-29'),
        log(id: 'c', tanggal: '2026-10-15'),
      ]);

      expect(hasil.map((e) => e.id), ['b', 'c', 'a']);
    });

    test('urutan kronologis benar walau tanggal beda tahun', () {
      final hasil = urutkanTerbaruDulu([
        log(id: 'lama', tanggal: '2025-12-31'),
        log(id: 'baru', tanggal: '2026-01-01'),
      ]);

      expect(hasil.first.id, 'baru');
    });

    test('tanggal sama diurutkan menurut id agar hasilnya tetap', () {
      final hasil = urutkanTerbaruDulu([
        log(id: 'a', tanggal: '2026-10-29'),
        log(id: 'c', tanggal: '2026-10-29'),
        log(id: 'b', tanggal: '2026-10-29'),
      ]);

      expect(hasil.map((e) => e.id), ['c', 'b', 'a']);
    });

    test('daftar masukan tidak diubah', () {
      final masukan = [
        log(id: 'a', tanggal: '2026-10-01'),
        log(id: 'b', tanggal: '2026-10-29'),
      ];
      urutkanTerbaruDulu(masukan);

      expect(masukan.map((e) => e.id), ['a', 'b']);
    });

    test('hasil tidak bisa diubah pemanggil', () {
      final hasil = urutkanTerbaruDulu([log(id: 'a', tanggal: '2026-10-29')]);

      expect(
        () => hasil.add(log(id: 'b', tanggal: '2026-10-30')),
        throwsUnsupportedError,
      );
    });

    test('berat terakhir diambil dari tanggal terbaru, bukan id terbesar', () {
      // Kasus yang mudah salah: dokumen yang baru dibuat bisa punya tanggal
      // lampau (pengguna mencatat mundur), jadi "terakhir" harus dari tanggal.
      final hasil = urutkanTerbaruDulu([
        log(id: 'zzz', tanggal: '2026-09-01', berat: 80),
        log(id: 'aaa', tanggal: '2026-10-29', berat: 73.6),
      ]);

      expect(hasil.first.berat, 73.6);
    });
  });
}
