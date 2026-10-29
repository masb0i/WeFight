import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

/// Sapaan di atas konten.
///
/// Dipakai Dashboard (dan nanti halaman lain). Tidak ada ikon lonceng karena
/// notifikasi berstatus Won't now — jangan menaruh tombol yang tidak berfungsi.
class AppTopBar extends StatelessWidget {
  const AppTopBar({
    super.key,
    this.greeting = AppStrings.sapaan,
    this.subtitle = AppStrings.sapaanSub,
    this.initial = 'F',
    this.name = 'Fighter',
  });

  final String greeting;
  final String subtitle;

  /// Inisial untuk avatar.
  final String initial;

  final String name;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Di layar sempit cukup avatar — nama lengkap ada di halaman Profil.
        final showName = constraints.maxWidth >= 420;

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greeting,
                    style: AppTextStyles.h1,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: AppTextStyles.caption,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            CircleAvatar(
              radius: 18,
              backgroundColor: AppColors.burgundy700,
              child: Text(
                initial,
                style: AppTextStyles.label.copyWith(
                  color: AppColors.peach100,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (showName) ...[
              const SizedBox(width: AppSpacing.sm),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 120),
                child: Text(
                  name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppTextStyles.label,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
