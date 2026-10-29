# Tabel Uji Form

Latihan 3 modul Minggu 7: setiap aturan validasi diuji, hasil yang diharapkan
ditulis lebih dulu, lalu hasil nyata dicatat.

Status: **Login** dan **Daftar** sudah diuji. Tabel untuk **Target Timbang** dan
**Catat Berat** ditambahkan pada M9 dan M10.

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

Aturan berat badan **30–200 kg** (Catat Berat) sudah disiapkan di
`lib/core/utils/validators.dart` dan diuji terpisah di M15.

## 2. Tabel uji Login

| # | Kasus uji | Input | Hasil yang diharapkan | Hasil nyata | Bukti |
|---|---|---|---|---|---|
| 1 | Semua kolom kosong | — | Dua pesan wajib muncul di bawah kolom masing-masing; data tidak terkirim | **Sesuai.** "Email wajib diisi." + "Kata sandi wajib diisi." muncul | test `Login menolak kolom kosong` |
| 2 | Format email salah | `bukan-email` / `123456` | "Format email tidak valid." | **Sesuai** | test `Login menolak format email salah` |
| 3 | Kata sandi terlalu pendek | `a@b.com` / `123` | "Kata sandi minimal 6 karakter." | **Sesuai** | test `Login menolak kata sandi kurang dari 6 karakter` |
| 4 | Kirim form tidak valid | — | Pesan status (SnackBar) "Periksa kembali isian yang ditandai merah." | **Sesuai** | test `Kirim form tidak valid menampilkan pesan status` |
| 5 | Kredensial salah | email terdaftar / sandi salah | "Email atau kata sandi salah." di form **dan** SnackBar; tetap di halaman Login | **Perlu dicoba manual** di Chrome — butuh Firebase sungguhan | — |
| 6 | Semua valid | akun demo | Masuk, diarahkan ke Dashboard, SnackBar "Berhasil masuk." | **Perlu dicoba manual** di Chrome | — |

## 3. Tabel uji Daftar

| # | Kasus uji | Input | Hasil yang diharapkan | Hasil nyata | Bukti |
|---|---|---|---|---|---|
| 7 | Nama kosong | — / `a@b.com` / `123456` / `123456` | "Nama wajib diisi." | **Sesuai** | test `Daftar menolak kolom nama kosong` |
| 8 | Kata sandi tidak sama | `Rasyid` / `a@b.com` / `123456` / `1234567` | "Kata sandi tidak sama." | **Sesuai** | test `Daftar menolak kata sandi yang tidak sama` |
| 9 | Email sudah terdaftar | email akun demo | "Email sudah terdaftar. Silakan masuk." | **Perlu dicoba manual** di Chrome | — |
| 10 | Semua valid | nama + email baru + sandi | Akun dibuat, `users/{uid}` tertulis, diarahkan ke Dashboard, SnackBar "Akun berhasil dibuat." | **Perlu dicoba manual** di Chrome | — |

## 4. Catatan pengujian

- Uji otomatis memakai `FakeAuthRepository` dan `FakeUserRepository`, jadi tidak
  menyentuh Firebase sama sekali — hasilnya tidak berubah karena koneksi internet.
- Kasus 5, 6, 9, 10 bergantung pada layanan Firebase, sehingga hanya bisa
  dibuktikan dengan `flutter run -d chrome` dan akun sungguhan.
- Pesan kesalahan diperbarui otomatis saat pengguna memperbaiki kolom
  (`AutovalidateMode.onUserInteraction` pada `Form`), jadi pesan lama tidak
  tertinggal.
- Pesan status memakai `AppSnackBar` yang selalu memanggil `hideCurrentSnackBar()`
  lebih dulu, supaya pesan baru tidak antre di belakang pesan lama.
- Status tidak dibedakan hanya dengan warna: setiap SnackBar berisi ikon **dan**
  teks (aturan bisnis PLAN §3 poin 10).
