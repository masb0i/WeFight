// Alat bantu (bukan bagian test suite): merender layar jadi PNG.
//
// Jalankan dari akar proyek:
//   flutter test --update-goldens tool/render_screens_test.dart
//
// Hasil masuk ke docs/screenshots/. File ini sengaja diletakkan di luar folder
// test/ supaya `flutter test` biasa tidak ikut membandingkan golden (rapuh
// antar mesin/font), tetapi tetap bisa dipanggil manual saat UI berubah.
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wefight/app/router.dart';
import 'package:wefight/app/theme.dart';
import 'package:wefight/core/constants/app_routes.dart';

Future<void> _loadFonts(WidgetTester tester) async {
  await tester.runAsync(() async {
    final loader = FontLoader('Plus Jakarta Sans');
    for (final name in const [
      'Regular',
      'Medium',
      'SemiBold',
      'Bold',
      'ExtraBold',
    ]) {
      loader.addFont(
        rootBundle.load('assets/fonts/PlusJakartaSans-$name.ttf'),
      );
    }
    await loader.load();

    // Ikon Material tidak tersedia di lingkungan test — muat dari SDK.
    final root = Platform.environment['FLUTTER_ROOT'];
    if (root == null) return;
    final icons = File(
      '$root/bin/cache/artifacts/material_fonts/materialicons-regular.otf',
    );
    if (!icons.existsSync()) return;

    final iconLoader = FontLoader('MaterialIcons')
      ..addFont(
        Future.value(ByteData.sublistView(icons.readAsBytesSync())),
      );
    await iconLoader.load();
  });
}

Future<void> _shoot(
  WidgetTester tester, {
  required Size size,
  required String route,
  required String file,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  final router = buildAppRouter();
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        debugShowCheckedModeBanner: false,
        theme: buildAppTheme(),
        routerConfig: router,
      ),
    ),
  );
  router.go(route);
  await tester.pumpAndSettle();

  await expectLater(
    find.byType(MaterialApp),
    matchesGoldenFile('../docs/screenshots/$file'),
  );
}

void main() {
  testWidgets('render layar', (tester) async {
    await _loadFonts(tester);

    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.splash,
      file: '01_splash_mobile.png',
    );
    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.login,
      file: '02_login_mobile.png',
    );
    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.dashboard,
      file: '03_dashboard_mobile.png',
    );
    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.riwayat,
      file: '04_riwayat_mobile.png',
    );
    await _shoot(
      tester,
      size: const Size(820, 1000),
      route: AppRoutes.dashboard,
      file: '05_dashboard_tablet.png',
    );
    await _shoot(
      tester,
      size: const Size(1440, 900),
      route: AppRoutes.dashboard,
      file: '06_dashboard_web.png',
    );
    await _shoot(
      tester,
      size: const Size(1440, 900),
      route: AppRoutes.riwayat,
      file: '07_riwayat_web.png',
    );
  });
}
