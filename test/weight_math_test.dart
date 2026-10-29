import 'package:flutter_test/flutter_test.dart';

import 'package:wefight/core/constants/app_strings.dart';
import 'package:wefight/core/utils/weight_math.dart';

/// Unit test `WeightMath` (M12-1, M15-1).
///
/// Semua kasus diambil langsung dari `docs/PLAN.md` §3 poin 4–5, supaya kalau
/// aturan bisnis berubah, test ini yang lebih dulu gagal.
void main() {
  group('WeightMath.hitungSelisih', () {
    test('berat di atas batas menghasilkan nilai positif', () {
      expect(
        WeightMath.hitungSelisih(beratTerakhir: 73.6, batasBerat: 71),
        2.6,
      );
    });

    test('berat di bawah batas menghasilkan nilai negatif', () {
      expect(
        WeightMath.hitungSelisih(beratTerakhir: 70, batasBerat: 71),
        -1,
      );
    });

    test('berat tepat di batas menghasilkan nol', () {
      expect(
        WeightMath.hitungSelisih(beratTerakhir: 71, batasBerat: 71),
        0,
      );
    });

    test('dibulatkan ke satu desimal, bukan sisa floating point', () {
      // 73,4 − 73 pada double menghasilkan 0.3999999999999986.
      expect(
        WeightMath.hitungSelisih(beratTerakhir: 73.4, batasBerat: 73),
        0.4,
      );
    });

    test('selisih di bawah 0,05 dibulatkan menjadi tepat di batas', () {
      expect(
        WeightMath.hitungSelisih(beratTerakhir: 71.04, batasBerat: 71),
        0,
      );
    });
  });

  group('WeightMath.labelSelisih', () {
    test('positif memakai "di atas batas"', () {
      expect(WeightMath.labelSelisih(2.6), '2.6 kg di atas batas');
    });

    test('negatif memakai "di bawah batas" tanpa tanda minus', () {
      expect(WeightMath.labelSelisih(-1), '1 kg di bawah batas');
    });

    test('nol memakai "Tepat di batas"', () {
      expect(WeightMath.labelSelisih(0), AppStrings.selisihTepat);
    });

    test('nilai bulat tidak menampilkan desimal', () {
      expect(WeightMath.labelSelisih(3), '3 kg di atas batas');
    });
  });

  group('WeightMath.hitungSisaHari', () {
    final acuan = DateTime(2026, 10, 29);

    test('hari ini menghasilkan nol', () {
      expect(
        WeightMath.hitungSisaHari(DateTime(2026, 10, 29), hariIni: acuan),
        0,
      );
    });

    test('tanggal yang sudah lewat menghasilkan negatif', () {
      expect(
        WeightMath.hitungSisaHari(DateTime(2026, 10, 26), hariIni: acuan),
        -3,
      );
    });

    test('tanggal mendatang menghasilkan positif', () {
      expect(
        WeightMath.hitungSisaHari(DateTime(2026, 11, 12), hariIni: acuan),
        14,
      );
    });
  });

  group('WeightMath.labelHitungMundur', () {
    test('nol berarti hari ini', () {
      expect(
        WeightMath.labelHitungMundur(0),
        AppStrings.hitungMundurHariIni,
      );
    });

    test('negatif berarti terlewat, tanpa tanda minus', () {
      expect(WeightMath.labelHitungMundur(-3), 'Hari timbang terlewat 3 hari');
    });

    test('positif berarti masih ada sisa hari', () {
      expect(WeightMath.labelHitungMundur(14), '14 hari lagi');
    });

    test('satu hari tetap memakai kata "hari"', () {
      expect(WeightMath.labelHitungMundur(1), '1 hari lagi');
    });
  });

  group('WeightMath.labelPerubahan', () {
    test('naik diberi tanda plus', () {
      expect(
        WeightMath.hitungPerubahan(berat: 74, beratSebelumnya: 73.6),
        0.4,
      );
      expect(WeightMath.labelPerubahan(0.4), '+0.4 kg');
    });

    test('turun memakai tanda minus, bukan kata', () {
      expect(WeightMath.labelPerubahan(-0.7), '-0.7 kg');
    });

    test('tidak berubah memakai "Tetap"', () {
      expect(WeightMath.labelPerubahan(0), AppStrings.perubahanTetap);
    });
  });
}
