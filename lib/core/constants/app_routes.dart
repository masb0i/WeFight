/// Path route aplikasi.
///
/// Dipisah dari `app/router.dart` supaya `core/` tidak bergantung pada `app/`.
/// Nama halaman mengikuti `docs/PLAN.md` §1.1.
abstract final class AppRoutes {
  static const splash = '/splash';
  static const login = '/login';
  static const register = '/register';
  static const dashboard = '/';
  static const target = '/target';
  static const catatBerat = '/weight/new';
  static const editBerat = '/weight/:id/edit';
  static const riwayat = '/history';
  static const profil = '/profile';

  /// Path edit untuk id tertentu.
  static String editBeratPath(String id) => '/weight/$id/edit';
}
