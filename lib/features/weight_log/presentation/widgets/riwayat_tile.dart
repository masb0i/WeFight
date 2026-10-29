import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/angka.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../models/weight_log.dart';

/// Satu baris daftar Riwayat Berat (H6).
///
/// Kolom mengikuti `docs/UI_SPEC.md` §7: tanggal, berat, catatan. Kolom
/// "Perubahan" ditambahkan pada M12 bersama `weight_math`, supaya aturan
/// selisih hanya ditulis di satu tempat.
///
/// [onHapus] null berarti aksi hapus tidak tersedia (mis. saat masih memuat).
class RiwayatTile extends StatelessWidget {
  const RiwayatTile({
    super.key,
    required this.log,
    required this.onTap,
    required this.onHapus,
  });

  final WeightLog log;
  final VoidCallback onTap;
  final VoidCallback onHapus;

  /// Label pendek hanya untuk dua hari terdekat; tanggal lain sudah terbaca
  /// dari baris tanggal di bawahnya.
  String? get _labelRelatif {
    final selisih = AppDate.selisihHari(log.tanggal, AppDate.hariIni());
    return switch (selisih) {
      0 => 'Hari ini',
      -1 => 'Kemarin',
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final label = _labelRelatif;

    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AppColors.peach200.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(AppRadius.input),
            ),
            child: const Icon(
              Icons.monitor_weight_outlined,
              size: 20,
              color: AppColors.burgundy700,
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        '${Angka.kg(log.berat)} ${AppStrings.satuanKg}',
                        style: AppTextStyles.h3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (label != null) ...[
                      const SizedBox(width: AppSpacing.sm),
                      StatusChip(label: label),
                    ],
                  ],
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  AppDate.panjang(log.tanggal),
                  style: AppTextStyles.caption,
                ),
                if (log.punyaCatatan) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    log.catatan!,
                    style: AppTextStyles.body.copyWith(
                      color: AppColors.ink500,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
          IconButton(
            onPressed: onHapus,
            tooltip: AppStrings.hapusCatatanTooltip,
            visualDensity: VisualDensity.compact,
            icon: const Icon(
              Icons.delete_outline,
              size: 20,
              color: AppColors.ink500,
            ),
          ),
        ],
      ),
    );
  }
}
