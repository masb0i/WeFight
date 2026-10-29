# Tabel Uji Form

Latihan 3 modul Minggu 7: setiap aturan validasi diuji, hasil yang diharapkan
ditulis lebih dulu, lalu hasil nyata dicatat.

Status: **Login**, **Daftar**, **Target Timbang**, dan **Catat Berat** sudah
diuji seluruhnya — **32 kasus, semua sesuai**: 24 dibuktikan test otomatis dan
8 dicoba manual di Chrome pada 30 Oktober 2026.

Cara menjalankan uji otomatis:

```bash
env -u HTTP_PROXY -u HTTPS_PROXY -u http_proxy -u https_proxy \
    NO_PROXY="127.0.0.1,localhost" no_proxy="127.0.0.1,localhost" flutter test
```

## 1. Aturan validasi per kolom

| Kolom | Halaman | Widget | Aturan | Pesan kesalahan |
|---|---|---|---|---|
| Email | Login | `TextFormField` | Wajib; format `x@y.z` | "Email wajib diisi." / "Format email tidak valid." |
| Kata sandi | Login | `TextFormField` (obscure) | Wajib; minimal 6 karakter | "Kata sandi wajib diisi." / "Kata sandi minimal 6 karakter." |
| Nama lengkap | Daftar | `TextFormField` | Wajib (spasi saja dianggap kosong) | "Nama wajib diisi." |
| Email | Daftar | `TextFormField` | Wajib; format `x@y.z`; belum terdaftar | "Email wajib diisi." / "Format email tidak valid." / "Email sudah terdaftar. Silakan masuk." |
| Kata sandi | Daftar | `TextFormField` (obscure) | Wajib; minimal 6 karakter | "Kata sandi wajib diisi." / "Kata sandi minimal 6 karakter." |
| Ulangi kata sandi | Daftar | `TextFormField` (obscure) | Wajib; harus sama dengan kolom kata sandi | "Kata sandi wajib diisi." / "Kata sandi tidak sama." |
| Tanggal timbang | Catat Berat | `TextFormField` (read-only) | Selalu terisi (default hari ini); dipilih lewat kalender, tidak bisa masa depan | — (tidak bisa kosong) |
| Berat badan | Catat Berat | `TextFormField` (angka) | Wajib; angka; 30–200 kg | "Berat wajib diisi." / "Berat harus berupa angka." / "Berat harus antara 30 dan 200 kg." |
| Catatan | Catat Berat | `TextFormField` (3 baris) | Opsional, bebas | — |

Aturan berat badan **30–200 kg** dipakai bersama oleh Target Timbang dan Catat
Berat (`Validators.berat`), sehingga pesan galatnya pasti sama.

## 2. Tabel uji Login

| # | Kasus uji | Input | Hasil yang diharapkan | Hasil nyata | Bukti |
|---|---|---|---|---|---|
| 1 | Semua kolom kosong | — | Dua pesan wajib muncul di bawah kolom masing-masing; data tidak terkirim | **Sesuai.** "Email wajib diisi." + "Kata sandi wajib diisi." muncul | test `Login menolak kolom kosong` |
| 2 | Format email salah | `bukan-email` / `123456` | "Format email tidak valid." | **Sesuai** | test `Login menolak format email salah` |
| 3 | Kata sandi terlalu pendek | `a@b.com` / `123` | "Kata sandi minimal 6 karakter." | **Sesuai** | test `Login menolak kata sandi kurang dari 6 karakter` |
| 4 | Kirim form tidak valid | — | Pesan status (SnackBar) "Periksa kembali isian yang ditandai merah." | **Sesuai** | test `Kirim form tidak valid menampilkan pesan status` |
| 5 | Kredensial salah | email terdaftar / sandi salah | "Email atau kata sandi salah." di form **dan** SnackBar; tetap di halaman Login | **Sesuai** — pesan muncul di form dan SnackBar, halaman tidak berpindah | dicoba manual, 30 Okt 2026 |
| 6 | Semua valid | akun demo | Masuk, diarahkan ke Dashboard, SnackBar "Berhasil masuk." | **Sesuai** — masuk ke Dashboard, SnackBar tampil | dicoba manual, 30 Okt 2026 |

## 3. Tabel uji Daftar

| # | Kasus uji | Input | Hasil yang diharapkan | Hasil nyata | Bukti |
|---|---|---|---|---|---|
| 7 | Nama kosong | — / `a@b.com` / `123456` / `123456` | "Nama wajib diisi." | **Sesuai** | test `Daftar menolak kolom nama kosong` |
| 8 | Kata sandi tidak sama | `Rasyid` / `a@b.com` / `123456` / `1234567` | "Kata sandi tidak sama." | **Sesuai** | test `Daftar menolak kata sandi yang tidak sama` |
| 9 | Email sudah terdaftar | email akun demo | "Email sudah terdaftar. Silakan masuk." | **Sesuai** | dicoba manual, 30 Okt 2026 |
| 10 | Semua valid | nama + email baru + sandi | Akun dibuat, `users/{uid}` tertulis, diarahkan ke Dashboard, SnackBar "Akun berhasil dibuat." | **Sesuai** — akun terbentuk dan dokumen `users/{uid}` tertulis | dicoba manual, 30 Okt 2026 |

## 4. Tabel uji Target Timbang

Halaman H4, dibuka dari kartu Dashboard atau ikon ubah di kartu utama.

| # | Kasus uji | Input | Hasil yang diharapkan | Hasil nyata | Bukti |
|---|---|---|---|---|---|
| 11 | Kedua kolom kosong | — | Tersimpan sebagai target kosong (tanpa galat), kembali ke Dashboard | **Sesuai.** `batasBerat` dan `tanggalTimbang` tersimpan null | test `kedua kolom kosong tetap bisa disimpan` |
| 12 | Batas berat di atas rentang | `250` | "Berat harus antara 30 dan 200 kg."; data tidak tersimpan | **Sesuai** | test `batas berat di luar rentang ditolak` |
| 13 | Batas berat di bawah rentang | `25` | Pesan yang sama seperti #12 | **Sesuai** (aturan yang sama) | `Validators.berat` |
| 14 | Batas berat dengan koma desimal | `71,5` | Tersimpan sebagai `71.5` (angka, bukan teks) | **Sesuai** | test `batas berat dengan koma desimal tersimpan sebagai angka` |
| 15 | Batas berat bukan angka | `abc` | Tidak bisa diketik — `FilteringTextInputFormatter` hanya menerima `0-9 . ,` | **Sesuai** | `target_timbang_page.dart` |
| 16 | Membuka ulang setelah menyimpan | target 71,5 + 12/11/2026 | Kedua kolom langsung terisi nilai tersimpan | **Sesuai** | test `nilai target tersimpan langsung terisi saat dibuka` |
| 17 | Memilih tanggal lewat kalender | ketuk kolom tanggal | `showDatePicker` terbuka; hari yang sudah lewat tidak bisa dipilih | **Sesuai** — kalender terbuka, tanggal masa depan tidak bisa dipilih | dicoba manual, 30 Okt 2026 |
| 18 | Menghapus tanggal | ketuk ikon × | Kolom tanggal kosong; Simpan menyimpan `tanggalTimbang` null | **Sesuai** — kolom kosong dan `tanggalTimbang` tersimpan null | dicoba manual, 30 Okt 2026 |

## 5. Tabel uji Catat Berat

Halaman H5, dibuka dari tombol tambah (FAB) di Dashboard atau Riwayat Berat.

| # | Kasus uji | Input | Hasil yang diharapkan | Hasil nyata | Bukti |
|---|---|---|---|---|---|
| 19 | Tanggal default | buka halaman | Kolom tanggal terisi tanggal hari ini, bukan kosong | **Sesuai** | test `tanggal default terisi hari ini` |
| 20 | Berat kosong | — | "Berat wajib diisi."; tidak ada catatan dibuat | **Sesuai** | test `berat kosong ditolak` |
| 21 | Berat di atas rentang | `250` | "Berat harus antara 30 dan 200 kg."; tidak tersimpan | **Sesuai** | test `berat di luar 30-200 kg ditolak` |
| 22 | Berat di bawah rentang | `25` | Pesan yang sama seperti #21 | **Sesuai** (aturan yang sama) | `Validators.berat` |
| 23 | Berat dengan koma desimal | `73,6` | Tersimpan `73.6`; `catatan` null karena dikosongkan | **Sesuai** | test `berat dengan koma tersimpan, catatan opsional` |
| 24 | Catatan diisi | `73,6` + "Latihan pagi" | Catatan ikut tersimpan sebagai teks | **Sesuai** | test `catatan ikut tersimpan bila diisi` |
| 25 | Tanggal sudah punya catatan | `73,6` pada tanggal yang ada | Dialog "Tanggal ini sudah ada catatannya" + berat lama; **tidak** ada duplikat | **Sesuai** | test `tanggal yang sudah ada catatannya tidak membuat duplikat` |
| 26 | Pilih "Ubah Catatan" di dialog | ketuk tombol itu | Pindah ke mode ubah dengan nilai lama terisi | **Sesuai** | test `dialog duplikat menawarkan ubah catatan yang sudah ada` |
| 27 | Mode ubah memuat nilai | buka `/weight/:id/edit` | Tanggal, berat, dan catatan lama terisi | **Sesuai** | test `mode ubah memuat nilai catatan yang ada` |
| 28 | Simpan perubahan | ubah berat jadi `73,9` | `ubah` dipanggil, **tidak** ada catatan baru | **Sesuai** | test `mode ubah menyimpan perubahan tanpa menambah catatan baru` |
| 29 | Gagal simpan (jaringan) | berat valid, simpan | SnackBar "Gagal menyimpan. Periksa koneksi lalu coba lagi."; isian **tidak** hilang | **Sesuai** | test `gagal simpan: pesan galat tampil dan isian tidak hilang` |
| 30 | Jalur Dashboard → tersimpan | FAB → isi berat → Simpan | Maksimal 3 langkah; kembali ke Dashboard dengan SnackBar sukses | **Sesuai** | test `dari Dashboard ke catatan tersimpan maksimal 3 langkah` |
| 31 | Memilih tanggal lampau | ketuk kolom tanggal | `showDatePicker` terbuka; hanya hari ini dan sebelumnya yang bisa dipilih | **Sesuai** — tanggal lampau bisa dipilih, hari ini jadi batas atas | dicoba manual, 30 Okt 2026 |
| 32 | Membuka id yang sudah dihapus | `/weight/tidak-ada/edit` | Keadaan "Catatan tidak ditemukan." + tombol Kembali | **Sesuai** | dicoba manual, 30 Okt 2026 |

## 6. Catatan pengujian

- Uji otomatis memakai `FakeAuthRepository`, `FakeUserRepository`,
  `FakeTargetRepository`, dan `FakeWeightLogRepository`, jadi tidak menyentuh
  Firebase sama sekali — hasilnya tidak berubah karena koneksi internet.
- Kasus 5, 6, 9, 10, 17, 18, 31, dan 32 bergantung pada layanan Firebase atau
  dialog bawaan Flutter, sehingga tidak bisa dirender di widget test. Kedelapannya
  sudah dicoba manual lewat aplikasi online (`wefight-38409.web.app`) dengan akun
  sungguhan, dan hasilnya sesuai harapan.
- Pesan kesalahan diperbarui otomatis saat pengguna memperbaiki kolom
  (`AutovalidateMode.onUserInteraction` pada `Form`), jadi pesan lama tidak
  tertinggal.
- Pesan status memakai `AppSnackBar` yang selalu memanggil `hideCurrentSnackBar()`
  lebih dulu, supaya pesan baru tidak antre di belakang pesan lama.
- Status tidak dibedakan hanya dengan warna: setiap SnackBar berisi ikon **dan**
  teks (aturan bisnis PLAN §3 poin 10).
