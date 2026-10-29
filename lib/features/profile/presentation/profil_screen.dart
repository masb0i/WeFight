import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/placeholder_screen.dart';

/// H7 Profil — prioritas Should.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: AppStrings.halamanProfil,
      milestone: 'M7',
      note: 'Info akun, Pengaturan Target, Riwayat, dan Keluar.',
    );
  }
}
