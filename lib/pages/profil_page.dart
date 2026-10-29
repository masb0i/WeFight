import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../core/constants/app_colors.dart';
import '../core/constants/app_routes.dart';
import '../core/constants/app_spacing.dart';
import '../core/constants/app_strings.dart';
import '../core/constants/app_text_styles.dart';
import '../core/widgets/app_card.dart';
import '../core/widgets/app_scaffold.dart';
import '../features/auth/presentation/auth_providers.dart';

/// H7 Profil — prioritas Should.
class ProfilPage extends ConsumerWidget {
  const ProfilPage({super.key});

  Future<void> _konfirmasiKeluar(BuildContext context, WidgetRef ref) async {
    final keluar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.cream200,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text(AppStrings.keluarJudul),
        content: const Text(AppStrings.keluarPesan),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text(AppStrings.batal),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text(AppStrings.keluar),
          ),
        ],
      ),
    );

    if (keluar != true) return;
    // Redirect router yang memindahkan pengguna ke Login.
    await ref.read(authRepositoryProvider).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isWide = MediaQuery.sizeOf(context).width >= AppBreakpoints.mobile;
    final padding = isWide ? AppSpacing.pageWeb : AppSpacing.pageMobile;

    final user = ref.watch(authStateProvider).asData?.value;
    final name = ref.watch(currentUserNameProvider);
    final initial = ref.watch(currentUserInitialProvider);

    return AppScaffold(
      index: 2,
      title: AppStrings.halamanProfil,
      showFab: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(padding, padding, padding,
              AppSpacing.bottomFor(MediaQuery.sizeOf(context).width)),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppCard(
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: AppColors.burgundy700,
                        child: Text(
                          initial,
                          style: AppTextStyles.h2.copyWith(
                            color: AppColors.peach100,
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.lg),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: AppTextStyles.h2,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              AppStrings.profilFighter,
                              style: AppTextStyles.caption,
                            ),
                            if (user?.email != null) ...[
                              const SizedBox(height: 2),
                              Text(
                                user!.email!,
                                style: AppTextStyles.caption,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gap),
                AppCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children: [
                      _MenuTile(
                        icon: Icons.flag_outlined,
                        label: AppStrings.pengaturanTarget,
                        onTap: () => context.push(AppRoutes.target),
                      ),
                      const Divider(height: 1, color: AppColors.border),
                      _MenuTile(
                        icon: Icons.history,
                        label: AppStrings.riwayatMenu,
                        onTap: () => context.go(AppRoutes.riwayat),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.gap),
                OutlinedButton.icon(
                  onPressed: () => _konfirmasiKeluar(context, ref),
                  icon: const Icon(Icons.logout, size: 18),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.danger,
                    side: const BorderSide(color: AppColors.danger),
                  ),
                  label: const Text(AppStrings.keluar),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xl,
        vertical: AppSpacing.xs,
      ),
      leading: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: AppColors.peach200.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(AppRadius.input),
        ),
        child: Icon(icon, size: 18, color: AppColors.burgundy700),
      ),
      title: Text(label, style: AppTextStyles.h3),
      trailing: const Icon(
        Icons.chevron_right,
        size: 20,
        color: AppColors.ink300,
      ),
    );
  }
}
