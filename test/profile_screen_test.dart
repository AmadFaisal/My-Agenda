// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ujian_uts_amad/models/holiday_plan_model.dart';
import 'package:ujian_uts_amad/models/trip_type_model.dart';
import 'package:ujian_uts_amad/models/user_model.dart';
import 'package:ujian_uts_amad/screens/profile_screen.dart';
import 'package:ujian_uts_amad/theme/app_theme.dart';

void main() {
  testWidgets('shows account details and live collection statistics', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ProfileScreen(
          userLoader: () async =>
              UserModel(id: 1, name: 'Amina Putri', email: 'amina@example.com'),
          planLoader: () async => [
            HolidayPlanModel(id: 1, tripTypeId: 1, title: 'Mudik Lebaran'),
            HolidayPlanModel(id: 2, tripTypeId: 1, title: 'Liburan Keluarga'),
          ],
          categoryLoader: () async => [
            TripTypeModel(id: 1, name: 'Mudik Keluarga'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Profil'), findsOneWidget);
    expect(find.text('Amina Putri'), findsOneWidget);
    expect(find.text('amina@example.com'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('1'), findsOneWidget);
    expect(find.text('date.nager.at/api/v3'), findsOneWidget);
    await tester.drag(find.byType(ListView), const Offset(0, -1200));
    await tester.pumpAndSettle();
    expect(find.text('Identitas Pembuat'), findsOneWidget);
    expect(find.text('Ahmad Faisal'), findsOneWidget);
    expect(find.text('XII RPL 2'), findsOneWidget);
    expect(find.text('Keluar Akun'), findsOneWidget);
  });
}
