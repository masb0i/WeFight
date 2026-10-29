// Alat bantu (bukan bagian aplikasi): mengisi data simulasi ke Firestore.
//
//   dart run tool/seed_demo.dart
//   dart run tool/seed_demo.dart --email=fighter@wefight.demo --password=wefight123
//   dart run tool/seed_demo.dart --bersihkan     # + hapus catatan di luar data demo
//
// Kenapa lewat REST dan bukan SDK Firestore:
//  * SDK butuh konteks Flutter, skrip ini cukup `dart run`.
//  * Firebase Admin SDK butuh service account (berkas rahasia) — tidak dipakai
//    di proyek ini karena hanya Spark plan.
//
// Skrip ini idempoten: document id tetap, jadi menjalankannya dua kali
// menimpa data demo yang sama, bukan membuat duplikat.

import 'dart:io';

import 'firebase_rest.dart';

const _defaultEmail = 'fighter@wefight.demo';
const _defaultPassword = 'wefight123';
const _defaultNama = 'Fighter Demo';

/// Batas berat & jarak hari timbang untuk akun demo.
const _batasBerat = 71.0;
const _hariMenujuTimbang = 14;

/// Enam catatan berat: tren turun 76,4 → 73,6 kg dalam 4 minggu.
const _polaCatatan = <({int mundur, double berat, String? catatan})>[
  (mundur: 28, berat: 76.4, catatan: 'Awal program'),
  (mundur: 21, berat: 75.8, catatan: null),
  (mundur: 14, berat: 75.1, catatan: 'Latihan pagi'),
  (mundur: 7, berat: 74.3, catatan: null),
  (mundur: 3, berat: 73.9, catatan: 'Hampir di batas'),
  (mundur: 0, berat: 73.6, catatan: 'Timbang pagi'),
];

Future<void> main(List<String> args) async {
  final opsi = _bacaArgumen(args);
  final config = bacaKonfigurasi();
  final api = FirebaseRest(config);

  stdout.writeln('WeFight — isi data simulasi');
  stdout.writeln('  proyek : ${config.projectId}');
  stdout.writeln('  akun   : ${opsi.email}');
  stdout.writeln('');

  try {
    final sesi = await api.masukAtauDaftar(
      email: opsi.email,
      password: opsi.password,
      nama: _defaultNama,
    );
    stdout.writeln('  uid    : ${sesi.uid}');

    final sekarang = DateTime.now();
    final hariIni = DateTime(sekarang.year, sekarang.month, sekarang.day);
    final tanggalTimbang = hariIni.add(const Duration(days: _hariMenujuTimbang));

    await api.tulisDokumen(
      path: 'users/${sesi.uid}',
      idToken: sesi.idToken,
      fields: {
        'uid': fieldTeks(sesi.uid),
        'nama': fieldTeks(_defaultNama),
        'email': fieldTeks(opsi.email),
        'dibuatPada': fieldWaktu(hariIni),
      },
    );
    stdout.writeln('  users/${sesi.uid} ... ok');

    await api.tulisDokumen(
      path: 'targets/${sesi.uid}',
      idToken: sesi.idToken,
      fields: {
        'batasBerat': fieldAngka(_batasBerat),
        'tanggalTimbang': fieldTeks(kunciTanggal(tanggalTimbang)),
        'diperbaruiPada': fieldWaktu(hariIni),
      },
    );
    stdout.writeln('  targets/${sesi.uid} ... ok '
        '($_batasBerat kg, timbang ${kunciTanggal(tanggalTimbang)})');

    final prefix = sesi.uid.substring(0, 8);
    for (var i = 0; i < _polaCatatan.length; i++) {
      final pola = _polaCatatan[i];
      final tanggal = hariIni.subtract(Duration(days: pola.mundur));
      final id = '$prefix-demo-${(i + 1).toString().padLeft(2, '0')}';

      await api.tulisDokumen(
        path: 'weightLogs/$id',
        idToken: sesi.idToken,
        fields: {
          'uid': fieldTeks(sesi.uid),
          'tanggal': fieldTeks(kunciTanggal(tanggal)),
          'berat': fieldAngka(pola.berat),
          'catatan':
              pola.catatan == null ? fieldKosong() : fieldTeks(pola.catatan!),
          'dibuatPada': fieldWaktu(tanggal),
          'diperbaruiPada': fieldWaktu(hariIni),
        },
      );
      stdout.writeln('  weightLogs/$id ... ok '
          '(${kunciTanggal(tanggal)}, ${pola.berat} kg)');
    }

    // `--bersihkan` menghapus catatan yang bukan bagian dari data demo.
    //
    // Berguna sebelum demo UAS: sisa uji coba manual (mis. catatan yang
    // ditambahkan lewat aplikasi) bisa membuat dua catatan pada tanggal yang
    // sama, sehingga Riwayat tampak dobel dan Dashboard memilih angka yang
    // salah. Default TIDAK menghapus apa pun.
    if (opsi.bersihkan) {
      final semua = await api.kueri(
        koleksi: 'weightLogs',
        field: 'uid',
        nilai: sesi.uid,
        idToken: sesi.idToken,
      );
      final idDemo = {
        for (var i = 0; i < _polaCatatan.length; i++)
          '$prefix-demo-${(i + 1).toString().padLeft(2, '0')}',
      };
      var dihapus = 0;
      for (final dokumen in semua) {
        final nama = (dokumen['name'] as String?) ?? '';
        final id = nama.split('/').last;
        if (idDemo.contains(id)) continue;
        await api.hapusDokumen(
          path: 'weightLogs/$id',
          idToken: sesi.idToken,
        );
        stdout.writeln('  hapus weightLogs/$id ... ok (bukan data demo)');
        dihapus++;
      }
      stdout.writeln(dihapus == 0
          ? '  tidak ada catatan di luar data demo.'
          : '  $dihapus catatan di luar data demo dihapus.');
    }

    stdout.writeln('');
    stdout.writeln('Selesai. Masuk ke aplikasi dengan:');
    stdout.writeln('  email     : ${opsi.email}');
    stdout.writeln('  kata sandi: ${opsi.password}');
  } on ApiException catch (e) {
    stderr.writeln('');
    stderr.writeln('GAGAL: ${e.pesan}');
    stderr.writeln(_petunjuk(e));
    exitCode = 1;
  }
}

/// Petunjuk perbaikan berdasarkan kode galat Firebase.
String _petunjuk(ApiException e) {
  return switch (e.kode) {
    'EMAIL_NOT_FOUND' || 'INVALID_LOGIN_CREDENTIALS' =>
      'Periksa email/kata sandi akun demo.',
    'OPERATION_NOT_ALLOWED' =>
      'Aktifkan penyedia Email/Password di Firebase Console → Authentication.',
    'PERMISSION_DENIED' =>
      'Aturan Firestore menolak. Jalankan '
          '`firebase deploy --only firestore:rules` lebih dulu.',
    'API_KEY_INVALID' =>
      'API key di lib/firebase_options.dart tidak valid untuk proyek ini.',
    _ => 'Cek pesan di atas; jalankan ulang setelah diperbaiki.',
  };
}

({String email, String password, bool bersihkan}) _bacaArgumen(List<String> args) {
  var email = _defaultEmail;
  var password = _defaultPassword;
  var bersihkan = false;
  for (final arg in args) {
    if (arg.startsWith('--email=')) email = arg.substring(8);
    if (arg.startsWith('--password=')) password = arg.substring(11);
    if (arg == '--bersihkan') bersihkan = true;
  }
  return (email: email, password: password, bersihkan: bersihkan);
}
