import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../constants/app_colors.dart';
import '../constants/app_gradients.dart';
import '../constants/app_nav.dart';
import '../constants/app_routes.dart';
import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import '../constants/app_text_styles.dart';

/// Kerangka halaman untuk tiga tujuan menu utama.
///
/// - Lebar < 600 px: bottom navigation + FAB "Catat Berat" di tengah (notch).
/// - Lebar ≥ 600 px: sidebar gradient, versi ringkas (ikon) di bawah 1024 px.
///
/// Sumber: `docs/UI_SPEC.md` §5–§6, `docs/PLAN.md` §13.
class AppScaffold extends StatelessWidget {
  const AppScaffold({
    super.key,
    required this.index,
    required this.child,
    this.title,
    this.actions,
    this.showFab = true,
  });

  /// Indeks tujuan aktif (0 Dashboard, 1 Riwayat Berat, 2 Profil).
  final int index;

  final Widget child;

  /// Bila null, halaman mengatur judulnya sendiri (mis. Dashboard).
  final String? title;

  final List<Widget>? actions;

  final bool showFab;

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;

    if (width < AppBreakpoints.mobile) {
      return _MobileShell(
        index: index,
        title: title,
        actions: actions,
        showFab: showFab,
        child: child,
      );
    }

    return _WideShell(
      index: index,
      extended: width >= AppBreakpoints.tablet,
      title: title,
      actions: actions,
      showFab: showFab,
      child: child,
    );
  }
}

// ---------------------------------------------------------------------------
// Mobile
// ---------------------------------------------------------------------------

class _MobileShell extends StatelessWidget {
  const _MobileShell({
    required this.index,
    required this.title,
    required this.actions,
    required this.showFab,
    required this.child,
  });

  final int index;
  final String? title;
  final List<Widget>? actions;
  final bool showFab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream100,
      appBar: title == null
          ? null
          : AppBar(
              title: Text(title!),
              actions: actions,
              backgroundColor: AppColors.cream100,
            ),
      body: SafeArea(bottom: false, child: child),
      floatingActionButton: showFab ? const _CatatBeratFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: _BottomNav(index: index, showFab: showFab),
    );
  }
}

class _BottomNav extends StatelessWidget {
  const _BottomNav({required this.index, required this.showFab});

  final int index;

  /// Bila FAB tidak ditampilkan, bar tidak memakai notch dan ketiga menu
  /// dibagi rata — supaya tidak ada cekungan kosong di tengah.
  final bool showFab;

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      color: AppColors.cream200,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      height: 72,
      padding: EdgeInsets.zero,
      shape: showFab ? const CircularNotchedRectangle() : null,
      notchMargin: 8,
      child: Row(
        children: [
          Expanded(
            child: _NavItem(destination: appDestinations[0], selected: index == 0),
          ),
          Expanded(
            child: _NavItem(destination: appDestinations[1], selected: index == 1),
          ),
          if (showFab)
            const SizedBox(width: 76)
          else
            const SizedBox.shrink(),
          Expanded(
            child: _NavItem(destination: appDestinations[2], selected: index == 2),
          ),
        ],
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.destination, required this.selected});

  final NavDestination destination;
  final bool selected;

  @override
  Widget build(BuildContext context) {
    final color = selected ? NavColors.active : NavColors.inactive;

    return Semantics(
      selected: selected,
      button: true,
      label: destination.label,
      child: InkWell(
        onTap: () => context.go(destination.route),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              selected ? destination.activeIcon : destination.icon,
              size: 22,
              color: color,
            ),
            const SizedBox(height: 2),
            Text(
              destination.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: AppTextStyles.caption.copyWith(
                color: color,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Web / layar lebar
// ---------------------------------------------------------------------------

class _WideShell extends StatelessWidget {
  const _WideShell({
    required this.index,
    required this.extended,
    required this.title,
    required this.actions,
    required this.showFab,
    required this.child,
  });

  final int index;
  final bool extended;
  final String? title;
  final List<Widget>? actions;
  final bool showFab;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cream100,
      body: Container(
        decoration: const BoxDecoration(gradient: AppGradients.pageBg),
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.shell),
          child: Row(
            children: [
              _SideNav(index: index, extended: extended),
              Expanded(
                child: ColoredBox(
                  color: AppColors.cream100,
                  child: Column(
                    children: [
                      if (title != null)
                        _WideHeader(title: title!, actions: actions),
                      Expanded(child: child),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: showFab ? const _CatatBeratFab() : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}

class _WideHeader extends StatelessWidget {
  const _WideHeader({required this.title, this.actions});

  final String title;
  final List<Widget>? actions;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.pageWeb,
        AppSpacing.xxl,
        AppSpacing.pageWeb,
        AppSpacing.sm,
      ),
      child: Row(
        children: [
          Expanded(child: Text(title, style: AppTextStyles.h1)),
          ...?actions,
        ],
      ),
    );
  }
}

class _SideNav extends StatelessWidget {
  const _SideNav({required this.index, required this.extended});

  final int index;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: extended ? AppSizes.sidebar : 88,
      decoration: const BoxDecoration(gradient: AppGradients.sidebar),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.fromLTRB(
                extended ? AppSpacing.xl : AppSpacing.md,
                AppSpacing.xxl,
                extended ? AppSpacing.xl : AppSpacing.md,
                AppSpacing.lg,
              ),
              child: _Logo(extended: extended),
            ),
            for (var i = 0; i < appDestinations.length; i++)
              _SideItem(
                destination: appDestinations[i],
                selected: index == i,
                extended: extended,
              ),
            const Spacer(),
            if (extended)
              const Padding(
                padding: EdgeInsets.all(AppSpacing.lg),
                child: _QuoteCard(),
              ),
          ],
        ),
      ),
    );
  }
}

class _Logo extends StatelessWidget {
  const _Logo({required this.extended});

  final bool extended;

  @override
  Widget build(BuildContext context) {
    final mark = Container(
      width: 36,
      height: 36,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(AppRadius.input),
      ),
      child: const Icon(
        Icons.sports_martial_arts,
        size: 20,
        color: AppColors.peach100,
      ),
    );

    if (!extended) {
      return Center(child: mark);
    }

    return Row(
      children: [
        mark,
        const SizedBox(width: AppSpacing.md),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                AppStrings.appName,
                style: TextStyle(
                  fontFamily: AppFonts.family,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.white,
                ),
              ),
              Text(
                AppStrings.appTagline,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: AppFonts.family,
                  fontSize: 10,
                  color: AppColors.peach200,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _SideItem extends StatelessWidget {
  const _SideItem({
    required this.destination,
    required this.selected,
    required this.extended,
  });

  final NavDestination destination;
  final bool selected;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final color = selected ? AppColors.white : AppColors.peach200;

    final item = Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.md,
        vertical: 3,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context.go(destination.route),
          borderRadius: BorderRadius.circular(AppRadius.button),
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: extended ? AppSpacing.lg : AppSpacing.md,
              vertical: AppSpacing.md,
            ),
            decoration: BoxDecoration(
              color: selected ? Colors.white.withValues(alpha: 0.14) : null,
              borderRadius: BorderRadius.circular(AppRadius.button),
            ),
            child: Row(
              mainAxisAlignment: extended
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              children: [
                Icon(
                  selected ? destination.activeIcon : destination.icon,
                  size: 20,
                  color: color,
                ),
                if (extended) ...[
                  const SizedBox(width: AppSpacing.md),
                  Flexible(
                    child: Text(
                      destination.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppTextStyles.label.copyWith(
                        color: color,
                        fontWeight:
                            selected ? FontWeight.w600 : FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    return Semantics(selected: selected, button: true, child: item);
  }
}

class _QuoteCard extends StatelessWidget {
  const _QuoteCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppRadius.card),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.sports_martial_arts, size: 18, color: AppColors.peach200),
          SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.splashQuote,
            style: TextStyle(
              fontFamily: AppFonts.family,
              fontSize: 12,
              height: 1.4,
              color: AppColors.peach100,
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Aksi utama
// ---------------------------------------------------------------------------

class _CatatBeratFab extends StatelessWidget {
  const _CatatBeratFab();

  @override
  Widget build(BuildContext context) {
    return FloatingActionButton(
      onPressed: () => context.push(AppRoutes.catatBerat),
      backgroundColor: AppColors.burgundy700,
      foregroundColor: AppColors.peach100,
      elevation: 3,
      tooltip: AppStrings.catatBerat,
      shape: const CircleBorder(),
      child: const Icon(Icons.add, size: 26),
    );
  }
}
