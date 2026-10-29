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
  static const validasiBeratKosong = 'Berat wajib diisi.';
  static const validasiBeratAngka = 'Berat harus berupa angka.';
  static const validasiBeratRentang = 'Berat harus antara 30 dan 200 kg.';

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

  // Target Timbang.
  static const targetSubtitle =
      'Atur batas berat dan hari timbang. Keduanya boleh dikosongkan.';
  static const labelBatasBerat = 'Batas Berat (kg)';
  static const labelTanggalTimbang = 'Tanggal Timbang';
  static const targetBantuanBatas = 'Boleh dikosongkan. Contoh: 71 atau 71,5';
  static const targetBantuanTanggal = 'Boleh dikosongkan.';
  static const pilihTanggal = 'Pilih tanggal';
  static const hapusTanggal = 'Hapus tanggal';
  static const targetInfoKosong =
      'Tanpa target, Dashboard hanya menampilkan berat terakhir tanpa selisih '
      'dan hitung mundur.';
  static const targetTersimpan = 'Target timbang tersimpan.';
  static const simpanGagal = 'Gagal menyimpan. Periksa koneksi lalu coba lagi.';

  // Catat Berat.
  static const catatSubtitleTambah =
      'Satu catatan per tanggal. Kalau tanggal itu sudah ada, kamu bisa '
      'mengubah catatannya.';
  static const catatSubtitleEdit = 'Mengubah catatan yang sudah tersimpan.';
  static const labelBeratBadan = 'Berat Badan (kg)';
  static const bantuanBerat = 'Antara 30 dan 200 kg. Contoh: 73,6';
  static const labelCatatan = 'Catatan (opsional)';
  static const hintCatatan = 'Misalnya: timbang pagi sebelum latihan';
  static const duplikatJudul = 'Tanggal ini sudah ada catatannya';
  static const ubahCatatan = 'Ubah Catatan';
  static const catatanTersimpan = 'Catatan berat tersimpan.';
  static const catatanDiperbarui = 'Catatan berat diperbarui.';
  static const catatanTidakDitemukan = 'Catatan tidak ditemukan.';
  static const tanggalDipakaiLain =
      'Sudah ada catatan lain pada tanggal itu. Pilih tanggal lain.';

  /// Pesan dialog saat tanggal yang dipilih sudah punya catatan.
  static String duplikatPesan(String berat, String tanggal) =>
      'Sudah ada catatan $berat kg pada $tanggal. '
      'Ubah catatan itu, atau pilih tanggal lain.';

  // Dashboard.
  static const sapaan = 'Halo, Fighter!';
  static const sapaanSub = 'Ayo catat progresmu hari ini.';
  static const labelBeratSaatIni = 'Berat Badan Saat Ini';
  static const labelTargetBerat = 'Target Berat';
  static const satuanKg = 'kg';
  static const nilaiKosong = '—';
  static const heroBelumAdaCatatan = 'Belum ada catatan';
  static const heroBelumAdaTarget = 'Batas berat belum diatur';

  static const dashboardKosongJudul = 'Belum ada catatan berat';
  static const dashboardKosongPesan =
      'Catatan pertamamu akan muncul di sini setelah kamu menimbang.';
  static const aturTarget = 'Atur Target Timbang';

  // Dashboard — selisih & hitung mundur (PLAN §3 poin 4–5).
  static const selisihTepat = 'Tepat di batas';
  static String selisihAtas(String nilai) => '$nilai kg di atas batas';
  static String selisihBawah(String nilai) => '$nilai kg di bawah batas';

  static const hitungMundurHariIni = 'Hari ini hari timbang';
  static String hitungMundurLewat(int hari) =>
      'Hari timbang terlewat $hari hari';
  static String hitungMundurLagi(int hari) => '$hari hari lagi';

  static const labelHariTimbang = 'Hari Timbang';
  static const belumAdaTargetJudul = 'Belum ada target berat';
  static const belumAdaTargetPesan =
      'Atur batas berat dan hari timbang supaya selisih serta hitung mundur '
      'bisa ditampilkan di sini.';

  // Perubahan antar catatan (kolom "Perubahan" di Riwayat, UI_SPEC §7).
  static const perubahanTetap = 'Tetap';
  static String perubahanNaik(String nilai) => '+$nilai kg';
  static String perubahanTurun(String nilai) => '-$nilai kg';

  // Riwayat.
  static const riwayatKosongJudul = 'Belum ada catatan berat';
  static const riwayatKosongPesan =
      'Catatan pertamamu akan muncul di sini setelah kamu menimbang.';
  static const riwayatSubtitle = 'Semua catatan beratmu, yang terbaru di atas.';
  static const riwayatTapHint = 'Ketuk catatan untuk mengubahnya.';

  /// Jumlah catatan, misalnya "6 catatan".
  static String riwayatJumlah(int jumlah) =>
      jumlah == 1 ? '1 catatan' : '$jumlah catatan';

  static const hapusCatatanJudul = 'Hapus catatan ini?';
  static const hapusCatatanTooltip = 'Hapus catatan';
  static const catatanDihapus = 'Catatan berat dihapus.';
  static const hapusGagal = 'Gagal menghapus. Periksa koneksi lalu coba lagi.';
  static const muatGagal = 'Gagal memuat catatan. Periksa koneksi.';
  static const muatGagalPesan =
      'Daftar catatan tidak bisa diambil. Periksa koneksi internet lalu coba '
      'lagi.';
  static const coba = 'Coba lagi';

  /// Pesan dialog konfirmasi hapus.
  static String hapusCatatanPesan(String berat, String tanggal) =>
      'Catatan $berat kg pada $tanggal akan dihapus permanen. '
      'Tindakan ini tidak bisa dibatalkan.';

  // Profil.
  static const profilBelumAda = 'Info akun dan pengaturan akan tampil di sini.';

  // Placeholder saat pengembangan.
  static const placeholderBelumDibangun = 'Halaman ini belum dibangun.';
}
