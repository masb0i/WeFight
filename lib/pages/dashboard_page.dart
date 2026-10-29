import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/weight_math.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/primary_button.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/dashboard/presentation/widgets/hero_weight_card.dart';
import '../features/dashboard/presentation/widgets/peach_info_card.dart';
import '../features/target/models/target.dart';
import '../features/target/presentation/target_providers.dart';
import '../features/weight_log/presentation/weight_log_providers.dart';

/// H3 Dashboard.
///
/// M12: kartu ringkasan berisi berat terakhir, selisih terhadap batas, dan
/// hitung mundur hari timbang. Semua angkanya datang dari `WeightMath`
/// (`docs/PLAN.md` §3 poin 4–6) — halaman ini tidak menghitung apa pun sendiri.
///
/// Keadaan yang ditangani (M12-3):
///  * belum ada catatan berat → kartu penjelasan, angka tampil "—"
///  * belum ada target → kartu ajakan "Atur Target Timbang" (M12-4)
///  * hari timbang lewat / hari ini / masih N hari lagi → chip di PeachInfoCard
///
/// Grafik tren menyusul di M13, tata letak dua kolom di M14.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    final padding = isWide ? AppSpacing.pageWeb : AppSpacing.pageMobile;

    final targetAsync = ref.watch(targetProvider);
    final logsAsync = ref.watch(weightLogsProvider);

    final name = ref.watch(currentUserNameProvider);
    final initial = ref.watch(currentUserInitialProvider);

    final target = targetAsync.asData?.value ?? const Target();
    final logs = logsAsync.asData?.value ?? const [];
    final terakhir = logs.isEmpty ? null : logs.first;

    final batas = target.batasBerat;
    final tanggalTimbang = target.tanggalTimbang;

    // PLAN §3 poin 4: selisih hanya bisa dihitung bila dua angkanya ada.
    final String deltaLabel;
    if (terakhir == null) {
      deltaLabel = AppStrings.heroBelumAdaCatatan;
    } else if (batas == null) {
      deltaLabel = AppStrings.heroBelumAdaTarget;
    } else {
      deltaLabel = WeightMath.labelSelisih(
        WeightMath.hitungSelisih(
          beratTerakhir: terakhir.berat,
          batasBerat: batas,
        ),
      );
    }

    final memuat = targetAsync.isLoading || logsAsync.isLoading;
    final targetKosong = batas == null && tanggalTimbang == null;

    return AppScaffold(
      index: 0,
      child: memuat
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, 96),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 720),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTopBar(
                        greeting: 'Halo, ${name.split(' ').first}!',
                        initial: initial,
                        name: name,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      HeroWeightCard(
                        beratKg: terakhir?.berat,
                        targetKg: batas,
                        deltaLabel: deltaLabel,
                        onEdit: () => context.push(AppRoutes.target),
                      ),
                      const SizedBox(height: AppSpacing.gap),
                      // M12-5: aksi utama aplikasi, selebar konten, sama di
                      // mobile dan web.
                      PrimaryButton(
                        label: AppStrings.catatBerat,
                        icon: Icons.add,
                        onPressed: () => context.push(AppRoutes.catatBerat),
                      ),
                      if (tanggalTimbang != null) ...[
                        const SizedBox(height: AppSpacing.gap),
                        PeachInfoCard(
                          tanggal: tanggalTimbang,
                          sisaHari: WeightMath.hitungSisaHari(tanggalTimbang),
                        ),
                      ],
                      // M12-4: kartu ajakan hanya untuk target yang benar-benar
                      // kosong, bukan untuk target yang tinggal satu kolom.
                      if (targetKosong) ...[
                        const SizedBox(height: AppSpacing.gap),
                        _AjakanTarget(
                          onAtur: () => context.push(AppRoutes.target),
                        ),
                      ],
                      if (logs.isEmpty) ...[
                        const SizedBox(height: AppSpacing.gap),
                        const _KosongCatatan(),
                      ],
                    ],
                  ),
                ),
              ),
            ),
    );
  }
}

/// Ajakan mengatur target — muncul hanya bila target masih kosong (M12-4).
///
/// Tombolnya bergaya sekunder supaya tidak bersaing dengan "Catat Berat".
class _AjakanTarget extends StatelessWidget {
  const _AjakanTarget({required this.onAtur});

  final VoidCallback onAtur;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
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
                  Icons.flag_outlined,
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
                      AppStrings.belumAdaTargetJudul,
                      style: AppTextStyles.h3,
                    ),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      AppStrings.belumAdaTargetPesan,
                      style: AppTextStyles.body.copyWith(
                        color: AppColors.ink500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: onAtur,
              child: const Text(AppStrings.aturTarget),
            ),
          ),
        ],
      ),
    );
  }
}

/// Keadaan "belum ada catatan berat" (M12-3).
///
/// Tanpa tombol: tombol "Catat Berat" sudah ada tepat di atas kartu ini,
/// jadi menambahkan CTA kedua hanya mengulang aksi yang sama.
class _KosongCatatan extends StatelessWidget {
  const _KosongCatatan();

  @override
  Widget build(BuildContext context) {
    return const AppCard(
      child: EmptyState(
        icon: Icons.monitor_weight_outlined,
        title: AppStrings.dashboardKosongJudul,
        message: AppStrings.dashboardKosongPesan,
      ),
    );
  }
}
