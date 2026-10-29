import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Kerangka sementara untuk halaman yang belum dibangun.
///
/// Dipakai pada M5 agar ketujuh route bisa dibuka. Setiap halaman diganti
/// dengan implementasi aslinya sesuai milestone di `docs/PLAN.md` §7.
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.milestone,
    this.note,
  });

  final String title;

  /// Misalnya 'M7' — kapan halaman ini akan dibangun.
  final String milestone;

  final String? note;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xxl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.peach200,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.construction_outlined,
                  color: AppColors.burgundy700,
                  size: 28,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text(title, style: AppTextStyles.h2, textAlign: TextAlign.center),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Akan dibangun pada $milestone.',
                style: AppTextStyles.body.copyWith(color: AppColors.ink500),
                textAlign: TextAlign.center,
              ),
              if (note != null) ...[
                const SizedBox(height: AppSpacing.sm),
                Text(note!, style: AppTextStyles.caption, textAlign: TextAlign.center),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
