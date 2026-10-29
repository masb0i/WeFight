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
import '../core/widgets/gagal_muat.dart';
import '../core/widgets/primary_button.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/dashboard/presentation/widgets/hero_weight_card.dart';
import '../features/dashboard/presentation/widgets/peach_info_card.dart';
import '../features/dashboard/presentation/widgets/tren_chart.dart';
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

    // D25: galat dibedakan dari keadaan kosong. Tanpa ini, query yang gagal
    // tampil sebagai "Belum ada catatan berat" dan angka "—", sehingga
    // pengguna mengira catatannya hilang.
    final gagal = logsAsync.hasError || targetAsync.hasError;

    final batas = target.batasBerat;
    final tanggalTimbang = target.tanggalTimbang;

    // PLAN §3 poin 4: selisih hanya bisa dihitung bila dua angkanya ada.
    final String deltaLabel;
    if (gagal && terakhir == null) {
      deltaLabel = AppStrings.heroGagalMuat;
    } else if (terakhir == null) {
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

    // Selama galat, spinner tidak boleh terus berputar — tampilkan kartu
    // galat dengan tombol coba lagi (D25).
    final memuat = !gagal && (targetAsync.isLoading || logsAsync.isLoading);
    final targetKosong = batas == null && tanggalTimbang == null;

    // M14-2: mulai 1024 px konten dipecah dua kolom — angka ringkasan di kiri,
    // grafik di kanan. Di bawah itu tetap satu kolom supaya tidak sempit.
    final lebar = MediaQuery.sizeOf(context).width;
    final duaKolom = lebar >= AppBreakpoints.tablet;

    // Kolom kiri: berat terakhir, aksi utama, hitung mundur.
    final kiri = <Widget>[
      HeroWeightCard(
        beratKg: terakhir?.berat,
        targetKg: batas,
        deltaLabel: deltaLabel,
        onEdit: () => context.push(AppRoutes.target),
      ),
      const SizedBox(height: AppSpacing.gap),
      // M12-5: aksi utama aplikasi, selebar konten, sama di mobile dan web.
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
    ];

    // Kolom kanan: ajakan target dan grafik tren.
    final kanan = <Widget>[
      // D25: galat didahulukan — jangan menampilkan "belum ada catatan" atau
      // grafik kosong saat datanya sebenarnya tidak berhasil diambil.
      if (gagal)
        GagalMuat(
          onCobaLagi: () {
            ref.invalidate(weightLogsProvider);
            ref.invalidate(targetProvider);
          },
          judul: AppStrings.dashboardGagal,
          pesan: AppStrings.dashboardGagalPesan,
        )
      else ...[
        // M12-4: kartu ajakan hanya untuk target yang benar-benar kosong,
        // bukan untuk target yang tinggal satu kolom.
        if (targetKosong) ...[
          _AjakanTarget(onAtur: () => context.push(AppRoutes.target)),
          const SizedBox(height: AppSpacing.gap),
        ],
        if (logs.isEmpty)
          const _KosongCatatan()
        else
          // M13: grafik tren. Dengan 1 catatan, kartu ini sendiri yang
          // menampilkan "data belum cukup" (PLAN §3 poin 7).
          TrenChart(logs: logs, batasBerat: batas),
      ],
    ];

    return AppScaffold(
      index: 0,
      // Di layar lebar tombol "Catat Berat" sudah ada di kolom kiri, jadi FAB
      // tidak ditampilkan dua kali.
      showFab: !isWide,
      child: memuat
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(padding, padding, padding, 96),
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: duaKolom ? AppSizes.maxContent : 720,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppTopBar(
                        greeting: 'Halo, ${name.split(' ').first}!',
                        initial: initial,
                        name: name,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      if (duaKolom)
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              flex: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: kiri,
                              ),
                            ),
                            const SizedBox(width: AppSpacing.gap),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: kanan,
                              ),
                            ),
                          ],
                        )
                      else
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            ...kiri,
                            const SizedBox(height: AppSpacing.gap),
                            ...kanan,
                          ],
                        ),
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
