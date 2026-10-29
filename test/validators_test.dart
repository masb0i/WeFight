import 'package:flutter_test/flutter_test.dart';

import 'package:wefight/core/constants/app_strings.dart';
import 'package:wefight/core/utils/validators.dart';

/// Unit test `Validators` (M15-2).
///
/// Rentang berat 30–200 kg adalah asumsi yang ditandai di worksheet
/// (`docs/PLAN.md` §3 poin 2). Batas bawah dan batas atas diuji **inklusif**,
/// karena salah satu kesalahan paling mudah terjadi adalah menulis `< 30`
/// padahal seharusnya `<= 30`.
void main() {
  group('Validators.berat', () {
    test('kosong ditolak', () {
      expect(Validators.berat(null), AppStrings.validasiBeratKosong);
      expect(Validators.berat(''), AppStrings.validasiBeratKosong);
      expect(Validators.berat('   '), AppStrings.validasiBeratKosong);
    });

    test('bukan angka ditolak', () {
      expect(Validators.berat('abc'), AppStrings.validasiBeratAngka);
      expect(Validators.berat('73kg'), AppStrings.validasiBeratAngka);
      expect(Validators.berat('7.3.6'), AppStrings.validasiBeratAngka);
    });

    test('di bawah 30 kg ditolak', () {
      expect(Validators.berat('29.9'), AppStrings.validasiBeratRentang);
      expect(Validators.berat('0'), AppStrings.validasiBeratRentang);
      expect(Validators.berat('-5'), AppStrings.validasiBeratRentang);
    });

    test('di atas 200 kg ditolak', () {
      expect(Validators.berat('200.1'), AppStrings.validasiBeratRentang);
      expect(Validators.berat('250'), AppStrings.validasiBeratRentang);
    });

    test('batas 30 dan 200 diterima (inklusif)', () {
      expect(Validators.berat('30'), isNull);
      expect(Validators.berat('200'), isNull);
    });

    test('nilai di tengah rentang diterima', () {
      expect(Validators.berat('73.6'), isNull);
      expect(Validators.berat('73'), isNull);
    });

    test('koma desimal diterima seperti titik', () {
      expect(Validators.berat('71,5'), isNull);
      expect(Validators.berat('29,9'), AppStrings.validasiBeratRentang);
    });

    test('spasi di awal dan akhir dibuang', () {
      expect(Validators.berat(' 73,6 '), isNull);
      expect(Validators.berat('  '), AppStrings.validasiBeratKosong);
    });
  });

  group('Validators.batasBeratOpsional', () {
    test('kosong dianggap sah (target boleh kosong)', () {
      expect(Validators.batasBeratOpsional(null), isNull);
      expect(Validators.batasBeratOpsional(''), isNull);
      expect(Validators.batasBeratOpsional('  '), isNull);
    });

    test('kalau diisi, aturannya sama dengan berat badan', () {
      expect(Validators.batasBeratOpsional('71'), isNull);
      expect(Validators.batasBeratOpsional('250'), AppStrings.validasiBeratRentang);
      expect(Validators.batasBeratOpsional('abc'), AppStrings.validasiBeratAngka);
    });
  });

  group('Validators.email', () {
    test('kosong ditolak', () {
      expect(Validators.email(null), AppStrings.validasiEmailKosong);
      expect(Validators.email('  '), AppStrings.validasiEmailKosong);
    });

    test('format salah ditolak', () {
      expect(Validators.email('bukan-email'), AppStrings.validasiEmailFormat);
      expect(Validators.email('a@b'), AppStrings.validasiEmailFormat);
      expect(Validators.email('@b.com'), AppStrings.validasiEmailFormat);
    });

    test('format benar diterima', () {
      expect(Validators.email('fighter@wefight.demo'), isNull);
      expect(Validators.email(' a@b.com '), isNull);
    });
  });

  group('Validators.kataSandi', () {
    test('kosong ditolak', () {
      expect(Validators.kataSandi(null), AppStrings.validasiSandiKosong);
      expect(Validators.kataSandi(''), AppStrings.validasiSandiKosong);
    });

    test('kurang dari 6 karakter ditolak', () {
      expect(Validators.kataSandi('12345'), AppStrings.validasiSandiPendek);
    });

    test('6 karakter atau lebih diterima', () {
      expect(Validators.kataSandi('123456'), isNull);
      expect(Validators.kataSandi('wefight123'), isNull);
    });
  });

  group('Validators.nama', () {
    test('kosong atau spasi saja ditolak', () {
      expect(Validators.nama(null), AppStrings.validasiNamaKosong);
      expect(Validators.nama('   '), AppStrings.validasiNamaKosong);
    });

    test('nama berisi diterima', () {
      expect(Validators.nama('Rasyid'), isNull);
    });
  });

  group('Validators.konfirmasiKataSandi', () {
    test('kosong ditolak', () {
      expect(
        Validators.konfirmasiKataSandi('', 'wefight123'),
        AppStrings.validasiSandiKosong,
      );
    });

    test('berbeda ditolak', () {
      expect(
        Validators.konfirmasiKataSandi('wefight124', 'wefight123'),
        AppStrings.validasiSandiBeda,
      );
    });

    test('sama diterima', () {
      expect(Validators.konfirmasiKataSandi('wefight123', 'wefight123'), isNull);
    });
  });
}
