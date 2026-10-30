# Artefak UTS — Dari Masalah sampai Bukti Uji

Dokumen ini merangkum artefak **Discover** (Minggu 1–2) dan **Design** (Minggu 3)
ke dalam repositori, lalu menyambungkan setiap artefak ke baris kode dan kasus uji
yang benar-benar ada. Tujuannya satu: membuat **rantai ketertelusuran** bisa
ditunjuk dalam satu tarikan mata saat presentasi UTS.

Rantai yang dimaksud:

```
Masalah → Persona → User Story + Kriteria Penerimaan → Kebutuhan (MoSCoW)
        → Use Case → User Flow → Sitemap + Navigasi
        → Kode (validator, halaman) → Kasus Uji
```

> **Catatan sumber.** Isi dokumen ini disalin dari worksheet Minggu 1–3 milik
> pemilik proyek. Worksheet aslinya **tidak dipublikasikan** (lihat `.gitignore`);
> dokumen ini adalah ringkasannya yang boleh dibaca penilai. Kalau ada selisih,
> worksheet yang menang.

> **Catatan jujur soal riset.** Persona di bawah bertumpu pada **pengalaman
> langsung pemilik** dan **asumsi yang ditandai**. Belum ada wawancara pengguna.
> Semua data di aplikasi adalah data simulasi.

---

## A. Problem Statement

**Versi Minggu 1** (Pertemuan 1, worksheet):

> Fighter pemula Muay Thai yang akan menjalani pertandingan pertama mengalami
> kesulitan memantau berat badan terhadap batas berat dan sisa waktu menuju hari
> timbang ketika mendekati fight pertama, karena berat dicatat tidak teratur di
> catatan HP. Masalah ini menyebabkan ia tidak menyadari sisa waktu dan jarak ke
> target sehingga persiapan berat badan tidak terkontrol. WeFight membantu dengan
> mencatat berat beserta catatan singkat, lalu menampilkan berat terakhir, selisih
> ke batas, hitung mundur hari timbang, dan grafik tren dalam satu dashboard.

**Versi Minggu 2** (diperbarui setelah analisis kebutuhan) — perubahan ada pada
penegasan "tanpa memberi saran":

> … WeFight membantu dengan mencatat berat secara cepat, lalu menampilkan berat
> terakhir, selisih ke batas, hitung mundur hari timbang, dan grafik tren dalam
> satu dashboard, **tanpa memberi saran diet**.

### Mengapa masalah ini yang dipilih

| Kriteria scope | Jawaban | Alasan |
|---|---|---|
| Masalah benar-benar terjadi | Ya | Dialami langsung: berat dicatat di catatan HP menjelang fight pertama, tanpa hitung mundur dan tanpa selisih ke batas |
| Pengguna dapat diidentifikasi | Ya | Fighter pemula Muay Thai yang akan bertanding pertama kali |
| Data yang dibutuhkan jelas | Ya | Batas berat, tanggal timbang, tanggal catat, berat, catatan singkat |
| Dapat dibuat dalam 16 pertemuan | Ya | Satu alur inti: atur target → catat berat → lihat dashboard |
| Tidak butuh layanan berbayar | Ya | Firebase Spark, Firestore, Auth email/sandi, Hosting |

Masalah lain yang **sengaja tidak dikerjakan**: jadwal latihan, tugas kuliah,
pengeluaran gym. Ketiganya hanya dicatat di Aktivitas 1 worksheet dan berstatus
*Won't now*.

---

## B. Persona — satu pengguna utama

| Elemen | Isi |
|---|---|
| Peran & konteks | Fighter pemula Muay Thai yang belum pernah bertanding, rutin berlatih, sedang bersiap untuk pertandingan pertama. Memakai aplikasi terutama **di HP**, biasanya segera setelah menimbang |
| Tujuan utama | Memastikan berat badannya berada dalam batas berat pada hari timbang |
| Kesulitan sekarang | Mencatat berat di catatan HP secara tidak teratur, tanpa format tetap. Tidak ada hitung mundur, selisih ke batas, maupun grafik. Batas berat dan tanggal timbang kadang belum diketahui |
| Kebutuhan utama | Mencatat berat dengan cepat, lalu melihat berat terakhir, selisih ke batas, sisa hari, dan tren dalam satu tampilan. Batas berat dan tanggal boleh diisi belakangan |

### Temuan vs asumsi

| Jenis | Isi |
|---|---|
| **Temuan** (dialami/diamati langsung) | Kebiasaan mencatat berat di catatan HP; tidak ada hitung mundur dan selisih; menimbang tidak teratur; perangkat utama HP |
| **Asumsi** (belum diuji) | Fighter pemula lain mengalami hal yang sama; batas berat sering baru diketahui belakangan; rentang wajar 30–200 kg; satu catatan per tanggal sudah cukup; atlet berpengalaman juga butuh |

**Pertanyaan validasi yang disiapkan** (belum diajukan):

> "Ceritakan terakhir kali kamu menimbang berat menjelang persiapan bertanding:
> kapan, apa yang kamu catat, dan kapan kamu baru sadar berat masih jauh dari
> batas?"

**Uji konsistensi persona:** bila fighter pemula tidak ada, masalah pelacakan
berat menuju batas timbang tetap dialami atlet lain yang menimbang tidak teratur —
jadi masalahnya tetap valid. Persona difokuskan ke pemula karena mereka paling
belum punya sistem pencatatan.

---

## C. User Story dan Kriteria Penerimaan

Enam story. Story 1–6 adalah bahan langsung untuk tabel uji di bagian I.

### S1 — Akun pribadi
> Sebagai fighter pemula, saya ingin mendaftar dan masuk dengan email dan password,
> agar catatan berat saya tersimpan di akun pribadi.

1. Pendaftaran dengan email valid dan password sesuai ketentuan membuat akun dan
   langsung memasuki aplikasi.
2. Email/password salah atau kolom kosong menampilkan pesan kesalahan dan pengguna
   tidak masuk.
3. Setelah keluar, halaman data tidak dapat dibuka tanpa masuk kembali.

### S2 — Target timbang
> Sebagai fighter pemula, saya ingin menyimpan batas berat dan tanggal timbang
> (boleh diisi belakangan), agar punya acuan target dan sisa waktu.

1. Batas berat berupa angka lebih dari 0 dan tanggal valid tersimpan, serta dapat
   diedit.
2. Batas berat dan/atau tanggal boleh dikosongkan; aplikasi tetap menyimpan tanpa
   pesan galat.
3. Batas berat bukan angka atau ≤ 0 ditolak dengan pesan di bawah kolom.

### S3 — Catat berat
> Sebagai fighter pemula, saya ingin mencatat berat badan beserta tanggal dan
> catatan singkat setelah menimbang, agar riwayat berat saya tersimpan rapi.

1. Berat berupa angka dalam rentang wajar (30–200 kg, **asumsi**) dan tanggal
   terisi tersimpan serta muncul di riwayat; catatan bersifat opsional.
2. Berat kosong, bukan angka, atau di luar rentang menampilkan pesan di bawah kolom
   dan data belum tersimpan.
3. Jika tanggal sudah punya catatan, tidak dibuat catatan kedua; pengguna ditawari
   mengedit catatan tanggal itu.

### S4 — Ubah dan hapus
> Sebagai fighter pemula, saya ingin mengubah atau menghapus catatan berat yang
> salah, agar riwayat dan dashboard saya tetap akurat.

1. Perubahan berat atau catatan tersimpan dan nilainya ikut berubah di riwayat dan
   dashboard.
2. Penghapusan meminta konfirmasi, lalu catatan hilang dari riwayat dan grafik.
3. Perubahan dengan berat tidak valid ditolak dengan aturan yang sama seperti saat
   menambah.

### S5 — Ringkasan dashboard
> Sebagai fighter pemula, saya ingin melihat berat terakhir, selisih ke batas, dan
> hitung mundur hari timbang dalam satu tampilan, agar segera tahu posisi berat saya.

1. Dengan target dan catatan, dashboard menampilkan berat dari catatan bertanggal
   terbaru, selisih ("X kg di atas batas", "Tepat di batas", atau "X kg di bawah
   batas"), dan sisa hari.
2. Jika belum ada target, catatan, atau tanggal timbang, dashboard menampilkan pesan
   kosong yang jelas dengan ajakan mengisinya.
3. Pada tanggal timbang tampil "Hari ini hari timbang"; jika lewat tampil "Hari
   timbang terlewat".

### S6 — Grafik tren
> Sebagai fighter pemula, saya ingin melihat grafik tren berat badan, agar tahu
> berat saya naik atau turun dari waktu ke waktu.

1. Dengan minimal 2 catatan, grafik garis menampilkan berat menurut tanggal secara
   berurutan.
2. Dengan kurang dari 2 catatan, tampil pesan bahwa data belum cukup untuk tren.
3. Grafik ikut diperbarui setelah catatan ditambah, diubah, atau dihapus.

---

## D. Kebutuhan dan Prioritas MoSCoW

`F` = fungsional, `NF` = nonfungsional.

| Kode | Kebutuhan | Jenis | Prioritas | Alasan |
|---|---|---|---|---|
| K1 | Daftar, masuk, keluar dengan email/password (S1) | F | **Must** | Data berat dan target dimiliki per pengguna |
| K2 | Simpan/edit batas berat dan tanggal timbang, boleh kosong (S2) | F | **Must** | Acuan selisih dan hitung mundur |
| K3 | Catat berat + tanggal + catatan; ubah, hapus; satu catatan per tanggal; validasi (S3, S4) | F | **Must** | Alur inti dan sumber semua data dashboard |
| K4 | Dashboard: berat terakhir, selisih, hitung mundur, tampilan kosong (S5) | F | **Must** | Menjawab masalah utama |
| K5 | Grafik tren berat menurut tanggal (S6) | F | **Must** | Dinilai wajib pemilik proyek; versi sederhana satu garis |
| K6 | Cepat diisi, jalan di HP maupun browser, pesan validasi menunjuk kolom salah | NF | **Must** | Pengguna paling sering memakai HP sesudah menimbang |
| K7 | Data pribadi: hanya pemilik (`uid`) yang bisa baca/tulis `targets` dan `weightLogs` | NF | **Must** | Berat badan adalah data pribadi |
| K8 | Lupa kata sandi lewat email | F | Should | Penting, MVP tetap jalan tanpanya |
| K9 | Filter riwayat per rentang tanggal | F | Should | Mempermudah pencarian, bukan syarat alur inti |
| K10 | Multi-target, notifikasi, ekspor, >1 catatan/hari, saran diet/rehidrasi/water cut | F | **Won't now** | Di luar stack semester; saran kesehatan berisiko dan melanggar batas proyek |

---

## E. Use Case Inti — Catat Berat Badan

| Bagian | Isi |
|---|---|
| Nama / tujuan | Catat berat badan — menyimpan berat terbaru beserta catatan singkat agar dashboard terbarui |
| Aktor | Fighter pemula Muay Thai |
| Pemicu | Pengguna baru selesai menimbang berat badan |
| Prasyarat | Pengguna sudah masuk. Target boleh belum diisi; dashboard menampilkan keadaan kosong untuk bagian yang belum ada datanya |

**Alur utama**

1. Pengguna membuka layar Catat Berat dari dashboard.
2. Sistem menampilkan isian tanggal (bawaan hari ini), berat, dan catatan opsional.
3. Pengguna mengisi berat (dan catatan bila perlu), lalu menekan simpan.
4. Sistem memeriksa: berat terisi, berupa angka, dalam rentang wajar, tanggal
   terisi, dan belum ada catatan pada tanggal itu.
5. Sistem menyimpan catatan ke `weightLogs` milik pengguna.
6. Sistem kembali ke dashboard dengan berat terakhir, selisih ke batas, hitung
   mundur, dan grafik yang sudah diperbarui.

**Alur alternatif**

- **A.** Berat kosong, bukan angka, atau di luar rentang → pesan di bawah kolom,
  data belum tersimpan, pengguna memperbaiki isian.
- **B.** Tanggal sudah punya catatan → sistem memberi tahu dan menawarkan mengedit
  catatan itu; tidak dibuat catatan kedua.
- **C.** Data gagal tersimpan (koneksi terputus) → pesan gagal, isian tetap ada,
  dashboard tidak berubah.

**Hasil akhir.** Berhasil: tepat satu catatan berat untuk tanggal itu tersimpan
(baru atau hasil edit) dan dashboard menampilkan nilai terbaru. Gagal: tidak ada
perubahan data dan pengguna mendapat pesan yang jelas.

---

## F. User Flow

Tujuan alur: **mencatat berat badan, lalu melihat dashboard yang sudah terbarui.**

```
( Mulai )
    │
    ▼
[ Login ] ──email/password tidak valid──▶ ( pesan galat, tetap di Login )
    │ valid
    ▼
[ Dashboard ]
    │ tap "Catat Berat"
    ▼
[ Catat Berat ] ◀──┐
    │              │
    ◇ Berat terisi, angka, 30–200 kg?  ──tidak──┘  (pesan di bawah kolom)
    │ ya
    ◇ Tanggal sudah punya catatan? ──ya──▶ ( dialog "Ubah Catatan" )
    │ tidak                                        │
    ▼                                              ▼
 simpan ke weightLogs ─────────────────▶ [ Dashboard ] ( Selesai )
```

| Komponen | Isi |
|---|---|
| Urutan halaman | Login → Dashboard → Catat Berat → Dashboard (Selesai) |
| Keputusan sistem | (1) Email & password valid? (2) Berat terisi, angka, 30–200 kg? (3) Tanggal sudah punya catatan? |
| Alur alternatif | **A.** Input tidak valid → kembali ke Catat Berat, kolom ditandai, isian lain tidak hilang. **B.** Tanggal sudah ada catatan → tetap di Catat Berat dalam mode ubah (bila dibuka dari Riwayat Berat, kembali ke Riwayat Berat setelah tersimpan) |
| Jumlah langkah Login → tujuan | **4 langkah** — sudah ringkas, tidak ada yang perlu dipangkas |

---

## G. Sitemap dan Prioritas Halaman

| Kode | Nama halaman | Tujuan / isi utama | Prioritas |
|---|---|---|---|
| H1 | Login | Masuk dengan email/password | **Must** |
| H2 | Daftar | Membuat akun baru (email/password) | Should |
| H3 | Dashboard | Berat terakhir, selisih, hitung mundur, grafik tren; tombol utama Catat Berat; ajakan Atur Target bila target belum ada | **Must** |
| H4 | Target Timbang | Form isi/ubah batas berat dan tanggal timbang, boleh dikosongkan | **Must** |
| H5 | Catat Berat | Form tambah berat, tanggal, catatan, dengan validasi | **Must** |
| H6 | Riwayat Berat | Daftar seluruh catatan; tap item untuk mengubah/menghapus | **Must** |
| H7 | Profil | Info akun dan tombol keluar | Should |

Catatan scope: H6 tidak dilalui pada alur inti pencatatan tunggal, tetapi
diperlukan agar S4 (ubah/hapus) dapat dijalankan — karena itu tetap **Must**.
Jumlah halaman Must = **5**, sesuai batas 3–5.

---

## H. Navigasi

| Keputusan | Isi |
|---|---|
| Pola mobile | Bottom navigation (3 tujuan) |
| Pola web | Sidebar + header |
| Item menu & urutan | **Dashboard · Riwayat Berat · Profil** — urutan sama di mobile dan web |
| Aksi utama | "Catat Berat": tombol utama di Dashboard, dan FAB di Riwayat Berat |
| Di luar menu | Login & Daftar (sebelum masuk) · Target Timbang (dari kartu ajakan Dashboard) · Catat Berat (dari tombol utama) · Keluar (di app bar/header, bukan item menu) |

**Konsistensi penamaan.** Satu istilah untuk satu halaman di flow, sitemap, menu,
judul layar, dan nama kelas Dart:

| Halaman | Label menu | Nama kelas |
|---|---|---|
| Dashboard | `Dashboard` | `DashboardPage` |
| Riwayat Berat | `Riwayat Berat` | `RiwayatBeratPage` |
| Profil | `Profil` | `ProfilPage` |
| Target Timbang | — (bukan item menu) | `TargetTimbangPage` |
| Catat Berat | — (aksi, bukan tujuan menu) | `CatatBeratPage` |

---

## I. Tabel Ketertelusuran — artefak ke bukti

Inilah tabel yang perlu ditunjukkan saat presentasi. Setiap baris menjawab:
*"kriteria penerimaan ini dibuktikan di mana?"*

| Story / Kebutuhan | Kriteria yang dibuktikan | Bukti di kode | Bukti uji otomatis | Kasus uji form |
|---|---|---|---|---|
| **S1 / K1** Login | Kolom kosong & format email ditolak | `lib/core/utils/validators.dart` (`email`, `kataSandi`) · `lib/pages/login_page.dart` | grup `Validasi form autentikasi`, `Guard login` | #1–6 |
| **S1 / K8** Daftar | Nama kosong, sandi tidak sama, email terdaftar | `validators.dart` (`nama`, `konfirmasiKataSandi`) · `lib/pages/daftar_page.dart` | grup `Validasi form autentikasi` | #7–10 |
| **S2 / K2** Target | Batas berat 30–200, boleh kosong, koma diterima | `validators.dart` (`batasBeratOpsional`) · `lib/pages/target_timbang_page.dart` | grup `Form Target Timbang`, `Validators.batasBeratOpsional` | #11–18 |
| **S3 / K3** Catat berat | Berat wajib, angka, 30–200, tanggal default | `validators.dart` (`berat`) · `lib/pages/catat_berat_page.dart` | grup `Form Catat Berat`, `Validators.berat` | #19–26 |
| **S3 kriteria 3** Satu catatan per tanggal | Tanggal duplikat → tawarkan ubah, bukan catatan kedua | `catat_berat_page.dart` (dialog "Ubah Catatan", bandingkan `bentrok.id != widget.logId`) | grup `Form Catat Berat` | #25–26 |
| **S4 / K3** Ubah & hapus | Nilai berubah di riwayat + dashboard; hapus minta konfirmasi | `catat_berat_page.dart` mode ubah · `lib/pages/riwayat_berat_page.dart` | grup `Riwayat Berat` | #27–29, #32 |
| **S5 / K4** Dashboard | Selisih, hitung mundur, keadaan kosong | `lib/core/utils/weight_math.dart` · `lib/pages/dashboard_page.dart` | grup `WeightMath.hitungSelisih`, `labelSelisih`, `hitungSisaHari`, `labelHitungMundur`, `Ringkasan Dashboard` | #30 |
| **S6 / K5** Grafik tren | ≥2 catatan tampil garis; <2 tampil "Data belum cukup" | `lib/features/dashboard/presentation/widgets/tren_chart.dart` | grup `Grafik tren` | — (bukti: `docs/screenshots/`) |
| **K6** Responsif & cepat | Dipakai di HP dan browser, tanpa overflow | `lib/core/constants/app_spacing.dart` (termasuk `AppBreakpoints`) · `lib/core/widgets/app_scaffold.dart` | grup `Responsif` (13 test: 360/768/1440 px, menu, layout web) | — |
| **K7** Data pribadi | Akun B tidak bisa melihat data akun A | `firestore.rules` | `dart run tool/cek_isolasi.dart` → **5/5** | — |

**Ringkasan angka:** 144 test otomatis lulus (5 berkas) · 32 kasus uji form
(24 otomatis + 8 manual) · 5 pemeriksaan isolasi data.

### Status fitur Should

| Kode | Status nyata |
|---|---|
| K8 lupa kata sandi | Metode `sendPasswordReset` sudah ada di `AuthRepository` (`lib/features/auth/data/auth_repository.dart`), **tetapi belum dipasang sebagai tombol di halaman Login**. Belum selesai |
| K9 filter riwayat | **Belum dikerjakan** |
| H2 Daftar | Selesai (`lib/pages/daftar_page.dart`) |
| H7 Profil | Selesai (`lib/pages/profil_page.dart`) |

Dicatat apa adanya supaya tidak ada klaim berlebih saat ditanya.

---

## J. Yang Ditunda dan Alasannya

| Ditunda | Alasan |
|---|---|
| Multi-target / banyak pertandingan | Satu target aktif cukup; fighter perlu pemulihan antar-pertandingan |
| Notifikasi pengingat | Butuh layanan di luar stack semester |
| Ekspor data | Tidak menjawab masalah utama |
| Lebih dari satu catatan per hari | Satu catatan per tanggal sudah mewakili progres harian |
| Saran diet / rehidrasi / water cut | Berisiko, di luar batas proyek, dan melanggar ketentuan mata kuliah |
| Halaman Detail Catatan terpisah | Fungsi ubah/hapus sudah tercakup di Riwayat Berat |
| Panel pengelola / peran lain | Aplikasi satu peran; peran lain cukup disimulasikan lewat data |

---

## K. Cara memakai dokumen ini saat presentasi

1. **Buka bagian A** → ceritakan masalah dan mengapa masalah itu nyata.
2. **Buka bagian B** → tunjukkan siapa penggunanya, dan sebut terus terang mana
   temuan, mana asumsi.
3. **Buka bagian C–D** → tunjukkan 6 story dan bagaimana MoSCoW memotongnya jadi
   7 halaman.
4. **Buka bagian I** → tunjuk satu baris, misalnya S3: "kriteria 30–200 kg ini
   ada di `validators.dart` baris 46, diuji 21 test di `validators_test.dart`, dan
   kasus #20–22 di `docs/UJI_FORM.md`". Rantai itu yang dinilai.
5. **Buka aplikasi** → demo Login → Dashboard → Catat Berat → kembali ke Dashboard.

---

## Rujukan

- [`PLAN.md`](./PLAN.md) — rencana implementasi, milestone M5–M16, keputusan D1–D26
- [`UI_SPEC.md`](./UI_SPEC.md) — palet, tipografi, komponen, layout responsif
- [`UJI_FORM.md`](./UJI_FORM.md) — 32 kasus uji form
- [`PROGRESS.md`](./PROGRESS.md) — log pengerjaan bertanggal
- `docs/ui-reference/` — gambar acuan visual
- `docs/screenshots/` — render 15 layar (bisa dibuat ulang)
- Aplikasi live: <https://wefight-38409.web.app>
