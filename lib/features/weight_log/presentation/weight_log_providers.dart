import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/weight_log_repository.dart';
import '../models/weight_log.dart';

/// Repository catatan berat. Di test di-override dengan implementasi palsu.
final weightLogRepositoryProvider = Provider<WeightLogRepository>((ref) {
  return FirestoreWeightLogRepository(FirebaseFirestore.instance);
});

/// Semua catatan berat pengguna, urut tanggal terbaru lebih dulu.
///
/// Satu sumber untuk Dashboard, Riwayat, dan grafik tren — supaya
/// menambah/mengubah/menghapus catatan langsung memperbarui ketiganya
/// (keputusan D8: real-time lewat stream Firestore).
final weightLogsProvider = StreamProvider<List<WeightLog>>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream<List<WeightLog>>.value(const <WeightLog>[]);
  return ref.watch(weightLogRepositoryProvider).watchAll(uid);
});

/// Catatan dengan tanggal terbaru — "berat terakhir" pada aturan bisnis
/// §3 poin 6 (dari tanggal, bukan dari waktu dibuat).
final beratTerakhirProvider = Provider<WeightLog?>((ref) {
  final logs = ref.watch(weightLogsProvider).asData?.value ?? const <WeightLog>[];
  return logs.isEmpty ? null : logs.first;
});
