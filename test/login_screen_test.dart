// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ujian_uts_amad/screens/login_screen.dart';
import 'package:ujian_uts_amad/theme/app_theme.dart';

void main() {
  testWidgets('shows Stitch login content and toggles password visibility', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const LoginScreen()),
    );
    expect(find.textContaining('Selamat datang kembali!'), findsOneWidget);
    expect(find.text('Kata Sandi'), findsOneWidget);
    expect(find.textContaining('Tips Libur:'), findsOneWidget);
    expect(find.text('Belum punya akun?'), findsOneWidget);

    final passwordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(passwordField.obscureText, isTrue);

    await tester.tap(find.byTooltip('Tampilkan kata sandi'));
    await tester.pumpAndSettle();

    final visiblePasswordField = tester.widget<TextField>(
      find.byType(TextField).at(1),
    );
    expect(visiblePasswordField.obscureText, isFalse);
  });
}
