import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_scaffold.dart';
import '../core/widgets/empty_state.dart';

/// H6 Riwayat Berat.
///
/// M6: kerangka + keadaan kosong. Daftar, ubah, dan hapus menyusul di M11.
class RiwayatBeratPage extends StatelessWidget {
  const RiwayatBeratPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    final padding = isWide ? AppSpacing.pageWeb : AppSpacing.pageMobile;

    return AppScaffold(
      index: 1,
      title: AppStrings.halamanRiwayat,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, padding, padding, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: AppCard(
              child: EmptyState(
                icon: Icons.history,
                title: AppStrings.riwayatKosongJudul,
                message: AppStrings.riwayatKosongPesan,
                primaryLabel: AppStrings.catatBerat,
                onPrimary: () => context.push(AppRoutes.catatBerat),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
