# WeFight — Log Progres

Log ini **append-only**: tambahkan entri baru di paling bawah, jangan pernah mengedit atau menghapus entri lama.
Rencana dan checklist ada di [`PLAN.md`](./PLAN.md) — log ini mencatat apa yang benar-benar terjadi.

**Format setiap entri** (satu entri = satu tugas):

```markdown
## YYYY-MM-DD HH:mm — [ID tugas] Judul singkat
- **Status:** selesai | sebagian | terblokir
- **Yang dikerjakan:** …
- **File disentuh:** …
- **Keputusan/kompromi:** … (atau "tidak ada")
- **Kendala:** … (atau "tidak ada")
- **Berikutnya:** [ID tugas]
```

---

## 2026-10-29 17:31 — Perencanaan proyek
- **Status:** selesai
- **Yang dikerjakan:** Mempelajari 5 dokumen di `worksheet/`, mengekstrak teksnya, lalu menyusun `docs/PLAN.md` (spesifikasi, aturan bisnis, arsitektur, 12 milestone M5–M16, 60+ tugas ber-ID, DoD, risiko) dan `docs/PROGRESS.md` ini beserta protokol pencatatan progres.
- **File disentuh:** `docs/PLAN.md`, `docs/PROGRESS.md`, `.workbuddy-ai/memory/MEMORY.md`, `.workbuddy-ai/tmp/extract_docx.py`
- **Keputusan/kompromi:** Riverpod + GoRouter + fl_chart (D1–D3, D8). Tanggal disimpan sebagai `String yyyy-MM-dd` agar pengecekan "satu catatan per tanggal" sederhana (D4). Font Inter masih terbuka (D5) — sementara pakai `textTheme` Material 3.
- **Kendala:** Belum ada repository git dan `lib/main.dart` masih counter app bawaan Flutter. Keputusan D5 menunggu pemilik proyek.
- **Berikutnya:** M5-1 `git init` + commit pertama.

## 2026-10-29 17:58 — Menetapkan referensi UI baru
- **Status:** selesai
- **Yang dikerjakan:** Menyimpan 3 gambar referensi UI ke `docs/ui-reference/`, mengambil warna aslinya lewat sampling piksel (bukan menebak), lalu menulis `docs/UI_SPEC.md` — palet 18 token, 6 definisi gradient, skala tipografi, 20 komponen, layout web/mobile, pemetaan 8 layar referensi ke 7 halaman final, dan catatan implementasi Flutter. `PLAN.md` §6 diganti ke palet burgundy→peach, ditambah §13 soal selisih referensi vs worksheet.
- **File disentuh:** `docs/UI_SPEC.md` (baru), `docs/ui-reference/*` (3 gambar), `docs/PLAN.md` (§0, §5, §6, §8 M5–M6, §12, §13), `docs/PROGRESS.md`
- **Keputusan/kompromi:** D5 selesai — font Plus Jakarta Sans dibundel. D9 — gambar referensi menggantikan style guide Figma sebagai acuan visual. D10 — baseline progres ("sudah turun X dari Y") dihitung dari catatan terawal, jadi tidak perlu field baru di `targets`. Palet worksheet (#1F3A5F biru) dibatalkan, diganti burgundy #59171B.
- **Kendala:** Referensi menampilkan fitur **Jadwal Latihan/Timbang/Pertandingan** yang berstatus Won't now di worksheet Minggu 2. Ditahan sebagai keputusan D11 + §13; default sementara = visual saja, kartu jadwal diganti "Riwayat Terbaru".
- **Berikutnya:** konfirmasi pemilik soal D11 (menu 5 slot) & fitur jadwal, lalu M5-1.

## 2026-10-29 18:14 — M5 Fondasi proyek
- **Status:** selesai
- **Yang dikerjakan:** Pemilik memilih **opsi A** (visual referensi diikuti, fitur tetap sesuai worksheet) → D11 dikunci ke 3 destinasi menu. Lalu seluruh M5 dikerjakan: `git init` branch `main` + commit pertama `1a99e85` (162 file), `main.dart` dibersihkan dari counter app, 7 dependency dipasang, struktur folder feature-first, token desain (warna/jarak/gradient/tipografi), theme `ColorScheme` eksplisit, font Plus Jakarta Sans 5 weight dibundel, router GoRouter 7 route + `errorBuilder`, placeholder screen per halaman, dan 2 widget test. `flutter analyze` bersih, `flutter test` 2/2 lolos, `flutter build web` berhasil (95 detik).
- **File disentuh:** `lib/main.dart`, `lib/app/{app,router,theme}.dart`, `lib/core/constants/{app_colors,app_spacing,app_gradients,app_text_styles,app_strings}.dart`, `lib/core/widgets/placeholder_screen.dart`, 7 file `lib/features/*/presentation/*_screen.dart`, `test/widget_test.dart`, `pubspec.yaml`, `.gitignore`, `assets/fonts/*.ttf` (5 file), `docs/{PLAN,UI_SPEC,PROGRESS}.md`
- **Keputusan/kompromi:** Versi dependency diserahkan ke `flutter pub add` agar tidak salah tebak (hasil: riverpod 3.4.3, go_router 18.1.1, fl_chart 1.3.0, firebase_auth 7.0.1, cloud_firestore 7.1.0). Font diambil sebagai TTF statis dari `fonts.gstatic.com`, bukan variable font, supaya `fontWeight` bekerja normal di Flutter. `AppBar` dibuat transparan karena latar konten sudah krem. `CardTheme`/`InputDecorationTheme` sengaja tidak dipasang di ThemeData (nama kelasnya berubah antar versi Flutter) — kartu dibuat lewat `Container` + `BoxDecoration`, input diatur langsung di form.
- **Kendala:** `flutter test` gagal dengan `WebSocketException: Invalid WebSocket upgrade request` karena variabel `HTTP_PROXY` mencegat koneksi loopback ke `flutter_tester`. Solusinya dijalankan dengan `env -u HTTP_PROXY -u HTTPS_PROXY ... flutter test`; sudah didokumentasikan di PLAN §14. Aplikasi belum dijalankan di device fisik/emulator — verifikasi memakai `flutter build web`.
- **Berikutnya:** M6-1 `app_scaffold.dart` — bottom nav (<600 px) dan rail (≥600 px) dengan 3 destinasi + FAB.

## 2026-10-29 18:31 — M6 Kerangka UI & navigasi
- **Status:** selesai
- **Yang dikerjakan:** `AppScaffold` dengan tiga mode: bottom nav + FAB ber-notch di bawah 600 px, sidebar ringkas (ikon saja) 600–1023 px, sidebar penuh 240 px dengan kartu kutipan di atas 1024 px. Web memakai bingkai gradient `pageBg` + radius shell 28 seperti referensi. Komponen dasar dibuat: `AppCard`, `PrimaryButton`, `EmptyState`, `StatusChip`, `ErrorText`, `AppTopBar`. Dashboard sekarang punya `HeroWeightCard` gradient dua kolom (berat + target, dipisah garis) dan state kosong dengan dua CTA. Riwayat Berat dan Profil memakai `AppScaffold` sehingga navigasi benar-benar jalan. Splash screen dengan gradient + wordmark, pindah ke Login setelah 1,2 detik. Ditambah alat render layar ke `docs/screenshots/` (7 gambar: mobile, tablet, web).
- **File disentuh:** `lib/core/widgets/{app_scaffold,app_card,primary_button,empty_state,status_chip,error_text,app_top_bar}.dart`, `lib/core/constants/{app_routes,app_nav,app_strings}.dart`, `lib/app/router.dart`, `lib/features/splash/presentation/splash_screen.dart`, `lib/features/dashboard/presentation/{dashboard_screen,widgets/hero_weight_card}.dart`, `lib/features/{weight_log/presentation/riwayat_berat_screen,profile/presentation/profil_screen,auth/presentation/login_screen}.dart`, `test/widget_test.dart`, `tool/render_screens_test.dart`, `docs/screenshots/*.png`
- **Keputusan/kompromi:** `AppRoutes` dipindah ke `core/constants/app_routes.dart` supaya `core/` tidak bergantung pada `app/`. `buildAppRouter()` dijadikan fungsi agar tiap test dapat instance bersih. FAB diletakkan di tengah bar dengan notch (bukan menimpa item menu) — 3 destinasi tetap sesuai worksheet. Ikon lonceng referensi **tidak** dipakai karena notifikasi berstatus Won't now. Di layar <420 px nama pengguna disembunyikan, hanya avatar — mencegah teks mepet tepi. Tombol "Lanjut ke Dashboard" di Login bersifat **sementara** sampai auth M7 ada.
- **Kendala:** Golden test sempat menggantung (`SIGTERM`) saat memuat font ikon secara sinkron; solusinya membungkus pemuatan font dengan `tester.runAsync`. Aplikasi belum dijalankan di device fisik — verifikasi lewat `flutter build web` dan render golden.
- **Berikutnya:** M7-1 inisialisasi Firebase (`flutterfire configure`) — butuh project Firebase dari pemilik.

## 2026-10-29 19:02 — Panduan setup Firebase
- **Status:** selesai
- **Yang dikerjakan:** Menulis `docs/FIREBASE_SETUP.md` — 8 bagian (buat project, aktifkan Auth email/password, buat Firestore, pasang rules, daftarkan app web + Android, pasang CLI, verifikasi, hosting), tabel masalah umum, dan aturan keamanan Firestore lengkap untuk tiga koleksi. Menu console diverifikasi ke dokumentasi resmi (sekarang **Databases & Storage → Firestore**, bukan Build). Package Android dicek dari `build.gradle.kts`: `com.example.wefight`. Ditambah M7-0 di checklist PLAN sebagai langkah manual pemilik.
- **File disentuh:** `docs/FIREBASE_SETUP.md` (baru), `docs/PLAN.md` (§8 M7, §12), `docs/PROGRESS.md`
- **Keputusan/kompromi:** Mode keamanan Firestore disarankan **Production mode** (bukan Test mode) karena aturan sudah disiapkan di dokumen yang sama — Test mode akan membuka data 30 hari lalu mati sendiri. Lokasi `asia-southeast2` (Jakarta) disarankan; dicatat bahwa lokasi permanen. Analytics disarankan dimatikan agar setup lebih singkat.
- **Kendala:** `firebase-tools` dan `flutterfire_cli` belum terpasang di mesin ini (Node v22.22.2 dan npm 10.9.7 sudah ada). Perlu `npm install -g firebase-tools`, `dart pub global activate flutterfire_cli`, lalu `firebase login`.
- **Berikutnya:** menunggu Project ID dari pemilik, lalu M7-1.

## 2026-10-29 20:05 — M7 Autentikasi
- **Status:** selesai
- **Yang dikerjakan:** Firebase tersambung ke project `wefight-38409` (web + Android, dibuat sendiri oleh pemilik). `main.dart` menginisialisasi Firebase dengan penanganan gagal (menampilkan `BootstrapErrorApp`, bukan layar putih). `AuthRepository` dibuat sebagai interface + `FirebaseAuthRepository`; `login_screen` dan `register_screen` memakai `AuthShell` bersama, validasi lewat `Validators`, pesan galat Firebase diterjemahkan ke bahasa Indonesia di `auth_error.dart`. Guard login dipasang di GoRouter lewat `redirect` + `refreshListenable` (langganan auth otomatis lepas saat router di-dispose). Profil kini menampilkan nama, email, menu Pengaturan Target & Riwayat, dan tombol Keluar dengan dialog konfirmasi. Dashboard memakai nama pengguna asli untuk sapaan. Tombol sementara "Lanjut ke Dashboard" sudah dihapus. Test naik dari 5 ke 11.
- **File disentuh:** `lib/main.dart`, `lib/app/{app,router}.dart`, `lib/features/auth/data/{auth_repository,auth_error}.dart`, `lib/features/auth/presentation/{login_screen,register_screen,auth_providers}.dart`, `lib/features/auth/presentation/widgets/auth_shell.dart`, `lib/core/utils/validators.dart`, `lib/core/widgets/{app_text_field,app_card}.dart`, `lib/features/profile/presentation/profil_screen.dart`, `lib/features/dashboard/presentation/dashboard_screen.dart`, `test/widget_test.dart`, `tool/render_screens_test.dart`, `docs/screenshots/*` (9 PNG)
- **Keputusan/kompromi:** `AuthRepository` dijadikan **interface** (bukan kelas konkret) supaya guard router bisa diuji dengan `FakeAuthRepository` tanpa Firebase — ini yang membuat dua test guard bisa ada. Status loading/galat form disimpan sebagai state lokal widget, bukan provider, karena hanya hidup selama satu layar. Guard dipasang dengan `refreshListenable` alih-alih membuat ulang router, supaya riwayat navigasi tidak hilang. **Bug ditemukan lewat render golden:** `ListTile` di dalam `AppCard` memicu assertion "ink splashes may be invisible" — `AppCard` diubah memakai `Material` sebagai latar, bukan `DecoratedBox`, dan ripple kini terlihat. Notch bottom bar juga hanya dipakai saat FAB tampil.
- **Kendala:** Belum diuji login sungguhan di perangkat — perlu `flutter run -d chrome` oleh pemilik untuk memastikan kredensial benar-benar diterima Firebase. Render golden sempat gagal karena Dashboard kini membaca `authStateProvider`; alat render diberi override `Stream<User?>.value(null)`.
- **Berikutnya:** M8-1 model `Target` + `WeightLog`, lalu repository Firestore dan rules (rules sudah disiapkan di `docs/FIREBASE_SETUP.md` §D).





## 2026-10-29 20:21 — M8 Lapisan data Firestore
- **Status:** selesai
- **Yang dikerjakan:** Tiga model immutable (`Target`, `WeightLog`, `UserProfile`) lengkap dengan `fromMap`/`fromDoc`, `toMap`, dan `copyWith` yang bisa mengosongkan field. `AppDate` di `core/utils/date_format.dart` jadi satu-satunya tempat konversi tanggal ↔ kunci `yyyy-MM-dd`, plus nama bulan Indonesia dan hitung selisih hari. Tiga repository: `FirestoreTargetRepository` (doc id = uid), `FirestoreWeightLogRepository` (query wajib `where uid`, urut tanggal menurun, ada `cariTanggal` untuk aturan satu-catatan-per-tanggal), `FirestoreUserRepository` (`users/{uid}`). Provider `currentUidProvider`, `targetProvider`, `weightLogsProvider`, `beratTerakhirProvider`. Layar Daftar sekarang menulis `users/{uid}` setelah akun dibuat. Aturan keamanan dipindah ke `firestore.rules` + `.firebaserc` dan **berhasil di-deploy** ke `wefight-38409`. Data demo terisi: akun `fighter@wefight.demo` dengan target 71 kg, hari timbang 14 hari lagi, dan 6 catatan berat 76,4 → 73,6 kg. Test naik dari 11 ke 31 (20 test model/tanggal baru).
- **File disentuh:** `lib/core/utils/date_format.dart`, `lib/features/target/{models/target,data/target_repository,presentation/target_providers}.dart`, `lib/features/weight_log/{models/weight_log,data/weight_log_repository,presentation/weight_log_providers}.dart`, `lib/features/profile/{models/user_profile,data/user_repository,presentation/profile_providers}.dart`, `lib/features/auth/data/auth_repository.dart` (getter `currentUid`), `lib/features/auth/presentation/{auth_providers,register_screen}.dart`, `test/{models_test,widget_test}.dart`, `tool/{firebase_rest,seed_demo,cek_isolasi}.dart`, `firestore.rules`, `.firebaserc`, `firebase.json`, `docs/{PLAN,FIREBASE_SETUP,PROGRESS}.md`
- **Keputusan/kompromi:** Pertanyaan terbuka di §5 dijawab pemilik: `users/{uid}` **ditulis saat daftar** (D12), dan data demo diisi **skrip REST** (D13), bukan tombol dev di aplikasi. `weightLogs` memakai `id` kosong sebagai penanda "belum tersimpan" — menghindari null-check di mana-mana. `Target.fromMap` mengembalikan `Target.kosong` (bukan null) supaya layar tidak perlu membedakan "memuat" dan "belum diatur". `copyWith` memakai flag `hapusX` karena parameter nullable tidak bisa membedakan "tidak diubah" dan "dijadikan null".
- **Kendala:** Dua bug nyata ketemu saat verifikasi. (1) `AppDate.relatif` awalnya membalik tanda — kemarin menghasilkan −1, bukan +1; ketahuan dari unit test. (2) Aturan Firestore memakai `request.data`, yang **bukan field yang dikenal** sehingga semua penulisan `weightLogs` ditolak `Missing or insufficient permissions`; nama yang benar `request.resource.data`. Gejalanya menipu karena `targets/{uid}` (diperiksa lewat id) tetap berhasil. Keduanya sudah diperbaiki dan dicatat di PLAN §14. Skrip seed juga sempat gagal karena koneksi keep-alive basi (`Connection closed before full header was received`) — sekarang tiap permintaan memakai koneksi baru + satu retry.
- **Berikutnya:** M9-1 form Target Timbang (batas berat + `showDatePicker`), memakai `targetProvider` dan `TargetRepository.simpan`.

### Verifikasi M8-4 (isolasi data per uid)
`dart run tool/cek_isolasi.dart` → **5/5 lulus** dengan dua akun:

```
LULUS  Akun A membaca catatannya sendiri ... 6 catatan
LULUS  Akun B membaca catatan akun A ... ditolak aturan
LULUS  Akun B membaca catatan miliknya ... 0 catatan (memang kosong)
LULUS  Akun B membuka target akun A ... ditolak aturan
LULUS  Akun B menulis catatan atas nama akun A ... ditolak aturan
```

## 2026-10-29 20:35 — P Penyesuaian modul praktik Minggu 5–7
- **Status:** selesai (kecuali P5 & P6 yang butuh tindakan pemilik)
- **Yang dikerjakan:** Pemilik menyerahkan folder `modulmateri/` berisi tiga modul dosen (Minggu 5–7) yang belum pernah dibaca. Ketiganya diekstrak dan dibandingkan dengan kondisi proyek; hasilnya ditulis sebagai PLAN §15. Lima selisih diperbaiki: (1) README ditulis ulang berisi identitas, deskripsi, tautan Figma, cara menjalankan, akun demo, dan 5 screenshot; (2) tujuh halaman dipindah ke `lib/pages/` dengan kelas `*Page` sesuai modul Minggu 6; (3) `AppSnackBar` baru dipakai di Login & Daftar untuk pesan status berhasil/gagal; (4) `AutovalidateMode.onUserInteraction` dipasang di kedua Form; (5) `docs/UJI_FORM.md` berisi 10 kasus uji form. Test naik dari 31 ke 34 (3 kasus validasi & pesan status baru).
- **File disentuh:** `README.md` (ditulis ulang), `lib/pages/*.dart` (8 berkas, hasil `git mv`), `lib/app/router.dart`, `lib/core/widgets/app_snackbar.dart` (baru), `lib/core/constants/app_strings.dart`, `test/widget_test.dart`, `docs/{PLAN,PROGRESS,UJI_FORM}.md`, `.gitignore`
- **Keputusan/kompromi:** Pemilik memilih **mengubah struktur ke `lib/pages/`** (D15) meski sebelumnya feature-first, agar sesuai tuntutan modul; lapisan data tetap di `lib/features/` supaya query Firestore tidak tercampur kode tampilan. Warna primer **tetap burgundy** (D16) karena modul menyebut warna style guide sebagai opsional dan pemilik sudah memilih gambar referensi — alasannya ditulis di README supaya bisa dipertanggungjawabkan. Folder `modulmateri/` **tidak di-commit** (materi dosen, bukan bagian aplikasi).
- **Kendala:** Refactor path sempat meninggalkan impor relatif yang menunjuk kedalaman lama (`'auth_providers.dart'`, `'widgets/auth_shell.dart'`); skrip pemindah hanya menangani impor berawalan titik. Diperbaiki dengan pass kedua yang me-resolve semua impor relatif terhadap folder lama, lalu `flutter analyze` bersih. Screenshot tidak berubah karena tampilan tidak berubah.
- **Berikutnya:** **P5 push ke GitHub** (pemilik membuat repo kosong lalu memberi URL) dan **P6 `flutter run -d chrome`**. Setelah itu M9-1 form Target Timbang.
