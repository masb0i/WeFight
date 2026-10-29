import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/auth_repository.dart';

/// Repository autentikasi.
///
/// Di lingkungan test, provider ini **tidak** boleh disentuh tanpa override
/// karena `FirebaseAuth.instance` menuntut Firebase sudah diinisialisasi.
final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return FirebaseAuthRepository(FirebaseAuth.instance);
});

/// Status sesi. Null berarti belum masuk.
final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authRepositoryProvider).authStateChanges;
});

/// uid pengguna yang sedang masuk. Null saat belum masuk atau masih dimuat.
///
/// Semua query Firestore memakai uid ini — tidak pernah uid dari parameter
/// luar — sehingga data tidak mungkin tercampur antar akun.
final currentUidProvider = Provider<String?>((ref) {
  return ref.watch(authStateProvider).asData?.value?.uid;
});

/// Nama tampilan pengguna, dengan cadangan bila kosong.
final currentUserNameProvider = Provider<String>((ref) {
  final user = ref.watch(authStateProvider).asData?.value;
  final name = user?.displayName?.trim();
  if (name != null && name.isNotEmpty) return name;
  final email = user?.email;
  if (email != null && email.contains('@')) {
    return email.split('@').first;
  }
  return 'Fighter';
});

/// Inisial untuk avatar.
final currentUserInitialProvider = Provider<String>((ref) {
  final name = ref.watch(currentUserNameProvider);
  return name.isEmpty ? 'F' : name.substring(0, 1).toUpperCase();
});
