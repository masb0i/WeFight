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
  String? _error;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
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
