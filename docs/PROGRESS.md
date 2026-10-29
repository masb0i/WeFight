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


