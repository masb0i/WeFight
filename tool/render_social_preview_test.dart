// Alat bantu (bukan bagian test suite): merender kartu social preview GitHub.
//
// Jalankan dari akar proyek:
//   flutter test --update-goldens tool/render_social_preview_test.dart
//
// Hasil: docs/social-preview.png (1280 x 640), lalu unggah manual lewat
// Settings -> General -> Social preview di GitHub.
//
// Kenapa dirender lewat Flutter, bukan alat gambar luar: font Plus Jakarta Sans
// sudah dibundel di repo, token warna sudah ada di AppColors, dan tangkapan
// layar Dashboard diambil dari docs/screenshots/. Jadi kartu ini selalu memakai
// aset yang sama dengan aplikasi, tanpa risiko salah warna atau salah font.
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wefight/core/constants/app_colors.dart';

/// Ukuran yang diminta GitHub untuk social preview.
const _lebar = 1280.0;
const _tinggi = 640.0;

const _kunciKartu = ValueKey('kartu-social-preview');

/// Tangkapan layar yang dipasang di bingkai ponsel.
const _berkasLayar = 'docs/screenshots/04_dashboard_mobile.png';

Future<void> _muatFont(WidgetTester tester) async {
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
  });
}

/// Mendekode PNG lebih dulu di luar zona fake-async.
///
/// Kalau `Image.memory` dipakai langsung, dekode berjalan asinkron di dalam
/// zona test dan golden bisa terekam sebelum gambarnya sempat dilukis.
/// `RawImage` melukis sinkron, jadi hasilnya pasti.
Future<ui.Image> _muatGambar(WidgetTester tester) async {
  final bytes = File(_berkasLayar).readAsBytesSync();
  late ui.Image gambar;
  await tester.runAsync(() async {
    final codec = await ui.instantiateImageCodec(bytes);
    gambar = (await codec.getNextFrame()).image;
  });
  return gambar;
}

Widget _kartu(ui.Image layar) {
  return SizedBox(
    width: _lebar,
    height: _tinggi,
    child: Stack(
      children: [
        // Latar: burgundy gelap, senada hero card Dashboard.
        const Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.burgundy800, AppColors.burgundy900],
              ),
            ),
          ),
        ),
        // Dua bidang cahaya tipis supaya latar tidak terlihat datar.
        Positioned(
          top: -180,
          right: -120,
          child: Container(
            width: 520,
            height: 520,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.peach100.withValues(alpha: 0.07),
            ),
          ),
        ),
        Positioned(
          bottom: -240,
          left: 180,
          child: Container(
            width: 420,
            height: 420,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.rose400.withValues(alpha: 0.10),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(64),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _kolomTeks()),
              const SizedBox(width: 56),
              _bingkaiPonsel(layar),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _kolomTeks() {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Container(
        width: 56,
        height: 4,
        decoration: BoxDecoration(
          color: AppColors.peach100,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(height: 22),
      const Text(
        'WeFight',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 84,
          height: 1.0,
          fontWeight: FontWeight.w800,
          letterSpacing: -2.5,
          color: AppColors.peach100,
        ),
      ),
      const SizedBox(height: 10),
      const Text(
        'Weight for Fight Tracker',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 29,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
          color: AppColors.peach200,
        ),
      ),
      const SizedBox(height: 30),
      SizedBox(
        width: 560,
        child: Text(
          'Berat terakhir, selisih ke batas kelas, dan hitung mundur '
          'hari timbang dalam satu layar.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 22,
            height: 1.5,
            fontWeight: FontWeight.w400,
            color: AppColors.cream200.withValues(alpha: 0.90),
          ),
        ),
      ),
      const Spacer(),
      Text(
        'Flutter  ·  Firebase Auth & Firestore  ·  Mobile and Web '
        'Application Development',
        style: TextStyle(
          fontFamily: 'Plus Jakarta Sans',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: AppColors.peach200.withValues(alpha: 0.55),
        ),
      ),
    ],
  );
}

/// Bingkai ponsel berisi tangkapan layar Dashboard asli.
Widget _bingkaiPonsel(ui.Image layar) {
  const tinggi = 512.0;
  final lebar = tinggi * 390 / 844;

  return Container(
    width: lebar,
    height: tinggi,
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(30),
      border: Border.all(
        color: AppColors.peach100.withValues(alpha: 0.30),
        width: 3,
      ),
      boxShadow: [
        BoxShadow(
          color: AppColors.burgundy900.withValues(alpha: 0.55),
          blurRadius: 40,
          offset: const Offset(0, 18),
        ),
      ],
    ),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(27),
      child: RawImage(
        image: layar,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.high,
      ),
    ),
  );
}

void main() {
  testWidgets('render kartu social preview', (tester) async {
    await _muatFont(tester);
    final layar = await _muatGambar(tester);

    tester.view.physicalSize = const Size(_lebar, _tinggi);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: Center(
          child: RepaintBoundary(
            key: _kunciKartu,
            child: _kartu(layar),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await expectLater(
      find.byKey(_kunciKartu),
      matchesGoldenFile('../docs/social-preview.png'),
    );
  });
}
