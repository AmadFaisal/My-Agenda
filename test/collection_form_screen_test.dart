// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ujian_uts_amad/models/holiday_plan_model.dart';
import 'package:ujian_uts_amad/models/trip_type_model.dart';
import 'package:ujian_uts_amad/screens/collection_form_screen.dart';
import 'package:ujian_uts_amad/theme/app_theme.dart';

void main() {
  testWidgets('validates a new category before saving', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const CollectionFormScreen.category(),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Tambah Kategori'), findsOneWidget);
    expect(find.byKey(const ValueKey('collection-form-name')), findsOneWidget);

    await tester.tap(find.text('Simpan Tambah Kategori'));
    await tester.pumpAndSettle();

    expect(find.text('Nama kategori harus diisi'), findsOneWidget);
  });

  testWidgets('validates plan input and supports an existing plan', (
    tester,
  ) async {
    final plan = HolidayPlanModel(
      id: 8,
      tripTypeId: 1,
      tripTypeName: 'Mudik Keluarga',
      title: 'Mudik Lebaran',
      notes: 'Pesan tiket',
      holidayDate: '2028-08-17',
    );

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CollectionFormScreen.plan(
          plan: plan,
          tripTypeLoader: () async => [
            TripTypeModel(id: 1, name: 'Mudik Keluarga'),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Edit Rencana'), findsOneWidget);
    expect(find.text('Mudik Keluarga'), findsOneWidget);
    expect(find.text('Mudik Lebaran'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('collection-form-name')),
      '',
    );
    await tester.tap(find.text('Simpan Edit Rencana'));
    await tester.pumpAndSettle();

    expect(find.text('Nama rencana harus diisi'), findsOneWidget);
  });
}
