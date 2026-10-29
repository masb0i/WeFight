import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../features/auth/presentation/login_screen.dart';
import '../features/auth/presentation/register_screen.dart';
import '../features/dashboard/presentation/dashboard_screen.dart';
import '../features/profile/presentation/profil_screen.dart';
import '../features/target/presentation/target_screen.dart';
import '../features/weight_log/presentation/catat_berat_screen.dart';
import '../features/weight_log/presentation/riwayat_berat_screen.dart';

/// Route aplikasi. Nama dan path mengikuti `docs/PLAN.md` §1.1.
abstract final class AppRoutes {
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/';
  static const target = '/target';
  static const catatBerat = '/weight/new';
  static const editBerat = '/weight/:id/edit';
  static const riwayat = '/history';
  static const profil = '/profile';

  /// Path edit untuk id tertentu.
  static String editBeratPath(String id) => '/weight/$id/edit';
}

final GoRouter appRouter = GoRouter(
  initialLocation: AppRoutes.login,
  // Auth guard (redirect) ditambahkan pada M7.
  routes: [
    GoRoute(
      path: AppRoutes.login,
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: AppRoutes.register,
      name: 'register',
      builder: (context, state) => const RegisterScreen(),
    ),
    GoRoute(
      path: AppRoutes.dashboard,
      name: 'dashboard',
      builder: (context, state) => const DashboardScreen(),
    ),
    GoRoute(
      path: AppRoutes.target,
      name: 'target',
      builder: (context, state) => const TargetScreen(),
    ),
    GoRoute(
      path: AppRoutes.catatBerat,
      name: 'catatBerat',
      builder: (context, state) => const CatatBeratScreen(),
    ),
    GoRoute(
      path: AppRoutes.editBerat,
      name: 'editBerat',
      builder: (context, state) => CatatBeratScreen(
        logId: state.pathParameters['id'],
      ),
    ),
    GoRoute(
      path: AppRoutes.riwayat,
      name: 'riwayat',
      builder: (context, state) => const RiwayatBeratScreen(),
    ),
    GoRoute(
      path: AppRoutes.profil,
      name: 'profil',
      builder: (context, state) => const ProfilScreen(),
    ),
  ],
  errorBuilder: (context, state) => _RuteTidakDikenal(lokasi: state.uri.toString()),
);

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
