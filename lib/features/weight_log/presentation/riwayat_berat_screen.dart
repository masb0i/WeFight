import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/placeholder_screen.dart';

/// H6 Riwayat Berat.
class RiwayatBeratScreen extends StatelessWidget {
  const RiwayatBeratScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: AppStrings.halamanRiwayat,
      milestone: 'M11',
      note: 'Daftar catatan, ubah, hapus, dan state kosong.',
    );
  }
}
