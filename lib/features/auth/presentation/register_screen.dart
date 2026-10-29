import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/utils/validators.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/widgets/error_text.dart';
import '../../../core/widgets/primary_button.dart';
import '../../profile/models/user_profile.dart';
import '../../profile/presentation/profile_providers.dart';
import '../data/auth_error.dart';
import 'auth_providers.dart';
import 'widgets/auth_shell.dart';

/// H2 Daftar — prioritas Should.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nama = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _ulangi = TextEditingController();

  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _nama.dispose();
    _email.dispose();
    _password.dispose();
    _ulangi.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _error = null);
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _loading = true);
    try {
      final auth = ref.read(authRepositoryProvider);
      await auth.signUp(
        nama: _nama.text,
        email: _email.text,
        password: _password.text,
      );
      await _simpanProfil(auth.currentUid);
      // Navigasi ditangani redirect router.
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = authErrorMessage(e));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Menulis dokumen `users/{uid}` sesuai skema PLAN §1.3.
  ///
  /// Kegagalan di sini **tidak** menggagalkan pendaftaran: akun Auth sudah
  /// dibuat dan nama masih terbaca dari `displayName`.
  Future<void> _simpanProfil(String? uid) async {
    if (uid == null) return;
    try {
      await ref.read(userRepositoryProvider).simpanProfil(
            UserProfile(
              uid: uid,
              nama: _nama.text.trim(),
              email: _email.text.trim(),
            ),
          );
    } catch (error) {
      debugPrint('Gagal menyimpan profil users/$uid: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthShell(
      title: AppStrings.halamanDaftar,
      subtitle: AppStrings.registerSubtitle,
      footer: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            AppStrings.sudahPunyaAkun,
            style: AppTextStyles.caption.copyWith(color: AppColors.peach200),
          ),
          TextButton(
            onPressed: _loading ? null : () => context.go(AppRoutes.login),
            child: Text(
              AppStrings.masuk,
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AppTextField(
              controller: _nama,
              label: AppStrings.namaLengkap,
              textInputAction: TextInputAction.next,
              textCapitalization: TextCapitalization.words,
              autofillHints: const [AutofillHints.name],
              validator: Validators.nama,
              enabled: !_loading,
            ),
            const SizedBox(height: AppSpacing.lg),
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
              textInputAction: TextInputAction.next,
              autofillHints: const [AutofillHints.newPassword],
              validator: Validators.kataSandi,
              enabled: !_loading,
            ),
            const SizedBox(height: AppSpacing.lg),
            AppTextField(
              controller: _ulangi,
              label: AppStrings.ulangiKataSandi,
              obscure: true,
              textInputAction: TextInputAction.done,
              validator: (v) =>
                  Validators.konfirmasiKataSandi(v, _password.text),
              onFieldSubmitted: (_) => _submit(),
              enabled: !_loading,
            ),
            if (_error != null) ...[
              const SizedBox(height: AppSpacing.md),
              ErrorText(_error!),
            ],
            const SizedBox(height: AppSpacing.xxl),
            PrimaryButton(
              label: AppStrings.halamanDaftar,
              loading: _loading,
              onPressed: _submit,
            ),
          ],
        ),
      ),
    );
  }
}
