// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ujian_uts_amad/screens/register_screen.dart';
import 'package:ujian_uts_amad/theme/app_theme.dart';

void main() {
  Future<void> pumpRegisterScreen(WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(theme: AppTheme.lightTheme, home: const RegisterScreen()),
    );
  }

  testWidgets('shows Stitch registration layout and all account fields', (
    tester,
  ) async {
    await pumpRegisterScreen(tester);

    expect(find.text('Langkah Awal Liburan'), findsOneWidget);
    expect(find.text('Buat akun baru ✨'), findsOneWidget);
    expect(find.text('Konfirmasi Kata Sandi'), findsOneWidget);
    expect(find.text('Cuti Bersama Otomatis Terhubung'), findsOneWidget);
    expect(find.byType(TextField), findsNWidgets(4));
    expect(
      find.text('Minimal 8 karakter & kombinasi huruf/angka'),
      findsOneWidget,
    );
  });

  testWidgets('updates password strength and confirmation feedback', (
    tester,
  ) async {
    await pumpRegisterScreen(tester);

    final passwordFinder = find.byKey(const ValueKey('register-password'));
    await tester.ensureVisible(passwordFinder);
    await tester.enterText(passwordFinder, 'libur12');
    await tester.pump();
    expect(
      find.text('Kata sandi lemah (tambahkan kombinasi angka/huruf)'),
      findsOneWidget,
    );

    await tester.enterText(passwordFinder, 'liburan12');
    await tester.pump();
    expect(find.text('Cukup kuat untuk keamanan akunmu'), findsOneWidget);

    final confirmationFinder = find.byKey(
      const ValueKey('register-confirm-password'),
    );
    await tester.ensureVisible(confirmationFinder);
    await tester.enterText(confirmationFinder, 'liburan13');
    await tester.pump();
    expect(find.text('Kata sandi belum cocok'), findsOneWidget);

    await tester.enterText(confirmationFinder, 'liburan12');
    await tester.pump();
    expect(find.text('Kata sandi sesuai dan cocok'), findsOneWidget);
  });

  testWidgets('keeps required-field validation', (tester) async {
    await pumpRegisterScreen(tester);

    final submitButton = find.text('Daftar Sekarang');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);
    await tester.pump();

    expect(find.text('Semua kolom wajib diisi'), findsOneWidget);
  });
}
