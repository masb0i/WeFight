import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/widgets/placeholder_screen.dart';

/// H5 Catat Berat.
///
/// Dipakai untuk dua mode: tambah (`logId == null`) dan edit (`logId != null`).
class CatatBeratScreen extends StatelessWidget {
  const CatatBeratScreen({super.key, this.logId});

  /// Id catatan yang sedang diedit. Null berarti mode tambah.
  final String? logId;

  bool get isEdit => logId != null;

  @override
  Widget build(BuildContext context) {
    return PlaceholderScreen(
      title: AppStrings.halamanCatatBerat,
      milestone: 'M10',
      note: isEdit
          ? 'Mode edit catatan $logId.'
          : 'Validasi 30–200 kg dan aturan satu catatan per tanggal.',
    );
  }
}
