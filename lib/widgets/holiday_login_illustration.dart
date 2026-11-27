import 'dart:math' as math;

// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class HolidayLoginIllustration extends StatelessWidget {
  const HolidayLoginIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return const SizedBox(
      width: 176,
      height: 144,
      child: CustomPaint(painter: _HolidayIllustrationPainter()),
    );
  }
}

class _HolidayIllustrationPainter extends CustomPainter {
  const _HolidayIllustrationPainter();

  static const _mint = Color(0xFFB4E4D6);
  static const _mintLine = Color(0xFF87CDBB);
  static const _green = Color(0xFF3A665C);
  static const _olive = Color(0xFF6A5E30);
  static const _cream = Color(0xFFFFEEB3);
  static const _coral = Color(0xFFFF9E80);
  static const _rust = Color(0xFF944930);
  static const _red = Color(0xFFBA1A1A);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.save();
    canvas.scale(size.width / 200, size.height / 160);
    _drawDecorations(canvas);
    _drawKetupat(canvas);
    _drawSuitcase(canvas);
    _drawCalendar(canvas);
    _drawRibbon(canvas);
    canvas.restore();
  }

  void _drawDecorations(Canvas canvas) {
    canvas.drawCircle(
      const Offset(28, 38),
      4,
      Paint()..color = _olive.withValues(alpha: 0.6),
    );
    canvas.drawCircle(
      const Offset(178, 80),
      3,
      Paint()..color = _green.withValues(alpha: 0.7),
    );
    _drawStar(canvas, const Offset(165, 35), 11, _rust.withValues(alpha: 0.8));
  }

  void _drawKetupat(Canvas canvas) {
    canvas.save();
    canvas.translate(35, 86);
    canvas.rotate(-15 * math.pi / 180);
    final shape = Path()
      ..moveTo(11, 0)
      ..lineTo(22, 11)
      ..lineTo(11, 22)
      ..lineTo(0, 11)
      ..close();
    canvas.drawPath(shape, Paint()..color = const Color(0xFFBCEDDE));
    final linePaint = Paint()
      ..color = _green
      ..strokeWidth = 1.8
      ..strokeCap = StrokeCap.round;
    canvas.drawLine(const Offset(11, 1), const Offset(11, 21), linePaint);
    canvas.drawLine(const Offset(1, 11), const Offset(21, 11), linePaint);
    canvas.drawPath(
      Path()
        ..moveTo(11, 21)
        ..quadraticBezierTo(13, 31, 8, 37),
      Paint()
        ..color = _green
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..strokeCap = StrokeCap.round,
    );
    canvas.restore();
  }

  void _drawSuitcase(Canvas canvas) {
    final handle = Paint()
      ..color = _olive
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(114, 54, 20, 14),
        const Radius.circular(4),
      ),
      handle,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(92, 64, 64, 74),
        const Radius.circular(14),
      ),
      Paint()..color = _mint,
    );
    final ribPaint = Paint()
      ..color = _mintLine
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    for (final x in [108.0, 124.0, 140.0]) {
      canvas.drawLine(Offset(x, 74), Offset(x, 128), ribPaint);
    }
    canvas.drawCircle(const Offset(140, 88), 9, Paint()..color = _coral);
    _drawStar(canvas, const Offset(140, 88), 6, Colors.white);

    for (final x in [102.0, 136.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 136, 10, 6),
          const Radius.circular(3),
        ),
        Paint()..color = _green,
      );
    }
  }

  void _drawCalendar(Canvas canvas) {
    canvas.save();
    canvas.translate(48, 48);
    canvas.rotate(-8 * math.pi / 180);
    final card = RRect.fromRectAndRadius(
      const Rect.fromLTWH(0, 0, 56, 64),
      const Radius.circular(12),
    );
    final cardPath = Path()..addRRect(card);
    canvas.drawShadow(cardPath, Colors.black.withValues(alpha: 0.12), 2, true);
    canvas.drawRRect(card, Paint()..color = Colors.white);

    canvas.save();
    canvas.clipRRect(card);
    canvas.drawRect(const Rect.fromLTWH(0, 0, 56, 18), Paint()..color = _cream);
    canvas.restore();

    for (final x in [16.0, 40.0]) {
      canvas.drawCircle(Offset(x, 9), 2.5, Paint()..color = _olive);
    }
    final gridPaint = Paint()..color = const Color(0xFFC2F2E0);
    for (final x in [10.0, 22.0, 34.0]) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, 26, 6, 4),
          const Radius.circular(1),
        ),
        gridPaint,
      );
    }
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        const Rect.fromLTWH(20, 36, 18, 18),
        const Radius.circular(6),
      ),
      Paint()..color = const Color(0xFFFFEAE4),
    );
    _drawText(canvas, '17', const Offset(22, 34));
    _drawStar(canvas, const Offset(44, 42), 4, _rust);
    canvas.restore();
  }

  void _drawRibbon(Canvas canvas) {
    canvas.drawPath(
      Path()
        ..moveTo(125, 32)
        ..quadraticBezierTo(145, 15, 155, 35)
        ..quadraticBezierTo(165, 55, 180, 40),
      Paint()
        ..color = _coral
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..strokeCap = StrokeCap.round,
    );
  }

  void _drawStar(Canvas canvas, Offset center, double radius, Color color) {
    final points = <Offset>[];
    for (var i = 0; i < 10; i++) {
      final angle = -math.pi / 2 + i * math.pi / 5;
      final pointRadius = i.isEven ? radius : radius * 0.42;
      points.add(
        center +
            Offset(
              math.cos(angle) * pointRadius,
              math.sin(angle) * pointRadius,
            ),
      );
    }
    final star = Path()..moveTo(points.first.dx, points.first.dy);
    for (final point in points.skip(1)) {
      star.lineTo(point.dx, point.dy);
    }
    star.close();
    canvas.drawPath(star, Paint()..color = color);
  }

  void _drawText(Canvas canvas, String text, Offset offset) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: const TextStyle(
          color: _red,
          fontSize: 11,
          fontWeight: FontWeight.w800,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant _HolidayIllustrationPainter oldDelegate) =>
      false;
}
