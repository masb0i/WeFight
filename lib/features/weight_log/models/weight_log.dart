import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../core/utils/date_format.dart';

/// Satu catatan berat badan — isi dokumen `weightLogs/{autoId}` (PLAN §1.3).
///
/// [uid] disimpan sebagai *field* karena document id-nya auto, berbeda dengan
/// [Target] yang memakai `uid` sebagai id. Field ini yang dipakai aturan
/// keamanan Firestore dan yang wajib dipakai di `.where('uid', ...)`.
class WeightLog {
  const WeightLog({
    required this.tanggal,
    required this.berat,
    this.id = '',
    this.catatan,
    this.dibuatPada,
    this.diperbaruiPada,
  });

  /// Document id Firestore. String kosong berarti belum tersimpan.
  final String id;

  /// Tanggal timbang (tanpa jam). Satu tanggal hanya boleh punya satu catatan.
  final DateTime tanggal;

  /// Berat dalam kg. Rentang wajar 30–200 divalidasi di `Validators`.
  final double berat;

  /// Catatan bebas, opsional.
  final String? catatan;

  final DateTime? dibuatPada;
  final DateTime? diperbaruiPada;

  /// Kunci `yyyy-MM-dd` — dasar pengecekan duplikat tanggal.
  String get tanggalKunci => AppDate.keKunci(tanggal);

  bool get punyaCatatan => (catatan ?? '').trim().isNotEmpty;

  bool get tersimpan => id.isNotEmpty;

  /// Membaca dari Firestore. Data rusak/kosong → null (bukan exception),
  /// supaya satu dokumen buruk tidak mematikan seluruh daftar riwayat.
  static WeightLog? fromMap(String id, Map<String, dynamic>? data) {
    if (data == null) return null;
    final tanggal = AppDate.dariKunci(data['tanggal']);
    final berat = data['berat'];
    if (tanggal == null || berat is! num) return null;

    final catatan = (data['catatan'] as String?)?.trim();
    return WeightLog(
      id: id,
      tanggal: tanggal,
      berat: berat.toDouble(),
      catatan: (catatan == null || catatan.isEmpty) ? null : catatan,
      dibuatPada: _keTanggal(data['dibuatPada']),
      diperbaruiPada: _keTanggal(data['diperbaruiPada']),
    );
  }

  static WeightLog? fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) =>
      fromMap(doc.id, doc.data());

  /// `uid` selalu ikut ditulis — aturan Firestore menolak dokumen tanpa
  /// `uid` yang cocok dengan pengguna yang sedang masuk.
  ///
  /// [sertakanDibuatPada] dimatikan saat mengubah catatan agar waktu dibuat
  /// tidak tertimpa.
  Map<String, dynamic> toMap({
    required String uid,
    bool sertakanDibuatPada = true,
  }) {
    return {
      'uid': uid,
      'tanggal': tanggalKunci,
      'berat': berat,
      'catatan': punyaCatatan ? catatan!.trim() : null,
      if (sertakanDibuatPada)
        'dibuatPada': dibuatPada == null
            ? FieldValue.serverTimestamp()
            : Timestamp.fromDate(dibuatPada!),
      'diperbaruiPada': diperbaruiPada == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(diperbaruiPada!),
    };
  }

  /// Untuk mengosongkan catatan, pakai [hapusCatatan].
  WeightLog copyWith({
    String? id,
    DateTime? tanggal,
    double? berat,
    String? catatan,
    DateTime? dibuatPada,
    DateTime? diperbaruiPada,
    bool hapusCatatan = false,
  }) {
    return WeightLog(
      id: id ?? this.id,
      tanggal: tanggal ?? this.tanggal,
      berat: berat ?? this.berat,
      catatan: hapusCatatan ? null : (catatan ?? this.catatan),
      dibuatPada: dibuatPada ?? this.dibuatPada,
      diperbaruiPada: diperbaruiPada ?? this.diperbaruiPada,
    );
  }

  static DateTime? _keTanggal(Object? nilai) => switch (nilai) {
        final Timestamp t => t.toDate(),
        final DateTime d => d,
        _ => null,
      };

  @override
  bool operator ==(Object other) =>
      other is WeightLog &&
      other.id == id &&
      other.tanggal == tanggal &&
      other.berat == berat &&
      other.catatan == catatan &&
      other.dibuatPada == dibuatPada &&
      other.diperbaruiPada == diperbaruiPada;

  @override
  int get hashCode =>
      Object.hash(id, tanggal, berat, catatan, dibuatPada, diperbaruiPada);

  @override
  String toString() =>
      'WeightLog($id, ${AppDate.keKunci(tanggal)}, $berat kg)';
}
