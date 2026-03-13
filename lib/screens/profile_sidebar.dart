import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import '../theme/app_theme.dart';
import '../utils/api_config.dart';
import 'package:http/http.dart' as http;

import 'login_screen.dart';

class ProfileSidebar extends StatelessWidget {
  final AnimationController controller;
  final VoidCallback onClose;
  final UserRole role;

  const ProfileSidebar({
    super.key,
    required this.controller,
    required this.onClose,
    this.role = UserRole.passenger,
  });

  static const _paxAccount = [
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
  static const _paxSafety = [
    (
      icon: Icons.shield_outlined,
      label: 'Safety Center',
      sub: 'SOS & contacts',
    ),
    (icon: Icons.payments_outlined, label: 'Payments', sub: 'UPI, wallet'),
  ];
  static const _paxSupport = [
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

  // RIDER: no Saved Places
  static const _riderAccount = [
    (
      icon: Icons.person_outline_rounded,
      label: 'My Profile',
      sub: 'View & edit info',
    ),
    (
      icon: Icons.history_rounded,
      label: 'Ride History',
      sub: 'Completed rides',
    ),
    (
      icon: Icons.two_wheeler_rounded,
      label: 'Vehicle Info',
      sub: 'Bike details & RC',
    ),
  ];
  static const _riderSafety = [
    (
      icon: Icons.shield_outlined,
      label: 'Safety Center',
      sub: 'SOS & emergency',
    ),
    (
      icon: Icons.payments_outlined,
      label: 'Earnings & UPI',
      sub: 'Withdrawal settings',
    ),
  ];
  static const _riderSupport = [
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

  // ADMIN: admin-specific items
  static const _adminAccount = [
    (
      icon: Icons.person_outline_rounded,
      label: 'Admin Profile',
      sub: 'View & edit info',
    ),
    (
      icon: Icons.people_outline_rounded,
      label: 'Manage Users',
      sub: 'All students & riders',
    ),
    (
      icon: Icons.verified_user_outlined,
      label: 'Approvals',
      sub: 'Pending verifications',
    ),
  ];
  static const _adminTools = [
    (
      icon: Icons.analytics_outlined,
      label: 'Reports',
      sub: 'Revenue & usage data',
    ),
    (
      icon: Icons.campaign_outlined,
      label: 'Broadcast',
      sub: 'Send notifications',
    ),
    (
      icon: Icons.price_change_outlined,
      label: 'Pricing',
      sub: 'Surge & base pricing',
    ),
  ];
  static const _adminSupport = [
    (icon: Icons.report_outlined, label: 'Disputes', sub: 'Passenger vs rider'),
    (
      icon: Icons.settings_outlined,
      label: 'Settings',
      sub: 'App-wide settings',
    ),
  ];

  Future<void> _performLogout(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');

      if (token != null) {
        http.post(
          Uri.parse(ApiConfig.logout),
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
            'Authorization': 'Bearer $token',
          },
        );
      }

      await prefs.clear();

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    } catch (e) {
      debugPrint("Logout Error: $e");
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      if (!context.mounted) return;
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
        (route) => false,
      );
    }
  }

  void _showLogoutDialog(BuildContext context) {
    HapticFeedback.heavyImpact();
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (context, anim1, anim2) => Container(),
      transitionBuilder: (context, anim1, anim2, child) {
        return Transform.scale(
          scale: anim1.value,
          child: Opacity(
            opacity: anim1.value,
            child: AlertDialog(
              backgroundColor: const Color(0xFF022B3A).withOpacity(0.95),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
                side: BorderSide(
                  color: Colors.white.withOpacity(0.1),
                  width: 1,
                ),
              ),
              title: Text(
                "Log Out?",
                style: AppTheme.playfair(
                  size: 20,
                  color: Colors.white,
                  weight: FontWeight.w700,
                ),
                textAlign: TextAlign.center,
              ),
              content: Text(
                "Are you sure you want to exit? You'll need to login again to book or offer rides.",
                style: AppTheme.inter(size: 13, color: Colors.white70),
                textAlign: TextAlign.center,
              ),
              actionsAlignment: MainAxisAlignment.spaceEvenly,
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(
                    "Cancel",
                    style: AppTheme.inter(size: 14, color: Colors.white54),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Dialog band karo
                    _performLogout(context); // Logout start karo
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                  ),
                  child: Text(
                    "Logout",
                    style: AppTheme.inter(
                      size: 14,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

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
        // Scrim
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

        // Panel
        SlideTransition(
          position: slideAnim,
          child: Align(
            alignment: Alignment.centerLeft,
            child: ClipRRect(
              borderRadius: const BorderRadius.only(
                topRight: Radius.circular(36),
                bottomRight: Radius.circular(36),
              ),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: Container(
                  width: size.width * 0.82,
                  height: double.infinity,
                  decoration: BoxDecoration(
                    color: const Color(0xFF011E2A).withOpacity(0.95),
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
                        _buildProfileCard(context),
                        const SizedBox(height: 12),
                        Expanded(
                          child: SingleChildScrollView(
                            physics: const ClampingScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: _buildMenuByRole(context),
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

  Widget _buildMenuByRole(BuildContext context) {
    if (role == UserRole.rider) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('ACCOUNT'),
          _menuSection(_riderAccount, 0),
          const SizedBox(height: 16),
          _sectionHeader('EARNINGS & SAFETY'),
          _menuSection(_riderSafety, 3),
          const SizedBox(height: 16),
          _sectionHeader('MORE'),
          _menuSection(_riderSupport, 5),
          const SizedBox(height: 24),
          _logoutButton(context),
          const SizedBox(height: 24),
        ],
      );
    }

    if (role == UserRole.admin) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _sectionHeader('ADMIN'),
          _menuSection(_adminAccount, 0),
          const SizedBox(height: 16),
          _sectionHeader('TOOLS'),
          _menuSection(_adminTools, 3),
          const SizedBox(height: 16),
          _sectionHeader('SYSTEM'),
          _menuSection(_adminSupport, 6),
          const SizedBox(height: 24),
          _logoutButton(context),
          const SizedBox(height: 24),
        ],
      );
    }

    // passenger (default)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionHeader('ACCOUNT'),
        _menuSection(_paxAccount, 0),
        const SizedBox(height: 16),
        _sectionHeader('SAFETY & PAYMENTS'),
        _menuSection(_paxSafety, 3),
        const SizedBox(height: 16),
        _sectionHeader('MORE'),
        _menuSection(_paxSupport, 5),
        const SizedBox(height: 24),
        _logoutButton(context),
        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildProfileCard(BuildContext context) {
    final roleLabel = role == UserRole.admin
        ? 'Admin'
        : role == UserRole.rider
        ? 'Rider'
        : 'Passenger';
    final roleColor = role == UserRole.admin
        ? const Color(0xFF64B5F6)
        : role == UserRole.rider
        ? const Color(0xFF4CAF50)
        : AppTheme.yellow;

    // Stats differ by role
    final stats = role == UserRole.admin
        ? [('142', 'Users'), ('38', 'Riders'), ('₹9.2k', 'Revenue')]
        : role == UserRole.rider
        ? [('28', 'Rides'), ('4.8 ★', 'Rating'), ('₹720', 'Earned')]
        : [('24', 'Rides'), ('4.8 ★', 'Rating'), ('₹380', 'Saved')];

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
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Avatar
              Stack(
                children: [
                  Container(
                    width: 62,
                    height: 62,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          roleColor.withOpacity(0.22),
                          roleColor.withOpacity(0.04),
                        ],
                      ),
                      border: Border.all(
                        color: roleColor.withOpacity(0.55),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: roleColor.withOpacity(0.18),
                          blurRadius: 16,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    child: Icon(
                      role == UserRole.admin
                          ? Icons.admin_panel_settings_rounded
                          : Icons.person,
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
                      'Moh Abuzar',
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
                        color: roleColor.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: roleColor.withOpacity(0.35),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            role == UserRole.admin
                                ? Icons.admin_panel_settings_rounded
                                : Icons.verified_rounded,
                            size: 10,
                            color: roleColor,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            roleLabel,
                            style: AppTheme.inter(
                              size: 10.5,
                              color: roleColor,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              // Close
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
            children: stats.asMap().entries.expand((e) {
              final widgets = <Widget>[
                _StatCell(
                  value: e.value.$1,
                  label: e.value.$2,
                  color: roleColor,
                ),
              ];
              if (e.key < stats.length - 1) {
                widgets.add(
                  Container(
                    width: 1,
                    height: 24,
                    color: Colors.white.withOpacity(0.15),
                  ),
                );
              }
              return widgets;
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _sectionHeader(String title) => Padding(
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

  Widget _menuSection(
    List<({IconData icon, String label, String sub})> items,
    int startIdx,
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
                delay: Duration(milliseconds: 38 * (startIdx + i)),
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

  Widget _logoutButton(BuildContext context) => GestureDetector(
    onTap: () => _showLogoutDialog(context),
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

class _StatCell extends StatelessWidget {
  final String value, label;
  final Color color;
  const _StatCell({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value,
          style: AppTheme.inter(
            size: 16,
            color: color,
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

class _SidebarMenuItem extends StatelessWidget {
  final IconData icon;
  final String label, sub;
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
            splashColor: AppTheme.yellow.withOpacity(0.07),
            highlightColor: AppTheme.yellow.withOpacity(0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
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
