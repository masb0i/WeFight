import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/weight_math.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';

/// Kartu "Hari Timbang" — tanggal target dan hitung mundurnya (M12-2).
///
/// Sumber tampilan: `docs/UI_SPEC.md` §4 (`PeachInfoCard`). Warna status tidak
/// pernah menjadi satu-satunya penanda: chip selalu berisi teks
/// (PLAN §3 poin 10).
class PeachInfoCard extends StatelessWidget {
  const PeachInfoCard({
    super.key,
    required this.tanggal,
    required this.sisaHari,
  });

  final DateTime tanggal;

  /// Hasil `WeightMath.hitungSisaHari`: 0 hari ini, negatif sudah lewat.
  final int sisaHari;

  StatusChipVariant get _variant => switch (sisaHari) {
        < 0 => StatusChipVariant.galat,
        0 => StatusChipVariant.peringatan,
        _ => StatusChipVariant.terang,
      };

  @override
  Widget build(BuildContext context) {
    return AppCard(
      color: AppColors.peach200,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: const Icon(
              Icons.event_outlined,
              size: 20,
              color: AppColors.burgundy700,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.labelHariTimbang,
                  style: AppTextStyles.caption.copyWith(
                    color: AppColors.ink500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(AppDate.panjang(tanggal), style: AppTextStyles.h3),
                const SizedBox(height: AppSpacing.sm),
                StatusChip(
                  label: WeightMath.labelHitungMundur(sisaHari),
                  variant: _variant,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
