import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/user_repository.dart';

/// Repository profil (`users/{uid}`).
final userRepositoryProvider = Provider<UserRepository>((ref) {
  return FirestoreUserRepository(FirebaseFirestore.instance);
});
