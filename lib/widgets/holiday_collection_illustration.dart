// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class HolidayCollectionIllustration extends StatelessWidget {
  const HolidayCollectionIllustration({super.key, this.size = 132});

  final double size;

  static const _mint = Color(0xFF3A665C);
  static const _paleMint = Color(0xFFBCEDE0);
  static const _cream = Color(0xFFFFEEB3);
  static const _coral = Color(0xFFFFB59E);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: size * 0.78,
            height: size * 0.78,
            decoration: const BoxDecoration(
              color: Color(0xFFD8FFF0),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            top: size * 0.09,
            left: size * 0.13,
            child: Transform.rotate(
              angle: -0.15,
              child: Container(
                width: size * 0.38,
                height: size * 0.48,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(size * 0.1),
                  border: Border.all(color: _paleMint, width: 2),
                ),
                child: Icon(
                  Icons.event_note_rounded,
                  color: _coral,
                  size: size * 0.22,
                ),
              ),
            ),
          ),
          Positioned(
            right: size * 0.12,
            top: size * 0.3,
            child: Icon(
              Icons.explore_rounded,
              color: _cream,
              size: size * 0.26,
            ),
          ),
          Positioned(
            bottom: size * 0.1,
            left: size * 0.32,
            child: Container(
              width: size * 0.42,
              height: size * 0.44,
              decoration: BoxDecoration(
                color: _paleMint,
                borderRadius: BorderRadius.circular(size * 0.12),
                border: Border.all(color: _mint, width: 3),
              ),
              child: Icon(
                Icons.luggage_rounded,
                color: _mint,
                size: size * 0.3,
              ),
            ),
          ),
          Positioned(
            right: size * 0.16,
            bottom: size * 0.17,
            child: Icon(
              Icons.auto_awesome_rounded,
              color: _mint,
              size: size * 0.13,
            ),
          ),
        ],
      ),
    );
  }
}
