import 'package:flutter/material.dart';

import '../core/constants/app_strings.dart';
import 'router.dart';
import 'theme.dart';

/// Akar aplikasi.
///
/// `Firebase.initializeApp` dan `ProviderScope` disiapkan di `main.dart`.
class WeFightApp extends StatelessWidget {
  const WeFightApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: AppStrings.appName,
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      routerConfig: appRouter,
    );
  }
}
