import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:wefight/app/router.dart';
import 'package:wefight/app/theme.dart';
import 'package:wefight/core/constants/app_colors.dart';
import 'package:wefight/core/constants/app_routes.dart';
import 'package:wefight/core/constants/app_strings.dart';
import 'package:wefight/features/auth/data/auth_repository.dart';
import 'package:wefight/features/auth/presentation/auth_providers.dart';
import 'package:wefight/features/profile/data/user_repository.dart';
import 'package:wefight/features/profile/models/user_profile.dart';
import 'package:wefight/features/profile/presentation/profile_providers.dart';
import 'package:wefight/features/target/data/target_repository.dart';
import 'package:wefight/features/target/models/target.dart';
import 'package:wefight/features/target/presentation/target_providers.dart';

/// Repository palsu — tidak menyentuh Firebase sama sekali.
class FakeAuthRepository implements AuthRepository {
  FakeAuthRepository({this.signedIn = false});

  bool signedIn;
  final _changes = StreamController<User?>.broadcast();

  @override
  bool get isSignedIn => signedIn;

  @override
  String? get currentUid => signedIn ? 'uid-uji' : null;

  @override
  Stream<User?> get authStateChanges => _changes.stream;

  @override
  Future<void> signIn({required String email, required String password}) async {
    signedIn = true;
    _changes.add(null);
  }

  @override
  Future<void> signUp({
    required String nama,
    required String email,
    required String password,
  }) async {
    signedIn = true;
    _changes.add(null);
  }

  @override
  Future<void> signOut() async {
    signedIn = false;
    _changes.add(null);
  }

  @override
  Future<void> sendPasswordReset(String email) async {}
}

/// Repository profil palsu — layar Daftar menulis `users/{uid}` setelah
/// pendaftaran berhasil, jadi provider ini wajib di-override di test.
class FakeUserRepository implements UserRepository {
  final disimpan = <UserProfile>[];

  @override
  Future<void> simpanProfil(UserProfile profil) async => disimpan.add(profil);

  @override
  Future<UserProfile?> ambil(String uid) async => disimpan.isEmpty
      ? null
      : disimpan.firstWhere((profil) => profil.uid == uid);
}

/// Repository target palsu — mencatat setiap penyimpanan agar bisa diperiksa.
class FakeTargetRepository implements TargetRepository {
  FakeTargetRepository({this.awal = const Target()});

  Target awal;
  final disimpan = <Target>[];

  @override
  Stream<Target> watch(String uid) => Stream<Target>.value(awal);

  @override
  Future<Target> ambil(String uid) async => awal;

  @override
  Future<void> simpan(String uid, Target target) async {
    disimpan.add(target);
    awal = target;
  }
}

/// Memasang aplikasi dengan ukuran layar tertentu.
///
/// `auth` null berarti guard login dimatikan.
Future<GoRouter> pumpApp(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  AuthRepository? auth,
  Target targetAwal = const Target(),
  FakeTargetRepository? targetRepo,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final router = buildAppRouter(auth: auth);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        // Wajib: tanpa ini provider akan memanggil FirebaseAuth.instance.
        authStateProvider.overrideWith(
          (ref) => auth?.authStateChanges ?? Stream<User?>.value(null),
        ),
        userRepositoryProvider.overrideWithValue(FakeUserRepository()),
        // Target: tanpa override, provider akan memanggil FirebaseFirestore.
        currentUidProvider.overrideWithValue('uid-uji'),
        targetProvider.overrideWith(
          (ref) => Stream<Target>.value(targetAwal),
        ),
        targetRepositoryProvider.overrideWithValue(
          targetRepo ?? FakeTargetRepository(),
        ),
      ],
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
  group('Kerangka aplikasi', () {
    testWidgets('splash tampil lalu berpindah ke Login', (tester) async {
      await pumpApp(tester);

      expect(find.text(AppStrings.appName), findsOneWidget);

      await tester.pump(const Duration(milliseconds: 1500));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loginSubtitle), findsOneWidget);
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
  });

  group('Guard login', () {
    testWidgets('belum masuk, membuka Dashboard dialihkan ke Login',
        (tester) async {
      final auth = FakeAuthRepository(signedIn: false);
      final router = await pumpApp(tester, auth: auth);

      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.loginSubtitle), findsOneWidget);
      expect(find.text(AppStrings.dashboardKosongJudul), findsNothing);
    });

    testWidgets('sudah masuk, membuka Login dialihkan ke Dashboard',
        (tester) async {
      final auth = FakeAuthRepository(signedIn: true);
      final router = await pumpApp(tester, auth: auth);

      router.go(AppRoutes.login);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.dashboardKosongJudul), findsOneWidget);
    });
  });

  group('Validasi form autentikasi', () {
    testWidgets('Login menolak kolom kosong', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.login);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, AppStrings.masuk));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiEmailKosong), findsOneWidget);
      expect(find.text(AppStrings.validasiSandiKosong), findsOneWidget);
    });

    testWidgets('Login menolak format email salah', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.login);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'bukan-email');
      await tester.enterText(find.byType(TextFormField).at(1), '123456');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.masuk));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiEmailFormat), findsOneWidget);
    });

    testWidgets('Daftar menolak kata sandi yang tidak sama', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.register);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'Rasyid');
      await tester.enterText(find.byType(TextFormField).at(1), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.enterText(find.byType(TextFormField).at(3), '1234567');
      await tester.tap(
        find.widgetWithText(FilledButton, AppStrings.halamanDaftar),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiSandiBeda), findsOneWidget);
    });

    testWidgets('tautan Daftar membuka halaman Daftar', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.login);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.halamanDaftar));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.registerSubtitle), findsOneWidget);
    });

    testWidgets('Login menolak kata sandi kurang dari 6 karakter',
        (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.login);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(0), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.masuk));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiSandiPendek), findsOneWidget);
    });

    testWidgets('Daftar menolak kolom nama kosong', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.register);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), 'a@b.com');
      await tester.enterText(find.byType(TextFormField).at(2), '123456');
      await tester.enterText(find.byType(TextFormField).at(3), '123456');
      await tester.tap(
        find.widgetWithText(FilledButton, AppStrings.halamanDaftar),
      );
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiNamaKosong), findsOneWidget);
    });

    testWidgets('Kirim form tidak valid menampilkan pesan status',
        (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.login);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, AppStrings.masuk));
      await tester.pump(); // biarkan SnackBar mulai tampil

      expect(find.text(AppStrings.periksaIsian), findsOneWidget);
    });
  });

  group('Form Target Timbang', () {
    testWidgets('kedua kolom kosong tetap bisa disimpan', (tester) async {
      final repo = FakeTargetRepository();
      final router = await pumpApp(tester, targetRepo: repo);
      router.go(AppRoutes.target);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(repo.disimpan, hasLength(1));
      expect(repo.disimpan.single.batasBerat, isNull);
      expect(repo.disimpan.single.tanggalTimbang, isNull);
    });

    testWidgets('batas berat di luar rentang ditolak', (tester) async {
      final repo = FakeTargetRepository();
      final router = await pumpApp(tester, targetRepo: repo);
      router.go(AppRoutes.target);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '250');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiBeratRentang), findsOneWidget);
      expect(repo.disimpan, isEmpty);
    });

    testWidgets('batas berat dengan koma desimal tersimpan sebagai angka',
        (tester) async {
      final repo = FakeTargetRepository();
      final router = await pumpApp(tester, targetRepo: repo);
      router.go(AppRoutes.target);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).first, '71,5');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(repo.disimpan.single.batasBerat, 71.5);
    });

    testWidgets('nilai target tersimpan langsung terisi saat dibuka',
        (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: Target(
          batasBerat: 71.5,
          tanggalTimbang: DateTime(2026, 11, 12),
        ),
      );
      router.go(AppRoutes.target);
      await tester.pumpAndSettle();

      expect(find.text('71.5'), findsOneWidget);
      expect(find.text('12 November 2026'), findsOneWidget);
    });
  });
}
