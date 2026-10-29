import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../features/auth/presentation/auth_providers.dart';
import 'router.dart';
import 'theme.dart';

/// Router aplikasi, lengkap dengan guard login.
///
/// Dibuat lewat provider agar `AuthRepository` bisa diganti saat test.
final appRouterProvider = Provider<GoRouter>((ref) {
  final auth = ref.watch(authRepositoryProvider);
  final router = buildAppRouter(auth: auth);
  ref.onDispose(router.dispose);
  return router;
});

/// Akar aplikasi.
class WeFightApp extends ConsumerWidget {
  const WeFightApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);

    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: router,
    );
  }
}

/// Ditampilkan hanya bila `Firebase.initializeApp` gagal, supaya pengguna
/// melihat pesan jelas alih-alih layar putih.
class BootstrapErrorApp extends StatelessWidget {
  const BootstrapErrorApp({super.key, required this.error});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxl),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cloud_off, size: 40, color: AppColors.danger),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Aplikasi gagal terhubung ke Firebase.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.h2,
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  '$error',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption,
                ),
                const SizedBox(height: AppSpacing.lg),
                Text(
                  'Periksa koneksi internet lalu jalankan ulang aplikasi.',
                  textAlign: TextAlign.center,
                  style: AppTextStyles.body.copyWith(color: AppColors.ink500),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
