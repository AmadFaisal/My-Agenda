// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ujian_uts_amad/models/public_holiday_model.dart';
import 'package:ujian_uts_amad/screens/explore_detail_screen.dart';
import 'package:ujian_uts_amad/theme/app_theme.dart';

void main() {
  testWidgets('shows Stitch-inspired holiday details with real holiday data', (
    tester,
  ) async {
    final holiday = PublicHoliday(
      date: '2028-08-17',
      localName: 'Hari Kemerdekaan Republik Indonesia',
      name: 'Independence Day',
      countryCode: 'ID',
      types: const ['Public'],
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ExploreDetailScreen(holiday: holiday),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Detail Libur'), findsOneWidget);
    expect(find.text('Hari Kemerdekaan Republik Indonesia'), findsOneWidget);
    expect(find.text('Kamis, 17 Agustus 2028'), findsOneWidget);
    expect(find.text('ID'), findsOneWidget);
    expect(find.textContaining('Simpan ke Koleksi Rencana'), findsOneWidget);
    expect(find.text('Liburan non-stop 9 hari'), findsNothing);
  });
}
