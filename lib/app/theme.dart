import 'package:flutter/material.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_text_styles.dart';

/// Tema aplikasi.
///
/// PENTING: `ColorScheme` ditulis eksplisit. **Jangan** memakai
/// `ColorScheme.fromSeed()` — hasilnya tidak akan menyerupai referensi UI.
/// Lihat `docs/UI_SPEC.md` §9.
const ColorScheme _colorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: AppColors.burgundy700,
  onPrimary: AppColors.peach100,
  secondary: AppColors.rose400,
  onSecondary: AppColors.white,
  surface: AppColors.cream100,
  onSurface: AppColors.ink900,
  error: AppColors.danger,
  onError: AppColors.white,
  outline: AppColors.border,
  outlineVariant: AppColors.border,
  surfaceContainerHighest: AppColors.cream200,
);

ThemeData buildAppTheme() {
  return ThemeData(
    useMaterial3: true,
    colorScheme: _colorScheme,
    scaffoldBackgroundColor: AppColors.cream100,
    fontFamily: AppFonts.family,
    dividerColor: AppColors.border,
    textTheme: const TextTheme(
      displaySmall: AppTextStyles.displayWeight,
      headlineSmall: AppTextStyles.h1,
      titleMedium: AppTextStyles.h2,
      titleSmall: AppTextStyles.h3,
      bodyMedium: AppTextStyles.body,
      labelMedium: AppTextStyles.label,
      bodySmall: AppTextStyles.caption,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      foregroundColor: AppColors.ink900,
      elevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.h2,
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.burgundy700,
        foregroundColor: AppColors.peach100,
        disabledBackgroundColor: AppColors.cream200,
        disabledForegroundColor: AppColors.ink300,
        minimumSize: const Size.fromHeight(AppSizes.buttonMobile),
        textStyle: AppTextStyles.h3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
        ),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.burgundy700,
        side: const BorderSide(color: AppColors.burgundy700, width: 1.5),
        minimumSize: const Size.fromHeight(AppSizes.buttonMobile),
        textStyle: AppTextStyles.h3,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(AppRadius.button)),
        ),
      ),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: AppColors.cream200,
      surfaceTintColor: Colors.transparent,
      indicatorColor: Colors.transparent,
      height: 68,
      labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return AppTextStyles.caption.copyWith(
          fontWeight: active ? FontWeight.w600 : FontWeight.w400,
          color: active ? AppColors.burgundy700 : AppColors.ink300,
        );
      }),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        final active = states.contains(WidgetState.selected);
        return IconThemeData(
          size: 22,
          color: active ? AppColors.burgundy700 : AppColors.ink300,
        );
      }),
    ),
    snackBarTheme: const SnackBarThemeData(
      backgroundColor: AppColors.ink900,
      contentTextStyle: AppTextStyles.body,
      behavior: SnackBarBehavior.floating,
    ),
  );
}
