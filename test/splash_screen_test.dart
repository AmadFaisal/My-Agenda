// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ujian_uts_amad/screens/splash_screen.dart';

void main() {
  testWidgets('uses the mint palette and animated two-outline loader', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    await tester.pumpWidget(
      MaterialApp(
        home: const SplashScreen(),
        onGenerateRoute: (_) =>
            MaterialPageRoute<void>(builder: (_) => const SizedBox.shrink()),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Agenda Liburku'), findsOneWidget);
    expect(find.byKey(const ValueKey('agenda-splash-loader')), findsOneWidget);
    expect(find.byType(LinearProgressIndicator), findsNothing);
    expect(find.byType(Positioned), findsNWidgets(2));

    final scaffold = tester.widget<Scaffold>(find.byType(Scaffold));
    expect(scaffold.backgroundColor, const Color(0xFFE6FFF4));
    final calendarIcon = tester.widget<Icon>(
      find.byIcon(Icons.calendar_month_outlined),
    );
    expect(calendarIcon.color, const Color(0xFF3A665C));

    await tester.pump(const Duration(milliseconds: 1500));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('agenda-splash-loader')), findsNothing);
  });
}
