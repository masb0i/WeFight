import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_gradients.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';

/// Kartu utama berisi berat terakhir dan target.
///
/// Nilai null berarti data belum ada — ditampilkan sebagai "—", bukan 0.
/// Sumber: `docs/UI_SPEC.md` §4.
class HeroWeightCard extends StatelessWidget {
  const HeroWeightCard({
    super.key,
    this.beratKg,
    this.targetKg,
    this.deltaLabel,
    this.onEdit,
  });

  final double? beratKg;
  final double? targetKg;

  /// Misalnya "+0,5 kg dari minggu lalu". Null bila belum bisa dihitung.
  final String? deltaLabel;

  final VoidCallback? onEdit;

  static String _format(double? value) {
    if (value == null) return AppStrings.nilaiKosong;
    return value.toStringAsFixed(1);
  }

  @override
  Widget build(BuildContext context) {
    final hasBerat = beratKg != null;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      decoration: BoxDecoration(
        gradient: AppGradients.hero,
        borderRadius: BorderRadius.circular(AppRadius.hero),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  AppStrings.labelBeratSaatIni,
                  style: AppTextStyles.label.copyWith(
                    color: AppColors.peach200,
                  ),
                ),
              ),
              if (onEdit != null)
                IconButton(
                  onPressed: onEdit,
                  tooltip: AppStrings.ubah,
                  visualDensity: VisualDensity.compact,
                  icon: const Icon(
                    Icons.edit_outlined,
                    size: 18,
                    color: AppColors.peach200,
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                flex: 3,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Flexible(
                          child: Text(
                            _format(beratKg),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: hasBerat
                                ? AppTextStyles.displayWeight.copyWith(
                                    color: AppColors.white,
                                  )
                                : AppTextStyles.h1.copyWith(
                                    color: AppColors.white.withValues(
                                      alpha: 0.45,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        Text(
                          AppStrings.satuanKg,
                          style: AppTextStyles.h3.copyWith(
                            color: AppColors.peach200,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      deltaLabel ?? AppStrings.heroBelumAdaCatatan,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.peach200,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 1,
                height: 48,
                margin: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                ),
                color: Colors.white.withValues(alpha: 0.18),
              ),
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppStrings.labelTargetBerat,
                      style: AppTextStyles.caption.copyWith(
                        color: AppColors.peach200,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      targetKg == null
                          ? AppStrings.nilaiKosong
                          : '${_format(targetKg)} ${AppStrings.satuanKg}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.h3.copyWith(
                        color: AppColors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
