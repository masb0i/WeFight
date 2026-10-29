// Pembungkus tipis REST API Firebase untuk alat bantu di folder `tool/`.
//
// Bukan bagian aplikasi — hanya dipakai skrip `dart run` supaya tidak perlu
// Firebase Admin SDK (yang menuntut service account) maupun konteks Flutter.
//
// API key Firebase memang publik (ikut terkirim di setiap aplikasi web),
// jadi aman dibaca dari lib/firebase_options.dart.

import 'dart:convert';
import 'dart:io';

class FirebaseConfig {
  const FirebaseConfig({required this.apiKey, required this.projectId});

  final String apiKey;
  final String projectId;
}

/// Membaca apiKey & projectId dari berkas hasil `flutterfire configure`.
FirebaseConfig bacaKonfigurasi() {
  final berkas = File('lib/firebase_options.dart');
  if (!berkas.existsSync()) {
    stderr.writeln('lib/firebase_options.dart tidak ditemukan. Jalankan dari '
        'akar proyek dan selesaikan M7 dulu.');
    exit(1);
  }
  final isi = berkas.readAsStringSync();
  final apiKey = RegExp(r"apiKey:\s*'([^']+)'").firstMatch(isi)?.group(1);
  final projectId = RegExp(r"projectId:\s*'([^']+)'").firstMatch(isi)?.group(1);
  if (apiKey == null || projectId == null) {
    stderr.writeln('Tidak bisa membaca apiKey/projectId dari '
        'lib/firebase_options.dart.');
    exit(1);
  }
  return FirebaseConfig(apiKey: apiKey, projectId: projectId);
}

/// Nilai field Firestore dalam format REST.
Map<String, dynamic> fieldTeks(String nilai) => {'stringValue': nilai};
Map<String, dynamic> fieldAngka(double nilai) => {'doubleValue': nilai};
Map<String, dynamic> fieldWaktu(DateTime nilai) =>
    {'timestampValue': nilai.toUtc().toIso8601String()};
Map<String, dynamic> fieldKosong() => {'nullValue': null};

/// Kunci tanggal `yyyy-MM-dd` — sama dengan `AppDate.keKunci`.
String kunciTanggal(DateTime tanggal) =>
    '${tanggal.year.toString().padLeft(4, '0')}-'
    '${tanggal.month.toString().padLeft(2, '0')}-'
    '${tanggal.day.toString().padLeft(2, '0')}';

class Sesi {
  const Sesi({required this.uid, required this.idToken});

  final String uid;
  final String idToken;
}

class ApiException implements Exception {
  ApiException(this.kode, this.pesan);

  final String kode;
  final String pesan;

  /// Benar bila penolakan datang dari aturan keamanan Firestore.
  bool get ditolakAturan =>
      kode == 'PERMISSION_DENIED' || kode == 'HTTP_403';

  @override
  String toString() => '$kode: $pesan';
}

class FirebaseRest {
  FirebaseRest(this.config);

  final FirebaseConfig config;

  Uri get _dokumen => Uri.parse(
        'https://firestore.googleapis.com/v1/projects/'
        '${config.projectId}/databases/(default)/documents',
      );

  Future<Sesi> masuk({required String email, required String password}) async {
    final hasil = await _post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword',
      {'email': email, 'password': password, 'returnSecureToken': true},
    );
    return Sesi(
      uid: hasil['localId'] as String,
      idToken: hasil['idToken'] as String,
    );
  }

  /// Masuk memakai email/password; kalau akun belum ada, daftarkan sekalian.
  Future<Sesi> masukAtauDaftar({
    required String email,
    required String password,
    required String nama,
  }) async {
    try {
      return await masuk(email: email, password: password);
    } on ApiException catch (e) {
      if (e.kode != 'EMAIL_NOT_FOUND' && e.kode != 'INVALID_LOGIN_CREDENTIALS') {
        rethrow;
      }
    }

    stdout.writeln('  akun belum ada, mendaftarkan...');
    final hasil = await _post(
      'https://identitytoolkit.googleapis.com/v1/accounts:signUp',
      {'email': email, 'password': password, 'returnSecureToken': true},
    );
    final sesi = Sesi(
      uid: hasil['localId'] as String,
      idToken: hasil['idToken'] as String,
    );

    // Nama tampilan supaya sapaan Dashboard tidak jatuh ke potongan email.
    await _post(
      'https://identitytoolkit.googleapis.com/v1/accounts:update',
      {
        'idToken': sesi.idToken,
        'displayName': nama,
        'returnSecureToken': true,
      },
    );
    return sesi;
  }

  /// PATCH = buat bila belum ada, timpa bila sudah ada (idempoten).
  Future<void> tulisDokumen({
    required String path,
    required String idToken,
    required Map<String, dynamic> fields,
  }) async {
    final uri = _dokumen.replace(path: '${_dokumen.path}/$path');
    await _kirim(
      'PATCH',
      uri,
      {'fields': fields},
      headers: {'Authorization': 'Bearer $idToken'},
    );
  }

  /// Menjalankan query `where <field> == <nilai>`.
  ///
  /// Melempar [ApiException] dengan `ditolakAturan == true` bila aturan
  /// Firestore menolak — inilah yang dipakai `cek_isolasi.dart`.
  Future<List<Map<String, dynamic>>> kueri({
    required String koleksi,
    required String field,
    required String nilai,
    required String idToken,
  }) async {
    final uri = Uri.parse('https://firestore.googleapis.com/v1/projects/'
        '${config.projectId}/databases/(default)/documents:runQuery');

    final hasil = await _kirimList(
      'POST',
      uri,
      {
        'structuredQuery': {
          'from': [
            {'collectionId': koleksi},
          ],
          'where': {
            'fieldFilter': {
              'field': {'fieldPath': field},
              'op': 'EQUAL',
              'value': fieldTeks(nilai),
            },
          },
        },
      },
      headers: {'Authorization': 'Bearer $idToken'},
    );

    return hasil
        .where((baris) => baris.containsKey('document'))
        .map((baris) => baris['document'] as Map<String, dynamic>)
        .toList(growable: false);
  }

  /// Membaca satu dokumen berdasarkan path lengkap, mis. `targets/<uid>`.
  Future<Map<String, dynamic>> bacaDokumen({
    required String path,
    required String idToken,
  }) async {
    final uri = _dokumen.replace(path: '${_dokumen.path}/$path');
    final teks = await _minta(
      'GET',
      uri,
      null,
      {'Authorization': 'Bearer $idToken'},
    );
    return teks.isEmpty ? const {} : jsonDecode(teks) as Map<String, dynamic>;
  }

  /// Menghapus satu dokumen berdasarkan path lengkap, mis. `weightLogs/abc`.
  Future<void> hapusDokumen({
    required String path,
    required String idToken,
  }) async {
    final uri = _dokumen.replace(path: '${_dokumen.path}/$path');
    await _minta(
      'DELETE',
      uri,
      null,
      {'Authorization': 'Bearer $idToken'},
    );
  }

  Future<Map<String, dynamic>> _post(
    String url,
    Map<String, dynamic> body,
  ) {
    final uri = Uri.parse('$url?key=${config.apiKey}');
    return _kirim('POST', uri, body);
  }

  Future<Map<String, dynamic>> _kirim(
    String metode,
    Uri uri,
    Map<String, dynamic> body, {
    Map<String, String> headers = const {},
  }) async {
    final respons = await _minta(metode, uri, body, headers);
    return respons.isEmpty ? const {} : jsonDecode(respons) as Map<String, dynamic>;
  }

  Future<List<Map<String, dynamic>>> _kirimList(
    String metode,
    Uri uri,
    Map<String, dynamic> body, {
    Map<String, String> headers = const {},
  }) async {
    final respons = await _minta(metode, uri, body, headers);
    if (respons.isEmpty) return const [];
    return (jsonDecode(respons) as List)
        .cast<Map<String, dynamic>>()
        .toList(growable: false);
  }

  /// Satu permintaan HTTP, dengan satu kali percobaan ulang.
  ///
  /// Koneksi dibuat baru setiap permintaan: koneksi keep-alive yang sudah
  /// lama menganggur kadang ditutup server dan menghasilkan
  /// `HttpException: Connection closed before full header was received`.
  Future<String> _minta(
    String metode,
    Uri uri,
    Map<String, dynamic>? body,
    Map<String, String> headers,
  ) async {
    Object? galatTerakhir;

    for (var percobaan = 0; percobaan < 2; percobaan++) {
      final klien = HttpClient()..connectionTimeout = const Duration(seconds: 20);
      try {
        final permintaan = await klien.openUrl(metode, uri);
        if (body != null) permintaan.headers.contentType = ContentType.json;
        headers.forEach(permintaan.headers.set);
        if (body != null) permintaan.write(jsonEncode(body));

        final respons = await permintaan.close();
        final teks = await respons.transform(utf8.decoder).join();

        if (respons.statusCode >= 400) {
          throw _keException(teks, respons.statusCode);
        }
        return teks;
      } on HttpException catch (e) {
        galatTerakhir = e;
      } on SocketException catch (e) {
        galatTerakhir = e;
      } finally {
        klien.close();
      }
    }

    throw ApiException('JARINGAN', 'Koneksi ke Firebase gagal: $galatTerakhir');
  }

  ApiException _keException(String teks, int status) {
    try {
      final json = jsonDecode(teks);
      // `runQuery` mengembalikan array, endpoint lain objek — dua-duanya
      // bisa membawa {"error": ...}.
      final isi = switch (json) {
        final List<dynamic> daftar =>
          daftar.isEmpty ? null : daftar.first,
        final Map<String, dynamic> peta => peta,
        _ => null,
      };
      final error = isi is Map<String, dynamic> ? isi['error'] : null;
      if (error is Map<String, dynamic>) {
        // Firestore: {"error":{"code":403,"status":"PERMISSION_DENIED"}}
        final statusFirestore = error['status'] as String?;
        final pesan = error['message'] as String? ?? teks;
        if (statusFirestore != null) {
          return ApiException(statusFirestore, pesan);
        }
        // Identity Toolkit: {"error":{"message":"EMAIL_NOT_FOUND : ..."}}
        final mentah = error['message'] as String? ?? teks;
        return ApiException(mentah.split(' : ').first.trim(), mentah);
      }
    } on FormatException {
      // jatuh ke galat umum di bawah
    }
    return ApiException('HTTP_$status', teks);
  }
}
