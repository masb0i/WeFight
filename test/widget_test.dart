import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:fl_chart/fl_chart.dart';
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
///
/// `watchAll` meniru kontrak repository sungguhan: mengirim isi terbaru lebih
/// dulu, lalu setiap perubahan (tambah/ubah/hapus) — itulah yang membuat
/// daftar Riwayat ikut berubah tanpa memuat ulang halaman (M11-5).
class FakeWeightLogRepository implements WeightLogRepository {
  FakeWeightLogRepository({
    List<WeightLog>? awal,
    this.gagalTambah = false,
    this.gagalWatch = false,
  }) : daftar = [...?awal];

  final List<WeightLog> daftar;
  final ditambah = <WeightLog>[];
  final diubah = <WeightLog>[];
  final dihapus = <String>[];
  final bool gagalTambah;

  /// Meniru query Firestore yang ditolak server (mis. indeks belum ada atau
  /// aturan menolak). Dipakai menguji keadaan galat di layar (D25).
  final bool gagalWatch;

  final _perubahan = StreamController<List<WeightLog>>.broadcast();

  WeightLog? _cari(bool Function(WeightLog) uji) {
    for (final log in daftar) {
      if (uji(log)) return log;
    }
    return null;
  }

  /// Meniru `urutkanTerbaruDulu` di repository Firestore (D24).
  List<WeightLog> get _urut => [...daftar]
    ..sort((a, b) => b.tanggal.compareTo(a.tanggal));

  void _kabarkan() {
    if (!_perubahan.isClosed) {
      _perubahan.add(List<WeightLog>.unmodifiable(_urut));
    }
  }

  @override
  Stream<List<WeightLog>> watchAll(String uid) async* {
    if (gagalWatch) throw Exception('tidak ada koneksi');
    yield List<WeightLog>.unmodifiable(_urut);
    yield* _perubahan.stream;
  }

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
    _kabarkan();
    return id;
  }

  @override
  Future<void> ubah(String uid, WeightLog log) async {
    if (gagalTambah) throw Exception('jaringan mati');
    diubah.add(log);
    final posisi = daftar.indexWhere((item) => item.id == log.id);
    if (posisi != -1) {
      daftar[posisi] = log;
      _kabarkan();
    }
  }

  @override
  Future<void> hapus(String id) async {
    if (gagalTambah) throw Exception('jaringan mati');
    dihapus.add(id);
    daftar.removeWhere((log) => log.id == id);
    _kabarkan();
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

    // Kolom berat memakai `FilteringTextInputFormatter` yang membuang huruf,
    // jadi teks "73kg" tidak pernah sampai ke validator — yang tersisa "73".
    // Nilai bukan angka tetap bisa lolos lewat pemisah desimal sendirian,
    // dan di situlah pesan "harus berupa angka" harus muncul.
    testWidgets('berat bukan angka ditolak', (tester) async {
      final repo = FakeWeightLogRepository();
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.catatBerat);
      await tester.pumpAndSettle();

      await tester.enterText(find.byType(TextFormField).at(1), '73kg');
      await tester.pump();
      expect(find.text('73'), findsOneWidget);

      await tester.enterText(find.byType(TextFormField).at(1), '.');
      await tester.tap(find.widgetWithText(FilledButton, AppStrings.simpan));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.validasiBeratAngka), findsOneWidget);
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
      // Kembali ke Dashboard dan berat terakhir langsung terpakai.
      expect(find.text(AppStrings.catatSubtitleTambah), findsNothing);
      expect(find.text('73.6'), findsOneWidget);
    });
  });

  group('Riwayat Berat', () {
    /// Dua catatan: hari ini dan dua hari lalu.
    List<WeightLog> duaCatatan() => [
          WeightLog(
            id: 'baru',
            tanggal: AppDate.hariIni(),
            berat: 73.6,
            catatan: 'Latihan pagi',
          ),
          WeightLog(
            id: 'lama',
            tanggal: AppDate.hariIni().subtract(const Duration(days: 2)),
            berat: 74.2,
          ),
        ];

    testWidgets('daftar menampilkan berat, tanggal, dan catatan', (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(awal: duaCatatan()),
      );
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      expect(find.text('73.6 kg'), findsOneWidget);
      expect(find.text('74.2 kg'), findsOneWidget);
      expect(find.text(AppDate.panjang(AppDate.hariIni())), findsOneWidget);
      expect(find.text('Latihan pagi'), findsOneWidget);
      expect(find.text(AppStrings.riwayatJumlah(2)), findsOneWidget);
    });

    testWidgets('kolom perubahan menampilkan selisih terhadap catatan sebelumnya',
        (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(awal: duaCatatan()),
      );
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      // 73,6 − 74,2 = −0,6 → turun.
      expect(find.text('-0.6 kg'), findsOneWidget);
      // Catatan paling awal tidak punya pembanding.
      expect(find.text('Tetap'), findsNothing);
    });

    testWidgets('catatan terbaru tampil paling atas', (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(awal: duaCatatan()),
      );
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      final atas = tester.getTopLeft(find.text('73.6 kg')).dy;
      final bawah = tester.getTopLeft(find.text('74.2 kg')).dy;
      expect(atas, lessThan(bawah));
    });

    testWidgets('keadaan kosong mengarahkan ke Catat Berat', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.riwayatKosongJudul), findsOneWidget);
      expect(find.text(AppStrings.catatBerat), findsOneWidget);
    });

    testWidgets('ketuk catatan membuka mode ubah', (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(awal: duaCatatan()),
      );
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      await tester.tap(find.text('74.2 kg'));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.catatSubtitleEdit), findsOneWidget);
      expect(find.text('74.2'), findsOneWidget);
    });

    testWidgets('hapus menampilkan dialog konfirmasi yang bisa dibatalkan',
        (tester) async {
      final repo = FakeWeightLogRepository(awal: duaCatatan());
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.hapusCatatanJudul), findsOneWidget);

      await tester.tap(find.text(AppStrings.batal));
      await tester.pumpAndSettle();

      expect(repo.dihapus, isEmpty);
      expect(find.text('73.6 kg'), findsOneWidget);
    });

    testWidgets('konfirmasi hapus menghilangkan catatan dari daftar',
        (tester) async {
      final repo = FakeWeightLogRepository(awal: duaCatatan());
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.delete_outline).first);
      await tester.pumpAndSettle();
      await tester.tap(find.text(AppStrings.hapus));
      await tester.pumpAndSettle();

      expect(repo.dihapus, ['baru']);
      expect(find.text('73.6 kg'), findsNothing);
      expect(find.text('74.2 kg'), findsOneWidget);
      expect(find.text(AppStrings.riwayatJumlah(1)), findsOneWidget);
    });

    testWidgets('tombol tambah di halaman riwayat membuka Catat Berat',
        (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.catatSubtitleTambah), findsOneWidget);
    });
  });

  group('Ringkasan Dashboard', () {
    List<WeightLog> catatan(double berat) => [
          WeightLog(id: 'satu', tanggal: AppDate.hariIni(), berat: berat),
        ];

    testWidgets('menampilkan berat terakhir dan selisih di atas batas',
        (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: const Target(batasBerat: 71),
        logRepo: FakeWeightLogRepository(awal: catatan(73.6)),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text('73.6'), findsOneWidget);
      expect(find.text('71 kg'), findsOneWidget);
      expect(find.text('2.6 kg di atas batas'), findsOneWidget);
    });

    testWidgets('selisih negatif memakai "di bawah batas"', (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: const Target(batasBerat: 71),
        logRepo: FakeWeightLogRepository(awal: catatan(70)),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text('1 kg di bawah batas'), findsOneWidget);
    });

    testWidgets('berat tepat di batas menampilkan "Tepat di batas"',
        (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: const Target(batasBerat: 71),
        logRepo: FakeWeightLogRepository(awal: catatan(71)),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.selisihTepat), findsOneWidget);
    });

    testWidgets('hitung mundur: masih ada sisa hari', (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: Target(
          batasBerat: 71,
          tanggalTimbang: AppDate.hariIni().add(const Duration(days: 14)),
        ),
        logRepo: FakeWeightLogRepository(awal: catatan(73.6)),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.labelHariTimbang), findsOneWidget);
      expect(find.text('14 hari lagi'), findsOneWidget);
    });

    testWidgets('hitung mundur: hari ini hari timbang', (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: Target(
          batasBerat: 71,
          tanggalTimbang: AppDate.hariIni(),
        ),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.hitungMundurHariIni), findsOneWidget);
    });

    testWidgets('hitung mundur: hari timbang sudah terlewat', (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: Target(
          batasBerat: 71,
          tanggalTimbang: AppDate.hariIni().subtract(const Duration(days: 3)),
        ),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text('Hari timbang terlewat 3 hari'), findsOneWidget);
    });

    testWidgets('kartu ajakan target muncul hanya bila target kosong',
        (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.belumAdaTargetJudul), findsOneWidget);
      expect(find.text(AppStrings.aturTarget), findsOneWidget);
    });

    testWidgets('kartu ajakan target hilang setelah target diisi',
        (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: const Target(batasBerat: 71),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.belumAdaTargetJudul), findsNothing);
      expect(find.text(AppStrings.aturTarget), findsNothing);
    });

    testWidgets('belum ada catatan: berat kosong dan kartu penjelasan tampil',
        (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: const Target(batasBerat: 71),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.dashboardKosongJudul), findsOneWidget);
      expect(find.text(AppStrings.dashboardKosongPesan), findsOneWidget);
      expect(find.text(AppStrings.heroBelumAdaCatatan), findsOneWidget);
      // D21: kartu keadaan kosong tidak menambah tombol — aksi utama tetap
      // satu, yaitu tombol di atasnya.
      expect(
        find.widgetWithText(FilledButton, AppStrings.catatBerat),
        findsOneWidget,
      );
    });

    testWidgets('tombol Catat Berat membuka form', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      await tester.tap(find.widgetWithText(FilledButton, AppStrings.catatBerat));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.catatSubtitleTambah), findsOneWidget);
    });
  });

  group('Grafik tren', () {
    /// Tiga catatan, urut terbaru lebih dulu seperti keluaran provider.
    List<WeightLog> tigaCatatan() => [
          WeightLog(
            id: 'c',
            tanggal: AppDate.hariIni(),
            berat: 73.6,
          ),
          WeightLog(
            id: 'b',
            tanggal: AppDate.hariIni().subtract(const Duration(days: 1)),
            berat: 73.9,
          ),
          WeightLog(
            id: 'a',
            tanggal: AppDate.hariIni().subtract(const Duration(days: 2)),
            berat: 74.2,
          ),
        ];

    testWidgets('satu catatan belum cukup untuk menggambar grafik',
        (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(
          awal: [
            WeightLog(id: 'a', tanggal: AppDate.hariIni(), berat: 73.6),
          ],
        ),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.grafikBelumCukup), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });

    testWidgets('dua catatan atau lebih menggambar garis', (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(awal: tigaCatatan()),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.grafikJudul), findsOneWidget);
      expect(find.byType(LineChart), findsOneWidget);
      expect(find.text(AppStrings.grafikBelumCukup), findsNothing);
    });

    testWidgets('titik grafik urut dari catatan terlama ke terbaru',
        (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(awal: tigaCatatan()),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final spots = chart.data.lineBarsData.first.spots;

      expect(spots, hasLength(3));
      expect(spots.map((s) => s.x), [0, 1, 2]);
      expect(spots.map((s) => s.y), [74.2, 73.9, 73.6]);
    });

    testWidgets('garis target hanya muncul bila batas berat diisi',
        (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: const Target(batasBerat: 71),
        logRepo: FakeWeightLogRepository(awal: tigaCatatan()),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      final garis = chart.data.extraLinesData.horizontalLines;

      expect(garis, hasLength(1));
      expect(garis.single.y, 71);
    });

    testWidgets('tanpa batas berat tidak ada garis target', (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(awal: tigaCatatan()),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      final chart = tester.widget<LineChart>(find.byType(LineChart));
      expect(chart.data.extraLinesData.horizontalLines, isEmpty);
      expect(find.text(AppStrings.grafikTanpaTarget), findsOneWidget);
    });

    testWidgets('grafik dibungkus RepaintBoundary', (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(awal: tigaCatatan()),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(
        find.ancestor(
          of: find.byType(LineChart),
          matching: find.byType(RepaintBoundary),
        ),
        findsWidgets,
      );
    });

    testWidgets('grafik ikut berubah setelah catatan dihapus', (tester) async {
      final repo = FakeWeightLogRepository(awal: tigaCatatan());
      final router = await pumpApp(tester, logRepo: repo);
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.byType(LineChart), findsOneWidget);

      await repo.hapus('a');
      await repo.hapus('b');
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.grafikBelumCukup), findsOneWidget);
      expect(find.byType(LineChart), findsNothing);
    });
  });

  // D25: kegagalan mengambil data tidak boleh tampil sebagai "belum ada data".
  // Kalau tercampur, pengguna mengira catatannya hilang — persis yang terjadi
  // saat query Firestore ditolak karena indeks komposit belum ada.
  group('Keadaan galat', () {
    testWidgets('Dashboard menampilkan galat, bukan keadaan kosong',
        (tester) async {
      final router = await pumpApp(
        tester,
        targetAwal: const Target(batasBerat: 71),
        logRepo: FakeWeightLogRepository(gagalWatch: true),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.dashboardGagal), findsOneWidget);
      expect(find.text(AppStrings.dashboardGagalPesan), findsOneWidget);
      // Bukan keadaan kosong, dan bukan angka karangan.
      expect(find.text(AppStrings.dashboardKosongJudul), findsNothing);
      expect(find.text(AppStrings.heroGagalMuat), findsOneWidget);
      expect(find.text(AppStrings.nilaiKosong), findsOneWidget);
    });

    testWidgets('Dashboard tidak berputar selamanya saat galat', (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(gagalWatch: true),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.widgetWithText(FilledButton, AppStrings.coba), findsOneWidget);
    });

    testWidgets('Dashboard punya tombol coba lagi', (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(gagalWatch: true),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.widgetWithText(FilledButton, AppStrings.coba), findsOneWidget);
    });

    testWidgets('Riwayat menampilkan galat dengan tombol coba lagi',
        (tester) async {
      final router = await pumpApp(
        tester,
        logRepo: FakeWeightLogRepository(gagalWatch: true),
      );
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.muatGagal), findsOneWidget);
      expect(find.text(AppStrings.muatGagalPesan), findsOneWidget);
      expect(find.text(AppStrings.riwayatKosongJudul), findsNothing);
      expect(find.widgetWithText(FilledButton, AppStrings.coba), findsOneWidget);
    });
  });

  // D26: bar bawah sempat memakai notch dengan FAB ditengah, padahal menu ada
  // tiga. Tiga item yang dibagi rata menaruh item tengah tepat di titik tengah,
  // jadi FAB selalu menutupi "Riwayat Berat". Test ini mengunci geometrinya.
  group('Navigasi bawah', () {
    Rect rectItem(WidgetTester tester, String label) {
      return tester.getRect(
        find
            .ancestor(
              of: find.text(label),
              matching: find.byType(InkWell),
            )
            .first,
      );
    }

    testWidgets('FAB tidak menimpa satu pun item menu', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      final fab = tester.getRect(find.byType(FloatingActionButton));
      for (final label in [
        AppStrings.navDashboard,
        AppStrings.navRiwayat,
        AppStrings.navProfil,
      ]) {
        expect(
          fab.overlaps(rectItem(tester, label)),
          isFalse,
          reason: 'FAB menimpa menu "$label"',
        );
      }
    });

    testWidgets('FAB berada di atas bar, bukan menembusnya', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      final fab = tester.getRect(find.byType(FloatingActionButton));
      final item = rectItem(tester, AppStrings.navDashboard);

      // Seluruh badan FAB harus berakhir sebelum bar dimulai.
      expect(fab.bottom, lessThanOrEqualTo(item.top));
    });

    testWidgets('tiga item menu berjarak rata', (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      final tengah = [
        for (final label in [
          AppStrings.navDashboard,
          AppStrings.navRiwayat,
          AppStrings.navProfil,
        ])
          tester.getCenter(find.text(label)).dx,
      ];

      final jarakKiri = tengah[1] - tengah[0];
      final jarakKanan = tengah[2] - tengah[1];
      expect(jarakKiri, greaterThan(0));
      expect(
        (jarakKiri - jarakKanan).abs(),
        lessThan(1.0),
        reason: 'jarak antar menu tidak rata: $jarakKiri vs $jarakKanan',
      );
    });

    testWidgets('item aktif ditandai teks tebal, bukan warna saja',
        (tester) async {
      final router = await pumpApp(tester);
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      final aktif = tester.widget<Text>(find.text(AppStrings.navDashboard));
      final pasif = tester.widget<Text>(find.text(AppStrings.navProfil));

      expect(aktif.style?.fontWeight, FontWeight.w700);
      expect(pasif.style?.fontWeight, isNot(FontWeight.w700));
    });
  });

  group('Responsif', () {
    List<WeightLog> contoh() => [
          WeightLog(id: 'b', tanggal: AppDate.hariIni(), berat: 73.6),
          WeightLog(
            id: 'a',
            tanggal: AppDate.hariIni().subtract(const Duration(days: 3)),
            berat: 74.2,
          ),
        ];

    for (final lebar in [360.0, 768.0, 1440.0]) {
      testWidgets('Dashboard ${lebar.toInt()} px tanpa overflow',
          (tester) async {
        final router = await pumpApp(
          tester,
          size: Size(lebar, 900),
          targetAwal: Target(
            batasBerat: 71,
            tanggalTimbang: AppDate.hariIni().add(const Duration(days: 14)),
          ),
          logRepo: FakeWeightLogRepository(awal: contoh()),
        );
        router.go(AppRoutes.dashboard);
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.labelBeratSaatIni), findsOneWidget);
        expect(find.text('73.6'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('Riwayat ${lebar.toInt()} px tanpa overflow', (tester) async {
        final router = await pumpApp(
          tester,
          size: Size(lebar, 900),
          logRepo: FakeWeightLogRepository(awal: contoh()),
        );
        router.go(AppRoutes.riwayat);
        await tester.pumpAndSettle();

        expect(find.text('73.6 kg'), findsOneWidget);
        expect(tester.takeException(), isNull);
      });

      testWidgets('form Catat Berat ${lebar.toInt()} px tanpa overflow',
          (tester) async {
        final router = await pumpApp(tester, size: Size(lebar, 900));
        router.go(AppRoutes.catatBerat);
        await tester.pumpAndSettle();

        expect(find.text(AppStrings.labelBeratBadan), findsOneWidget);
        expect(tester.takeException(), isNull);
      });
    }

    testWidgets('menu memakai label yang sama di mobile dan web',
        (tester) async {
      final mobile = await pumpApp(tester, size: const Size(390, 844));
      mobile.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.navDashboard), findsOneWidget);
      expect(find.text(AppStrings.navRiwayat), findsOneWidget);
      expect(find.text(AppStrings.navProfil), findsOneWidget);

      final web = await pumpApp(tester, size: const Size(1440, 900));
      web.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.navDashboard), findsOneWidget);
      expect(find.text(AppStrings.navRiwayat), findsOneWidget);
      expect(find.text(AppStrings.navProfil), findsOneWidget);
    });

    testWidgets('menu web membuka halaman yang sama seperti mobile',
        (tester) async {
      final router = await pumpApp(tester, size: const Size(1440, 900));
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      await tester.tap(find.text(AppStrings.navRiwayat));
      await tester.pumpAndSettle();

      expect(find.text(AppStrings.riwayatKosongJudul), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('Dashboard web memakai dua kolom', (tester) async {
      final router = await pumpApp(
        tester,
        size: const Size(1440, 900),
        targetAwal: const Target(batasBerat: 71),
        logRepo: FakeWeightLogRepository(awal: contoh()),
      );
      router.go(AppRoutes.dashboard);
      await tester.pumpAndSettle();

      // Hero di kiri, grafik di kanan: titik tengah grafik berada di paruh
      // kanan layar.
      final hero = tester.getCenter(find.text(AppStrings.labelBeratSaatIni));
      final grafik = tester.getCenter(find.byType(LineChart));

      expect(hero.dx, lessThan(grafik.dx));
      expect(grafik.dx, greaterThan(720));
    });

    testWidgets('halaman Riwayat web memakai tombol di kanan atas',
        (tester) async {
      final router = await pumpApp(tester, size: const Size(1440, 900));
      router.go(AppRoutes.riwayat);
      await tester.pumpAndSettle();

      final tombol = find.widgetWithText(FilledButton, AppStrings.catatBerat);
      expect(tombol, findsOneWidget);
      // Tidak ada FAB di layar lebar — aksi utama tidak boleh dobel.
      expect(find.byType(FloatingActionButton), findsNothing);
      // Posisinya di area header (atas), bukan di tengah konten.
      expect(tester.getCenter(tombol).dy, lessThan(200));
    });
  });
}
