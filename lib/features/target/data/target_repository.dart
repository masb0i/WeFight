import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/target.dart';

/// Akses data target timbang.
///
/// Kontrak dipisah dari implementasi supaya layar bisa diuji tanpa Firestore
/// (pola yang sama dengan `AuthRepository`).
abstract interface class TargetRepository {
  /// Memantau target milik [uid]. Stream mengirim `Target.kosong` bila
  /// dokumen belum ada — bukan `null` — supaya UI tidak perlu membedakan
  /// "belum dimuat" dan "belum diatur".
  Stream<Target> watch(String uid);

  Future<Target> ambil(String uid);

  /// Menyimpan seluruh isi target. Field yang null ikut ditulis null
  /// sehingga benar-benar terhapus.
  Future<void> simpan(String uid, Target target);
}

/// Implementasi Cloud Firestore. Document id = `uid` (PLAN §1.3).
class FirestoreTargetRepository implements TargetRepository {
  FirestoreTargetRepository(this._db);

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _targets =>
      _db.collection('targets');

  @override
  Stream<Target> watch(String uid) => _targets
      .doc(uid)
      .snapshots()
      .map((snapshot) => Target.fromMap(snapshot.data()));

  @override
  Future<Target> ambil(String uid) async {
    final snapshot = await _targets.doc(uid).get();
    return Target.fromMap(snapshot.data());
  }

  @override
  Future<void> simpan(String uid, Target target) {
    return _targets.doc(uid).set(target.toMap());
  }
}
