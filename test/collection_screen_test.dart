import 'dart:async';

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ujian_uts_amad/models/holiday_plan_model.dart';
import 'package:ujian_uts_amad/models/trip_type_model.dart';
import 'package:ujian_uts_amad/screens/collection_screen.dart';
import 'package:ujian_uts_amad/theme/app_theme.dart';

void main() {
  testWidgets('shows a new category before the refresh request completes', (
    tester,
  ) async {
    final categories = <TripTypeModel>[];
    final refresh = Completer<List<TripTypeModel>>();
    var creationFinished = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: CollectionScreen(
          tripTypeLoader: () async {
            if (creationFinished) return refresh.future;
            return List.of(categories);
          },
          tripTypeCreator: (name) async {
            final category = TripTypeModel(id: 1, name: name);
            categories.add(category);
            creationFinished = true;
            return category;
          },
          holidayPlanLoader: ({int? tripTypeId}) async => [],
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('Jenis Liburan'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Tambah kategori'));
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const ValueKey('collection-form-name')),
      'Staycation',
    );
    await tester.tap(find.text('Simpan Tambah Kategori'));
    await tester.pumpAndSettle();

    expect(find.text('Staycation'), findsOneWidget);

    refresh.complete(List.of(categories));
    await tester.pumpAndSettle();
    expect(find.text('Staycation'), findsOneWidget);
  });

  testWidgets(
    'shows saved plans, filters by category, and keeps category CRUD',
    (tester) async {
      final categories = [
        TripTypeModel(id: 1, name: 'Mudik Keluarga'),
        TripTypeModel(id: 2, name: 'Pantai & Alam'),
      ];
      final plans = [
        HolidayPlanModel(
          id: 1,
          tripTypeId: 1,
          tripTypeName: 'Mudik Keluarga',
          title: 'Mudik Lebaran Jogja',
          notes: 'Tiket kereta dan hotel',
          holidayDate: '2028-08-17',
        ),
        HolidayPlanModel(
          id: 2,
          tripTypeId: 2,
          tripTypeName: 'Pantai & Alam',
          title: 'Long Weekend di Bali',
          notes: 'Jelajahi pantai',
          holidayDate: '2028-08-18',
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          home: CollectionScreen(
            tripTypeLoader: () async => categories,
            holidayPlanLoader: ({int? tripTypeId}) async => plans,
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Koleksi Liburanku 🎒'), findsOneWidget);
      expect(find.text('Mudik Lebaran Jogja'), findsOneWidget);
      expect(find.text('Long Weekend di Bali'), findsOneWidget);

      await tester.tap(find.text('Mudik Keluarga (1)'));
      await tester.pumpAndSettle();
      expect(find.text('Mudik Lebaran Jogja'), findsOneWidget);
      expect(find.text('Long Weekend di Bali'), findsNothing);

      await tester.tap(find.text('Jenis Liburan'));
      await tester.pumpAndSettle();
      expect(find.text('Mudik Keluarga'), findsOneWidget);
      expect(find.text('Pantai & Alam'), findsOneWidget);
      expect(find.byTooltip('Edit kategori'), findsNWidgets(2));
      expect(find.byTooltip('Hapus kategori'), findsNWidgets(2));
    },
  );
}
