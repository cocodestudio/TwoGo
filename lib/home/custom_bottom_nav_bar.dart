import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../theme/app_theme.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  static const _svgs = [
    'assets/icons/home.svg',
    'assets/icons/map.svg',
    'assets/icons/ride.svg',
  ];

  const CustomBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;

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
                _svgs.length,
                (i) => Expanded(
                  child: _NavItem(
                    svgString: _svgs[i],
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
  final String svgString;
  final bool isActive;
  final VoidCallback onTap;

  const _NavItem({
    required this.svgString,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 320),
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
            svgString,
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
}
