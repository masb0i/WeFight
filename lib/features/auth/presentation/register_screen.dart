import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/placeholder_screen.dart';

/// H2 Daftar — prioritas Should.
class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: AppStrings.halamanDaftar,
      milestone: 'M7',
      note: 'Dibangun setelah semua halaman Must selesai.',
    );
  }
}
