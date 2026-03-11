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

  static const _menuItems = [
    (icon: Icons.person_outline_rounded,      label: 'My Profile',     sub: 'View & edit info'),
    (icon: Icons.history_rounded,             label: 'Ride History',   sub: 'Past trips'),
    (icon: Icons.bookmark_border_rounded,     label: 'Saved Places',   sub: 'Home, University…'),
    (icon: Icons.notifications_none_rounded,  label: 'Notifications',  sub: 'Alerts & updates'),
    (icon: Icons.shield_outlined,             label: 'Safety Center',  sub: 'SOS & contacts'),
    (icon: Icons.payments_outlined,           label: 'Payments',       sub: 'UPI, wallet'),
    (icon: Icons.help_outline_rounded,        label: 'Help & Support', sub: 'FAQs, contact us'),
    (icon: Icons.settings_outlined,           label: 'Settings',       sub: 'App preferences'),
  ];

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    final slideAnim = Tween<Offset>(begin: const Offset(-1, 0), end: Offset.zero)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOutCubic));
    final scrimAnim = Tween<double>(begin: 0.0, end: 0.55)
        .animate(CurvedAnimation(parent: controller, curve: Curves.easeOut));

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

        // ── Sidebar panel ─────────────────────────────────
        SlideTransition(
          position: slideAnim,
          child: Align(
            alignment: Alignment.centerLeft,
            child: Container(
              width: size.width * 0.80,
              height: double.infinity,
              color: const Color(0xFF011E2A),
              child: SafeArea(
                child: Column(
                  children: [
                    // ── TOP: Profile card (visually distinct) ──
                    _buildProfileCard(context),

                    const SizedBox(height: 8),

                    // ── BOTTOM: Menu section ───────────────────
                    Expanded(
                      child: Container(
                        margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.04),
                          borderRadius: BorderRadius.circular(28),
                          border: Border.all(
                            color: Colors.white.withOpacity(0.06),
                            width: 1,
                          ),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(28),
                          child: Column(
                            children: [
                              Expanded(child: _buildMenuList()),
                              _buildLogoutButton(),
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
      ],
    );
  }

  // ── Profile header card ───────────────────────────────────
  Widget _buildProfileCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 16, 12, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF022B3A),
            const Color(0xFF03455E),
          ],
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
                      gradient: RadialGradient(colors: [
                        AppTheme.yellow.withOpacity(0.22),
                        AppTheme.yellow.withOpacity(0.04),
                      ]),
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
                    child: const Icon(Icons.person, color: Colors.white70, size: 28),
                  ),
                  Positioned(
                    bottom: 2, right: 2,
                    child: Container(
                      width: 13, height: 13,
                      decoration: BoxDecoration(
                        color: const Color(0xFF43E97B),
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFF022B3A), width: 2),
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
                    Text('Abuzar Khan',
                        style: AppTheme.playfair(
                            size: 17, color: Colors.white, weight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.yellow.withOpacity(0.14),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AppTheme.yellow.withOpacity(0.35), width: 1),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.verified_rounded,
                              size: 10, color: AppTheme.yellow),
                          const SizedBox(width: 4),
                          Text('Verified Student',
                              style: AppTheme.inter(
                                  size: 10.5,
                                  color: AppTheme.yellow,
                                  weight: FontWeight.w700)),
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
                  width: 30, height: 30,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.close_rounded,
                      size: 16, color: Colors.white.withOpacity(0.55)),
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Stats row
          Row(
            children: [
              _statCell(value: '24',    label: 'Rides'),
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
          Text(value,
              style: AppTheme.inter(
                  size: 15, color: AppTheme.yellow, weight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(label,
              style: AppTheme.inter(size: 10.5, color: Colors.white38)),
        ],
      ),
    );
  }

  Widget _dividerLine() {
    return Container(width: 1, height: 28, color: Colors.white.withOpacity(0.10));
  }

  // ── Menu list ─────────────────────────────────────────────
  Widget _buildMenuList() {
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
      physics: const BouncingScrollPhysics(),
      itemCount: _menuItems.length,
      itemBuilder: (context, i) => _SidebarMenuItem(
        icon: _menuItems[i].icon,
        label: _menuItems[i].label,
        sub: _menuItems[i].sub,
        delay: Duration(milliseconds: 38 * i),
        controller: controller,
      ),
    );
  }

  // ── Logout ────────────────────────────────────────────────
  Widget _buildLogoutButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 14),
      child: GestureDetector(
        onTap: () => HapticFeedback.mediumImpact(),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            color: Colors.red.withOpacity(0.07),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.red.withOpacity(0.18), width: 1),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.logout_rounded,
                  size: 17, color: Colors.redAccent.withOpacity(0.85)),
              const SizedBox(width: 8),
              Text('Log Out',
                  style: AppTheme.inter(
                      size: 13.5, color: Colors.redAccent, weight: FontWeight.w600)),
            ],
          ),
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
    final slideAnim = Tween<Offset>(begin: const Offset(-0.25, 0), end: Offset.zero)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Interval(t, 1.0, curve: Curves.easeOutCubic),
    ));
    final fadeAnim = Tween<double>(begin: 0.0, end: 1.0)
        .animate(CurvedAnimation(
      parent: controller,
      curve: Interval(t, 1.0, curve: Curves.easeOut),
    ));

    return SlideTransition(
      position: slideAnim,
      child: FadeTransition(
        opacity: fadeAnim,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: () => HapticFeedback.selectionClick(),
            borderRadius: BorderRadius.circular(16),
            splashColor: AppTheme.yellow.withOpacity(0.07),
            highlightColor: AppTheme.yellow.withOpacity(0.04),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
              child: Row(
                children: [
                  // Icon container
                  Container(
                    width: 38, height: 38,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.06),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.07), width: 1),
                    ),
                    child: Icon(icon, size: 18,
                        color: Colors.white.withOpacity(0.72)),
                  ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label,
                            style: AppTheme.inter(
                                size: 13.5,
                                color: Colors.white,
                                weight: FontWeight.w600)),
                        const SizedBox(height: 1),
                        Text(sub,
                            style: AppTheme.inter(
                                size: 11, color: Colors.white30)),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right_rounded,
                      size: 16, color: Colors.white.withOpacity(0.18)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}