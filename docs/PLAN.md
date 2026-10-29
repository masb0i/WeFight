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

Pola: **feature-first**, satu arah `presentation → data`, tanpa lapisan domain terpisah (terlalu berat untuk proyek individu).

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
      primary_button.dart
      empty_state.dart          # ikon + judul + penjelasan + CTA
      error_text.dart
      status_chip.dart
  features/
    auth/       data/auth_repository.dart, presentation/{login_screen,register_screen,auth_controller}
    target/     data/target_repository.dart, models/target.dart, presentation/{target_screen,target_controller}
    weight_log/ data/weight_log_repository.dart, models/weight_log.dart,
                presentation/{catat_berat_screen,riwayat_berat_screen,weight_log_controller}
    dashboard/  presentation/{dashboard_screen, widgets/{ringkasan_kartu,tren_chart,ajakan_target}}
    profile/    presentation/profil_screen.dart
```

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

**Belum diputuskan / perlu tanya pemilik:**
- Apakah `users` perlu ditulis saat register (nama diambil dari form) atau cukup `displayName` Auth.

**Sudah diputuskan (2026-10-29):**
- D11 → **opsi A**: ikut visual & layout referensi, **tetapi tidak menambah fitur**. Menu 3 destinasi sesuai worksheet, kartu "Jadwal Latihan & Timbang" diganti "Riwayat Terbaru", fitur jadwal tidak dibuat. Detail di §13.

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
- [ ] M5-1 `git init` + `.gitignore` Flutter + commit pertama
- [ ] M5-2 Bersihkan `main.dart` dari counter app; `main()` siap `runApp`
- [ ] M5-3 Tambah dependency: `flutter_riverpod`, `go_router`, `intl`, `fl_chart`, `firebase_core`, `firebase_auth`, `cloud_firestore`
- [ ] M5-4 Buat struktur folder §4 (file kosong boleh)
- [ ] M5-5 `core/constants/` — `app_colors.dart`, `app_spacing.dart`, `app_gradients.dart` sesuai UI_SPEC §1
- [ ] M5-6 `app/theme.dart` — `ColorScheme` eksplisit (bukan `fromSeed`) + `TextTheme` Plus Jakarta Sans
- [ ] M5-7 Bundel font `assets/fonts/PlusJakartaSans-*.ttf` + daftar di `pubspec.yaml`
- [ ] M5-8 `app/router.dart` — 7 route + placeholder screen
- [ ] M5-9 `flutter analyze` bersih, `flutter run` berhasil di 1 device

### M6 — Kerangka UI & navigasi
- [ ] M6-1 `core/widgets/app_scaffold.dart` — bottom nav <600 px, rail ≥600 px, item sama
- [ ] M6-2 `core/widgets/primary_button.dart`, `empty_state.dart`, `error_text.dart`, `status_chip.dart`
- [ ] M6-3 `dashboard_screen` shell: AppBar "Dashboard" + area konten
- [ ] M6-4 `EmptyState` Dashboard: target/catatan belum ada + CTA "Atur Target Timbang" & "Catat Berat"
- [ ] M6-5 Uji lebar 360 px dan 1440 px — menu tidak berubah isi/urutan
- [ ] M6-6 Gradient shell + `HeroWeightCard` sesuai UI_SPEC §1.1, §5, §6
- [ ] M6-7 Splash sederhana (gradient `splash` + wordmark) sebelum Login

### M7 — Autentikasi
- [ ] M7-1 `Firebase.initializeApp` + `flutterfire configure` (project Firebase baru, Spark)
- [ ] M7-2 `auth_repository`: `signIn`, `signUp`, `signOut`, `authStateChanges`
- [ ] M7-3 `login_screen` + state galat (email/password kosong, kredensial salah)
- [ ] M7-4 `register_screen` + validasi email & password
- [ ] M7-5 Auth guard GoRouter: belum login → `/login`; sudah login buka `/login` → `/`
- [ ] M7-6 Tombol Keluar di Profil/AppBar

### M8 — Lapisan data Firestore
- [ ] M8-1 Model `Target` + `WeightLog` (immutable, `copyWith`, `fromDoc`/`toMap`)
- [ ] M8-2 `target_repository` (watch/save, doc id = uid)
- [ ] M8-3 `weight_log_repository` (watch by uid, add, update, delete, cek tanggal sudah ada)
- [ ] M8-4 Firestore rules: hanya pemilik uid (uji dengan 2 akun)
- [ ] M8-5 Seed data simulasi 5–7 catatan berat untuk akun demo

### M9 — Target Timbang
- [ ] M9-1 Form `batasBerat` (angka, >0) + `tanggalTimbang` (`showDatePicker`)
- [ ] M9-2 Keduanya boleh kosong; Simpan tetap berhasil
- [ ] M9-3 Nilai galat tampil di bawah kolom
- [ ] M9-4 Memuat nilai tersimpan saat dibuka ulang (mode edit)
- [ ] M9-5 Setelah simpan → kembali ke Dashboard dengan data terbarui

### M10 — Catat Berat
- [ ] M10-1 Form: tanggal (default hari ini), berat, catatan opsional
- [ ] M10-2 Validator berat 30–200 kg + pesan galat
- [ ] M10-3 Cek tanggal sudah ada catatan → dialog tawarkan edit, tidak membuat duplikat
- [ ] M10-4 Mode tambah vs edit dibedakan lewat route/parameter
- [ ] M10-5 Gagal simpan → pesan galat, isian tidak hilang
- [ ] M10-6 Jalur ≤3 langkah dari Dashboard ke tersimpan

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
- Teks hasil ekstraksi: `.workbuddy-ai/tmp/ws/*.txt`
- **Spesifikasi UI: [`UI_SPEC.md`](./UI_SPEC.md)**
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
