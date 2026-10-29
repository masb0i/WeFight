import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/app_top_bar.dart';
import '../core/widgets/empty_state.dart';
import '../features/auth/presentation/auth_providers.dart';
import '../features/dashboard/presentation/widgets/hero_weight_card.dart';
import '../features/target/models/target.dart';
import '../features/target/presentation/target_providers.dart';

/// H3 Dashboard.
///
/// M6: kerangka + keadaan kosong. Angka asli dan grafik menyusul di M12–M13.
class DashboardPage extends ConsumerWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    final padding = isWide ? AppSpacing.pageWeb : AppSpacing.pageMobile;

    final name = ref.watch(currentUserNameProvider);
    final initial = ref.watch(currentUserInitialProvider);

    // M9: target sudah tampil di kartu utama supaya hasil form langsung
    // terlihat. Selisih, hitung mundur, dan grafik menyusul di M12–M13.
    final target = ref.watch(targetProvider).asData?.value ?? const Target();

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
                AppTopBar(
                  greeting: 'Halo, ${name.split(' ').first}!',
                  initial: initial,
                  name: name,
                ),
                const SizedBox(height: AppSpacing.xl),
                HeroWeightCard(
                  targetKg: target.batasBerat,
                  onEdit: () => context.push(AppRoutes.target),
                ),
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
