import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_spacing.dart';

/// Skala tipografi.
///
/// Sumber: `docs/UI_SPEC.md` §2. Tujuh gaya saja — jangan menambah ukuran baru
/// di luar daftar ini.
abstract final class AppTextStyles {
  static const _family = AppFonts.family;

  /// Angka berat besar (hero card, input berat).
  static const displayWeight = TextStyle(
    fontFamily: _family,
    fontSize: 40,
    fontWeight: FontWeight.w700,
    height: 1.1,
    color: AppColors.ink900,
    fontFeatures: [FontFeature.tabularFigures()],
  );

  /// Judul halaman.
  static const h1 = TextStyle(
    fontFamily: _family,
    fontSize: 24,
    fontWeight: FontWeight.w700,
    height: 1.25,
    color: AppColors.ink900,
  );

  /// Judul kartu.
  static const h2 = TextStyle(
    fontFamily: _family,
    fontSize: 18,
    fontWeight: FontWeight.w600,
    height: 1.3,
    color: AppColors.ink900,
  );

  /// Judul item daftar.
  static const h3 = TextStyle(
    fontFamily: _family,
    fontSize: 16,
    fontWeight: FontWeight.w600,
    height: 1.35,
    color: AppColors.ink900,
  );

  /// Teks isi dan baris tabel.
  static const body = TextStyle(
    fontFamily: _family,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    height: 1.5,
    color: AppColors.ink900,
  );

  /// Label kolom, tab, chip.
  static const label = TextStyle(
    fontFamily: _family,
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.4,
    color: AppColors.ink900,
  );

  /// Keterangan, satuan, tanggal kecil.
  static const caption = TextStyle(
    fontFamily: _family,
    fontSize: 12,
    fontWeight: FontWeight.w400,
    height: 1.4,
    color: AppColors.ink500,
  );
}
