/// Jarak, radius, dan ukuran tetap.
///
/// Sumber: `docs/UI_SPEC.md` §3. Semua jarak kelipatan 4, mayoritas kelipatan 8.
abstract final class AppSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 12.0;
  static const lg = 16.0;
  static const xl = 20.0;
  static const xxl = 24.0;
  static const xxxl = 32.0;
  static const huge = 40.0;

  /// Margin tepi konten.
  static const pageMobile = 16.0;
  static const pageWeb = 24.0;

  /// Jarak antar-kartu.
  static const gap = 20.0;

  /// Ruang bawah konten mobile supaya kartu terakhir tidak tertutup FAB
  /// melayang (D26). Bar 64 px + jarak FAB 16 px + tinggi FAB 56 px + sisa 16.
  static const bottomFab = 152.0;

  /// Ruang bawah konten di layar lebar (FAB di pojok, bukan di tengah).
  static const bottomWide = 96.0;

  /// Ruang bawah konten sesuai lebar layar.
  static double bottomFor(double width) =>
      width < AppBreakpoints.mobile ? bottomFab : bottomWide;
}

abstract final class AppRadius {
  static const card = 20.0;
  static const hero = 24.0;
  static const button = 14.0;
  static const input = 12.0;
  static const shell = 28.0;
  static const pill = 999.0;
}

abstract final class AppSizes {
  static const buttonMobile = 52.0;
  static const buttonWeb = 48.0;
  static const tableRow = 44.0;

  /// Lebar sidebar web.
  static const sidebar = 240.0;

  /// Lebar panel kanan web.
  static const rightPanel = 340.0;

  /// Lebar maksimum konten utama di layar sangat lebar.
  static const maxContent = 1400.0;
}

abstract final class AppBreakpoints {
  static const mobile = 600.0;
  static const tablet = 1024.0;
  static const wide = 1200.0;
}

abstract final class AppFonts {
  /// Harus sama dengan nama family di pubspec.yaml.
  static const family = 'Plus Jakarta Sans';
}
