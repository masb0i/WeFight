import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_text_styles.dart';

/// Kolom input standar.
///
/// Gaya ditulis langsung di sini (bukan `InputDecorationTheme` di ThemeData)
/// karena nama kelas tema input berubah antar versi Flutter. Lihat
/// `docs/UI_SPEC.md` §4.
class AppTextField extends StatelessWidget {
  const AppTextField({
    super.key,
    required this.controller,
    required this.label,
    this.hint,
    this.helper,
    this.obscure = false,
    this.keyboardType,
    this.textInputAction,
    this.validator,
    this.onFieldSubmitted,
    this.autofillHints,
    this.suffixIcon,
    this.enabled = true,
    this.readOnly = false,
    this.onTap,
    this.inputFormatters,
    this.maxLines = 1,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final String? hint;

  /// Keterangan kecil di bawah kolom, mis. "Boleh dikosongkan".
  final String? helper;

  final bool obscure;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final String? Function(String?)? validator;
  final void Function(String)? onFieldSubmitted;
  final Iterable<String>? autofillHints;
  final Widget? suffixIcon;
  final bool enabled;

  /// Untuk kolom tanggal: isian tidak diketik, tetapi dibuka lewat [onTap].
  final bool readOnly;

  final VoidCallback? onTap;
  final List<TextInputFormatter>? inputFormatters;

  /// `1` untuk isian satu baris, lebih besar untuk catatan bebas.
  final int maxLines;

  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    OutlineInputBorder border(Color color, [double width = 1]) {
      return OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.input),
        borderSide: BorderSide(color: color, width: width),
      );
    }

    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      autofillHints: autofillHints,
      enabled: enabled,
      readOnly: readOnly,
      onTap: onTap,
      inputFormatters: inputFormatters,
      maxLines: maxLines,
      textCapitalization: textCapitalization,
      style: AppTextStyles.body,
      cursorColor: AppColors.burgundy700,
      decoration: InputDecoration(
        labelText: label,
        hintText: hint,
        helperText: helper,
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: enabled ? AppColors.white : AppColors.cream100,
        labelStyle: AppTextStyles.body.copyWith(color: AppColors.ink500),
        floatingLabelStyle: AppTextStyles.label.copyWith(
          color: AppColors.burgundy700,
        ),
        hintStyle: AppTextStyles.body.copyWith(color: AppColors.ink300),
        helperStyle: AppTextStyles.caption.copyWith(color: AppColors.ink500),
        helperMaxLines: 2,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: border(AppColors.border),
        enabledBorder: border(AppColors.border),
        focusedBorder: border(AppColors.burgundy700, 1.5),
        errorBorder: border(AppColors.danger),
        focusedErrorBorder: border(AppColors.danger, 1.5),
        errorStyle: AppTextStyles.caption.copyWith(color: AppColors.danger),
      ),
    );
  }
}
