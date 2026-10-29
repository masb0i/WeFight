import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import '../core/widgets/placeholder_screen.dart';

/// H4 Target Timbang.
class TargetTimbangPage extends StatelessWidget {
  const TargetTimbangPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: AppStrings.halamanTarget,
      milestone: 'M9',
      note: 'Batas berat dan tanggal timbang — keduanya boleh dikosongkan.',
    );
  }
}
