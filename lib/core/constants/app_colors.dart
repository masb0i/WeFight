import 'package:flutter/material.dart';

/// Palet WeFight.
///
/// Sumber: `docs/UI_SPEC.md` §1, diturunkan dari `docs/ui-reference/`.
/// Jangan menambah warna di luar daftar ini — kalau butuh nuansa baru,
/// perbarui UI_SPEC.md dulu.
abstract final class AppColors {
  // Burgundy — keluarga utama.
  static const burgundy900 = Color(0xFF3E0D12);
  static const burgundy800 = Color(0xFF4A1016);
  static const burgundy700 = Color(0xFF59171B); // primer
  static const burgundy600 = Color(0xFF6E2A2B);

  // Rose — ujung terang gradient & garis grafik.
  static const rose500 = Color(0xFF8A4A3E);
  static const rose400 = Color(0xFFB7776D);
  static const clay300 = Color(0xFFD9A78F);

  // Peach & cream — permukaan.
  static const peach200 = Color(0xFFF4D5C3);
  static const peach100 = Color(0xFFFED7B8);
  static const cream200 = Color(0xFFFBECE1);
  static const cream100 = Color(0xFFF8E9DF);
  static const white = Color(0xFFFFFDFB);

  // Tinta.
  static const ink900 = Color(0xFF2A1714);
  static const ink500 = Color(0xFF8A6A62);
  static const ink300 = Color(0xFFB39C94);

  static const border = Color(0xFFEBD8CC);

  // Status. Naik = danger, turun = success (konvensi Indonesia).
  static const success = Color(0xFF2E7D32);
  static const warning = Color(0xFFEF6C00);
  static const danger = Color(0xFFC62828);

  /// Bayangan kartu: sangat lembut, sesuai referensi.
  static const cardShadow = Color(0x1459171B);
}
