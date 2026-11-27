// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import '../routes/app_routing.dart';
import '../services/storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  static const _background = Color(0xFFE6FFF4);
  static const _mint = Color(0xFFCEFEED);
  static const _mintBorder = Color(0xFFBCEDE0);
  static const _green = Color(0xFF3A665C);
  static const _ink = Color(0xFF002018);
  static const _muted = Color(0xFF4A625B);

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
      backgroundColor: _background,
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
                  color: _mint,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: _mintBorder, width: 1),
                ),
                child: const Icon(
                  Icons.calendar_month_outlined,
                  size: 32,
                  color: _green,
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Agenda Liburku',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: _ink,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Jadwal libur & rencana perjalanan',
                style: TextStyle(fontSize: 14, color: _muted),
              ),
              const SizedBox(height: 28),
              const _AnimatedOrbitLoader(key: ValueKey('agenda-splash-loader')),
            ],
          ),
        ),
      ),
    );
  }
}

class _AnimatedOrbitLoader extends StatefulWidget {
  const _AnimatedOrbitLoader({super.key});

  @override
  State<_AnimatedOrbitLoader> createState() => _AnimatedOrbitLoaderState();
}

class _AnimatedOrbitLoaderState extends State<_AnimatedOrbitLoader>
    with SingleTickerProviderStateMixin {
  static const _size = 65.0;
  static const _inset = 35.0;
  static const _duration = Duration(milliseconds: 2500);
  static const _frames = [
    _LoaderInsets(top: 0, right: _inset, bottom: _inset, left: 0),
    _LoaderInsets(top: 0, right: _inset, bottom: 0, left: 0),
    _LoaderInsets(top: _inset, right: _inset, bottom: 0, left: 0),
    _LoaderInsets(top: _inset, right: 0, bottom: 0, left: 0),
    _LoaderInsets(top: _inset, right: 0, bottom: 0, left: _inset),
    _LoaderInsets(top: 0, right: 0, bottom: 0, left: _inset),
    _LoaderInsets(top: 0, right: 0, bottom: _inset, left: _inset),
    _LoaderInsets(top: 0, right: 0, bottom: _inset, left: 0),
    _LoaderInsets(top: 0, right: _inset, bottom: _inset, left: 0),
  ];

  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration)
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  _LoaderInsets _insetsAt(double phase) {
    final normalizedPhase = phase % 1;
    final position = normalizedPhase * (_frames.length - 1);
    final frameIndex = position.floor();
    final progress = Curves.ease.transform(position - frameIndex);
    return _LoaderInsets.lerp(
      _frames[frameIndex],
      _frames[frameIndex + 1],
      progress,
    );
  }

  Widget _animatedOutline(double phaseOffset) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final insets = _insetsAt(_controller.value + phaseOffset);
        return Positioned(
          top: insets.top,
          right: insets.right,
          bottom: insets.bottom,
          left: insets.left,
          child: DecoratedBox(
            decoration: BoxDecoration(
              border: Border.all(color: _SplashScreenState._green, width: 3),
              borderRadius: BorderRadius.circular(50),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'Memuat Agenda Liburku',
      liveRegion: true,
      child: SizedBox(
        width: _size,
        height: _size,
        child: Stack(children: [_animatedOutline(0), _animatedOutline(0.5)]),
      ),
    );
  }
}

class _LoaderInsets {
  final double top;
  final double right;
  final double bottom;
  final double left;

  const _LoaderInsets({
    required this.top,
    required this.right,
    required this.bottom,
    required this.left,
  });

  static _LoaderInsets lerp(
    _LoaderInsets begin,
    _LoaderInsets end,
    double progress,
  ) {
    return _LoaderInsets(
      top: begin.top + (end.top - begin.top) * progress,
      right: begin.right + (end.right - begin.right) * progress,
      bottom: begin.bottom + (end.bottom - begin.bottom) * progress,
      left: begin.left + (end.left - begin.left) * progress,
    );
  }
}
