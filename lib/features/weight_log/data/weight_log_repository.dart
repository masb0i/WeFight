import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_format.dart';
import '../models/weight_log.dart';

/// Akses data catatan berat.
abstract interface class WeightLogRepository {
  /// Semua catatan milik [uid], tanggal terbaru lebih dulu.
  ///
  /// Wajib menyaring `uid` di query — aturan Firestore menolak query yang
  /// tidak menyebut pemiliknya (lihat `docs/FIREBASE_SETUP.md` §D).
  Stream<List<WeightLog>> watchAll(String uid);

  Future<WeightLog?> ambil(String id);

  /// Mencari catatan pada satu tanggal — dasar aturan bisnis §3 poin 1
  /// (satu catatan per tanggal).
  Future<WeightLog?> cariTanggal(String uid, DateTime tanggal);

  /// Menambah catatan baru, mengembalikan document id-nya.
  Future<String> tambah(String uid, WeightLog log);

  Future<void> ubah(String uid, WeightLog log);

  Future<void> hapus(String id);
}

class FirestoreWeightLogRepository implements WeightLogRepository {
  FirestoreWeightLogRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _logs =>
      _db.collection('weightLogs');

  @override
  Stream<List<WeightLog>> watchAll(String uid) {
    // Sengaja TANPA `orderBy('tanggal')` (D24). Menggabungkan
    // `.where('uid', isEqualTo: ...)` dengan `.orderBy('tanggal')` menuntut
    // indeks komposit yang harus dibuat manual per project; selama indeks itu
    // belum aktif Firestore menolak query dengan FAILED_PRECONDITION dan
    // aplikasi tampil seolah "tidak ada koneksi". Pengurutan dilakukan di
    // [urutkanTerbaruDulu] — hasilnya sama, tanpa syarat infrastruktur.
    return _logs.where('uid', isEqualTo: uid).snapshots().map(
          (snapshot) => urutkanTerbaruDulu(
            snapshot.docs
                .map((doc) => WeightLog.fromMap(doc.id, doc.data()))
                .whereType<WeightLog>(),
          ),
        );
  }

  @override
  Future<WeightLog?> ambil(String id) async {
    final snapshot = await _logs.doc(id).get();
    return WeightLog.fromMap(snapshot.id, snapshot.data());
  }

  @override
  Future<WeightLog?> cariTanggal(String uid, DateTime tanggal) async {
    // Dua filter kesetaraan tanpa orderBy — dilayani Firestore lewat
    // penggabungan indeks, tidak perlu indeks komposit.
    final snapshot = await _logs
        .where('uid', isEqualTo: uid)
        .where('tanggal', isEqualTo: AppDate.keKunci(tanggal))
        .limit(1)
        .get();
    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return WeightLog.fromMap(doc.id, doc.data());
  }

  @override
  Future<String> tambah(String uid, WeightLog log) async {
    final ref = await _logs.add(log.toMap(uid: uid));
    return ref.id;
  }

  @override
  Future<void> ubah(String uid, WeightLog log) {
    if (!log.tersimpan) {
      throw ArgumentError('Catatan tanpa id tidak bisa diubah.');
    }
    return _logs.doc(log.id).set(
          log.toMap(uid: uid, sertakanDibuatPada: false),
          SetOptions(merge: true),
        );
  }

  @override
  Future<void> hapus(String id) => _logs.doc(id).delete();
}

/// Urutkan catatan dari tanggal terbaru ke terlama (D24).
///
/// Ini satu-satunya tempat urutan ditentukan. Halaman Riwayat, Dashboard, dan
/// grafik tren semuanya membaca daftar yang sudah terurut dari sini — tidak
/// ada layar yang mengurutkan sendiri, jadi tidak mungkin berbeda urutan.
///
/// Kunci tanggal berformat `yyyy-MM-dd` sehingga perbandingan teks biasa
/// sudah kronologis (D4). Tanggal yang sama diurutkan menurut `id` supaya
/// hasilnya tetap sama setiap kali dibaca.
List<WeightLog> urutkanTerbaruDulu(Iterable<WeightLog> logs) {
  final hasil = logs.toList();
  hasil.sort((a, b) {
    final menurutTanggal = b.tanggalKunci.compareTo(a.tanggalKunci);
    return menurutTanggal != 0 ? menurutTanggal : b.id.compareTo(a.id);
  });
  return List<WeightLog>.unmodifiable(hasil);
}
