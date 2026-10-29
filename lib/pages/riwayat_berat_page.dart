import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/angka.dart';
import '../core/utils/date_format.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/app_snackbar.dart';
import '../core/widgets/empty_state.dart';
import '../core/widgets/status_chip.dart';
import '../features/weight_log/models/weight_log.dart';
import '../features/weight_log/presentation/weight_log_providers.dart';
import '../features/weight_log/presentation/widgets/riwayat_tile.dart';

/// H6 Riwayat Berat.
///
/// Daftar seluruh catatan pengguna, urut tanggal terbaru (M11-1). Ketuk satu
/// baris untuk mengubahnya (M11-2), atau ikon hapus untuk menghapus setelah
/// konfirmasi. Daftar memakai `weightLogsProvider` — stream Firestore yang sama
/// dengan Dashboard — sehingga tambah/ubah/hapus langsung terlihat tanpa
/// memuat ulang halaman (M11-5, keputusan D8).
class RiwayatBeratPage extends ConsumerWidget {
  const RiwayatBeratPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    final padding = isWide ? AppSpacing.pageWeb : AppSpacing.pageMobile;
    final catatan = ref.watch(weightLogsProvider);

    return AppScaffold(
      index: 1,
      title: AppStrings.halamanRiwayat,
      child: catatan.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, _) => _GagalMuat(
          onCobaLagi: () => ref.invalidate(weightLogsProvider),
        ),
        data: (logs) => logs.isEmpty
            ? _Kosong(padding: padding)
            : _Daftar(
                logs: logs,
                padding: padding,
                onUbah: (log) =>
                    context.push(AppRoutes.editBeratPath(log.id)),
                onHapus: (log) => _konfirmasiHapus(context, ref, log),
              ),
      ),
    );
  }

  /// M11-2: hapus selalu lewat dialog konfirmasi — tidak ada aksi
  /// yang tidak bisa dibatalkan tanpa persetujuan.
  Future<void> _konfirmasiHapus(
    BuildContext context,
    WidgetRef ref,
    WeightLog log,
  ) async {
    final repo = ref.read(weightLogRepositoryProvider);

    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.hapusCatatanJudul),
        content: Text(
          AppStrings.hapusCatatanPesan(
            Angka.kg(log.berat),
            AppDate.panjang(log.tanggal),
          ),
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.batal),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.hapus),
          ),
        ],
      ),
    );

    if (setuju != true || !context.mounted) return;

    try {
      await repo.hapus(log.id);
      if (!context.mounted) return;
      AppSnackBar.sukses(context, AppStrings.catatanDihapus);
    } catch (_) {
      if (!context.mounted) return;
      AppSnackBar.galat(context, AppStrings.hapusGagal);
    }
  }
}

/// Daftar catatan + judul kecil di atasnya.
class _Daftar extends StatelessWidget {
  const _Daftar({
    required this.logs,
    required this.padding,
    required this.onUbah,
    required this.onHapus,
  });

  final List<WeightLog> logs;
  final double padding;
  final void Function(WeightLog log) onUbah;
  final void Function(WeightLog log) onHapus;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: ListView.builder(
          padding: EdgeInsets.fromLTRB(padding, padding, padding, 96),
          // Indeks 0 adalah kepala daftar, sisanya catatan.
          itemCount: logs.length + 1,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _KepalaDaftar(jumlah: logs.length);
            }

            final log = logs[index - 1];
            // logs sudah urut terbaru → lebih dulu, jadi pembandingnya adalah
            // item berikutnya di daftar.
            final sebelumnya = index < logs.length ? logs[index] : null;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: RiwayatTile(
                key: ValueKey('riwayat-${log.id}'),
                log: log,
                sebelumnya: sebelumnya,
                onTap: () => onUbah(log),
                onHapus: () => onHapus(log),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _KepalaDaftar extends StatelessWidget {
  const _KepalaDaftar({required this.jumlah});

  final int jumlah;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  AppStrings.riwayatSubtitle,
                  style: AppTextStyles.body.copyWith(color: AppColors.ink500),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              StatusChip(label: AppStrings.riwayatJumlah(jumlah)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(AppStrings.riwayatTapHint, style: AppTextStyles.caption),
        ],
      ),
    );
  }
}

/// M11-3: keadaan kosong menjelaskan dan mengarahkan, bukan layar kosong.
class _Kosong extends StatelessWidget {
  const _Kosong({required this.padding});

  final double padding;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(padding, padding, padding, 96),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: AppCard(
            child: EmptyState(
              icon: Icons.history,
              title: AppStrings.riwayatKosongJudul,
              message: AppStrings.riwayatKosongPesan,
              primaryLabel: AppStrings.catatBerat,
              onPrimary: () => context.push(AppRoutes.catatBerat),
            ),
          ),
        ),
      ),
    );
  }
}

class _GagalMuat extends StatelessWidget {
  const _GagalMuat({required this.onCobaLagi});

  final VoidCallback onCobaLagi;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageMobile),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: AppCard(
            child: EmptyState(
              icon: Icons.cloud_off,
              title: AppStrings.muatGagal,
              message: AppStrings.muatGagalPesan,
              primaryLabel: AppStrings.coba,
              onPrimary: onCobaLagi,
            ),
          ),
        ),
      ),
    );
  }
}
