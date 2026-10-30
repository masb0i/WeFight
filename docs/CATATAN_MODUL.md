# Catatan Penyimpangan dari Modul Praktik

Beberapa hal dalam proyek ini sengaja berbeda dari modul praktik. Semua berbeda
dengan alasan yang bisa dipertanggungjawabkan, dan **tidak satu pun menambah
fitur di luar cakupan** yang ditetapkan pada Minggu 2.

## 1. Warna primer burgundy `#59171B`, bukan navy `#1F3A5F`

Style guide mini Minggu 4 memakai navy sebagai warna primer. Proyek ini memakai
burgundy karena acuan visualnya diganti ke gambar referensi milik sendiri
(gradient burgundy–peach).

Yang tetap diikuti dari Minggu 4: jarak kelipatan 8, margin tepi 16 px pada
mobile, radius kartu, dan aturan bahwa status tidak boleh dibedakan hanya dengan
warna. Rincian token ada di [`UI_SPEC.md`](./UI_SPEC.md).

## 2. Firebase sudah terpasang pada Pertemuan 7

Modul menempatkan integrasi Firebase **setelah** UTS. Di proyek ini, Form Login
dan Daftar sudah tersambung ke Firebase Auth dan Dashboard membaca data dari
Firestore sejak Pertemuan 7.

Ini urutan pengerjaan yang lebih cepat, bukan penambahan fitur: daftar fitur tetap
sama dengan yang disetujui pada Minggu 2.

## 3. Memakai paket dari pub.dev sejak awal

Riverpod, GoRouter, dan fl_chart dipakai sejak awal, padahal modul membatasi
Minggu 6–7 pada widget bawaan karena keterbatasan waktu kelas.

Alasannya: paket tersebut menggantikan kode yang kalau ditulis sendiri akan jauh
lebih panjang (state management dan routing), sehingga waktu pengerjaan bisa
dipakai untuk validasi, pengujian, dan penanganan keadaan kosong/galat.

## 4. Dua tempat spesifikasi awal berbeda dengan hasil akhir

Ini bukan penyimpangan dari modul, melainkan keputusan yang berubah saat
implementasi. Dicatat supaya tidak ada klaim berlebih:

| Hal | Rencana awal | Hasil akhir |
|---|---|---|
| Statistik di Profil | `UI_SPEC.md` §7 merencanakan 3 statistik | Tidak dipakai — Profil hanya berisi identitas dan menu |
| Kolom berat di Catat Berat | `UI_SPEC.md` §4 merencanakan `WeightInput` dengan dua picker | Memakai `AppTextField` biasa dengan angka besar |

Keduanya diputuskan saat implementasi karena versi sederhana lebih cepat dipakai
dan tidak mengurangi satu pun aturan bisnis di `PLAN.md` §3.
