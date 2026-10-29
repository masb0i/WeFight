import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Pesan status singkat di bawah layar (Minggu 7: "pesan status berhasil dan
/// gagal tampil").
///
/// Selalu memanggil `hideCurrentSnackBar()` lebih dulu supaya pesan baru tidak
/// antre di belakang pesan lama — pesan lama bisa menahan pesan baru sampai
/// beberapa detik, dan itu terasa seperti aplikasi tidak merespons.
///
/// Ikon + teks dipakai bersama warna, jadi status tidak dibedakan hanya dengan
/// warna (aturan bisnis §3 poin 10).
abstract final class AppSnackBar {
  static void sukses(BuildContext context, String pesan) => _tampil(
        context,
        pesan: pesan,
        warna: AppColors.success,
        ikon: Icons.check_circle_outline,
      );

  static void galat(BuildContext context, String pesan) => _tampil(
        context,
        pesan: pesan,
        warna: AppColors.danger,
        ikon: Icons.error_outline,
      );

  static void info(BuildContext context, String pesan) => _tampil(
        context,
        pesan: pesan,
        warna: AppColors.burgundy700,
        ikon: Icons.info_outline,
      );

  static void _tampil(
    BuildContext context, {
    required String pesan,
    required Color warna,
    required IconData ikon,
  }) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        backgroundColor: warna,
        duration: const Duration(seconds: 4),
        content: Row(
          children: [
            Icon(ikon, color: AppColors.white, size: 20),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(pesan, style: const TextStyle(color: AppColors.white)),
            ),
          ],
        ),
      ),
    );
  }
}
