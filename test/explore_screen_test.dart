// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:ujian_uts_amad/models/public_holiday_model.dart';
import 'package:ujian_uts_amad/models/user_model.dart';
import 'package:ujian_uts_amad/screens/explore_screen.dart';
import 'package:ujian_uts_amad/theme/app_theme.dart';

void main() {
  testWidgets('shows the home design and filters holidays by month', (
    tester,
  ) async {
    final today = DateTime.now();
    final firstDate = DateTime(today.year, today.month, today.day + 2);
    final secondDate = firstDate.add(const Duration(days: 40));
    String isoDate(DateTime date) =>
        '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ExploreScreen(
          holidayLoader: () async => [
            PublicHoliday(
              date: isoDate(firstDate),
              localName: 'Libur Utama',
              name: 'Main Holiday',
              countryCode: 'ID',
              types: const ['Public'],
            ),
            PublicHoliday(
              date: isoDate(secondDate),
              localName: 'Libur Berikutnya',
              name: 'Next Holiday',
              countryCode: 'ID',
              types: const ['Public'],
            ),
          ],
          userLoader: () async =>
              UserModel(id: 1, name: 'Amina Putri', email: 'amina@example.com'),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Jadwal'), findsOneWidget);
    expect(find.textContaining('Halo, Amina!'), findsOneWidget);
    expect(find.text('LIBUR TERDEKAT'), findsOneWidget);
    expect(find.text('Jadwal Kalender'), findsOneWidget);
    expect(find.byKey(const ValueKey('monthly-calendar')), findsOneWidget);
    expect(find.byKey(const ValueKey('calendar-grid')), findsOneWidget);

    final monthFilter = find.byKey(
      ValueKey('month-filter-${secondDate.month}'),
    );
    await tester.ensureVisible(monthFilter);
    await tester.tap(monthFilter);
    await tester.pumpAndSettle();

    final selectedChip = find.descendant(
      of: monthFilter,
      matching: find.byType(ChoiceChip),
    );
    expect(tester.widget<ChoiceChip>(selectedChip).selected, isTrue);
    await tester.drag(find.byType(ListView).first, const Offset(0, -1000));
    await tester.pumpAndSettle();
    expect(find.text('Libur Berikutnya'), findsOneWidget);
  });

  testWidgets('opens the profile when the explore avatar is tapped', (
    tester,
  ) async {
    var profileOpened = false;
    final today = DateTime.now();
    final holidayDate = today.add(const Duration(days: 2));
    final isoDate =
        '${holidayDate.year}-${holidayDate.month.toString().padLeft(2, '0')}-${holidayDate.day.toString().padLeft(2, '0')}';

    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: ExploreScreen(
          holidayLoader: () async => [
            PublicHoliday(
              date: isoDate,
              localName: 'Libur Utama',
              name: 'Main Holiday',
              countryCode: 'ID',
              types: const ['Public'],
            ),
          ],
          userLoader: () async =>
              UserModel(id: 1, name: 'Amina Putri', email: 'amina@example.com'),
          onProfileTap: () => profileOpened = true,
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Amina Putri'));
    expect(profileOpened, isTrue);
  });
}
