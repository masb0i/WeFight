# WeFight — Rencana Implementasi

> **File ini adalah sumber kebenaran proyek.** Baca file ini dari atas sampai bawah setiap memulai sesi baru,
> sebelum menyentuh kode. Setelah itu baca entri terakhir di [`PROGRESS.md`](./PROGRESS.md).
> Jangan mengubah bagian **§1 Spesifikasi** dan **§3 Aturan Bisnis** tanpa persetujuan pemilik proyek —
> isinya diturunkan dari worksheet Minggu 1–4 yang sudah dinilai.

Terakhir diperbarui: 2026-10-29

---

## 0. Cara memakai file ini

| Peran | Tindakan |
|---|---|
| Sesi baru (konteks habis) | Baca §1–§4 → cek checklist §8 untuk posisi terakhir → baca entri terakhir `PROGRESS.md` |
| Sebelum membangun UI | Baca [`UI_SPEC.md`](./UI_SPEC.md) + buka gambar di `docs/ui-reference/` |
| Sebelum mulai tugas | Cari ID tugas (`M6-2`) di §8, ubah `[ ]` → `[~]` |
| Setelah tugas selesai | `[~]` → `[x]` + tulis entri di `PROGRESS.md` (format di §9) |
| Ada keputusan teknis baru | Catat di §5 tabel keputusan, jangan hanya di log |
| Ragu soal requirement | Cek §1/§3 dulu; kalau tetap tidak ada, **tanya pemilik**, jangan mengarang |

---

## 1. Spesifikasi (dari worksheet, jangan diubah)

**Produk:** WeFight — Weight for Fight Tracker. Aplikasi mobile + web untuk memantau berat badan menuju hari timbang pertandingan Muay Thai.

**Pengguna:** fighter pemula Muay Thai yang akan menjalani pertandingan pertama. Satu peran saja, tanpa fitur sosial/pelatih.

**Masalah:** berat badan dicatat di catatan HP tanpa hitung mundur ke hari timbang dan tanpa selisih ke batas berat, sehingga pengguna baru sadar beratnya masih jauh dari batas ketika waktu sudah dekat.

**Stack wajib:** Flutter + Dart, Firebase Authentication (email/password), Cloud Firestore, Firebase Hosting, GitHub, Figma.

**Dilarang:** billing account, Cloud Functions, autentikasi telepon/OTP, unggah berkas besar, payment gateway, saran diet/rehidrasi/water cut.

**Data:** hanya data simulasi untuk demo; tanpa data medis atau data pribadi sensitif.

### 1.1 Tujuh halaman final

Nama ini **wajib identik** di route, judul AppBar, item menu, dan nama frame Figma.

| Kode | Halaman | Prioritas | Route usulan |
|---|---|---|---|
| H1 | Login | Must | `/login` |
| H2 | Daftar | Should | `/register` |
| H3 | Dashboard | Must | `/` |
| H4 | Target Timbang | Must | `/target` |
| H5 | Catat Berat | Must | `/weight/new` (+ `/weight/:id/edit`) |
| H6 | Riwayat Berat | Must | `/history` |
| H7 | Profil | Should | `/profile` |

### 1.2 Navigasi

- Mobile (<600 px): `NavigationBar` — Dashboard · Riwayat Berat · Profil (urutan tetap).
- Web (≥600 px): `NavigationRail` / sidebar — item dan urutan sama persis.
- Aksi utama "Catat Berat": tombol menonjol di Dashboard + FAB di Riwayat Berat.
- Target Timbang dibuka dari kartu ajakan di Dashboard (bukan item menu).
- Login/Daftar di luar navigasi; Keluar di AppBar/header.

### 1.3 Skema Firestore

```
users/{uid}            { nama, email, dibuatPada }
targets/{uid}          { batasBerat?, tanggalTimbang?, diperbaruiPada }
weightLogs/{autoId}    { tanggal (yyyy-MM-dd), berat (num), catatan?, dibuatPada, diperbaruiPada }
```

- `targets` memakai `uid` sebagai document id → satu target aktif per pengguna.
- `weightLogs` difilter `where uid == currentUser.uid`, diurutkan `tanggal desc`.
- `users` boleh menyimpan `uid` di dalam dokumen untuk konsistensi aturan.
- Aturan keamanan: pengguna hanya boleh baca/tulis dokumen miliknya sendiri (`request.auth.uid`).

---

## 2. Ruang lingkup

**Must (dibangun):** Login, Dashboard, Target Timbang, Catat Berat, Riwayat Berat + grafik tren + isolasi data per uid.

**Should (setelah semua Must selesai):** Daftar (register), Profil + Keluar, lupa password, filter riwayat per rentang tanggal.

**Won't now (jangan dikerjakan):** multi-target/pertandingan, notifikasi/pengingat, ekspor data, lebih dari satu catatan per hari, detail catatan sebagai halaman terpisah, saran kesehatan apa pun.

---

## 3. Aturan bisnis (harus dipatuhi kode)

1. **Satu catatan per tanggal.** Jika pengguna menyimpan berat pada tanggal yang sudah punya catatan, jangan buat duplikat — beri tahu dan tawarkan mode edit untuk catatan itu.
2. **Validasi berat:** wajib, harus angka, rentang wajar **30–200 kg** (asumsi yang ditandai di worksheet). Di luar rentang → pesan galat di bawah kolom, data tidak tersimpan.
3. **Target boleh kosong.** `batasBerat` dan/atau `tanggalTimbang` boleh null. Dashboard menampilkan state kosong yang mengarahkan, bukan error.
4. **Selisih** = berat terakhir − batas berat. Tampilkan salah satu dari: `X kg di atas batas` / `Tepat di batas` / `X kg di bawah batas`. Selisih 0 → "Tepat di batas".
5. **Hitung mundur** = tanggal timbang − hari ini. `0` → "Hari ini hari timbang". Negatif → "Hari timbang terlewat".
6. **Berat terakhir** = berat dari catatan dengan `tanggal` terbaru (bukan `dibuatPada`).
7. **Grafik tren** butuh ≥2 catatan; kurang dari itu tampilkan pesan "data belum cukup".
8. **Data terisolasi per uid.** Akun B tidak boleh melihat data akun A.
9. **Hanya menampilkan data.** Tidak ada rekomendasi, saran, atau interpretasi medis.
10. **Status tidak boleh dibedakan hanya dengan warna** — selalu sertakan teks.

---

## 4. Arsitektur & struktur folder

Pola: **satu file per halaman di `lib/pages/`** (sesuai modul Minggu 6) + **lapisan data
per fitur** di `lib/features/` (keputusan D15). Arah dependensi satu arah:
`pages → features/presentation (provider) → features/data → Firestore`.

```
lib/
  main.dart                     # bootstrap: Firebase.initializeApp + ProviderScope
  app/
    app.dart                    # MaterialApp.router
    router.dart                 # GoRouter + auth redirect guard
    theme.dart                  # ThemeData dari design token §6
  core/
    constants/
      app_colors.dart
      app_spacing.dart          # spacing 8/16/24, radius, tinggi tombol 48
      app_strings.dart          # semua teks Indonesia (hindari hardcode di widget)
    utils/
      weight_math.dart          # hitungSelisih, hitungSisaHari, labelSelisih
      validators.dart           # validateBerat, validateTanggal
      date_format.dart          # format & parse yyyy-MM-dd
    widgets/
      app_scaffold.dart         # AppBar + NavigationBar/NavigationRail responsif
      app_snackbar.dart         # pesan status berhasil/galat (modul Minggu 7)
      primary_button.dart
      empty_state.dart          # ikon + judul + penjelasan + CTA
      error_text.dart
      status_chip.dart
  pages/                        # SATU FILE PER HALAMAN — H1–H7
    splash_page.dart            # Splash
    login_page.dart             # H1 Login
    daftar_page.dart            # H2 Daftar
    dashboard_page.dart         # H3 Dashboard
    target_timbang_page.dart    # H4 Target Timbang
    catat_berat_page.dart       # H5 Catat Berat
    riwayat_berat_page.dart     # H6 Riwayat Berat
    profil_page.dart            # H7 Profil
  features/
    auth/       data/auth_repository.dart, presentation/auth_providers.dart,
                presentation/widgets/auth_shell.dart
    target/     models/target.dart, data/target_repository.dart,
                presentation/target_providers.dart
    weight_log/ models/weight_log.dart, data/weight_log_repository.dart,
                presentation/weight_log_providers.dart
    dashboard/  presentation/widgets/hero_weight_card.dart
    profile/    models/user_profile.dart, data/user_repository.dart,
                presentation/profile_providers.dart
```

Halaman hanya berisi tampilan; query Firestore tidak pernah ditulis di `lib/pages/`.

**Aturan penulisan kode** (dari panduan Flutter):
- `const` constructor pada semua widget statis; pecah widget besar ke file sendiri.
- State immutable; pakai `ref.watch(provider.select(...))` untuk rebuild granular.
- `ListView.builder` untuk daftar; `RepaintBoundary` untuk area grafik.
- Dispose semua `TextEditingController` dan subscription.
- Spacing kelipatan 8; margin tepi 16; target sentuh minimal 48 px.

---

## 5. Keputusan teknis

| # | Keputusan | Alasan | Status |
|---|---|---|---|
| D1 | State management **Riverpod** (`flutter_riverpod`, `NotifierProvider`/`AsyncNotifier`) | Ringan, tanpa BuildContext, mudah diuji | disetujui |
| D2 | Routing **GoRouter** dengan `redirect` untuk auth guard | Deep link web + guard login di satu tempat | disetujui |
| D3 | Grafik **fl_chart** (`LineChart`) | Gratis, ringan, cukup untuk satu garis tren | disetujui |
| D4 | Tanggal disimpan sebagai `String yyyy-MM-dd` + parse `DateTime` di lapisan model | Menghindari `Timestamp` Firestore yang menyulitkan perbandingan "satu catatan per tanggal" | disetujui |
| D5 | Font **Plus Jakarta Sans** dibundel sebagai asset (`assets/fonts/`) | Demo tidak boleh bergantung internet; bentuk huruf mendekati referensi UI | disetujui (2026-10-29) |
| D6 | Lokalisasi: teks Indonesia langsung di `app_strings.dart`, tanpa `flutter_localizations` | Satu bahasa, hemat waktu; i18n di luar scope | disetujui |
| D7 | Auth: hanya email/password + `signOut`; lupa password = Should | Sesuai batasan stack | disetujui |
| D8 | Data akses lewat repository + `StreamProvider` Firestore (real-time) | Dashboard & riwayat langsung terbarui setelah simpan | disetujui |
| D9 | **Sumber kebenaran visual = `docs/ui-reference/` + `UI_SPEC.md`**, menggantikan style guide Figma Minggu 4 | Figma terlalu sederhana menurut pemilik; referensi punya gradient & layout final | disetujui (2026-10-29) |
| D10 | Baseline grafik progres ("sudah turun X dari Y") dihitung dari catatan **terawal**, bukan field baru | Tidak perlu ubah skema `targets`; tetap sesuai worksheet | disetujui |
| D11 | Menu navigasi **3 destinasi sesuai worksheet** (Dashboard · Riwayat Berat · Profil) + FAB "Catat Berat" di tengah bar | Pemilik memilih tetap sesuai worksheet yang sudah dinilai; FAB adalah aksi, bukan tujuan menu, sehingga tidak menambah halaman | disetujui (2026-10-29) |
| D12 | Dokumen `users/{uid}` **ditulis saat Daftar** (nama dari form + email + `dibuatPada`), lewat `UserRepository` | Skema §1.3 jadi lengkap dan aturan keamanan punya contoh koleksi milik pengguna. Nama di UI tetap dibaca dari `displayName` Auth supaya Dashboard tidak perlu pembacaan tambahan | disetujui (2026-10-29) |
| D13 | Data simulasi diisi skrip **`tool/seed_demo.dart`** (REST API + API key publik), bukan tombol dev di aplikasi | Tidak menambah tombol yang tidak ada di worksheet, tidak perlu service account (Spark), dan idempoten sehingga bisa diulang saat demo | disetujui (2026-10-29) |
| D14 | Aturan keamanan disimpan di **`firestore.rules`** dan di-deploy lewat `firebase deploy --only firestore:rules`; isi yang sama tetap ditampilkan di FIREBASE_SETUP §D untuk pemasangan manual | Satu sumber kebenaran yang bisa di-diff di git, tidak bergantung pada tempel-tempel di console | disetujui (2026-10-29) |
| D15 | Tujuh halaman dipindah ke **`lib/pages/`** dengan nama `*_page.dart`, kelas `*Page`; lapisan data tetap di `lib/features/` | Modul Minggu 6 menuntut "satu file per halaman di `lib/pages/`". Memisahkan tampilan dari data membuat kode Firestore tidak tercampur dengan kode UI | disetujui (2026-10-29) |
| D16 | Warna primer **tetap burgundy `#59171B`**, bukan navy `#1F3A5F` style guide mini Minggu 4 | Modul menyebut warna style guide sebagai opsional; pemilik sudah memilih gambar referensi sendiri (D9). Alasan penggantian ditulis di README supaya bisa dipertanggungjawabkan saat penilaian | disetujui (2026-10-29) |
| D17 | Setiap form memakai **`AutovalidateMode.onUserInteraction`** + **SnackBar** pesan status (`AppSnackBar`) untuk berhasil dan gagal | Rubrik Minggu 7 menilai "validasi & pesan 25%" termasuk pesan status. Inline `ErrorText` tetap dipakai sebagai penjelas tambahan | disetujui (2026-10-29) |
| D18 | Catat Berat memakai **satu halaman untuk dua mode**: `/weight/new` (tambah) dan `/weight/:id/edit` (ubah), dibedakan oleh `logId` | Menghindari dua halaman yang isinya 95% sama; aturan validasi dan format angka pasti konsisten. Satu-satunya percabangan ada di `_simpan` dan judul | disetujui (2026-10-29) |
| D19 | Format & parsing angka kg dipusatkan di **`lib/core/utils/angka.dart`** (`Angka.kg`, `Angka.parseKg`), bukan helper privat per halaman | Target Timbang dan Catat Berat menampilkan angka yang sama; satu tempat untuk aturan "koma diterima, nol desimal dibuang" | disetujui (2026-10-29) |

**Belum diputuskan / perlu tanya pemilik:**
- (tidak ada)

**Sudah diputuskan (2026-10-29):**
- D11 → **opsi A**: ikut visual & layout referensi, **tetapi tidak menambah fitur**. Menu 3 destinasi sesuai worksheet, kartu "Jadwal Latihan & Timbang" diganti "Riwayat Terbaru", fitur jadwal tidak dibuat. Detail di §13.
- D12 → `users/{uid}` **ditulis saat daftar**. Sebelumnya ini pertanyaan terbuka; pemilik memilih skema tetap lengkap sesuai §1.3.
- D13 → data demo diisi lewat **skrip REST**, bukan tombol dev di Profil maupun input manual di console.

---

## 6. Design token

> **Rujukan visual = gambar referensi pemilik proyek**, bukan Figma Minggu 4 (terlalu sederhana).
> Spesifikasi lengkap: [`UI_SPEC.md`](./UI_SPEC.md) · gambar: `docs/ui-reference/`.
> Angka di bawah hanya ringkasan; kalau berbeda, **UI_SPEC.md yang menang**.

| Token | Nilai |
|---|---|
| Primer (burgundy) | `#59171B` |
| Gradient brand | `#59171B` → `#FED7B8` (135°) |
| Gradient hero card | `#4A1016` → `#8A4A3E` → `#B7776D` |
| Gradient sidebar | `#491216` → `#783735` (vertikal) |
| Kartu aksen | `#F4D5C3` |
| Permukaan kartu | `#FBECE1` |
| Latar konten | `#F8E9DF` |
| Teks utama / sekunder | `#2A1714` / `#8A6A62` |
| Border kartu | `#EBD8CC` (1 px) |
| Status | sukses `#2E7D32` · peringatan `#EF6C00` · galat `#C62828` |
| Tipografi | Plus Jakarta Sans — 40/24/18/16/14/13/12 px |
| Radius | kartu 20 · hero 24 · tombol 14 · input 12 · shell web 28 |
| Tombol | tinggi 52 mobile / 48 web |
| Spacing | 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40; margin 16 mobile / 24 web |
| Breakpoint | `<600` mobile · `600–1023` tablet · `1024–1199` web sempit · `≥1200` web penuh |

**Jangan pakai `ColorScheme.fromSeed()`** — tidak akan menyerupai referensi. Pakai `ColorScheme` eksplisit (UI_SPEC §9).

---

## 7. Peta milestone

| ID | Milestone | Pertemuan | Hasil yang bisa ditunjukkan |
|---|---|---|---|
| M5 | Fondasi proyek | 5 | Repo git + commit pertama, app jalan, 7 route kosong, theme terpasang |
| M6 | Kerangka UI & navigasi | 6 | `AppScaffold` responsif (bottom nav ↔ sidebar), Dashboard shell + state kosong |
| M7 | Autentikasi | 7 | Login + Daftar jalan, auth guard, Keluar |
| M8 | Lapisan data Firestore | 8 | Firebase aktif, model + repository, rules terpasang |
| M9 | Target Timbang | 9 | Form target tersimpan, boleh kosong, bisa diedit |
| M10 | Catat Berat | 10 | Form + validasi + aturan satu-catatan-per-tanggal + mode edit |
| M11 | Riwayat Berat | 11 | Daftar, edit, hapus + konfirmasi, state kosong |
| M12 | Logika Dashboard | 12 | Berat terakhir, selisih, hitung mundur, semua state |
| M13 | Grafik tren | 13 | `LineChart` + state <2 catatan |
| M14 | Versi web & responsif | 14 | Sidebar, 2 kolom, 2 halaman web rapi |
| M15 | Testing & perbaikan | 15 | Unit test `weight_math`/`validators` + widget test form |
| M16 | Deploy & penutupan | 16 | Hosting live, README, data demo, checklist UAS |

Milestone boleh bergeser; **urutan tidak boleh** — jangan mulai M10 sebelum M8 selesai.

---

## 8. Checklist tugas

### M5 — Fondasi proyek
- [x] M5-1 `git init` + `.gitignore` Flutter + commit pertama
- [x] M5-2 Bersihkan `main.dart` dari counter app; `main()` siap `runApp`
- [x] M5-3 Tambah dependency: `flutter_riverpod`, `go_router`, `intl`, `fl_chart`, `firebase_core`, `firebase_auth`, `cloud_firestore`
- [x] M5-4 Buat struktur folder §4 (file kosong boleh)
- [x] M5-5 `core/constants/` — `app_colors.dart`, `app_spacing.dart`, `app_gradients.dart` sesuai UI_SPEC §1
- [x] M5-6 `app/theme.dart` — `ColorScheme` eksplisit (bukan `fromSeed`) + `TextTheme` Plus Jakarta Sans
- [x] M5-7 Bundel font `assets/fonts/PlusJakartaSans-*.ttf` + daftar di `pubspec.yaml`
- [x] M5-8 `app/router.dart` — 7 route + placeholder screen
- [x] M5-9 `flutter analyze` bersih, `flutter build web` berhasil

### M6 — Kerangka UI & navigasi
- [x] M6-1 `core/widgets/app_scaffold.dart` — bottom nav <600 px, rail ≥600 px, item sama
- [x] M6-2 `core/widgets/primary_button.dart`, `empty_state.dart`, `error_text.dart`, `status_chip.dart`
- [x] M6-3 `dashboard_screen` shell: AppBar "Dashboard" + area konten
- [x] M6-4 `EmptyState` Dashboard: target/catatan belum ada + CTA "Atur Target Timbang" & "Catat Berat"
- [x] M6-5 Uji lebar 390 px, 820 px, dan 1440 px — menu tidak berubah isi/urutan
- [x] M6-6 Gradient shell + `HeroWeightCard` sesuai UI_SPEC §1.1, §5, §6
- [x] M6-7 Splash sederhana (gradient `splash` + wordmark) sebelum Login
- [x] M6-8 `AppCard`, `AppTopBar`, dan `tool/render_screens_test.dart` (render layar ke `docs/screenshots/`)

### M7 — Autentikasi
- [x] M7-0 Setup Firebase di console (**manual oleh pemilik**) — panduan: [`FIREBASE_SETUP.md`](./FIREBASE_SETUP.md)
- [x] M7-1 `Firebase.initializeApp` + `flutterfire configure` (project Firebase baru, Spark)
- [x] M7-2 `auth_repository`: `signIn`, `signUp`, `signOut`, `authStateChanges`
- [x] M7-3 `login_screen` + state galat (email/password kosong, kredensial salah)
- [x] M7-4 `register_screen` + validasi email & password
- [x] M7-5 Auth guard GoRouter: belum login → `/login`; sudah login buka `/login` → `/`
- [x] M7-6 Tombol Keluar di Profil/AppBar
- [x] M7-7 Hapus tombol sementara "Lanjut ke Dashboard" di Login

### M8 — Lapisan data Firestore
- [x] M8-1 Model `Target` + `WeightLog` (immutable, `copyWith`, `fromDoc`/`toMap`)
- [x] M8-2 `target_repository` (watch/save, doc id = uid)
- [x] M8-3 `weight_log_repository` (watch by uid, add, update, delete, cek tanggal sudah ada)
- [x] M8-4 Firestore rules: hanya pemilik uid (uji dengan 2 akun)
- [x] M8-5 Seed data simulasi 5–7 catatan berat untuk akun demo

### P — Penyesuaian modul praktik Minggu 5–7
> Modul dosen baru diterima 2026-10-29 (folder `modulmateri/`). Pemeriksaan lengkap: §15.

- [x] P1 README berisi identitas, deskripsi, tautan Figma, cara menjalankan, screenshot
- [x] P2 Pindahkan 7 halaman ke `lib/pages/` + ganti nama kelas menjadi `*Page`
- [x] P3 SnackBar pesan status + `AutovalidateMode.onUserInteraction` di form Login & Daftar
- [x] P4 Tabel uji form ≥5 kasus → [`UJI_FORM.md`](./UJI_FORM.md)
- [x] P5 Push repository ke GitHub + isi tautan di README → https://github.com/masb0i/WeFight
- [ ] P6 `flutter run -d chrome` sebagai bukti DoD Minggu 5 (**tindakan pemilik**)

### M9 — Target Timbang
- [x] M9-1 Form `batasBerat` (angka, >0) + `tanggalTimbang` (`showDatePicker`)
- [x] M9-2 Keduanya boleh kosong; Simpan tetap berhasil
- [x] M9-3 Nilai galat tampil di bawah kolom
- [x] M9-4 Memuat nilai tersimpan saat dibuka ulang (mode edit)
- [x] M9-5 Setelah simpan → kembali ke Dashboard dengan data terbarui

### M10 — Catat Berat
- [x] M10-1 Form: tanggal (default hari ini), berat, catatan opsional
- [x] M10-2 Validator berat 30–200 kg + pesan galat
- [x] M10-3 Cek tanggal sudah ada catatan → dialog tawarkan edit, tidak membuat duplikat
- [x] M10-4 Mode tambah vs edit dibedakan lewat route/parameter
- [x] M10-5 Gagal simpan → pesan galat, isian tidak hilang
- [x] M10-6 Jalur ≤3 langkah dari Dashboard ke tersimpan

### M11 — Riwayat Berat
- [ ] M11-1 `ListView.builder` urut tanggal terbaru, `ValueKey` per item
- [ ] M11-2 Tap item → edit; aksi hapus dengan dialog konfirmasi
- [ ] M11-3 `EmptyState` "Belum ada catatan berat" + CTA
- [ ] M11-4 FAB "Catat Berat"
- [ ] M11-5 Daftar ikut berubah setelah tambah/edit/hapus

### M12 — Logika Dashboard
- [ ] M12-1 `weight_math`: `hitungSelisih`, `labelSelisih`, `hitungSisaHari`, `labelHitungMundur`
- [ ] M12-2 Kartu ringkasan: berat terakhir, selisih, hitung mundur
- [ ] M12-3 State: belum ada target / belum ada catatan / tanggal timbang lewat / hari ini hari timbang
- [ ] M12-4 Kartu ajakan "Atur Target Timbang" hanya muncul bila target kosong
- [ ] M12-5 Tombol utama "Catat Berat" menonjol dan konsisten di mobile & web

### M13 — Grafik tren
- [ ] M13-1 `tren_chart.dart` pakai `fl_chart` `LineChart`, sumbu X tanggal
- [ ] M13-2 <2 catatan → pesan "data belum cukup"
- [ ] M13-3 Grafik diperbarui setelah tambah/edit/hapus
- [ ] M13-4 `RepaintBoundary` membungkus grafik

### M14 — Versi web & responsif
- [ ] M14-1 Sidebar + header untuk ≥600 px, item menu sama dengan mobile
- [ ] M14-2 Dashboard web: konten dua kolom, tombol di area konten
- [ ] M14-3 Riwayat Berat web: daftar dibatasi lebar, tombol kanan atas
- [ ] M14-4 Uji 360 / 768 / 1440 px tanpa overflow (`flutter run -d chrome`)

### M15 — Testing
- [ ] M15-1 Unit test `weight_math` (selisih 0, positif, negatif; sisa hari 0/negatif)
- [ ] M15-2 Unit test `validators` (kosong, bukan angka, 29.9, 200.1, 30, 200)
- [ ] M15-3 Widget test form Catat Berat: input tidak valid menampilkan pesan
- [ ] M15-4 Widget test `EmptyState` Dashboard
- [ ] M15-5 `flutter analyze` bersih, `flutter test` hijau

### M16 — Deploy & penutupan
- [ ] M16-1 `flutter build web` + `firebase deploy --only hosting`
- [ ] M16-2 README: cara jalan, akun demo, screenshot, link hosting
- [ ] M16-3 Data simulasi siap untuk demo UAS
- [ ] M16-4 Jalankan ulang checklist §10

---

## 9. Protokol penulisan progres (WAJIB setiap kali implementasi)

Setiap kali satu tugas implementasi selesai — sekecil apa pun — lakukan **tiga hal berurutan**:

1. **Update `PLAN.md`**: ubah `[ ]` → `[x]` pada ID tugas yang selesai. Jika baru sebagian, tulis `[~]`.
2. **Append ke `PROGRESS.md`** di bagian paling bawah (jangan pernah menimpa entri lama). Format:

```markdown
## YYYY-MM-DD HH:mm — M10-3 Cek tanggal duplikat
- **Status:** selesai | sebagian | terblokir
- **Yang dikerjakan:** satu sampai tiga kalimat, bahasa manusia.
- **File disentuh:** `lib/features/weight_log/...`, `lib/core/utils/validators.dart`
- **Keputusan/kompromi:** hal yang menyimpang dari rencana + alasannya. Kalau tidak ada, tulis "tidak ada".
- **Kendala:** error/perlu keputusan pemilik. Kalau tidak ada, tulis "tidak ada".
- **Berikutnya:** ID tugas selanjutnya.
```

3. **Kalau ada keputusan teknis baru atau perubahan aturan bisnis**, perbarui juga §5 (tabel keputusan) atau §3 di `PLAN.md`. Aturan bisnis tidak boleh diubah sepihak.

**Aturan tambahan:**
- Satu entri per tugas, bukan per hari. Lebih baik 5 entri pendek daripada 1 entri panjang.
- Jangan menulis progres untuk pekerjaan yang belum diverifikasi (`flutter analyze`/`flutter test` gagal = status `sebagian`).
- Jangan mencatat hal sementara (path temp, hasil pencarian) di `PROGRESS.md`.
- Kalau sesi berakhir di tengah tugas, tulis entri dengan status `sebagian` + apa yang tersisa, supaya sesi berikutnya bisa lanjut.

---

## 10. Definition of Done (berlaku untuk setiap tugas)

- [ ] `flutter analyze` tanpa error/warning baru
- [ ] Berjalan di mobile (≤412 px) **dan** web (≥1280 px) tanpa overflow
- [ ] Tidak ada teks hardcode di widget — lewat `app_strings.dart`
- [ ] Nama halaman di route, AppBar, dan menu konsisten dengan §1.1
- [ ] State kosong / galat / loading ditangani, bukan hanya jalur bahagia
- [ ] Tidak memakai layanan berbayar atau fitur di daftar Won't now
- [ ] `PROGRESS.md` sudah diperbarui

---

## 11. Risiko & mitigasi

| Risiko | Dampak | Mitigasi |
|---|---|---|
| Scope melebar (jadwal latihan, pengeluaran, saran diet) | Proyek tidak selesai | Tolak semua di luar §2; catat sebagai Won't now |
| Firebase rules terlalu longgar | Nilai NF (K7) hilang | Uji dengan 2 akun sebelum M9 |
| Grafik tren menyita waktu | M12–M14 mundur | Kerjakan satu garis sederhana dulu, poles belakangan |
| State kosong di Dashboard lupa dibuat | Nilai kriteria penerimaan hilang | Sudah jadi tugas eksplisit M6-4 & M12-3 |
| Perbedaan nama halaman antar artefak | Nilai navigasi turun | §1.1 sebagai satu-satunya rujukan nama |
| Firebase Spark limit | Data demo gagal | Data simulasi kecil (<50 dokumen) |

---

## 12. Rujukan

- Worksheet asli: `worksheet/*.docx` (Minggu 1–4 + Tutorial Figma)
- **Modul praktik dosen: `modulmateri/*.docx` (Minggu 5–7)** — kesesuaian di §15
- Teks hasil ekstraksi: `.workbuddy-ai/tmp/ws/*.txt`, `.workbuddy-ai/tmp/modul/*.txt`
- **Spesifikasi UI: [`UI_SPEC.md`](./UI_SPEC.md)**
- **Panduan setup Firebase: [`FIREBASE_SETUP.md`](./FIREBASE_SETUP.md)**
- **Gambar referensi UI: `docs/ui-reference/`** (palet gradient, dashboard web, 8 layar mobile)
- Wireframe Figma (arsip, **bukan acuan lagi**): https://www.figma.com/design/je3J8Dtm45YIgMLQylv0CP/
- Log progres: [`PROGRESS.md`](./PROGRESS.md)

---

## 13. Selisih antara referensi UI dan worksheet

> **KEPUTUSAN 2026-10-29 — opsi A:** ikut visual & layout referensi, **tanpa menambah fitur**.
> Tabel di bawah disimpan sebagai catatan supaya tidak dibuka ulang tanpa alasan kuat.

Referensi UI menampilkan fitur yang **tidak ada** di worksheet:

| Elemen referensi | Status di worksheet | Keputusan |
|---|---|---|
| Kartu + halaman **Jadwal Latihan & Timbang** | Masalah #2 Minggu 1, tidak dipilih; Minggu 2 K10 Won't now | **Tidak dibuat.** Kartu diganti "Riwayat Terbaru" (visual sama: kotak ikon + judul + tanggal) |
| **Jadwal Pertandingan** (sidebar) | Won't now | Tidak dibuat |
| **Grafik** sebagai tab navigasi sendiri | Grafik = komponen di Dashboard | Tetap di Dashboard. Menu 3 destinasi |
| Splash screen | Tidak ada | Dibuat (ringan, tanpa halaman bernavigasi) |
| Notifikasi / Bantuan / Data Pribadi | Won't now | Tidak dibuat. Profil hanya: Pengaturan Target, Riwayat, Keluar |
| Progres menuju target (ring + "sudah turun X dari Y") | Tidak eksplisit, tapi bisa dihitung | Dibuat, baseline = catatan terawal (D10) |

**Menu final (mobile & web, urutan sama):** Dashboard · Riwayat Berat · Profil.
FAB "Catat Berat" menempel di tengah bar sebagai **aksi**, bukan tujuan menu.
Web: item yang sama di sidebar kiri, FAB diganti tombol utama di area konten.

**Konsekuensi yang sudah diterima:** tampilan tidak akan identik dengan referensi di bagian jadwal. Sisanya (gradient, kartu, hero, grafik, tabel, sidebar, ring progres) diikuti penuh.

---

## 14. Catatan lingkungan pengembangan

| Hal | Nilai / perintah |
|---|---|
| Flutter | 3.47.7 stable · Dart 3.13.5 |
| Versi package terkunci | `flutter_riverpod ^3.4.3` · `go_router ^18.1.1` · `intl ^0.20.3` · `fl_chart ^1.3.0` · `firebase_core ^5.1.0` · `firebase_auth ^7.0.1` · `cloud_firestore ^7.1.0` |
| Font | Plus Jakarta Sans, 5 weight, dibundel di `assets/fonts/` |

**Jebakan: `flutter test` gagal dengan `WebSocketException: Invalid WebSocket upgrade request`.**
Penyebab: variabel `HTTP_PROXY`/`HTTPS_PROXY` di shell mencegat koneksi loopback ke `flutter_tester`.
Solusi — jalankan tanpa proxy:

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy \
    NO_PROXY="127.0.0.1,localhost" no_proxy="127.0.0.1,localhost" \
    flutter test
```

Perintah `flutter analyze`, `flutter build web`, dan `flutter run` tidak terpengaruh.

**Konvensi commit:** `<tipe>(<milestone>): <ringkasan>` — misalnya `feat(M6): app shell responsif`. Tipe: `feat`, `fix`, `chore`, `docs`, `test`, `refactor`.

**Render layar jadi PNG** (tanpa emulator, hasil ke `docs/screenshots/`):

```bash
flutter test --update-goldens tool/render_screens_test.dart
```

Skrip ini memuat font Plus Jakarta Sans dan font ikon Material dari SDK. Letaknya di `tool/` (bukan `test/`) supaya `flutter test` biasa tidak ikut membandingkan golden — perbandingan golden rapuh antar mesin. Perbarui gambar setiap kali UI berubah.

**Perintah Firebase & data demo** (butuh `firebase-tools` dan sudah `firebase login`):

```bash
firebase deploy --only firestore:rules      # pasang aturan keamanan dari firestore.rules
dart run tool/seed_demo.dart                # isi akun demo + 6 catatan berat (idempoten)
dart run tool/cek_isolasi.dart              # buktikan akun B tidak bisa melihat data akun A
```

Akun demo: `fighter@wefight.demo` / `wefight123` · akun pembanding: `rival@wefight.demo` / `wefight123`.
Keduanya dibuat oleh skrip, tidak perlu didaftarkan manual di aplikasi.

**Jebakan: `request.data` bukan field yang dikenal aturan Firestore.**
Aturan yang memakai `request.data.uid` **selalu** menolak dengan
`Missing or insufficient permissions` — nama yang benar adalah
`request.resource.data` (isi dokumen setelah ditulis). Gejalanya menipu: dokumen
yang aturannya memakai id (`targets/{uid}`) tetap berhasil, hanya koleksi yang
memeriksa field (`weightLogs`) yang gagal.

**Jebakan: cek duplikat tanggal harus mengecualikan catatan yang sedang diubah.**
`cariTanggal` akan menemukan catatan itu sendiri saat mode ubah, sehingga
tanpa `bentrok.id != widget.logId` setiap penyimpanan edit ditolak dengan
"tanggal sudah dipakai". Bandingkan **id**, bukan tanggal.

**Jebakan: `showDialog` lalu `context.pushReplacement` memakai context yang bisa
sudah mati.** Setelah `await` dialog, periksa `mounted` dulu. Kalau pengguna
memilih "Ubah Catatan", gunakan `pushReplacement` (bukan `push`) supaya tombol
kembali tidak menumpuk dua form yang isinya bertabrakan.

---

## 15. Kesesuaian dengan modul praktik dosen (Minggu 5–7)

Sumber: `modulmateri/` — tiga docx (`modul-minggu-05-setup-project-repository`,
`modul-minggu-06-widget-layout-navigasi`, `modul-minggu-07-form-validasi-state`).
Folder itu **tidak di-commit** (materi dosen, bukan bagian aplikasi — ada di `.gitignore`).
Teks hasil ekstraksi: `.workbuddy-ai/tmp/modul/*.txt`.

### 15.1 Sudah sesuai

| Tuntutan modul | Bukti di proyek |
|---|---|
| Project berjalan, judul & beranda sesuai aplikasi | `lib/main.dart`, `AppStrings.appName` |
| Repository + ≥2 commit dengan pesan jelas | 7 commit, konvensi `feat(M6): …` (§14) |
| Satu file per halaman, judul AppBar = nama halaman final | `lib/pages/` (8 berkas), nama dari §1.1 |
| `NavigationBar` untuk tujuan utama | `AppScaffold` <600 px |
| `NavigationRail` di layar lebar (opsional di modul) | `AppScaffold` ≥600 px + sidebar penuh ≥1024 px |
| Push/pop ke halaman turunan | `context.push` (GoRouter) ke `/weight/new`, `/target` |
| Keadaan kosong, bukan hanya jalur bahagia | `EmptyState` di Dashboard & Riwayat |
| `Form` + `GlobalKey<FormState>` + `validator` + controller di-dispose | `login_page.dart`, `daftar_page.dart` |
| `flutter analyze` bersih, test lulus | 34/34 |

### 15.2 Selisih yang sudah diselesaikan (blok P di §8)

| Tuntutan | Sebelum | Sesudah |
|---|---|---|
| README lengkap + screenshot | README bawaan `flutter create` | `README.md` baru + 5 gambar dari `docs/screenshots/` |
| Halaman di `lib/pages/` | `lib/features/*/presentation/*_screen.dart` | `lib/pages/*_page.dart`, kelas `*Page` (D15) |
| SnackBar pesan status | tidak ada | `AppSnackBar` di Login & Daftar (D17) |
| `AutovalidateMode.onUserInteraction` | tidak ada | dipasang di kedua `Form` |
| Tabel uji form ≥5 kasus | tidak ada | `docs/UJI_FORM.md` (10 kasus) |

### 15.3 Selisih yang diterima sengaja

| Hal | Modul | Proyek | Alasan |
|---|---|---|---|
| Warna primer | navy `#1F3A5F` (style guide M4) | burgundy `#59171B` (gambar referensi) | D16 — modul menyebutnya opsional |
| Urutan Firebase | setelah UTS | sudah aktif di pertemuan 7 | Lebih cepat, bukan menambah fitur; daftar fitur tetap §2 |
| Paket pub.dev | hanya widget bawaan di Minggu 6–7 | Riverpod, GoRouter, fl_chart | Menggantikan kode yang harus ditulis sendiri; menghemat waktu |
| Penyimpanan data | list di memori (hilang saat restart) | Cloud Firestore | Data harus bertahan antar perangkat; sudah jadi scope Must |

### 15.4 Yang masih perlu tindakan pemilik

- **P6** `flutter run -d chrome` untuk membuktikan DoD Minggu 5 di perangkat nyata.
- Kasus uji form nomor 5, 6, 9, 10 di `UJI_FORM.md` baru bisa dibuktikan setelah
  aplikasi dijalankan dengan Firebase sungguhan.

### 15.5 Repository

- Remote: `origin` → https://github.com/masb0i/WeFight (branch `main`)
- Aturan modul Minggu 5: jangan commit kata sandi, token, atau service account key.
  Yang ikut di-commit hanya `lib/firebase_options.dart` dan
  `android/app/google-services.json` — keduanya berisi API key Firebase yang
  memang publik, dan keamanan data dijaga `firestore.rules` (lihat README).
- Folder `modulmateri/` dan `.workbuddy-ai/` tidak di-commit.
