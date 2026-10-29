import 'package:flutter/material.dart';

import '../../../core/constants/app_spacing.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_scaffold.dart';
import '../../../core/widgets/empty_state.dart';

/// H7 Profil — prioritas Should.
///
/// M6: kerangka + menu dasar. Info akun dan Keluar menyusul di M7.
class ProfilScreen extends StatelessWidget {
  const ProfilScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    final padding = isWide ? AppSpacing.pageWeb : AppSpacing.pageMobile;

    return AppScaffold(
      index: 2,
      title: AppStrings.halamanProfil,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, padding, padding, 96),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: const AppCard(
              child: EmptyState(
                icon: Icons.person_outline,
                title: AppStrings.halamanProfil,
                message: AppStrings.profilBelumAda,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
