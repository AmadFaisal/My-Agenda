import 'package:flutter/material.dart';

import 'routes/app_routing.dart';
import 'theme/app_theme.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Agenda Liburku',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRouting.splash,
      onGenerateRoute: AppRouting.onGenerateRoute,
      // Constrain width on wide/desktop viewports to keep mobile timetable proportions.
      builder: (context, child) {
        return Container(
          color: AppTheme.surfaceSubtle,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: DecoratedBox(
                decoration: const BoxDecoration(
                  border: Border.symmetric(
                    vertical: BorderSide(color: AppTheme.border, width: 1),
                  ),
                ),
                child: child!,
              ),
            ),
          ),
        );
      },
    );
  }
}
