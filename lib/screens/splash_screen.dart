import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkToken();
  }

  Future<void> _checkToken() async {
    await Future.delayed(const Duration(seconds: 2));
    final token = await StorageService.getToken();
    if (!mounted) return;
    if (token != null) {
      Navigator.pushReplacementNamed(context, AppRouting.main);
    } else {
      Navigator.pushReplacementNamed(context, AppRouting.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.accentSoft,
                  borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  border: Border.all(color: AppTheme.accentBorder, width: 1),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: 32,
                  color: AppTheme.accent,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Agenda Liburku',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Jadwal libur & rencana perjalanan',
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.inkMuted,
                ),
              ),
              const SizedBox(height: 28),
              const SizedBox(
                width: 120,
                child: LinearProgressIndicator(
                  minHeight: 3,
                  color: AppTheme.accent,
                  backgroundColor: AppTheme.surfaceSubtle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
