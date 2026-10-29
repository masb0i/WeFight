# WeFight — Spesifikasi UI

> **Sumber kebenaran visual.** Menggantikan style guide mini Figma Minggu 4 (dianggap terlalu sederhana oleh pemilik proyek).
> Warna diambil langsung dari piksel gambar referensi, bukan dikira-kira.
> Aturan bisnis tetap di [`PLAN.md`](./PLAN.md) §3 — file ini hanya mengatur tampilan.

Terakhir diperbarui: 2026-10-29

## 0. Gambar referensi

| File | Isi |
|---|---|
| [`ui-reference/01-palette-gradient.png`](./ui-reference/01-palette-gradient.png) | Jangkar gradient: `#59171b` → `#fed7b8` |
| [`ui-reference/02-web-dashboard.jpg`](./ui-reference/02-web-dashboard.jpg) | Dashboard web: sidebar gradient, hero card, grafik, tabel, panel kanan |
| [`ui-reference/03-mobile-screens.jpg`](./ui-reference/03-mobile-screens.jpg) | 8 layar mobile: splash, dashboard, catat berat, grafik, jadwal, riwayat, tambah jadwal, profil |

Cara pakai: sebelum membangun sebuah layar, buka gambar referensinya, cocokkan susunan elemen, lalu terapkan token di bawah. Jangan mengarang warna baru di luar tabel §1.

---

## 1. Palet

Nilai bertanda **(ukur)** diambil dari sampling piksel; sisanya turunan yang dijaga kontrasnya.

| Token | Hex | Pemakaian |
|---|---|---|
| `burgundy900` | `#3E0D12` | ujung gelap gradient, teks di atas peach |
| `burgundy800` | `#4A1016` | sidebar atas, splash atas **(ukur #491216)** |
| **`burgundy700`** | **`#59171B`** | **PRIMARY** — aksi utama, nav aktif, brand **(jangkar referensi)** |
| `burgundy600` | `#6E2A2B` | hover/pressed, tengah sidebar **(ukur #783735)** |
| `rose500` | `#8A4A3E` | tengah gradient hero |
| `rose400` | `#B7776D` | ujung terang gradient hero, garis grafik **(ukur #B7776D)** |
| `clay300` | `#D9A78F` | garis area grafik, border kuat |
| `peach200` | `#F4D5C3` | kartu aksen (hari timbang, badge, FAB halo) **(ukur #F4D5C3)** |
| `peach100` | `#FED7B8` | ujung terang gradient brand **(jangkar referensi)** |
| `cream200` | `#FBECE1` | permukaan kartu **(ukur #FBECE1)** |
| `cream100` | `#F8E9DF` | latar konten **(ukur #F7E9DE)** |
| `white` | `#FFFDFB` | kartu bersih, teks di atas gelap |
| `ink900` | `#2A1714` | teks utama |
| `ink500` | `#8A6A62` | teks sekunder **(ukur #A0665F)** |
| `ink300` | `#B39C94` | placeholder, label tabel |
| `border` | `#EBD8CC` | garis kartu 1 px |
| `success` | `#2E7D32` | berat **turun**, berhasil |
| `warning` | `#EF6C00` | peringatan, hari timbang dekat |
| `danger` | `#C62828` | berat **naik**, galat |

**Aturan warna:**
- Gradient hanya untuk: sidebar, hero card, splash, tombol utama saat butuh penekanan, latar luar web. **Bukan** untuk kartu data biasa.
- Teks di atas `burgundy700` atau gradient gelap: `white` / `peach100`.
- Naik = `danger`, turun = `success` (konvensi Indonesia: merah naik, hijau turun). Selalu sertakan tanda `+`/`−` dan satuan, jangan warna saja.
- Jangan memakai `ColorScheme.fromSeed()` — hasilnya tidak akan menyerupai referensi. Pakai `ColorScheme` eksplisit (§9).

### 1.1 Definisi gradient

| Nama | Arah | Stop | Dipakai di |
|---|---|---|---|
| `brand` | 135° (topLeft→bottomRight) | `#59171B` → `#FED7B8` | splash, kartu motivasi |
| `hero` | topLeft→bottomRight | `#4A1016` → `#8A4A3E` → `#B7776D` | hero card berat badan |
| `sidebar` | top→bottom | `#491216` → `#783735` | sidebar web |
| `splash` | top→bottom | `#4B1218` → `#5C2320` → `#3E0D12` | splash / login background |
| `pageBg` | topLeft→bottomRight | `#B67767` → `#DCA994` | latar luar shell web |
| `chartArea` | top→bottom | `#B7776D` @ 22% → 0% | area di bawah garis grafik |

---

## 2. Tipografi

Keluarga: **Plus Jakarta Sans** (geometris, mendekati referensi), dibundel sebagai asset di `assets/fonts/`.
Fallback bila file belum tersedia: `TextTheme` Material 3 dengan ukuran yang sama.

| Gaya | Ukuran | Weight | Pemakaian |
|---|---|---|---|
| `displayWeight` | 40 | 700 | angka berat besar di hero card & input berat |
| `h1` | 24 | 700 | judul halaman ("Halo, Rasyid!") |
| `h2` | 18 | 600 | judul kartu ("Grafik Berat Badan") |
| `h3` | 16 | 600 | judul item daftar |
| `body` | 14 | 400 | teks isi, baris tabel |
| `label` | 13 | 500 | label kolom, tab, chip |
| `caption` | 12 | 400 | keterangan, satuan, tanggal kecil |

Aturan: minimal 12 px (tabel data 13 px agar terbaca), angka besar pakai `FontFeature.tabularFigures()` supaya tidak bergeser saat nilainya berubah.

---

## 3. Bentuk, jarak, bayangan

| Token | Nilai |
|---|---|
| Radius kartu | 20 |
| Radius hero card / panel besar | 24 |
| Radius tombol | 14 |
| Radius input | 12 |
| Radius chip / pill | 999 |
| Radius shell web | 28 |
| Spacing | 4 · 8 · 12 · 16 · 20 · 24 · 32 · 40 |
| Margin tepi konten | 24 (web), 16 (mobile) |
| Tinggi tombol | 52 (mobile), 48 (web) |
| Tinggi baris tabel | 44 |
| Bayangan kartu | `0x1459171B`, blur 24, offset (0, 8) — sangat lembut |
| Border kartu | 1 px `border` (bukan bayangan tebal) |

Prinsip: **permukaan dibedakan lewat warna, bukan bayangan.** Referensi hampir tanpa bayangan; kedalaman datang dari kontras krem vs putih vs peach.

---

## 4. Komponen

| Komponen | Anatomi | Padanan Flutter |
|---|---|---|
| `AppShell` | Sidebar gradient + area konten krem, radius shell 28 | `Row` + `Container(decoration: gradient)` |
| `Sidebar` (web) | Lebar 240; logo + tagline; item nav (ikon 20 + label); item aktif = pill putih 14% + teks `peach100`; bawah: kartu kutipan + siluet petinju | `NavigationRail` kustom / `Column` |
| `TopBar` | Sapaan `h1` + subjudul `caption`; kanan: ikon lonceng + avatar inisial + nama + chevron | `Row` di dalam `Padding` |
| `HeroWeightCard` | Gradient `hero`, radius 24, padding 24; kiri: label + `displayWeight` + delta; kanan: kolom target & sisa dipisah garis tipis; ikon pensil kanan atas | `Container` + `Row` |
| `PeachInfoCard` | Latar `peach200`, radius 20; ikon + judul + tanggal besar + "N hari lagi" + badge target | `Container` |
| `StatTriple` | 3 kolom angka + label, dipisah garis vertikal tipis | `Row` + `IntrinsicHeight` |
| `ProgressRing` | Donut 120 px, track `clay300`, isi gradient `brand`, tengah `h2` + `caption` | `CustomPaint` |
| `SegmentedRange` | Pill kontainer `cream200`; opsi aktif = `burgundy700` teks `peach100` | `SegmentedButton` / `ToggleButtons` |
| `WeightChart` | `LineChart`: garis `rose400` 2.5 px, titik 4 px, area gradient, garis target putus-putus `clay300`, tooltip bulat `burgundy700` | `fl_chart` |
| `DataTableRow` | Tanggal · Berat · Perubahan · Catatan; perubahan berwarna + tanda | `Table` / `Row` |
| `PrimaryButton` | Isian `burgundy700`, teks `peach100`, tinggi 52, radius 14 | `FilledButton` |
| `SecondaryButton` | Garis 1.5 px `burgundy700`, teks `burgundy700` | `OutlinedButton` |
| `AddButton` | Pill kecil `burgundy700` + ikon `+` | `FilledButton.icon` |
| `BottomNav` | 3 destinasi **Dashboard · Riwayat Berat · Profil** + **FAB "Catat Berat"** di tengah bar; aktif `burgundy700`, nonaktif `ink300` | `NavigationBar` + `FloatingActionButton` (docked) |
| `TextField` | Latar `white`, border `border`, radius 12, label mengambang; galat = border `danger` + pesan 12 px | `TextFormField` |
| `WeightInput` | Angka `displayWeight` + dua kolom picker (satuan & desimal) | `CupertinoPicker` / `ListWheelScrollView` |
| `EmptyState` | Ikon garis `clay300` 64, judul `h3`, penjelasan `body` `ink500`, CTA | `Column` |
| `MotivationCard` | Gradient `brand`, siluet petinju, kutipan, tombol panah bulat | `Container` |

---

## 5. Layout web (≥ 1024 px)

```
┌──────────┬─────────────────────────────────────────┬──────────────┐
│          │ TopBar: sapaan + lonceng + avatar       │              │
│ Sidebar  ├──────────────────────┬──────────────────┤  Panel kanan │
│ 240 px   │ HeroWeightCard       │ PeachInfoCard    │  320–360 px  │
│ gradient │ (2/3 lebar)          │ (1/3)            │              │
│          ├──────────────────────┴──────────────────┤ Progres      │
│          │ WeightChart + SegmentedRange            │ Menuju Target│
│          ├─────────────────────────────────────────┤              │
│          │ Riwayat Berat (tabel) + Tambah Data     │ Catatan      │
│          │                                         │ Terakhir     │
│          │                                         │ Motivasi     │
└──────────┴─────────────────────────────────────────┴──────────────┘
```

- Grid: `240 | 1fr | 340`; jarak antar-kartu 20; padding shell 20.
- Lebar konten utama dibatasi maksimum 1400 px dan dipusatkan bila layar sangat lebar.
- Panel kanan menjadi kolom terpisah ≥ 1200 px; di 1024–1199 px turun ke bawah konten utama.

## 6. Layout mobile (< 600 px)

- Urutan vertikal: `TopBar` (sapaan + avatar) → `HeroWeightCard` → `Progres Menuju Target` → `WeightChart` (ringkas) → kartu terakhir → `BottomNav` menempel bawah.
- `displayWeight` tetap 40 px; hero card padding 20.
- Semua kartu selebar layar dikurangi margin 16.
- `BottomNav` 3 destinasi dengan FAB "Catat Berat" menonjol di tengah bar, sedikit terangkat di atas bar. FAB adalah **aksi**, bukan tujuan menu.
- Splash: gradient `splash`, siluet petinju, wordmark "WeFight", tagline, kutipan di bawah.

---

## 7. Pemetaan layar referensi → 7 halaman final

| Layar di referensi | Halaman WeFight | Yang diadopsi | Catatan |
|---|---|---|---|
| Splash | — (sebelum `Login`) | Gradient `splash`, wordmark, tagline | Tambahan ringan, tidak menambah halaman bernavigasi |
| Login (tidak ada di referensi) | **H1 Login** | Gaya input + `PrimaryButton` dari referensi | Latar gradient `splash`, kartu krem di tengah |
| Beranda | **H3 Dashboard** | Hero card, kartu progres, grafik, tabel riwayat ringkas | Sumber utama tampilan |
| Catat Berat | **H5 Catat Berat** | Input angka besar + picker, tombol Simpan, baris tanggal | Validasi 30–200 kg per PLAN §3 |
| Grafik Berat Badan | bagian dari **H3 Dashboard** | Segmented 7/30/90, tooltip, ringkasan 3 angka | Filter rentang = K9 (Should); tidak ada tab Grafik terpisah |
| Riwayat Berat Badan | **H6 Riwayat Berat** | Tab rentang, tabel Tanggal/Berat/Perubahan/Catatan, tombol Lihat Grafik | Tap baris → mode edit |
| Profil | **H7 Profil** | Avatar inisial, nama + "Fighter in Progress", 3 statistik, daftar menu, kartu kutipan | Menu dibatasi §7.1 |
| Pengaturan Target | **H4 Target Timbang** | Form batas berat + tanggal, boleh kosong | Tidak ada di referensi mobile; pakai gaya `TextField` |
| Jadwal Latihan & Timbang / Tambah Jadwal | **tidak dipakai** | — | Lihat §7.1 |
| Jadwal Pertandingan (sidebar) | **tidak dipakai** | — | Di luar scope |
| Notifikasi, Bantuan, Data Pribadi | **tidak dipakai** | — | Di luar scope |

### 7.1 Keputusan: fitur jadwal TIDAK diikuti (2026-10-29)

Pemilik memilih **opsi A** — visual dan layout referensi diikuti, tetapi cakupan fitur tetap sesuai worksheet yang sudah dinilai.

- Kartu "Jadwal Latihan & Timbang" di Dashboard **diganti** kartu **"Riwayat Terbaru"** (3 catatan terakhir + "Lihat Semua" → H6). Susunan visual tetap sama: kartu krem, item dengan kotak ikon, judul + tanggal di kanan.
- Item menu "Jadwal" **tidak dibuat**; menu final 3 destinasi: Dashboard · Riwayat Berat · Profil.
- Submenu Profil dibatasi: **Pengaturan Target**, **Riwayat**, **Keluar**. Tanpa Notifikasi/Bantuan/Data Pribadi.
- Grafik **tetap bagian dari Dashboard**, bukan tab terpisah.

Konsekuensi yang diterima: tampilan tidak identik dengan referensi di area jadwal. Sisanya diikuti penuh.

---

## 8. Responsif

| Breakpoint | Perilaku |
|---|---|
| `< 600` | Mobile: bottom nav 5 slot + FAB, satu kolom, margin 16 |
| `600–1023` | Tablet: `NavigationRail` ringkas (ikon saja), satu kolom lebar maks 720 |
| `1024–1199` | Web sempit: sidebar 240 + konten utama, panel kanan turun ke bawah |
| `≥ 1200` | Web penuh: grid `240 | 1fr | 340` |

Yang **tidak berubah** antar breakpoint: nama halaman, isi & urutan menu, label aksi utama, palet, tipografi, pesan kosong/galat.
Yang **boleh berubah**: pola navigasi, jumlah kolom, posisi tombol utama, jumlah data yang tampil sekaligus.

---

## 9. Catatan implementasi Flutter

`ColorScheme` eksplisit — **jangan** `fromSeed`:

```dart
const scheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF59171B),
  onPrimary: Color(0xFFFED7B8),
  secondary: Color(0xFFB7776D),
  onSecondary: Color(0xFFFFFDFB),
  surface: Color(0xFFF8E9DF),
  onSurface: Color(0xFF2A1714),
  error: Color(0xFFC62828),
  onError: Color(0xFFFFFDFB),
);
```

Helper gradient di `core/constants/app_gradients.dart`:

```dart
const brand = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF59171B), Color(0xFFFED7B8)],
);
const hero = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFF4A1016), Color(0xFF8A4A3E), Color(0xFFB7776D)],
);
```

Catatan teknis:
- Gradient harus dipasang lewat `Container(decoration: BoxDecoration(gradient: ...))`, bukan `backgroundColor`.
- `fl_chart`: `LineChartBarData(curveSmoothness: 0.3, isCurved: true)` untuk tren; garis target pakai `HorizontalLine` dengan `dashArray: [6, 4]`.
- Angka besar: `TextStyle(fontFeatures: [FontFeature.tabularFigures()])`.
- Splash & sidebar memakai gambar siluet petinju → taruh di `assets/images/`, jangan menebak aset yang tidak ada; bila belum ada, pakai `Icons.sports_martial_arts` sampai aset tersedia.
- Kontras: teks `ink500` di atas `cream100` sudah lolos AA untuk 14 px; jangan memakai `ink300` untuk teks isi.

---

## 10. Daftar periksa UI

- [ ] Tidak ada warna di luar §1 (cek dengan mencari `Color(0xFF` yang tidak terdaftar)
- [ ] Gradient hanya pada sidebar, hero, splash, latar luar, kartu motivasi
- [ ] Angka berat memakai tabular figures
- [ ] Status naik/turun selalu punya tanda + satuan, bukan warna saja
- [ ] Kartu memakai border 1 px, bukan bayangan tebal
- [ ] Menu mobile dan web berisi item & urutan yang sama
- [ ] Setiap halaman punya state kosong dengan CTA
- [ ] Uji 360 / 768 / 1440 px tanpa overflow
