import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_spacing.dart';

/// Permukaan kartu standar.
///
/// Referensi UI membedakan permukaan lewat warna + garis 1 px, bukan bayangan
/// tebal. Lihat `docs/UI_SPEC.md` §3.
///
/// Kartu berwarna solid memakai `Material` sebagai latar, bukan `DecoratedBox`,
/// supaya ripple `InkWell`/`ListTile` di dalamnya tetap terlihat.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(AppSpacing.xl),
    this.color = AppColors.cream200,
    this.gradient,
    this.borderRadius = AppRadius.card,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final Color color;
  final Gradient? gradient;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(borderRadius);

    Widget content = Padding(padding: padding, child: child);
    if (onTap != null) {
      content = InkWell(
        onTap: onTap,
        borderRadius: radius,
        child: content,
      );
    }

    if (gradient != null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: radius,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: content,
      );
    }

    return Material(
      color: color,
      borderRadius: radius,
      clipBehavior: Clip.antiAlias,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: radius,
          border: Border.all(color: AppColors.border, width: 1),
        ),
        child: content,
      ),
    );
  }
}
