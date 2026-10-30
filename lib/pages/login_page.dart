import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/utils/validators.dart';
import '../core/widgets/app_text_field.dart';
import '../core/widgets/app_snackbar.dart';
import '../core/widgets/error_text.dart';
import '../core/widgets/primary_button.dart';
import '../features/auth/data/auth_error.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/auth/presentation/widgets/auth_shell.dart';

/// H1 Login.
///
/// Setelah masuk berhasil, router sendiri yang memindahkan pengguna ke
/// Dashboard lewat `redirect` (lihat `app/router.dart`).
class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  bool _loading = false;
  bool _resetLoading = false;
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  /// K8 — kirim tautan atur ulang kata sandi ke email yang sudah diisi.
  ///
  /// Email diambil dari kolom yang ada, bukan dari dialog terpisah, supaya
  /// pengguna tidak mengetik alamat yang sama dua kali. Kalau kolomnya masih
  /// kosong atau formatnya salah, alur dihentikan sebelum dialog dibuka —
  /// tidak ada gunanya mengonfirmasi pengiriman ke alamat yang belum sah.
  Future<void> _lupaSandi() async {
    final email = _email.text.trim();
    final pesanEmail = Validators.email(email);
    if (pesanEmail != null) {
      AppSnackBar.galat(context, pesanEmail);
      return;
    }

    final setuju = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text(AppStrings.resetJudul),
        content: Text(
          AppStrings.resetPesan(email),
          style: AppTextStyles.body,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.batal),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.resetKirim),
          ),
        ],
      ),
    );

    // Dialog bisa ditutup dengan tombol kembali atau tap di luar — perlakukan
    // sama seperti "Batal".
    if (setuju != true || !mounted) return;

    setState(() => _resetLoading = true);
    try {
      await ref.read(authRepositoryProvider).sendPasswordReset(email);
      if (!mounted) return;
      AppSnackBar.sukses(context, AppStrings.resetTerkirim);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.galat(context, passwordResetErrorMessage(e));
    } finally {
      if (mounted) setState(() => _resetLoading = false);
    }
  }

  Future<void> _submit() async {
    setState(() => _error = null);

    // Validasi dulu; kalau gagal, beri tahu lewat pesan status di bawah layar
    // supaya pengguna tahu mengapa belum terkirim (modul Minggu 7).
    if (!(_formKey.currentState?.validate() ?? false)) {
      AppSnackBar.galat(context, AppStrings.periksaIsian);
      return;
    }

    setState(() => _loading = true);
    try {
      await ref.read(authRepositoryProvider).signIn(
            email: _email.text,
            password: _password.text,
          );
      // Navigasi ditangani redirect router; pesan tetap tampil karena
      // ScaffoldMessenger berada di atas Navigator.
      if (mounted) AppSnackBar.sukses(context, AppStrings.loginBerhasil);
    } catch (e) {
      if (!mounted) return;
      final pesan = authErrorMessage(e);
      setState(() => _error = pesan);
      AppSnackBar.galat(context, pesan);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: AppStrings.halamanLogin,
      subtitle: AppStrings.loginSubtitle,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.belumPunyaAkun,
            style: AppTextStyles.caption.copyWith(color: AppColors.peach200),
          ),
          TextButton(
            onPressed: _loading ? null : () => context.go(AppRoutes.register),
            child: Text(
              AppStrings.halamanDaftar,
              style: AppTextStyles.label.copyWith(
                color: AppColors.peach100,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      child: Form(
        key: _formKey,
        // Pesan kesalahan ikut diperbarui begitu kolom diubah, jadi pesan lama
        // tidak tertinggal setelah diperbaiki (modul Minggu 7).
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _email,
              label: AppStrings.email,
              keyboardType: TextInputType.emailAddress,
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.email],
              validator: Validators.email,
              enabled: !_loading,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _password,
              label: AppStrings.kataSandi,
              obscure: true,
              textInputAction: TextInputAction.done,
              autofillHints: const [AutofillHints.password],
              validator: Validators.kataSandi,
              onFieldSubmitted: (_) => _submit(),
              enabled: !_loading,
            ),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: (_loading || _resetLoading) ? null : _lupaSandi,
                style: TextButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  minimumSize: const Size(0, 32),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: Text(
                  _resetLoading
                      ? AppStrings.resetMengirim
                      : AppStrings.lupaKataSandi,
                  style: AppTextStyles.caption.copyWith(
                    // Warna burgundy, bukan peach: tombol ini berada di atas
                    // kartu krem (#FBECE1), dan peach di atas krem hampir tidak
                    // terbaca. Saat menunggu, warnanya diredupkan.
                    color: (_loading || _resetLoading)
                        ? AppColors.ink300
                        : AppColors.burgundy700,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              ErrorText(_error!),
            ],
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: AppStrings.masuk,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
