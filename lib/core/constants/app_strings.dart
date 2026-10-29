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

  // Placeholder saat pengembangan.
  static const placeholderBelumDibangun = 'Halaman ini belum dibangun.';
}
