import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_routes.dart';
import 'app_strings.dart';

/// Satu tujuan di menu utama.
typedef NavDestination = ({
  IconData icon,
  IconData activeIcon,
  String label,
  String route,
});

/// Tiga tujuan menu utama — urutan tidak boleh berubah.
///
/// Sumber: `docs/PLAN.md` §13. FAB "Catat Berat" adalah aksi, bukan tujuan menu.
const List<NavDestination> appDestinations = [
  (
    icon: Icons.space_dashboard_outlined,
    activeIcon: Icons.space_dashboard,
    label: AppStrings.navDashboard,
    route: AppRoutes.dashboard,
  ),
  (
    icon: Icons.history_outlined,
    activeIcon: Icons.history,
    label: AppStrings.navRiwayat,
    route: AppRoutes.riwayat,
  ),
  (
    icon: Icons.person_outline,
    activeIcon: Icons.person,
    label: AppStrings.navProfil,
    route: AppRoutes.profil,
  ),
];

/// Warna teks menu saat aktif/tidak aktif.
abstract final class NavColors {
  static const active = AppColors.burgundy700;
  static const inactive = AppColors.ink300;
}
