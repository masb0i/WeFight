import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:wefight/app/app.dart';
import 'package:wefight/core/constants/app_strings.dart';

void main() {
  testWidgets('aplikasi terbuka di halaman Login', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: WeFightApp()));
    await tester.pumpAndSettle();

    expect(find.text(AppStrings.halamanLogin), findsWidgets);
  });

  testWidgets('tema memakai primer burgundy, bukan bawaan Flutter',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: WeFightApp()));
    await tester.pumpAndSettle();

    final context = tester.element(find.byType(Scaffold).first);
    final theme = Theme.of(context);

    expect(theme.colorScheme.primary, const Color(0xFF59171B));
    expect(theme.scaffoldBackgroundColor, const Color(0xFFF8E9DF));
  });
}
