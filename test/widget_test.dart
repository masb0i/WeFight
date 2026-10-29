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
import 'package:wefight/core/utils/date_format.dart';
import 'package:wefight/features/auth/data/auth_repository.dart';
import 'package:wefight/features/auth/presentation/auth_providers.dart';
import 'package:wefight/features/profile/data/user_repository.dart';
import 'package:wefight/features/profile/models/user_profile.dart';
import 'package:wefight/features/profile/presentation/profile_providers.dart';
import 'package:wefight/features/target/data/target_repository.dart';
import 'package:wefight/features/target/models/target.dart';
import 'package:wefight/features/target/presentation/target_providers.dart';
import 'package:wefight/features/weight_log/data/weight_log_repository.dart';
import 'package:wefight/features/weight_log/models/weight_log.dart';
import 'package:wefight/features/weight_log/presentation/weight_log_providers.dart';

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

/// Repository catatan berat palsu — menyimpan di list memori.
///
/// [gagalTambah] mensimulasikan kegagalan jaringan/aturan Firestore supaya
/// jalur "gagal simpan" (M10-5) bisa diuji tanpa Firebase.
class FakeWeightLogRepository implements WeightLogRepository {
  FakeWeightLogRepository({List<WeightLog>? awal, this.gagalTambah = false})
      : daftar = [...?awal];

  final List<WeightLog> daftar;
  final ditambah = <WeightLog>[];
  final diubah = <WeightLog>[];
  final dihapus = <String>[];
  final bool gagalTambah;

  WeightLog? _cari(bool Function(WeightLog) uji) {
    for (final log in daftar) {
      if (uji(log)) return log;
    }
    return null;
  }

  @override
  Stream<List<WeightLog>> watchAll(String uid) =>
      Stream.value(List<WeightLog>.unmodifiable(daftar));

  @override
  Future<WeightLog?> ambil(String id) async => _cari((log) => log.id == id);

  @override
  Future<WeightLog?> cariTanggal(String uid, DateTime tanggal) async =>
      _cari((log) => log.tanggalKunci == AppDate.keKunci(tanggal));

  @override
  Future<String> tambah(String uid, WeightLog log) async {
    if (gagalTambah) throw Exception('jaringan mati');
    ditambah.add(log);
    final id = 'baru-${ditambah.length}';
    daftar.add(log.copyWith(id: id));
    return id;
  }

  @override
  Future<void> ubah(String uid, WeightLog log) async {
    if (gagalTambah) throw Exception('jaringan mati');
    diubah.add(log);
  }

  @override
  Future<void> hapus(String id) async {
    dihapus.add(id);
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
  FakeWeightLogRepository? logRepo,
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
        weightLogRepositoryProvider.overrideWithValue(
          logRepo ?? FakeWeightLogRepository(),
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

  group('Form Catat Berat', () {
    testWidgets('tanggal default terisi hari ini', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      expect(find.text(AppDate.panjang(AppDate.hariIni())), findsOneWidget);
      expect(find.text(AppStrings.labelBeratBadan), findsOneWidget);
      expect(find.text(AppStrings.labelCatatan), findsOneWidget);
    });

    testWidgets('berat kosong ditolak', (tester) async {
      final repo = FakeWeightLogRepository();
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiBeratKosong), findsOneWidget);
      expect(repo.ditambah, isEmpty);
    });

    testWidgets('berat di luar 30-200 kg ditolak', (tester) async {
      final repo = FakeWeightLogRepository();
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '250');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiBeratRentang), findsOneWidget);
      expect(repo.ditambah, isEmpty);
    });

    testWidgets('berat dengan koma tersimpan, catatan opsional', (tester) async {
      final repo = FakeWeightLogRepository();
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '73,6');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(repo.ditambah, hasLength(1));
      expect(repo.ditambah.single.berat, 73.6);
      expect(repo.ditambah.single.catatan, isNull);
      expect(
        repo.ditambah.single.tanggalKunci,
        AppDate.keKunci(AppDate.hariIni()),
      );
    });

    testWidgets('catatan ikut tersimpan bila diisi', (tester) async {
      final repo = FakeWeightLogRepository();
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '74');
      await tester.enterText(
        find.byType(TextFormField).at(2),
        'Latihan pagi',
      );
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(repo.ditambah.single.catatan, 'Latihan pagi');
    });

    testWidgets('tanggal yang sudah ada catatannya tidak membuat duplikat',
        (tester) async {
      final repo = FakeWeightLogRepository(
        awal: [
          WeightLog(
            id: 'lama-1',
            tanggal: AppDate.hariIni(),
            berat: 74.2,
          ),
        ],
      );
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '73,6');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.duplikatJudul), findsOneWidget);
      expect(repo.ditambah, isEmpty);
    });

    testWidgets('dialog duplikat menawarkan ubah catatan yang sudah ada',
        (tester) async {
      final repo = FakeWeightLogRepository(
        awal: [
          WeightLog(
            id: 'lama-1',
            tanggal: AppDate.hariIni(),
            berat: 74.2,
          ),
        ],
      );
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '73,6');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.ubahCatatan));
      await tester.pumpAndSettle();

      // Pindah ke mode ubah dan memuat nilai yang sudah ada.
      expect(find.text(AppStrings.catatSubtitleEdit), findsOneWidget);
      expect(find.text('74.2'), findsOneWidget);
      expect(repo.ditambah, isEmpty);
    });

    testWidgets('mode ubah memuat nilai catatan yang ada', (tester) async {
      final repo = FakeWeightLogRepository(
        awal: [
          WeightLog(
            id: 'lama-1',
            tanggal: AppDate.hariIni(),
            berat: 74.2,
            catatan: 'Timbang pagi',
          ),
        ],
      );
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.editBeratPath('lama-1'));
      await tester.pumpAndSettle();

      expect(find.text('74.2'), findsOneWidget);
      expect(find.text('Timbang pagi'), findsOneWidget);
      expect(find.text(AppStrings.catatSubtitleEdit), findsOneWidget);
    });

    testWidgets('mode ubah menyimpan perubahan tanpa menambah catatan baru',
        (tester) async {
      final repo = FakeWeightLogRepository(
        awal: [
          WeightLog(
            id: 'lama-1',
            tanggal: AppDate.hariIni(),
            berat: 74.2,
          ),
        ],
      );
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.editBeratPath('lama-1'));
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '73,9');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(repo.diubah, hasLength(1));
      expect(repo.diubah.single.id, 'lama-1');
      expect(repo.diubah.single.berat, 73.9);
      expect(repo.ditambah, isEmpty);
    });

    testWidgets('gagal simpan: pesan galat tampil dan isian tidak hilang',
        (tester) async {
      final repo = FakeWeightLogRepository(gagalTambah: true);
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '73,6');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text(AppStrings.simpanGagal), findsOneWidget);
      expect(find.text('73,6'), findsOneWidget);
    });

    testWidgets('dari Dashboard ke catatan tersimpan maksimal 3 langkah',
        (tester) async {
      final repo = FakeWeightLogRepository();
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      // Langkah 1: tombol tambah di Dashboard.
      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();
      expect(find.text(AppStrings.catatSubtitleTambah), findsOneWidget);

      // Langkah 2: isi berat (tanggal sudah default hari ini).
      await tester.enterText(find.byType(TextFormField).at(1), '73,6');

      // Langkah 3: simpan.
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(repo.ditambah, hasLength(1));
      expect(find.text(AppStrings.dashboardKosongJudul), findsOneWidget);
    });
  });
}
