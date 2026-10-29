// Alat bantu (bukan bagian aplikasi): membuktikan aturan keamanan Firestore
// benar-benar mengisolasi data antar akun — checklist M8-4.
//
//   dart run tool/cek_isolasi.dart
//
// Membutuhkan dua akun:
//   A = akun demo (dibuat oleh tool/seed_demo.dart)
//   B = akun pembanding (dibuat otomatis oleh skrip ini)
//
// Keluar dengan kode 1 bila ada pemeriksaan yang gagal.

import 'dart:io';

import 'firebase_rest.dart';

const _emailA = 'fighter@wefight.demo';
const _emailB = 'rival@wefight.demo';
const _password = 'wefight123';

var _lulus = 0;
var _gagal = 0;

Future<void> main() async {
  final config = bacaKonfigurasi();
  final api = FirebaseRest(config);

  stdout.writeln('WeFight — cek isolasi data (M8-4)');
  stdout.writeln('  proyek : ${config.projectId}');
  stdout.writeln('');

  try {
    final a = await api.masuk(email: _emailA, password: _password);
    stdout.writeln('  akun A : $_emailA (${a.uid})');
    final b = await api.masukAtauDaftar(
      email: _emailB,
      password: _password,
      nama: 'Rival Demo',
    );
    stdout.writeln('  akun B : $_emailB (${b.uid})');
    stdout.writeln('');

    // 1. Akun A harus bisa membaca catatannya sendiri.
    final catatanA = await api.kueri(
      koleksi: 'weightLogs',
      field: 'uid',
      nilai: a.uid,
      idToken: a.idToken,
    );
    _periksa(
      'Akun A membaca catatannya sendiri',
      catatanA.isNotEmpty,
      '${catatanA.length} catatan',
      'kosong — jalankan tool/seed_demo.dart dulu',
    );

    // 2. Akun B tidak boleh membaca catatan akun A.
    _periksaTolak(
      'Akun B membaca catatan akun A',
      () => api.kueri(
        koleksi: 'weightLogs',
        field: 'uid',
        nilai: a.uid,
        idToken: b.idToken,
      ),
    );

    // 3. Akun B tidak boleh melihat satu pun dokumen milik akun A.
    //
    // Yang diuji adalah **tidak ada irisan** antara daftar A dan daftar B,
    // bukan "daftar B kosong". Akun B boleh saja punya catatan sendiri
    // (mis. sisa uji coba manual) tanpa berarti aturannya bocor.
    final catatanB = await api.kueri(
      koleksi: 'weightLogs',
      field: 'uid',
      nilai: b.uid,
      idToken: b.idToken,
    );
    final idA = catatanA.map(_idDokumen).toSet();
    final idB = catatanB.map(_idDokumen).toSet();
    final bocor = idB.intersection(idA);
    _periksa(
      'Akun B tidak melihat catatan akun A',
      bocor.isEmpty,
      '${catatanB.length} catatan miliknya, 0 milik A',
      'bocor ${bocor.length} dokumen milik A: ${bocor.join(', ')}',
    );

    // 4. Dokumen target memakai uid sebagai id, jadi ujinya berbeda.
    await _periksaTolak(
      'Akun B membuka target akun A',
      () => api.bacaDokumen(path: 'targets/${a.uid}', idToken: b.idToken),
    );

    // 5. Akun B tidak boleh menulis dokumen yang mengaku milik akun A.
    await _periksaTolak(
      'Akun B menulis catatan atas nama akun A',
      () => api.tulisDokumen(
        path: 'weightLogs/uji-isolasi',
        idToken: b.idToken,
        fields: {
          'uid': fieldTeks(a.uid),
          'tanggal': fieldTeks(kunciTanggal(DateTime.now())),
          'berat': fieldAngka(70.0),
          'catatan': fieldKosong(),
          'dibuatPada': fieldWaktu(DateTime.now()),
          'diperbaruiPada': fieldWaktu(DateTime.now()),
        },
      ),
    );

    stdout.writeln('');
  } on ApiException catch (e) {
    _gagal++;
    stderr.writeln('  GAGAL  pemeriksaan berhenti: ${e.pesan}');
    stderr.writeln('Pastikan akun demo sudah dibuat: '
        '`dart run tool/seed_demo.dart`.');
  } on Object catch (e) {
    _gagal++;
    stderr.writeln('  GAGAL  galat tak terduga: $e');
  }

  if (_gagal == 0) {
    stdout.writeln('Hasil: $_lulus/$_lulus lulus — data terisolasi per uid.');
  } else {
    stdout.writeln('Hasil: $_lulus lulus, $_gagal GAGAL.');
    stdout.writeln('Periksa firestore.rules, lalu jalankan '
        '`firebase deploy --only firestore:rules`.');
    exitCode = 1;
  }
}

void _periksa(String label, bool lulus, String pesanLulus, String pesanGagal) {
  if (lulus) {
    _lulus++;
    stdout.writeln('  LULUS  $label ... $pesanLulus');
  } else {
    _gagal++;
    stdout.writeln('  GAGAL  $label ... $pesanGagal');
  }
}

/// Document id dari hasil `runQuery` — segmen terakhir field `name`
/// (`projects/…/documents/weightLogs/<id>`).
String _idDokumen(Map<String, dynamic> dokumen) {
  final nama = (dokumen['name'] as String?) ?? '';
  final potong = nama.split('/');
  return potong.isEmpty ? nama : potong.last;
}

/// Pemeriksaan yang **harus** berakhir dengan penolakan aturan Firestore.
Future<void> _periksaTolak(
  String label,
  Future<Object?> Function() aksi,
) async {
  try {
    await aksi();
    _gagal++;
    stdout.writeln('  GAGAL  $label ... berhasil, seharusnya ditolak');
  } on ApiException catch (e) {
    if (e.ditolakAturan) {
      _lulus++;
      stdout.writeln('  LULUS  $label ... ditolak aturan');
    } else {
      _gagal++;
      stdout.writeln('  GAGAL  $label ... galat lain: ${e.kode}');
    }
  } on Object catch (e) {
    _gagal++;
    stdout.writeln('  GAGAL  $label ... galat tak terduga: $e');
  }
}
