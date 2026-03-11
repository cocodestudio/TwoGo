import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_theme.dart';

class ProfileSidebar extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onClose;

  const ProfileSidebar({
    super.key,
    required this.controller,
    required this.onClose,
  });

  // Grouped menu items for a cleaner, premium look
  static const _accountItems = [
    (
      icon: Icons.person_outline_rounded,
      label: 'My Profile',
      sub: 'View & edit info',
    ),
    (icon: Icons.history_rounded, label: 'Ride History', sub: 'Past trips'),
    (
      icon: Icons.bookmark_border_rounded,
      label: 'Saved Places',
      sub: 'Home, University…',
    ),
  ];

  static const _safetyItems = [
    (
      icon: Icons.shield_outlined,
      label: 'Safety Center',
      sub: 'SOS & contacts',
    ),
    (icon: Icons.payments_outlined, label: 'Payments', sub: 'UPI, wallet'),
  ];

  static const _supportItems = [
    (
      icon: Icons.notifications_none_rounded,
      label: 'Notifications',
      sub: 'Alerts & updates',
    ),
    (
      icon: Icons.help_outline_rounded,
      label: 'Help & Support',
      sub: 'FAQs, contact us',
    ),
    (icon: Icons.settings_outlined, label: 'Settings', sub: 'App preferences'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final slideAnim = Tween<Offset>(
      begin: const Offset(-1, 0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    final scrimAnim = Tween<double>(
      begin: 0.0,
      end: 0.55,
    ).animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

    return Stack(
      children: [
        // ── Scrim ────────────────────────────────────────
        FadeTransition(
          opacity: scrimAnim,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              onClose();
            },
            child: Container(color: Colors.black),
          ),
        ),

        // ── Sidebar panel (Fully Rounded & Glassy) ─────────
        SlideTransition(
          position: slideAnim,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              // The magic: Top and bottom right corners rounded
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: size.width * 0.82, // Slightly wider for elegance
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(
                      0xFF011E2A,
                    ).withOpacity(0.95), // Slight transparency for glass effect
                    border: Border(
                      right: BorderSide(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                  ),
                  child: SafeArea(
                    child: Column(
                      children: [
                        // ── TOP: Profile card ──
                        _buildProfileCard(context),

                        const SizedBox(height: 12),

                        // ── BOTTOM: Menu section (Grouped) ──
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const BouncingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildSectionHeader("ACCOUNT"),
                                  _buildMenuSection(_accountItems, 0),

                                  const SizedBox(height: 16),
                                  _buildSectionHeader("SAFETY & PAYMENTS"),
                                  _buildMenuSection(_safetyItems, 3),

                                  const SizedBox(height: 16),
                                  _buildSectionHeader("MORE"),
                                  _buildMenuSection(_supportItems, 5),

                                  const SizedBox(height: 24),
                                  _buildLogoutButton(),
                                  const SizedBox(height: 24),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ── Profile header card ───────────────────────────────────
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF022B3A), Color(0xFF03455E)],
        ),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Close button + avatar row
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar with glow
              Stack(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          AppTheme.yellow.withOpacity(0.22),
                          AppTheme.yellow.withOpacity(0.04),
                        ],
                      ),
                      border: Border.all(
                        color: AppTheme.yellow.withOpacity(0.55),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.yellow.withOpacity(0.18),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white70,
                      size: 28,
                    ),
                  ),
                  Positioned(
                    bottom: 2,
                    right: 2,
                    child: Container(
                      width: 14,
                      height: 14,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43E97B),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: const Color(0xFF022B3A),
                          width: 2.5,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: const Color(0xFF43E97B).withOpacity(0.5),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Abuzar Khan',
                      style: AppTheme.playfair(
                        size: 17,
                        color: Colors.white,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: AppTheme.yellow.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.verified_rounded,
                            size: 10,
                            color: AppTheme.yellow,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Verified Student',
                            style: AppTheme.inter(
                              size: 10.5,
                              color: AppTheme.yellow,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Close btn
              GestureDetector(
                onTap: onClose,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 22),

          // Stats row
          Row(
            children: [
              _statCell(value: '24', label: 'Rides'),
              _dividerLine(),
              _statCell(value: '4.8 ★', label: 'Rating'),
              _dividerLine(),
              _statCell(value: '₹380', label: 'Saved'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statCell({required String value, required String label}) {
    return Expanded(
      child: Column(
        children: [
          Text(
            value,
            style: AppTheme.inter(
              size: 16,
              color: AppTheme.yellow,
              weight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: AppTheme.inter(
              size: 11,
              color: Colors.white60,
              weight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _dividerLine() {
    return Container(
      width: 1,
      height: 24,
      color: Colors.white.withOpacity(0.15),
    );
  }

  // ── Section Header ────────────────────────────────────────
  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 8, top: 8),
      child: Text(
        title,
        style: AppTheme.inter(
          size: 11,
          color: Colors.white38,
          weight: FontWeight.w700,
        ).copyWith(letterSpacing: 1.2),
      ),
    );
  }

  // ── Grouped Menu Section ──────────────────────────────────
  Widget _buildMenuSection(
    List<({IconData icon, String label, String sub})> items,
    int startIndex,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.03),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
      ),
      child: Column(
        children: List.generate(items.length, (i) {
          final isLast = i == items.length - 1;
          return Column(
            children: [
              _SidebarMenuItem(
                icon: items[i].icon,
                label: items[i].label,
                sub: items[i].sub,
                delay: Duration(milliseconds: 38 * (startIndex + i)),
                controller: controller,
              ),
              if (!isLast)
                Padding(
                  padding: const EdgeInsets.only(left: 60, right: 16),
                  child: Divider(
                    color: Colors.white.withOpacity(0.05),
                    height: 1,
                  ),
                ),
            ],
          );
        }),
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => HapticFeedback.mediumImpact(),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 4),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.08),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.red.withOpacity(0.2), width: 1),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              size: 18,
              color: Colors.redAccent.withOpacity(0.9),
            ),
            const SizedBox(width: 8),
            Text(
              'Log Out',
              style: AppTheme.inter(
                size: 14,
                color: Colors.redAccent,
                weight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Animated menu item ────────────────────────────────────────
class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String sub;
  final Duration delay;
  final AnimationController controller;

  const _SidebarMenuItem({
    required this.icon,
    required this.label,
    required this.sub,
    required this.delay,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final t = (delay.inMilliseconds / 480).clamp(0.0, 0.75);
    final slideAnim =
        Tween<Offset>(begin: const Offset(-0.25, 0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: controller,
            curve: Interval(t, 1.0, curve: Curves.easeOutCubic),
          ),
        );
    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: controller,
        curve: Interval(t, 1.0, curve: Curves.easeOut),
      ),
    );

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => HapticFeedback.selectionClick(),
            borderRadius: BorderRadius.circular(24),
            splashColor: const Color(0xFFF7B32B).withOpacity(0.07),
            highlightColor: const Color(0xFFF7B32B).withOpacity(0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white.withOpacity(0.08),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      icon,
                      size: 18,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          label,
                          style: AppTheme.inter(
                            size: 14,
                            color: Colors.white,
                            weight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          sub,
                          style: AppTheme.inter(
                            size: 11,
                            color: Colors.white54,
                            weight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right_rounded,
                    size: 18,
                    color: Colors.white.withOpacity(0.2),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
