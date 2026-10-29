import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:wefight/core/utils/date_format.dart';
import 'package:wefight/features/profile/models/user_profile.dart';
import 'package:wefight/features/target/models/target.dart';
import 'package:wefight/features/weight_log/models/weight_log.dart';

/// Test lapisan data M8: konversi model ↔ Firestore dan utilitas tanggal.
///
/// Tidak menyentuh Firebase sama sekali — cukup `Map` biasa, jadi bisa jalan
/// di `flutter test` tanpa emulator maupun kredensial.
void main() {
  group('AppDate', () {
    test('kunci tanggal berformat yyyy-MM-dd dan membuang jam', () {
      expect(AppDate.keKunci(DateTime(2026, 1, 5, 23, 59)), '2026-01-05');
      expect(AppDate.keKunci(DateTime(2026, 10, 29)), '2026-10-29');
    });

    test('dariKunci mengembalikan null untuk nilai kosong atau rusak', () {
      expect(AppDate.dariKunci(null), isNull);
      expect(AppDate.dariKunci(''), isNull);
      expect(AppDate.dariKunci('29-10-2026'), isNull);
      expect(AppDate.dariKunci('bukan tanggal'), isNull);
      expect(AppDate.dariKunci('2026-10-29'), DateTime(2026, 10, 29));
    });

    test('bolak-balik kunci tidak mengubah tanggal', () {
      final tanggal = DateTime(2026, 2, 28);
      expect(AppDate.dariKunci(AppDate.keKunci(tanggal)), tanggal);
    });

    test('selisihHari menghitung maju dan mundur', () {
      expect(
        AppDate.selisihHari(DateTime(2026, 10, 29), DateTime(2026, 10, 29)),
        0,
      );
      expect(
        AppDate.selisihHari(DateTime(2026, 10, 30), DateTime(2026, 10, 29)),
        1,
      );
      expect(
        AppDate.selisihHari(DateTime(2026, 10, 20), DateTime(2026, 10, 29)),
        -9,
      );
    });

    test('relatif memakai kata untuk hari ini dan kemarin', () {
      final acuan = DateTime(2026, 10, 29);
      expect(AppDate.relatif(DateTime(2026, 10, 29), acuan: acuan), 'Hari ini');
      expect(AppDate.relatif(DateTime(2026, 10, 28), acuan: acuan), 'Kemarin');
      expect(AppDate.relatif(DateTime(2026, 10, 1), acuan: acuan), '1 Okt 2026');
    });

    test('panjang memakai nama bulan Indonesia', () {
      expect(AppDate.panjang(DateTime(2026, 5, 1)), '1 Mei 2026');
      expect(AppDate.panjang(DateTime(2026, 12, 31)), '31 Desember 2026');
    });
  });

  group('Target', () {
    final diperbarui = DateTime(2026, 10, 29, 8, 30);

    test('dokumen kosong dianggap target kosong', () {
      expect(Target.fromMap(null).kosong, isTrue);
      expect(const Target().kosong, isTrue);
      expect(const Target().adaBatasBerat, isFalse);
    });

    test('toMap lalu fromMap mengembalikan nilai yang sama', () {
      final target = Target(
        batasBerat: 71.5,
        tanggalTimbang: DateTime(2026, 11, 12),
        diperbaruiPada: diperbarui,
      );

      final peta = target.toMap();
      expect(peta['batasBerat'], 71.5);
      expect(peta['tanggalTimbang'], '2026-11-12');
      expect(Target.fromMap(peta), target);
    });

    test('batas berat dibaca sebagai double walau tersimpan sebagai int', () {
      final target = Target.fromMap({'batasBerat': 71});
      expect(target.batasBerat, 71.0);
    });

    test('satu field boleh kosong', () {
      final hanyaBatas = Target.fromMap({'batasBerat': 70.0});
      expect(hanyaBatas.adaBatasBerat, isTrue);
      expect(hanyaBatas.adaTanggalTimbang, isFalse);
      expect(hanyaBatas.kosong, isFalse);
    });

    test('copyWith bisa mengosongkan satu field tanpa menyentuh yang lain', () {
      final target = Target(
        batasBerat: 70,
        tanggalTimbang: DateTime(2026, 11, 12),
      );

      final tanpaBatas = target.copyWith(hapusBatasBerat: true);
      expect(tanpaBatas.batasBerat, isNull);
      expect(tanpaBatas.tanggalTimbang, DateTime(2026, 11, 12));

      final tanpaTanggal = target.copyWith(hapusTanggalTimbang: true);
      expect(tanpaTanggal.batasBerat, 70);
      expect(tanpaTanggal.tanggalTimbang, isNull);
    });

    test('tanggal timbang tersimpan sebagai kunci, bukan Timestamp', () {
      final peta = Target(tanggalTimbang: DateTime(2026, 11, 12, 17, 5)).toMap();
      expect(peta['tanggalTimbang'], isA<String>());
      expect(peta['tanggalTimbang'], '2026-11-12');
    });
  });

  group('WeightLog', () {
    test('fromMap menolak dokumen tanpa tanggal atau berat', () {
      expect(WeightLog.fromMap('a', null), isNull);
      expect(WeightLog.fromMap('a', {'berat': 70.0}), isNull);
      expect(WeightLog.fromMap('a', {'tanggal': '2026-10-29'}), isNull);
    });

    test('toMap selalu menyertakan uid dan kunci tanggal', () {
      final log = WeightLog(
        tanggal: DateTime(2026, 10, 29, 6, 15),
        berat: 73.6,
        catatan: '  Timbang pagi  ',
      );

      final peta = log.toMap(uid: 'uid-a');
      expect(peta['uid'], 'uid-a');
      expect(peta['tanggal'], '2026-10-29');
      expect(peta['berat'], 73.6);
      expect(peta['catatan'], 'Timbang pagi');
    });

    test('catatan kosong disimpan sebagai null, bukan string kosong', () {
      final log = WeightLog(tanggal: DateTime(2026, 10, 29), berat: 73.6);
      expect(log.toMap(uid: 'u')['catatan'], isNull);
      expect(log.punyaCatatan, isFalse);

      final spasi = log.copyWith(catatan: '   ');
      expect(spasi.toMap(uid: 'u')['catatan'], isNull);
    });

    test('ubah tidak menimpa dibuatPada', () {
      final log = WeightLog(
        id: 'log-1',
        tanggal: DateTime(2026, 10, 29),
        berat: 73.6,
        dibuatPada: DateTime(2026, 10, 29),
      );

      expect(log.toMap(uid: 'u').containsKey('dibuatPada'), isTrue);
      expect(
        log.toMap(uid: 'u', sertakanDibuatPada: false).containsKey('dibuatPada'),
        isFalse,
      );
    });

    test('bolak-balik dokumen mempertahankan Timestamp Firestore', () {
      final dibuat = DateTime(2026, 10, 29, 6, 15);
      final peta = <String, dynamic>{
        'uid': 'uid-a',
        'tanggal': '2026-10-29',
        'berat': 73.6,
        'catatan': 'Timbang pagi',
        'dibuatPada': Timestamp.fromDate(dibuat),
        'diperbaruiPada': Timestamp.fromDate(dibuat),
      };

      final log = WeightLog.fromMap('log-1', peta);
      expect(log, isNotNull);
      expect(log!.id, 'log-1');
      expect(log.tanggal, DateTime(2026, 10, 29));
      expect(log.berat, 73.6);
      expect(log.catatan, 'Timbang pagi');
      expect(log.dibuatPada, dibuat);
      expect(log.tersimpan, isTrue);
    });

    test('copyWith hapusCatatan mengosongkan catatan', () {
      final log = WeightLog(
        tanggal: DateTime(2026, 10, 29),
        berat: 73.6,
        catatan: 'Timbang pagi',
      );

      expect(log.copyWith(hapusCatatan: true).catatan, isNull);
      expect(log.copyWith(berat: 73.2).berat, 73.2);
      expect(log.copyWith(berat: 73.2).catatan, 'Timbang pagi');
    });
  });

  group('UserProfile', () {
    test('toMap menyertakan uid, nama, dan email', () {
      final peta = const UserProfile(
        uid: 'uid-a',
        nama: 'Fighter Demo',
        email: 'fighter@wefight.demo',
      ).toMap();

      expect(peta['uid'], 'uid-a');
      expect(peta['nama'], 'Fighter Demo');
      expect(peta['email'], 'fighter@wefight.demo');
    });

    test('fromMap memberi string kosong bila field tidak ada', () {
      final profil = UserProfile.fromMap('uid-a', null);
      expect(profil.uid, 'uid-a');
      expect(profil.nama, '');
      expect(profil.email, '');
    });
  });
}
