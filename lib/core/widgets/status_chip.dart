import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// `terang` dipakai di atas permukaan berwarna (mis. `PeachInfoCard`) supaya
/// chip tetap terbaca — `netral` berlatar krem akan tenggelam di atas peach.
enum StatusChipVariant { sukses, peringatan, galat, netral, terang }

/// Label status.
///
/// Aturan: status tidak boleh dibedakan hanya dengan warna — chip ini selalu
/// menampilkan teks. Lihat `docs/PLAN.md` §3 poin 10.
class StatusChip extends StatelessWidget {
  const StatusChip({
    super.key,
    required this.label,
    this.variant = StatusChipVariant.netral,
  });

  final String label;
  final StatusChipVariant variant;

  ({Color background, Color foreground}) get _colors {
    return switch (variant) {
      StatusChipVariant.sukses => (
          background: AppColors.success.withValues(alpha: 0.12),
          foreground: AppColors.success,
        ),
      StatusChipVariant.peringatan => (
          background: AppColors.warning.withValues(alpha: 0.12),
          foreground: AppColors.warning,
        ),
      StatusChipVariant.galat => (
          background: AppColors.danger.withValues(alpha: 0.12),
          foreground: AppColors.danger,
        ),
      StatusChipVariant.netral => (
          background: AppColors.cream200,
          foreground: AppColors.ink500,
        ),
      StatusChipVariant.terang => (
          background: AppColors.white,
          foreground: AppColors.ink900,
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final colors = _colors;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: AppSpacing.xs,
      ),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Text(
        label,
        style: AppTextStyles.label.copyWith(
          color: colors.foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
