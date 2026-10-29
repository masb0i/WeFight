import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/presentation/auth_providers.dart';
import '../data/target_repository.dart';
import '../models/target.dart';

/// Repository target. Di test di-override dengan implementasi palsu.
final targetRepositoryProvider = Provider<TargetRepository>((ref) {
  return FirestoreTargetRepository(FirebaseFirestore.instance);
});

/// Target timbang pengguna yang sedang masuk.
///
/// Selalu mengirim [Target] (bukan null): belum diatur = `Target.kosong`.
/// Dengan begitu layar cukup memeriksa `target.kosong` tanpa membedakan
/// "sedang memuat" dan "belum ada".
final targetProvider = StreamProvider<Target>((ref) {
  final uid = ref.watch(currentUidProvider);
  if (uid == null) return Stream<Target>.value(const Target());
  return ref.watch(targetRepositoryProvider).watch(uid);
});
