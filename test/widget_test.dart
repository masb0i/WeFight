import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wefight/app/router.dart';
import 'package:wefight/app/theme.dart';
import 'package:wefight/core/constants/app_colors.dart';
import 'package:wefight/core/constants/app_routes.dart';
import 'package:wefight/core/constants/app_strings.dart';

/// Memasang aplikasi dengan ukuran layar tertentu.
///
/// Ukuran default 390 × 844 (ponsel). Pakai 1440 × 900 untuk menguji layout web.
Future<GoRouter> pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final router = buildAppRouter();
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        theme: buildAppTheme(),
        routerConfig: router,
      ),
    ),
  );
  await tester.pump();
  return router;
}

void main() {
  testWidgets('splash tampil lalu berpindah ke Login', (tester) async {
    await pumpApp(tester);

    expect(find.text(AppStrings.appName), findsOneWidget);

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.halamanLogin), findsWidgets);
  });

  testWidgets('tema memakai primer burgundy, bukan bawaan Flutter',
      (tester) async {
    await pumpApp(tester);
    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(context);

    expect(theme.colorScheme.primary, AppColors.burgundy700);
    expect(theme.scaffoldBackgroundColor, AppColors.cream100);
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Plus Jakarta Sans');
  });

  testWidgets('Dashboard muat di lebar 390 px tanpa overflow', (tester) async {
    final router = await pumpApp(tester);
    router.go(AppRoutes.dashboard);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.dashboardKosongJudul), findsOneWidget);
    expect(find.text(AppStrings.aturTarget), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Dashboard muat di lebar 1440 px dan memakai sidebar',
      (tester) async {
    final router = await pumpApp(tester, size: const Size(1440, 900));
    router.go(AppRoutes.dashboard);
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.dashboardKosongJudul), findsOneWidget);
    // Ketiga tujuan menu harus ada di sidebar.
    expect(find.text(AppStrings.navDashboard), findsOneWidget);
    expect(find.text(AppStrings.navRiwayat), findsOneWidget);
    expect(find.text(AppStrings.navProfil), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('menu Riwayat Berat membuka halaman riwayat', (tester) async {
    final router = await pumpApp(tester);
    router.go(AppRoutes.dashboard);
    await tester.pumpAndSettle();

    await tester.tap(find.text(AppStrings.navRiwayat));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.riwayatKosongJudul), findsOneWidget);
  });
}
