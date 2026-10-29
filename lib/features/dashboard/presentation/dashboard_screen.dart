import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_routes.dart';
import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/app_top_bar.dart';
import '../../../core/widgets/empty_state.dart';
import 'widgets/hero_weight_card.dart';

/// H3 Dashboard.
///
/// M6: kerangka + keadaan kosong. Angka asli dan grafik menyusul di M12–M13.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    final padding = isWide ? AppSpacing.pageWeb : AppSpacing.pageMobile;

    return AppScaffold(
      index: 0,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, padding, padding, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const AppTopBar(),
                const SizedBox(height: AppSpacing.xl),
                const HeroWeightCard(),
                const SizedBox(height: AppSpacing.gap),
                AppCard(
                  child: EmptyState(
                    icon: Icons.monitor_weight_outlined,
                    title: AppStrings.dashboardKosongJudul,
                    message: AppStrings.dashboardKosongPesan,
                    primaryLabel: AppStrings.aturTarget,
                    onPrimary: () => context.push(AppRoutes.target),
                    secondaryLabel: AppStrings.catatBerat,
                    onSecondary: () => context.push(AppRoutes.catatBerat),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
