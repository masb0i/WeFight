import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/angka.dart';
import '../core/utils/date_format.dart';
import '../core/utils/validators.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_snackbar.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/primary_button.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/weight_log/data/weight_log_repository.dart';
import '../features/weight_log/models/weight_log.dart';
import '../features/weight_log/presentation/weight_log_providers.dart';

/// H5 Catat Berat.
///
/// Satu halaman untuk dua mode (M10-4):
///  * tambah — route `/weight/new`, `logId == null`
///  * ubah   — route `/weight/:id/edit`, `logId != null`
///
/// Aturan bisnis yang dijaga (PLAN §3 poin 1): **satu catatan per tanggal**.
/// Kalau tanggal yang dipilih sudah punya catatan, aplikasi menawarkan mode
/// ubah — tidak pernah membuat duplikat.
class CatatBeratPage extends ConsumerStatefulWidget {
  const CatatBeratPage({super.key, this.logId});

  /// Id catatan yang sedang diubah. Null berarti mode tambah.
  final String? logId;

  bool get isEdit => logId != null;

  @override
  ConsumerState<CatatBeratPage> createState() => _CatatBeratPageState();
}

class _CatatBeratPageState extends ConsumerState<CatatBeratPage> {
  final _formKey = GlobalKey<FormState>();
  final _berat = TextEditingController();
  final _catatan = TextEditingController();
  final _tanggal = TextEditingController();

  /// Tanggal terpilih. Default hari ini (M10-1).
  DateTime _tanggalTimbang = AppDate.hariIni();

  bool _menyimpan = false;
  bool _memuat = false;
  bool _tidakDitemukan = false;

  @override
  void initState() {
    super.initState();
    _tanggal.text = AppDate.panjang(_tanggalTimbang);

    if (widget.isEdit) {
      _memuat = true;
      WidgetsBinding.instance.addPostFrameCallback((_) => _muatCatatan());
    }
  }

  @override
  void dispose() {
    _berat.dispose();
    _catatan.dispose();
    _tanggal.dispose();
    super.dispose();
  }

  Future<void> _muatCatatan() async {
    final id = widget.logId;
    if (id == null) return;

    try {
      final catatan = await ref.read(weightLogRepositoryProvider).ambil(id);
      if (!mounted) return;

      if (catatan == null) {
        setState(() {
          _tidakDitemukan = true;
          _memuat = false;
        });
        return;
      }

      _berat.text = Angka.kg(catatan.berat);
      _catatan.text = catatan.catatan ?? '';
      _tanggalTimbang = catatan.tanggal;
      _tanggal.text = AppDate.panjang(catatan.tanggal);
      setState(() => _memuat = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _memuat = false);
      AppSnackBar.galat(context, AppStrings.simpanGagal);
    }
  }

  Future<void> _pilihTanggal() async {
    final hariIni = AppDate.hariIni();
    final dipilih = await showDatePicker(
      context: context,
      initialDate: _tanggalTimbang.isAfter(hariIni) ? hariIni : _tanggalTimbang,
      // Catatan berat tidak bisa berada di masa depan, tetapi boleh diisi
      // mundur untuk mencatat timbangan beberapa hari lalu.
      firstDate: hariIni.subtract(const Duration(days: 730)),
      lastDate: hariIni,
      helpText: AppStrings.labelTanggalTimbang,
    );

    if (dipilih == null || !mounted) return;
    setState(() {
      _tanggalTimbang = AppDate.tanpaJam(dipilih);
      _tanggal.text = AppDate.panjang(dipilih);
    });
  }

  Future<void> _simpan() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackBar.galat(context, AppStrings.periksaIsian);
      return;
    }

    final uid = ref.read(currentUidProvider);
    final berat = Angka.parseKg(_berat.text);
    if (uid == null || berat == null) {
      AppSnackBar.galat(context, AppStrings.simpanGagal);
      return;
    }

    final isiCatatan = _catatan.text.trim();
    setState(() => _menyimpan = true);

    try {
      final repo = ref.read(weightLogRepositoryProvider);

      if (widget.isEdit) {
        await _simpanPerubahan(repo, uid, berat, isiCatatan);
        return;
      }

      // Aturan §3 poin 1: cek duplikat sebelum menambah.
      final bentrok = await repo.cariTanggal(uid, _tanggalTimbang);
      if (bentrok != null) {
        if (!mounted) return;
        setState(() => _menyimpan = false);
        final mauUbah = await _tanyaDuplikat(bentrok);
        if (mauUbah == true && mounted) {
          context.pushReplacement(AppRoutes.editBeratPath(bentrok.id));
        }
        return;
      }

      await repo.tambah(
        uid,
        WeightLog(
          tanggal: _tanggalTimbang,
          berat: berat,
          catatan: isiCatatan.isEmpty ? null : isiCatatan,
          dibuatPada: DateTime.now(),
          diperbaruiPada: DateTime.now(),
        ),
      );
      if (!mounted) return;

      AppSnackBar.sukses(context, AppStrings.catatanTersimpan);
      _kembali();
    } catch (_) {
      // M10-5: isian tidak dibersihkan supaya pengguna bisa mencoba lagi.
      if (!mounted) return;
      AppSnackBar.galat(context, AppStrings.simpanGagal);
    } finally {
      if (mounted) setState(() => _menyimpan = false);
    }
  }

  Future<void> _simpanPerubahan(
    WeightLogRepository repo,
    String uid,
    double berat,
    String isiCatatan,
  ) async {
    // Memindahkan catatan ke tanggal yang sudah dipakai catatan lain akan
    // membuat duplikat — tolak, jangan diam-diam menimpa.
    final bentrok = await repo.cariTanggal(uid, _tanggalTimbang);
    if (bentrok != null && bentrok.id != widget.logId) {
      if (!mounted) return;
      AppSnackBar.galat(context, AppStrings.tanggalDipakaiLain);
      return;
    }

    await repo.ubah(
      uid,
      WeightLog(
        id: widget.logId!,
        tanggal: _tanggalTimbang,
        berat: berat,
        catatan: isiCatatan.isEmpty ? null : isiCatatan,
        diperbaruiPada: DateTime.now(),
      ),
    );
    if (!mounted) return;

    AppSnackBar.sukses(context, AppStrings.catatanDiperbarui);
    _kembali();
  }

  Future<bool?> _tanyaDuplikat(WeightLog bentrok) {
    return showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.duplikatJudul),
        content: Text(
          AppStrings.duplikatPesan(
            Angka.kg(bentrok.berat),
            AppDate.panjang(bentrok.tanggal),
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
            child: const Text(AppStrings.ubahCatatan),
          ),
        ],
      ),
    );
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.halamanCatatBerat),
        centerTitle: isWide,
      ),
      body: _memuat
          ? const Center(child: CircularProgressIndicator())
          : _tidakDitemukan
              ? _CatatanHilang(onKembali: _kembali)
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    padding,
                    0,
                    padding,
                    AppSpacing.huge,
                  ),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 560),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            widget.isEdit
                                ? AppStrings.catatSubtitleEdit
                                : AppStrings.catatSubtitleTambah,
                            style: AppTextStyles.body.copyWith(
                              color: AppColors.ink500,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          AppCard(
                            child: Form(
                              key: _formKey,
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  AppTextField(
                                    controller: _tanggal,
                                    label: AppStrings.labelTanggalTimbang,
                                    readOnly: true,
                                    onTap: _menyimpan ? null : _pilihTanggal,
                                    suffixIcon: IconButton(
                                      onPressed:
                                          _menyimpan ? null : _pilihTanggal,
                                      tooltip: AppStrings.pilihTanggal,
                                      icon: const Icon(
                                        Icons.calendar_today_outlined,
                                        size: 18,
                                        color: AppColors.ink500,
                                      ),
                                    ),
                                    enabled: !_menyimpan,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  AppTextField(
                                    controller: _berat,
                                    label: AppStrings.labelBeratBadan,
                                    helper: AppStrings.bantuanBerat,
                                    keyboardType:
                                        const TextInputType.numberWithOptions(
                                      decimal: true,
                                    ),
                                    textInputAction: TextInputAction.next,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.allow(
                                        RegExp(r'[0-9.,]'),
                                      ),
                                    ],
                                    validator: Validators.berat,
                                    enabled: !_menyimpan,
                                  ),
                                  const SizedBox(height: AppSpacing.xl),
                                  AppTextField(
                                    controller: _catatan,
                                    label: AppStrings.labelCatatan,
                                    hint: AppStrings.hintCatatan,
                                    maxLines: 3,
                                    textCapitalization:
                                        TextCapitalization.sentences,
                                    enabled: !_menyimpan,
                                  ),
                                  const SizedBox(height: AppSpacing.xxl),
                                  PrimaryButton(
                                    label: AppStrings.simpan,
                                    icon: Icons.check,
                                    loading: _menyimpan,
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
}

/// Keadaan ketika id catatan yang dibuka sudah tidak ada (mis. dihapus di
/// perangkat lain).
class _CatatanHilang extends StatelessWidget {
  const _CatatanHilang({required this.onKembali});

  final VoidCallback onKembali;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xxl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.search_off, size: 40, color: AppColors.ink300),
            const SizedBox(height: AppSpacing.lg),
            Text(AppStrings.catatanTidakDitemukan, style: AppTextStyles.h3),
            const SizedBox(height: AppSpacing.xl),
            OutlinedButton(
              onPressed: onKembali,
              child: const Text(AppStrings.kembali),
            ),
          ],
        ),
      ),
    );
  }
}
