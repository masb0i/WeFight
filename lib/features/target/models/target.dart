import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_format.dart';

/// Target timbang pengguna — isi dokumen `targets/{uid}` (PLAN §1.3).
///
/// Document id selalu `uid` pemilik, jadi model tidak menyimpan `uid`.
/// Kedua field boleh null: aturan bisnis §3 poin 3 menyatakan target boleh
/// kosong dan Dashboard harus menampilkan ajakan, bukan galat.
class Target {
  const Target({this.batasBerat, this.tanggalTimbang, this.diperbaruiPada});

  /// Batas berat kelas pertandingan (kg). Null = belum diatur.
  final double? batasBerat;

  /// Hari timbang. Null = belum diatur.
  final DateTime? tanggalTimbang;

  final DateTime? diperbaruiPada;

  /// Target kosong sama sekali — Dashboard memakai ini untuk memilih
  /// kartu ajakan "Atur Target Timbang".
  bool get kosong => batasBerat == null && tanggalTimbang == null;

  bool get adaBatasBerat => batasBerat != null;

  bool get adaTanggalTimbang => tanggalTimbang != null;

  /// Membaca dari Firestore. `null`/kosong → [Target.kosong].
  factory Target.fromMap(Map<String, dynamic>? data) {
    if (data == null) return const Target();
    final batas = data['batasBerat'];
    return Target(
      batasBerat: batas is num ? batas.toDouble() : null,
      tanggalTimbang: AppDate.dariKunci(data['tanggalTimbang']),
      diperbaruiPada: switch (data['diperbaruiPada']) {
        final Timestamp t => t.toDate(),
        final DateTime d => d,
        _ => null,
      },
    );
  }

  factory Target.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      Target.fromMap(doc.data());

  /// Menulis ke Firestore. Field null tetap ditulis sebagai `null` supaya
  /// menghapus target benar-benar menghapus nilainya, bukan menyisakan nilai
  /// lama (repository memakai `set`, bukan `update`).
  Map<String, dynamic> toMap() => {
        'batasBerat': batasBerat,
        'tanggalTimbang':
            tanggalTimbang == null ? null : AppDate.keKunci(tanggalTimbang!),
        'diperbaruiPada': diperbaruiPada == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(diperbaruiPada!),
      };

  /// Untuk mengosongkan satu field, pakai [hapusBatasBerat] /
  /// [hapusTanggalTimbang] — parameter nullable biasa tidak bisa membedakan
  /// "tidak diubah" dan "dijadikan null".
  Target copyWith({
    double? batasBerat,
    DateTime? tanggalTimbang,
    DateTime? diperbaruiPada,
    bool hapusBatasBerat = false,
    bool hapusTanggalTimbang = false,
  }) {
    return Target(
      batasBerat: hapusBatasBerat ? null : (batasBerat ?? this.batasBerat),
      tanggalTimbang: hapusTanggalTimbang
          ? null
          : (tanggalTimbang ?? this.tanggalTimbang),
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
    );
  }

  @override
  bool operator ==(Object other) =>
      other is Target &&
      other.batasBerat == batasBerat &&
      other.tanggalTimbang == tanggalTimbang &&
      other.diperbaruiPada == diperbaruiPada;

  @override
  int get hashCode => Object.hash(batasBerat, tanggalTimbang, diperbaruiPada);

  @override
  String toString() =>
      'Target(batasBerat: $batasBerat, tanggalTimbang: $tanggalTimbang)';
}
