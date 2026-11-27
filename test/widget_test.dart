// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

// ignore: deprecated_member_use
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:ujian_uts_amad/main.dart';

void main() {
  testWidgets('MyApp launches the splash screen', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MyApp());
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Agenda Liburku'), findsOneWidget);

    await tester.pump(const Duration(seconds: 2));
    await tester.pumpAndSettle();
  });
}
