import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/date_format.dart';
import '../core/utils/validators.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_snackbar.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/primary_button.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/target/models/target.dart';
import '../features/target/presentation/target_providers.dart';

/// H4 Target Timbang.
///
/// Halaman turunan (dibuka dengan `push` dari Dashboard), jadi memakai
/// `Scaffold` biasa tanpa menu bawah.
///
/// Aturan bisnis yang dijaga (PLAN §3 poin 3): **kedua kolom boleh kosong**.
/// Menyimpan form kosong berarti menghapus target, bukan menghasilkan galat.
class TargetTimbangPage extends ConsumerStatefulWidget {
  const TargetTimbangPage({super.key});

  @override
  ConsumerState<TargetTimbangPage> createState() => _TargetTimbangPageState();
}

class _TargetTimbangPageState extends ConsumerState<TargetTimbangPage> {
  final _formKey = GlobalKey<FormState>();
  final _batas = TextEditingController();
  final _tanggal = TextEditingController();

  DateTime? _tanggalTimbang;
  bool _loading = false;

  /// Penanda agar aliran data dari Firestore hanya mengisi form sekali —
  /// kalau tidak, ketikan pengguna bisa tertimpa saat stream memperbarui.
  bool _sudahDiisi = false;

  @override
  void initState() {
    super.initState();
    // Nilai tersimpan (mode edit) dibaca setelah frame pertama; membaca
    // provider saat initState belum tentu sudah punya data.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final tersimpan = ref.read(targetProvider).asData?.value;
      if (tersimpan != null) _isiDari(tersimpan);
    });
  }

  @override
  void dispose() {
    _batas.dispose();
    _tanggal.dispose();
    super.dispose();
  }

  void _isiDari(Target target) {
    if (_sudahDiisi) return;
    _sudahDiisi = true;

    final batas = target.batasBerat;
    _batas.text = batas == null ? '' : _formatAngka(batas);
    _tanggalTimbang = target.tanggalTimbang;
    _tanggal.text =
        target.tanggalTimbang == null ? '' : AppDate.panjang(target.tanggalTimbang!);
  }

  /// `71` tetap `71`, bukan `71.0`.
  static String _formatAngka(double nilai) {
    return nilai == nilai.roundToDouble()
        ? nilai.toStringAsFixed(0)
        : nilai.toStringAsFixed(1);
  }

  Future<void> _pilihTanggal() async {
    final hariIni = AppDate.hariIni();
    final awal = _tanggalTimbang ?? hariIni.add(const Duration(days: 30));

    final dipilih = await showDatePicker(
      context: context,
      // Batas tanggal adalah bentuk validasi: hari yang sudah lewat tidak bisa
      // dipilih sebagai hari timbang.
      initialDate: awal.isBefore(hariIni) ? hariIni : awal,
      firstDate: hariIni,
      lastDate: hariIni.add(const Duration(days: 730)),
      helpText: AppStrings.labelTanggalTimbang,
    );

    if (dipilih == null || !mounted) return;
    setState(() {
      _tanggalTimbang = AppDate.tanpaJam(dipilih);
      _tanggal.text = AppDate.panjang(dipilih);
    });
  }

  void _hapusTanggal() {
    setState(() {
      _tanggalTimbang = null;
      _tanggal.clear();
    });
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackBar.galat(context, AppStrings.periksaIsian);
      return;
    }

    final uid = ref.read(currentUidProvider);
    if (uid == null) {
      AppSnackBar.galat(context, AppStrings.simpanGagal);
      return;
    }

    setState(() => _loading = true);
    try {
      final target = Target(
        batasBerat: _parseBatas(_batas.text),
        tanggalTimbang: _tanggalTimbang,
        diperbaruiPada: DateTime.now(),
      );

      await ref.read(targetRepositoryProvider).simpan(uid, target);
      if (!mounted) return;

      AppSnackBar.sukses(context, AppStrings.targetTersimpan);
      _kembali();
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.galat(context, AppStrings.simpanGagal);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Kosong → null (target tanpa batas berat). Koma desimal diterima.
  static double? _parseBatas(String teks) {
    final bersih = teks.trim().replaceAll(',', '.');
    if (bersih.isEmpty) return null;
    return double.tryParse(bersih);
  }

  void _kembali() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.go(AppRoutes.dashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    final padding = isWide ? AppSpacing.pageWeb : AppSpacing.pageMobile;

    // Mengisi form begitu data dari Firestore tiba (mis. dibuka lewat URL
    // langsung, bukan dari Dashboard yang sudah memuat data).
    ref.listen<AsyncValue<Target>>(targetProvider, (_, next) {
      final target = next.asData?.value;
      if (target != null) _isiDari(target);
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.halamanTarget),
        // Di layar lebar judul ditengahkan agar sejajar dengan kartu form yang
        // juga di tengah, bukan menempel di ujung kiri layar.
        centerTitle: isWide,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, 0, padding, AppSpacing.huge),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AppStrings.targetSubtitle,
                  style: AppTextStyles.body.copyWith(color: AppColors.ink500),
                ),
                const SizedBox(height: AppSpacing.xl),
                AppCard(
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        AppTextField(
                          controller: _batas,
                          label: AppStrings.labelBatasBerat,
                          helper: AppStrings.targetBantuanBatas,
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          textInputAction: TextInputAction.done,
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9.,]'),
                            ),
                          ],
                          validator: Validators.batasBeratOpsional,
                          enabled: !_loading,
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        AppTextField(
                          controller: _tanggal,
                          label: AppStrings.labelTanggalTimbang,
                          helper: AppStrings.targetBantuanTanggal,
                          hint: AppStrings.pilihTanggal,
                          readOnly: true,
                          onTap: _loading ? null : _pilihTanggal,
                          suffixIcon: _ikonTanggal(),                          enabled: !_loading,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        const _InfoTargetKosong(),                        const SizedBox(height: AppSpacing.xxl),
                        PrimaryButton(
                          label: AppStrings.simpan,
                          icon: Icons.check,
                          loading: _loading,
                          onPressed: _simpan,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Ikon mengikuti isi controller, bukan variabel state, supaya tombol hapus
  /// langsung muncul saat form terisi dari data tersimpan — tanpa perlu
  /// `setState` di tengah proses memuat.
  Widget _ikonTanggal() {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: _tanggal,
      builder: (context, nilai, _) {
        final adaIsi = nilai.text.isNotEmpty;
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              onPressed: _loading ? null : _pilihTanggal,
              tooltip: AppStrings.pilihTanggal,
              visualDensity: VisualDensity.compact,
              icon: const Icon(
                Icons.calendar_today_outlined,
                size: 18,
                color: AppColors.ink500,
              ),
            ),
            if (adaIsi)
              IconButton(
                onPressed: _loading ? null : _hapusTanggal,
                tooltip: AppStrings.hapusTanggal,
                visualDensity: VisualDensity.compact,
                icon: const Icon(
                  Icons.close,
                  size: 18,
                  color: AppColors.ink500,
                ),
              ),
          ],
        );
      },
    );
  }
}

/// Keterangan bahwa target boleh kosong — supaya pengguna tidak mengira form
/// kosong adalah galat.
class _InfoTargetKosong extends StatelessWidget {
  const _InfoTargetKosong();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.cream100,
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline,
            size: 16,
            color: AppColors.ink500,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              AppStrings.targetInfoKosong,
              style: AppTextStyles.caption.copyWith(color: AppColors.ink500),
            ),
          ),
        ],
      ),
    );
  }
}
