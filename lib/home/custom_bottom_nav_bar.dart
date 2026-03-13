import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';
import 'home_screen.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final UserRole role;

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.role = UserRole.passenger,
  });

  List<({String svg, String label})> get _items {
    if (role == UserRole.rider) {
      return [
        (svg: 'assets/icons/home.svg', label: 'Home'),
        (svg: 'assets/icons/earnings.svg', label: 'Earnings'),
      ];
    }
    return [
      (svg: 'assets/icons/home.svg', label: 'Home'),
      (svg: 'assets/icons/map.svg', label: 'Map'),
      (svg: 'assets/icons/ride.svg', label: 'Rides'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final items = _items;

    return Padding(
      padding: EdgeInsets.only(left: 28, right: 28, bottom: bottomPad + 18),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(40),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppTheme.navy.withOpacity(0.93),
                  const Color(0xFF03364A).withOpacity(0.96),
                ],
              ),
              borderRadius: BorderRadius.circular(40),
              border: Border.all(
                color: Colors.white.withOpacity(0.10),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.navy.withOpacity(0.42),
                  blurRadius: 32,
                  spreadRadius: -2,
                  offset: const Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(
                items.length,
                (i) => Expanded(
                  child: _NavItem(
                    svgAsset: items[i].svg,
                    isActive: currentIndex == i,
                    onTap: () {
                      HapticFeedback.selectionClick();
                      onTap(i);
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final String svgAsset;
  final bool isActive;
  final VoidCallback onTap;
  const _NavItem({
    required this.svgAsset,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    behavior: HitTestBehavior.opaque,
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: isActive ? AppTheme.yellow : Colors.transparent,
        borderRadius: BorderRadius.circular(28),
        boxShadow: isActive
            ? [
                BoxShadow(
                  color: AppTheme.yellow.withOpacity(0.38),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ]
            : [],
      ),
      child: AnimatedScale(
        scale: isActive ? 1.10 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutBack,
        child: SvgPicture.asset(
          svgAsset,
          width: 22,
          height: 22,
          colorFilter: ColorFilter.mode(
            isActive ? AppTheme.navy : Colors.white.withOpacity(0.50),
            BlendMode.srcIn,
          ),
        ),
      ),
    ),
  );
}
