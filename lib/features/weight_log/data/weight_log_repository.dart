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
    return _logs
        .where('uid', isEqualTo: uid)
        .orderBy('tanggal', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => WeightLog.fromMap(doc.id, doc.data()))
            .whereType<WeightLog>()
            .toList(growable: false));
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
