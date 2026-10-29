import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/angka.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/utils/weight_math.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../models/weight_log.dart';

/// Satu baris daftar Riwayat Berat (H6).
///
/// Kolom mengikuti `docs/UI_SPEC.md` §7: tanggal, berat, perubahan, catatan.
/// [sebelumnya] adalah catatan yang lebih lama sebagai pembanding — null untuk
/// catatan paling awal, dan pada baris itu kolom perubahan dikosongkan.
///
/// [onHapus] null berarti aksi hapus tidak tersedia (mis. saat masih memuat).
class RiwayatTile extends StatelessWidget {
  const RiwayatTile({
    super.key,
    required this.log,
    required this.onTap,
    required this.onHapus,
    this.sebelumnya,
  });

  final WeightLog log;
  final WeightLog? sebelumnya;
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

  /// Selisih terhadap catatan sebelumnya, atau null bila tidak ada pembanding.
  double? get _perubahan {
    final acuan = sebelumnya;
    if (acuan == null) return null;
    return WeightMath.hitungPerubahan(
      berat: log.berat,
      beratSebelumnya: acuan.berat,
    );
  }

  /// Naik = `danger`, turun = `success` (konvensi Indonesia, UI_SPEC §1).
  /// Tanda `+`/`-` selalu ikut ditulis, jadi warna bukan satu-satunya penanda.
  Color get _warnaPerubahan {
    final nilai = _perubahan;
    if (nilai == null || nilai == 0) return AppColors.ink500;
    return nilai > 0 ? AppColors.danger : AppColors.success;
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
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        AppDate.panjang(log.tanggal),
                        style: AppTextStyles.caption,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (_perubahan != null)
                      Text(
                        WeightMath.labelPerubahan(_perubahan!),
                        style: AppTextStyles.label.copyWith(
                          color: _warnaPerubahan,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
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
