# Panduan Setup Firebase — WeFight

> Langkah manual yang harus dilakukan pemilik proyek di browser. Setelah selesai,
> `flutterfire configure` dijalankan sekali dan M7 bisa dikerjakan.
>
> **Aturan penting:** paket **Spark (gratis)**. Jangan pernah menekan tombol
> "Upgrade" / "Blaze" dan jangan memasang billing account — ini batasan mata kuliah.

Terakhir diperbarui: 2026-10-29

---

## A. Buat project

1. Buka https://console.firebase.google.com — masuk dengan akun Google.
2. Klik **Create a project** (atau **Add project**).
3. **Project name:** `wefight` — project ID akan otomatis jadi sesuatu seperti
   `wefight-1a2b3`. Project ID **permanen**, tidak bisa diganti.
4. **Google Analytics:** boleh dimatikan. Tidak dipakai proyek ini, dan
   mematikannya membuat setup lebih singkat.
5. Klik **Create project** → tunggu → **Continue**.

**Periksa:** di kiri bawah halaman Overview harus tertulis **Spark plan**.
Kalau tertulis Blaze, ada yang salah — jangan lanjut.

---

## B. Aktifkan Authentication (email/password)

1. Menu kiri → **Security** → **Authentication** (di sebagian tampilan:
   **Build** → **Authentication**).
2. Klik **Get started**.
3. Tab **Sign-in method** → pilih **Email/Password**.
4. **Enable** → biarkan "Email link (passwordless sign-in)" **mati** → **Save**.

**Periksa:** Email/Password muncul di daftar provider dengan status Enabled.

---

## C. Buat database Firestore

1. Menu kiri → **Databases & Storage** → **Firestore** (di tampilan lama:
   **Build** → **Firestore Database**).
2. Klik **Create database**.
3. **Kalau muncul pilihan edisi:** pilih **Standard edition**.
   Jangan pilih Enterprise — itu untuk MongoDB-compatible dan butuh billing.
4. **Location:** pilih `asia-southeast2` (Jakarta) — atau `asia-southeast1`
   (Singapore) bila Jakarta tidak tersedia.
   ⚠️ **Lokasi permanen.** Tidak bisa diubah setelah dibuat; mengganti berarti
   membuat project baru.
5. **Security rules starting mode:** pilih **Production mode**.
   (Test mode membuka data untuk siapa saja selama 30 hari — kita tulis aturan
   sendiri di langkah D.)
6. Klik **Create** → tunggu provisioning.

**Periksa:** tab **Data** terbuka dan kosong, tab **Rules** menampilkan
`allow read, write: if false;`.

---

## D. Pasang aturan keamanan

Tab **Rules** → tempel isi berikut → **Publish**.

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Profil: hanya pemilik. uid ikut diperiksa agar isi dokumen konsisten.
    match /users/{uid} {
      allow read, delete: if request.auth != null && request.auth.uid == uid;
      allow create, update: if request.auth != null
        && request.auth.uid == uid
        && request.resource.data.uid == uid;
    }

    // Target: document id = uid, hanya pemilik.
    match /targets/{uid} {
      allow read, write: if request.auth != null && request.auth.uid == uid;
    }

    // Catatan berat: uid adalah field, hanya pemilik.
    match /weightLogs/{logId} {
      allow read, delete: if request.auth != null
        && resource.data.uid == request.auth.uid;
      allow create: if request.auth != null
        && request.resource.data.uid == request.auth.uid;
      allow update: if request.auth != null
        && resource.data.uid == request.auth.uid
        && request.resource.data.uid == request.auth.uid;
    }
  }
}
```

**Catatan teknis:** aturan `weightLogs` hanya bekerja untuk *query* yang menyaring
`uid`, jadi kode wajib memakai
`.where('uid', isEqualTo: user.uid)` — bukan mengambil semua lalu memfilter di
Dart. Sudah dijadwalkan di M8-3.

**Nama field yang benar adalah `request.resource.data`, bukan `request.data`.**
`request.data` tidak dikenal aturan Firestore sehingga setiap penulisan ditolak
dengan `Missing or insufficient permissions` — dan gejalanya menipu, karena
koleksi yang diperiksa lewat id dokumen (`targets/{uid}`) tetap berhasil.

**Cara kedua (dipakai sejak M8):** aturan yang sama disimpan di berkas
`firestore.rules` di akar proyek, jadi bisa dipasang lewat CLI tanpa membuka
console:

```bash
firebase deploy --only firestore:rules
```

Kalau kedua cara dipakai bergantian, **berkas `firestore.rules` yang menang** —
tempel ulang isinya ke console hanya bila kamu mengubahnya di sana.

**Uji isolasi (M8-4) — sudah otomatis:**

```bash
dart run tool/cek_isolasi.dart
```

Skrip ini masuk sebagai dua akun (demo + pembanding) lalu memastikan akun B
ditolak saat membaca/menulis data akun A.

---

## E. Daftarkan aplikasi

Menu **Project settings** (ikon gerigi) → tab **Your apps**.

### Web (wajib — untuk Firebase Hosting)
1. Klik ikon **`</>`** (Web).
2. **App nickname:** `wefight-web`. **Jangan** centang Firebase Hosting di sini
   (kita atur di M16).
3. **Register app** → salin isi `firebaseConfig` bila diminta. Tidak perlu
   ditempel manual — `flutterfire configure` mengambilnya otomatis.

### Android (wajib — untuk uji di HP)
1. Klik ikon **Android**.
2. **Android package name:** isi persis `com.example.wefight`
   (sudah dicek dari `android/app/build.gradle.kts` — `applicationId` dan
   `namespace` keduanya `com.example.wefight`). Salah ketik = aplikasi tidak
   bisa terhubung.
3. **App nickname:** `wefight-android` → **Register app**.
4. Unduh `google-services.json` bila diminta — **tidak perlu** ditaruh manual,
   `flutterfire configure` menanganinya.

### iOS (opsional)
Hanya bila punya Mac. Kalau tidak, lewati.

---

## F. Pasang CLI dan hubungkan ke proyek

Jalankan di terminal, dari akar proyek `D:\dev\wefight`.

```bash
# 1. Firebase CLI (butuh Node — sudah ada: v22)
npm install -g firebase-tools

# 2. FlutterFire CLI
dart pub global activate flutterfire_cli

# 3. Login (membuka browser)
firebase login

# 4. Hubungkan proyek — pilih project wefight saat ditanya
flutterfire configure --project=<PROJECT_ID>
```

Saat `flutterfire configure` bertanya platform, pilih **android, ios, web** saja.
Jangan pilih windows/macos/linux — folder platform itu ada di scaffold tapi tidak
dipakai untuk mata kuliah ini, dan menambah konfigurasi yang tidak perlu.

**Hasil yang benar:** muncul file `lib/firebase_options.dart` dan
`android/app/google-services.json`.

### Kalau muncul `flutterfire : The term 'flutterfire' is not recognized`

Ini bukan kegagalan instalasi — launcher-nya ada, hanya foldernya belum masuk
`PATH`. Buktikan dulu:

```powershell
dart pub global list
```

Kalau muncul `flutterfire_cli 1.4.1`, paketnya terpasang. Perbaiki PATH:

```powershell
# Permanen (berlaku untuk terminal baru)
$pubBin = "$env:LOCALAPPDATA\Pub\Cache\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$pubBin*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$pubBin", "User")
}
```

Tutup terminal, buka lagi, lalu `flutterfire --version`.

Bila tidak ingin mengubah PATH, panggil langsung:

```powershell
dart pub global run flutterfire_cli:flutterfire configure --project=<PROJECT_ID>
```

Atau jalankan launcher-nya dengan path lengkap:
`%LOCALAPPDATA%\Pub\Cache\bin\flutterfire.bat`

---

## G. Verifikasi

Setelah langkah F, minta agent melanjutkan M7. Yang akan dilakukan:

1. `Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform)` di
   `main.dart`.
2. Halaman Login + Daftar dengan validasi.
3. Auth guard di GoRouter.
4. Uji: daftar akun → masuk → keluar → data tidak bisa diakses tanpa login.

Yang perlu kamu cek sendiri di console setelah M7:

| Cek | Di mana |
|---|---|
| Akun uji muncul | Authentication → tab **Users** |
| Dokumen target/catatan tersimpan | Firestore → **Data** → koleksi `targets` / `weightLogs` |
| Tidak ada billing aktif | Project settings → **Usage and billing** |

---

## H. Hosting (baru dipakai di M16)

Jangan dikerjakan sekarang. Ringkasnya:

```bash
flutter build web
firebase init hosting   # public directory: build/web, SPA: yes
firebase deploy --only hosting
```

---

## Masalah yang sering muncul

| Gejala | Penyebab | Solusi |
|---|---|---|
| `flutterfire` tidak dikenali padahal sudah `dart pub global activate` | Folder `%LOCALAPPDATA%\Pub\Cache\bin` belum ada di `PATH` (khas Windows) | Lihat §F; tambahkan ke PATH atau pakai `dart pub global run flutterfire_cli:flutterfire` |
| `flutterfire configure` gagal "no projects found" | Belum `firebase login`, atau akun Google berbeda | Jalankan `firebase login --reauth` |
| App Android tidak terhubung | `applicationId` tidak sama dengan package name di console | Daftarkan ulang app dengan package yang benar |
| Error `permission-denied` saat baca data | Rules belum di-Publish, atau query tidak menyaring `uid` | Cek tab Rules; pastikan `.where('uid', isEqualTo: ...)` |
| Muncul permintaan upgrade ke Blaze | Memilih fitur di luar Spark (Cloud Functions, Analytics lanjutan) | Batalkan; proyek ini tidak memakainya |
| Lokasi database salah | Sudah terlanjur dibuat | Buat project Firebase baru; lokasi tidak bisa diubah |

---

## Yang perlu dikirim balik ke agent

Cukup satu hal: **Project ID** (contoh `wefight-1a2b3`) dan konfirmasi bahwa
langkah A–F selesai. Setelah itu M7 dilanjutkan.
