import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/placeholder_screen.dart';

/// H3 Dashboard.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: AppStrings.halamanDashboard,
      milestone: 'M6',
      note: 'Hero card, ring progres, grafik tren, dan riwayat terbaru.',
    );
  }
}
