import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_spacing.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/app_text_styles.dart';
import '../../../../core/utils/angka.dart';
import '../../../../core/utils/date_format.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/status_chip.dart';
import '../../../weight_log/models/weight_log.dart';

/// Grafik tren berat badan (M13).
///
/// Aturan bisnis `docs/PLAN.md` §3 poin 7: grafik **butuh minimal 2 catatan**;
/// dengan 0 atau 1 catatan, yang tampil adalah pesan "data belum cukup",
/// bukan grafik kosong.
///
/// Tampilan mengikuti `docs/UI_SPEC.md` §4 (`WeightChart`): garis `rose400`
/// 2,5 px, area gradient di bawah garis, titik 4 px, dan garis target
/// putus-putus `clay300`.
class TrenChart extends StatelessWidget {
  const TrenChart({super.key, required this.logs, this.batasBerat});

  /// Catatan berat, **urut tanggal terbaru lebih dulu** (sama seperti
  /// `weightLogsProvider`). Di dalam grafik urutannya dibalik.
  final List<WeightLog> logs;

  /// Batas berat; null berarti tidak ada garis target.
  final double? batasBerat;

  static const _tinggi = 220.0;

  bool get _cukup => logs.length >= 2;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(AppStrings.grafikJudul, style: AppTextStyles.h2),
              ),
              if (_cukup)
                StatusChip(label: AppStrings.grafikJumlah(logs.length)),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            _cukup && batasBerat == null
                ? AppStrings.grafikTanpaTarget
                : AppStrings.grafikSubtitle,
            style: AppTextStyles.caption,
          ),
          const SizedBox(height: AppSpacing.lg),
          if (!_cukup)
            const _BelumCukup()
          else
            // M13-4: area grafik dipisah dari sisa halaman supaya tooltip dan
            // animasi garis tidak memicu repaint seluruh layar.
            RepaintBoundary(
              child: SizedBox(
                height: _tinggi,
                child: LineChart(_data()),
              ),
            ),
        ],
      ),
    );
  }

  LineChartData _data() {
    // Provider memberi urutan terbaru → terlama; grafik dibaca kiri ke kanan
    // dari yang terlama.
    final urut = logs.reversed.toList(growable: false);
    final spots = [
      for (var i = 0; i < urut.length; i++)
        FlSpot(i.toDouble(), urut[i].berat),
    ];

    final semuaNilai = [...urut.map((log) => log.berat), ?batasBerat];
    final minY = semuaNilai.reduce((a, b) => a < b ? a : b).floorToDouble() - 1;
    final maxY = semuaNilai.reduce((a, b) => a > b ? a : b).ceilToDouble() + 1;

    // Label sumbu X dipilih secukupnya: semua titik bila sedikit, dan hanya
    // awal–tengah–akhir bila banyak, supaya tidak saling menimpa di layar 360 px.
    final indeksLabel = _indeksLabel(urut.length);

    return LineChartData(
      minX: 0,
      maxX: (urut.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      clipData: const FlClipData.all(),
      gridData: FlGridData(
        drawVerticalLine: false,
        horizontalInterval: (maxY - minY) / 4,
        getDrawingHorizontalLine: (_) => const FlLine(
          color: AppColors.border,
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(show: false),
      titlesData: FlTitlesData(
        topTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        rightTitles: const AxisTitles(
          sideTitles: SideTitles(showTitles: false),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 36,
            interval: (maxY - minY) / 4,
            getTitlesWidget: (nilai, _) => Text(
              Angka.kg(nilai),
              style: AppTextStyles.caption,
            ),
          ),
        ),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: true,
            reservedSize: 26,
            interval: 1,
            getTitlesWidget: (nilai, meta) {
              final i = nilai.round();
              if (!indeksLabel.contains(i)) return const SizedBox.shrink();
              // `fitInside` menahan label pertama/terakhir agar tidak terpotong
              // tepi kartu — tanpa ini "1 Okt" hilang separuh.
              return SideTitleWidget(
                meta: meta,
                space: AppSpacing.sm,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta),
                child: Text(
                  AppDate.sumbu(urut[i].tanggal),
                  style: AppTextStyles.caption,
                ),
              );
            },
          ),
        ),
      ),
      extraLinesData: ExtraLinesData(
        horizontalLines: [
          if (batasBerat != null)
            HorizontalLine(
              y: batasBerat!,
              color: AppColors.clay300,
              strokeWidth: 1.5,
              dashArray: const [6, 4],
              label: HorizontalLineLabel(
                show: true,
                alignment: Alignment.topRight,
                style: AppTextStyles.caption.copyWith(
                  color: AppColors.rose500,
                ),
                labelResolver: (_) =>
                    AppStrings.grafikGarisTarget(Angka.kg(batasBerat!)),
              ),
            ),
        ],
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          color: AppColors.rose400,
          barWidth: 2.5,
          isCurved: true,
          curveSmoothness: 0.25,
          preventCurveOverShooting: true,
          isStrokeCapRound: true,
          dotData: FlDotData(
            show: true,
            getDotPainter: (_, _, _, _) => FlDotCirclePainter(
              radius: 4,
              color: AppColors.burgundy700,
              strokeWidth: 2,
              strokeColor: AppColors.cream200,
            ),
          ),
          belowBarData: BarAreaData(
            show: true,
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0x38B7776D), Color(0x00B7776D)],
            ),
          ),
        ),
      ],
      lineTouchData: LineTouchData(
        touchTooltipData: LineTouchTooltipData(
          getTooltipColor: (_) => AppColors.burgundy700,
          getTooltipItems: (disentuh) => [
            for (final titik in disentuh)
              LineTooltipItem(
                '${Angka.kg(titik.y)} ${AppStrings.satuanKg}',
                AppTextStyles.label.copyWith(color: AppColors.peach100),
              ),
          ],
        ),
      ),
    );
  }
}

/// Indeks titik yang diberi label di sumbu X.
///
/// ≤4 titik: semua. Lebih dari itu: awal, tengah, akhir — tiga label selalu
/// muat di lebar 360 px dan tetap menunjukkan rentang tanggalnya.
Set<int> _indeksLabel(int jumlah) {
  if (jumlah <= 1) return {0};
  if (jumlah <= 4) return {for (var i = 0; i < jumlah; i++) i};
  return {0, (jumlah - 1) ~/ 2, jumlah - 1};
}

/// Keadaan "data belum cukup" (M13-2).
class _BelumCukup extends StatelessWidget {
  const _BelumCukup();

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xxl,
      ),
      decoration: BoxDecoration(
        color: AppColors.cream100,
        borderRadius: BorderRadius.circular(AppRadius.input),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.show_chart,
            size: 28,
            color: AppColors.ink300,
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(AppStrings.grafikBelumCukup, style: AppTextStyles.h3),
          const SizedBox(height: AppSpacing.xs),
          Text(
            AppStrings.grafikBelumCukupPesan,
            style: AppTextStyles.body.copyWith(color: AppColors.ink500),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
