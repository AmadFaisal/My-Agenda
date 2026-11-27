// ignore: deprecated_member_use
import 'package:flutter/material.dart';

class HolidayRegisterIllustration extends StatelessWidget {
  const HolidayRegisterIllustration({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 112,
      height: 112,
      child: Stack(
        alignment: Alignment.center,
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEB3).withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
          ),
          Positioned(
            left: 0,
            top: 0,
            child: Transform.rotate(
              angle: -0.1,
              child: Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: const Color(0xFFFFDBD0),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14002018),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_activity_outlined,
                  color: Color(0xFF3A0B00),
                  size: 22,
                ),
              ),
            ),
          ),
          Positioned(
            right: -2,
            bottom: 1,
            child: Transform.rotate(
              angle: 0.2,
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFFA1D0C3),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: const [
                    BoxShadow(
                      color: Color(0x14002018),
                      blurRadius: 4,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: Color(0xFF002018),
                  size: 26,
                ),
              ),
            ),
          ),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(18),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x20002018),
                  blurRadius: 8,
                  offset: Offset(0, 3),
                ),
              ],
            ),
            child: const Icon(
              Icons.calendar_month,
              color: Color(0xFF6A5E30),
              size: 34,
            ),
          ),
        ],
      ),
    );
  }
}
