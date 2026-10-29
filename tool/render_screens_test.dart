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

import 'package:firebase_auth/firebase_auth.dart';

import 'package:wefight/app/router.dart';
import 'package:wefight/app/theme.dart';
import 'package:wefight/core/constants/app_routes.dart';
import 'package:wefight/features/auth/presentation/auth_providers.dart';
import 'package:wefight/features/target/models/target.dart';
import 'package:wefight/features/target/presentation/target_providers.dart';
import 'package:wefight/features/weight_log/data/weight_log_repository.dart';
import 'package:wefight/features/weight_log/models/weight_log.dart';
import 'package:wefight/features/weight_log/presentation/weight_log_providers.dart';

/// Target contoh supaya form terlihat terisi, bukan kosong.
final _targetContoh = Target(
  batasBerat: 71,
  tanggalTimbang: DateTime(2026, 11, 12),
);

/// Catatan contoh untuk layar Catat Berat mode ubah.
final _logContoh = WeightLog(
  id: 'demo-01',
  tanggal: DateTime(2026, 10, 29),
  berat: 73.6,
  catatan: 'Latihan pagi, badan terasa ringan.',
);

/// Repository catatan palsu — alat render tidak boleh menyentuh Firestore.
class _LogPalsu implements WeightLogRepository {
  const _LogPalsu();

  @override
  Stream<List<WeightLog>> watchAll(String uid) =>
      Stream<List<WeightLog>>.value(const []);

  @override
  Future<WeightLog?> ambil(String id) async =>
      id == _logContoh.id ? _logContoh : null;

  @override
  Future<WeightLog?> cariTanggal(String uid, DateTime tanggal) async => null;

  @override
  Future<String> tambah(String uid, WeightLog log) async => 'baru';

  @override
  Future<void> ubah(String uid, WeightLog log) async {}

  @override
  Future<void> hapus(String id) async {}
}

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
  Target? target,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;

  final router = buildAppRouter();
  await tester.pumpWidget(
    ProviderScope(
      // Key unik per layar: tanpa ini ProviderScope dipakai ulang antar
      // pengambilan gambar, sehingga data dari layar sebelumnya terbawa.
      key: ValueKey(file),
      overrides: [
        // Tanpa override, provider akan memanggil FirebaseAuth.instance.
        authStateProvider.overrideWith((ref) => Stream<User?>.value(null)),
        // Jumlah override harus tetap sama di setiap pemanggilan: ProviderScope
        // menolak daftar override yang panjangnya berubah antar rebuild.
        currentUidProvider.overrideWithValue('uid-demo'),
        targetProvider.overrideWith(
          (ref) => Stream<Target>.value(target ?? const Target()),
        ),
        weightLogRepositoryProvider.overrideWithValue(const _LogPalsu()),
      ],
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
      route: AppRoutes.register,
      file: '03_daftar_mobile.png',
    );
    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.dashboard,
      file: '04_dashboard_mobile.png',
    );
    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.riwayat,
      file: '05_riwayat_mobile.png',
    );
    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.profil,
      file: '06_profil_mobile.png',
    );
    await _shoot(
      tester,
      size: const Size(820, 1000),
      route: AppRoutes.dashboard,
      file: '07_dashboard_tablet.png',
    );
    await _shoot(
      tester,
      size: const Size(1440, 900),
      route: AppRoutes.dashboard,
      file: '08_dashboard_web.png',
    );
    await _shoot(
      tester,
      size: const Size(1440, 900),
      route: AppRoutes.riwayat,
      file: '09_riwayat_web.png',
    );
    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.target,
      file: '10_target_mobile.png',
      target: _targetContoh,
    );
    await _shoot(
      tester,
      size: const Size(1440, 900),
      route: AppRoutes.target,
      file: '11_target_web.png',
      target: _targetContoh,
    );
    await _shoot(
      tester,
      size: const Size(390, 844),
      route: AppRoutes.catatBerat,
      file: '12_catat_berat_mobile.png',
      target: _targetContoh,
    );
    await _shoot(
      tester,
      size: const Size(1440, 900),
      route: AppRoutes.editBeratPath(_logContoh.id),
      file: '13_catat_berat_web.png',
      target: _targetContoh,
    );
  });
}
