import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../features/auth/data/auth_repository.dart';
import '../pages/login_page.dart';
import '../pages/daftar_page.dart';
import '../pages/dashboard_page.dart';
import '../pages/profil_page.dart';
import '../pages/splash_page.dart';
import '../pages/target_timbang_page.dart';
import '../pages/catat_berat_page.dart';
import '../pages/riwayat_berat_page.dart';

/// Membuat router baru.
///
/// Dibuat sebagai fungsi (bukan variabel global) supaya test bisa memakai
/// instance bersih. Parameter `auth` opsional: bila null, guard login dimatikan
/// sehingga widget test bisa berjalan tanpa Firebase.
GoRouter buildAppRouter({AuthRepository? auth}) {
  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: auth == null ? null : _AuthRefreshNotifier(auth),
    redirect: (context, state) => _redirect(auth, state),
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashPage(),
      ),
      GoRoute(
        path: AppRoutes.login,
        name: 'login',
        builder: (context, state) => const LoginPage(),
      ),
      GoRoute(
        path: AppRoutes.register,
        name: 'register',
        builder: (context, state) => const DaftarPage(),
      ),
      GoRoute(
        path: AppRoutes.dashboard,
        name: 'dashboard',
        builder: (context, state) => const DashboardPage(),
      ),
      GoRoute(
        path: AppRoutes.target,
        name: 'target',
        builder: (context, state) => const TargetTimbangPage(),
      ),
      GoRoute(
        path: AppRoutes.catatBerat,
        name: 'catatBerat',
        builder: (context, state) => const CatatBeratPage(),
      ),
      GoRoute(
        path: AppRoutes.editBerat,
        name: 'editBerat',
        builder: (context, state) => CatatBeratPage(
          logId: state.pathParameters['id'],
        ),
      ),
      GoRoute(
        path: AppRoutes.riwayat,
        name: 'riwayat',
        builder: (context, state) => const RiwayatBeratPage(),
      ),
      GoRoute(
        path: AppRoutes.profil,
        name: 'profil',
        builder: (context, state) => const ProfilPage(),
      ),
    ],
    errorBuilder: (context, state) =>
        _RuteTidakDikenal(lokasi: state.uri.toString()),
  );
}

/// Aturan guard: belum masuk tidak boleh melihat halaman data.
String? _redirect(AuthRepository? auth, GoRouterState state) {
  if (auth == null) return null; // mode test tanpa Firebase

  final signedIn = auth.isSignedIn;
  final lokasi = state.matchedLocation;
  final diHalamanAuth =
      lokasi == AppRoutes.login || lokasi == AppRoutes.register;

  if (signedIn) {
    // Sudah masuk tapi membuka Login/Daftar/Splash → langsung ke Dashboard.
    if (diHalamanAuth || lokasi == AppRoutes.splash) return AppRoutes.dashboard;
    return null;
  }

  // Belum masuk: hanya Splash dan halaman auth yang boleh dibuka.
  if (diHalamanAuth || lokasi == AppRoutes.splash) return null;
  return AppRoutes.login;
}

/// Memberi tahu GoRouter saat status login berubah.
///
/// Langganan dibuat saat listener pertama dipasang dan dilepas saat listener
/// terakhir hilang — jadi ikut bersih ketika router di-dispose.
class _AuthRefreshNotifier extends ChangeNotifier {
  _AuthRefreshNotifier(this._auth);

  final AuthRepository _auth;
  StreamSubscription<User?>? _sub;

  @override
  void addListener(VoidCallback listener) {
    _sub ??= _auth.authStateChanges.listen((_) => notifyListeners());
    super.addListener(listener);
  }

  @override
  void removeListener(VoidCallback listener) {
    super.removeListener(listener);
    if (!hasListeners) {
      _sub?.cancel();
      _sub = null;
    }
  }
}

/// Pengganti layar kosong bila pengguna membuka path yang tidak ada.
class _RuteTidakDikenal extends StatelessWidget {
  const _RuteTidakDikenal({required this.lokasi});

  final String lokasi;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.appName)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.link_off, size: 40, color: AppColors.ink300),
              const SizedBox(height: AppSpacing.lg),
              Text('Halaman tidak ditemukan', style: AppTextStyles.h2),
              const SizedBox(height: AppSpacing.sm),
              Text(lokasi, style: AppTextStyles.caption),
              const SizedBox(height: AppSpacing.xl),
              FilledButton(
                onPressed: () => context.go(AppRoutes.dashboard),
                child: const Text('Ke Dashboard'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
