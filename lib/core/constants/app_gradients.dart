import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradient resmi aplikasi.
///
/// Sumber: `docs/UI_SPEC.md` §1.1. Gradient hanya dipakai untuk sidebar, hero
/// card, splash, latar luar web, dan kartu motivasi — bukan kartu data biasa.
abstract final class AppGradients {
  /// Jangkar brand: burgundy → peach. Untuk splash dan kartu motivasi.
  static const brand = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.burgundy700, AppColors.peach100],
  );

  /// Hero card berat badan.
  static const hero = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [AppColors.burgundy800, AppColors.rose500, AppColors.rose400],
  );

  /// Sidebar web: gelap di atas, memanas ke bawah.
  static const sidebar = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF491216), Color(0xFF783735)],
  );

  /// Latar splash & login.
  static const splash = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF4B1218), Color(0xFF5C2320), AppColors.burgundy900],
  );

  /// Latar luar shell web.
  static const pageBg = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFB67767), Color(0xFFDCA994)],
  );

  /// Area di bawah garis grafik tren.
  static const chartArea = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0x38B7776D), Color(0x00B7776D)],
  );
}
