import 'package:flutter/material.dart';

import '../constants/app_spacing.dart';
import '../constants/app_strings.dart';
import 'app_card.dart';
import 'empty_state.dart';

/// Kartu "gagal memuat" yang dipakai bersama Riwayat Berat dan Dashboard.
///
/// Dipisah jadi satu widget supaya kedua layar menyampaikan hal yang sama:
/// data **tidak berhasil diambil**, bukan "tidak ada data". Perbedaan itu
/// penting — sebelumnya kegagalan query tampil sebagai "Belum ada catatan",
/// sehingga pengguna mengira catatannya hilang (D25).
///
/// Kartu ini sengaja tidak membungkus dirinya dengan scroll atau lebar
/// maksimum; pemanggil yang menentukan, karena Dashboard memasukkannya ke
/// dalam kolom sedangkan Riwayat menaruhnya di tengah halaman.
class GagalMuat extends StatelessWidget {
  const GagalMuat({
    super.key,
    required this.onCobaLagi,
    this.judul = AppStrings.muatGagal,
    this.pesan = AppStrings.muatGagalPesan,
  });

  final VoidCallback onCobaLagi;
  final String judul;
  final String pesan;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: EmptyState(
        icon: Icons.cloud_off,
        title: judul,
        message: pesan,
        primaryLabel: AppStrings.coba,
        onPrimary: onCobaLagi,
      ),
    );
  }
}

/// Pembungkus untuk halaman yang isinya hanya [GagalMuat] (Riwayat Berat).
class GagalMuatHalaman extends StatelessWidget {
  const GagalMuatHalaman({
    super.key,
    required this.onCobaLagi,
    this.judul = AppStrings.muatGagal,
    this.pesan = AppStrings.muatGagalPesan,
    this.maxWidth = 720,
  });

  final VoidCallback onCobaLagi;
  final String judul;
  final String pesan;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.pageMobile),
      child: Center(
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: maxWidth),
          child: GagalMuat(
            onCobaLagi: onCobaLagi,
            judul: judul,
            pesan: pesan,
          ),
        ),
      ),
    );
  }
}
