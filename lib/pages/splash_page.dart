import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_gradients.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';

/// Layar pembuka.
///
/// Bukan halaman bernavigasi — hanya tampil sebentar lalu pindah ke Login.
/// Sumber: `docs/UI_SPEC.md` §6.
class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  static const _durasi = Duration(milliseconds: 1200);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer(_durasi, () {
      if (mounted) context.go(AppRoutes.login);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.burgundy900,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.splash),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.xxxl),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Spacer(),
                Column(
                  children: [
                    Container(
                      width: 84,
                      height: 84,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.sports_martial_arts,
                        size: 40,
                        color: AppColors.peach100,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xxl),
                    Text(
                      AppStrings.appName,
                      style: AppTextStyles.displayWeight.copyWith(
                        fontSize: 34,
                        color: AppColors.white,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.appTagline,
                      style: AppTextStyles.label.copyWith(
                        color: AppColors.peach200,
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  AppStrings.splashQuote,
                  textAlign: TextAlign.center,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.peach200,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
