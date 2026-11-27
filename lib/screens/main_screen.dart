// ignore: deprecated_member_use
import 'package:flutter/material.dart';

import 'collection_screen.dart';
import 'explore_screen.dart';
import 'profile_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          ExploreScreen(onProfileTap: () => setState(() => _index = 2)),
          const CollectionScreen(),
          const ProfileScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Color(0xFFFCFFFD),
          border: Border(top: BorderSide(color: Color(0xFFD8F4EA), width: 1)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 72,
            child: Row(
              children: [
                _buildNavItem(
                  0,
                  Icons.calendar_today_outlined,
                  Icons.calendar_today,
                  'Jadwal',
                ),
                _buildNavItem(
                  1,
                  Icons.bookmark_border,
                  Icons.bookmark,
                  'Koleksi',
                ),
                _buildNavItem(2, Icons.person_outline, Icons.person, 'Profil'),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(
    int index,
    IconData icon,
    IconData activeIcon,
    String label,
  ) {
    final isSelected = _index == index;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => _index = index),
        borderRadius: BorderRadius.circular(32),
        child: Center(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            width: isSelected ? 88 : 72,
            height: 58,
            decoration: BoxDecoration(
              color: isSelected ? const Color(0xFFBCEDDE) : Colors.transparent,
              borderRadius: BorderRadius.circular(32),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? activeIcon : icon,
                  color: isSelected
                      ? const Color(0xFF3A665C)
                      : const Color(0xFF51461B),
                  size: 22,
                ),
                const SizedBox(height: 2),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: isSelected
                        ? const Color(0xFF3A665C)
                        : const Color(0xFF51461B),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
