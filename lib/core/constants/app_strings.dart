/// Seluruh teks yang tampil ke pengguna.
///
/// Aturan: jangan menulis teks Indonesia langsung di widget — ambil dari sini
/// supaya konsisten dengan nama halaman di `docs/PLAN.md` §1.1.
abstract final class AppStrings {
  static const appName = 'WeFight';
  static const appTagline = 'Weight for Fight Tracker';

  // Navigasi utama — urutan dan nama tidak boleh berubah.
  static const navDashboard = 'Dashboard';
  static const navRiwayat = 'Riwayat Berat';
  static const navProfil = 'Profil';

  // Judul halaman (harus sama dengan nama halaman final).
  static const halamanLogin = 'Login';
  static const halamanDaftar = 'Daftar';
  static const halamanDashboard = 'Dashboard';
  static const halamanTarget = 'Target Timbang';
  static const halamanCatatBerat = 'Catat Berat';
  static const halamanRiwayat = 'Riwayat Berat';
  static const halamanProfil = 'Profil';

  // Aksi umum.
  static const simpan = 'Simpan';
  static const batal = 'Batal';
  static const hapus = 'Hapus';
  static const ubah = 'Ubah';
  static const kembali = 'Kembali';
  static const keluar = 'Keluar';
  static const lihatSemua = 'Lihat Semua';
  static const catatBerat = 'Catat Berat';

  // Autentikasi.
  static const masuk = 'Masuk';
  static const namaLengkap = 'Nama Lengkap';
  static const email = 'Email';
  static const kataSandi = 'Kata Sandi';
  static const ulangiKataSandi = 'Ulangi Kata Sandi';
  static const loginSubtitle = 'Masuk untuk menyimpan catatan beratmu.';
  static const registerSubtitle = 'Buat akun untuk mulai mencatat berat badan.';
  static const belumPunyaAkun = 'Belum punya akun?';
  static const sudahPunyaAkun = 'Sudah punya akun?';
  static const lupaKataSandi = 'Lupa kata sandi?';

  // Validasi form.
  static const validasiNamaKosong = 'Nama wajib diisi.';
  static const validasiEmailKosong = 'Email wajib diisi.';
  static const validasiEmailFormat = 'Format email tidak valid.';
  static const validasiSandiKosong = 'Kata sandi wajib diisi.';
  static const validasiSandiPendek = 'Kata sandi minimal 6 karakter.';
  static const validasiSandiBeda = 'Kata sandi tidak sama.';

  // Pesan status (SnackBar) setelah tombol Kirim — modul Minggu 7.
  static const periksaIsian = 'Periksa kembali isian yang ditandai merah.';
  static const loginBerhasil = 'Berhasil masuk.';
  static const daftarBerhasil = 'Akun berhasil dibuat.';

  // Pesan galat autentikasi.
  static const authEmailSalah = 'Email atau kata sandi salah.';
  static const authEmailTerdaftar = 'Email sudah terdaftar. Silakan masuk.';
  static const authSandiLemah = 'Kata sandi terlalu lemah (minimal 6 karakter).';
  static const authJaringan = 'Tidak ada koneksi internet. Coba lagi.';
  static const authUmum = 'Terjadi kesalahan. Coba lagi.';
  static const authResetTerkirim = 'Tautan atur ulang dikirim ke emailmu.';

  // Profil.
  static const keluarJudul = 'Keluar dari akun?';
  static const keluarPesan =
      'Kamu perlu masuk lagi untuk melihat catatan beratmu.';
  static const profilFighter = 'Fighter in Progress';
  static const pengaturanTarget = 'Pengaturan Target';
  static const riwayatMenu = 'Riwayat Berat';

  // Splash.
  static const splashQuote = 'Latih diri, capai berat ideal.';

  // Dashboard.
  static const sapaan = 'Halo, Fighter!';
  static const sapaanSub = 'Ayo catat progresmu hari ini.';
  static const labelBeratSaatIni = 'Berat Badan Saat Ini';
  static const labelTargetBerat = 'Target Berat';
  static const satuanKg = 'kg';
  static const nilaiKosong = '—';
  static const heroBelumAdaCatatan = 'Belum ada catatan berat';

  static const dashboardKosongJudul = 'Belum ada data';
  static const dashboardKosongPesan =
      'Mulai dengan mengatur target timbang, lalu catat berat pertamamu.';
  static const aturTarget = 'Atur Target Timbang';

  // Riwayat.
  static const riwayatKosongJudul = 'Belum ada catatan berat';
  static const riwayatKosongPesan =
      'Catatan pertamamu akan muncul di sini setelah kamu menimbang.';

  // Profil.
  static const profilBelumAda = 'Info akun dan pengaturan akan tampil di sini.';

  // Placeholder saat pengembangan.
  static const placeholderBelumDibangun = 'Halaman ini belum dibangun.';
}
