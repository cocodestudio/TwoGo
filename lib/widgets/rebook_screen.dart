import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class RebookScreen extends StatefulWidget {
  final Map<String, dynamic> ride;
  const RebookScreen({super.key, required this.ride});

  @override
  State<RebookScreen> createState() => _RebookScreenState();
}

class _RebookScreenState extends State<RebookScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  String _selectedTime = 'Now';
  int _selectedRideType = 0;
  bool _searching = false;
  bool _found = false;

  final _times = ['Now', 'In 15 min', 'In 30 min', 'Schedule'];
  final _rideTypes = [
    (icon: Icons.two_wheeler_rounded, label: 'Pillion', price: '₹15'),
    (icon: Icons.electric_scooter_rounded, label: 'Scooter', price: '₹25'),
    (icon: Icons.bolt_rounded, label: 'Express', price: '₹40'),
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    )..forward();
    final type = widget.ride['type'] ?? 'Scooter';
    _selectedRideType = _rideTypes
        .indexWhere((r) => r.label == type)
        .clamp(0, 2);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _confirmBook() async {
    HapticFeedback.mediumImpact();
    setState(() => _searching = true);
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;
    setState(() {
      _searching = false;
      _found = true;
    });
    HapticFeedback.heavyImpact();
  }

  String get _price => _rideTypes[_selectedRideType].price;

  @override
  Widget build(BuildContext context) {
    final mq = MediaQuery.of(context);
    final topPad = mq.padding.top;
    final bottomPad = mq.padding.bottom;
    // Bottom bar height = 54 (btn) + 14 top pad + 14 bottom pad + bottomPad
    final double bottomBarHeight = 54 + 28 + bottomPad;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // ── SCROLLABLE CONTENT ──────────────────────────────
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              SliverToBoxAdapter(child: _TopBar(topPad: topPad)),
              SliverPadding(
                padding: EdgeInsets.fromLTRB(20, 18, 20, bottomBarHeight + 16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _FadeSlide(
                      ctrl: _ctrl,
                      delay: 0.00,
                      child: _RouteCard(ride: widget.ride),
                    ),
                    const SizedBox(height: 14),
                    _FadeSlide(
                      ctrl: _ctrl,
                      delay: 0.11,
                      child: _SectionCard(
                        title: 'When do you want to go?',
                        child: _TimePicker(
                          times: _times,
                          selected: _selectedTime,
                          onSelect: (v) => setState(() => _selectedTime = v),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FadeSlide(
                      ctrl: _ctrl,
                      delay: 0.22,
                      child: _SectionCard(
                        title: 'Choose ride type',
                        child: _RideTypePicker(
                          types: _rideTypes,
                          selected: _selectedRideType,
                          onSelect: (i) =>
                              setState(() => _selectedRideType = i),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _FadeSlide(
                      ctrl: _ctrl,
                      delay: 0.33,
                      child: const _PromoCard(),
                    ),
                    const SizedBox(height: 14),
                    _FadeSlide(
                      ctrl: _ctrl,
                      delay: 0.42,
                      child: const _PaymentCard(),
                    ),
                  ]),
                ),
              ),
            ],
          ),

          // ── FIXED BOTTOM BAR ────────────────────────────────
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: _BottomBar(
              price: _price,
              searching: _searching,
              bottomPad: bottomPad,
              onTap: _searching ? null : _confirmBook,
            ),
          ),

          // ── RIDER FOUND OVERLAY ─────────────────────────────
          if (_found) _RiderFoundOverlay(onClose: () => Navigator.pop(context)),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// TOP BAR
// ════════════════════════════════════════════════════════════════
class _TopBar extends StatelessWidget {
  final double topPad;
  const _TopBar({required this.topPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: AppTheme.navy,
      padding: EdgeInsets.fromLTRB(20, topPad + 14, 20, 22),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.10),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white.withOpacity(0.12)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 19,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Rebook Ride',
                  style: AppTheme.inter(
                    size: 17,
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Quick rebooking',
                  style: AppTheme.inter(size: 12, color: Colors.white38),
                ),
              ],
            ),
          ),
          // Step dots
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.10),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                _StepDot(filled: true),
                const SizedBox(width: 5),
                _StepDot(filled: true),
                const SizedBox(width: 5),
                _StepDot(filled: false),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StepDot extends StatelessWidget {
  final bool filled;
  const _StepDot({required this.filled});
  @override
  Widget build(BuildContext context) => AnimatedContainer(
    duration: const Duration(milliseconds: 200),
    width: filled ? 18 : 7,
    height: 7,
    decoration: BoxDecoration(
      color: filled ? AppTheme.yellow : Colors.white24,
      borderRadius: BorderRadius.circular(4),
    ),
  );
}

// ════════════════════════════════════════════════════════════════
// SECTION CARD WRAPPER
// ════════════════════════════════════════════════════════════════
class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;
  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTheme.inter(
              size: 12.5,
              color: AppTheme.grey,
              weight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// ROUTE CARD
// ════════════════════════════════════════════════════════════════
class _RouteCard extends StatelessWidget {
  final Map<String, dynamic> ride;
  const _RouteCard({required this.ride});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Timeline
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Column(
              children: [
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: AppTheme.navy, width: 2.5),
                  ),
                ),
                Container(
                  width: 2,
                  height: 28,
                  margin: const EdgeInsets.symmetric(vertical: 3),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        AppTheme.navy.withOpacity(0.2),
                        AppTheme.yellow.withOpacity(0.6),
                      ],
                    ),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: AppTheme.yellow,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.yellow.withOpacity(0.45),
                        blurRadius: 6,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Locations
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _locRow('FROM', ride['origin'] ?? 'Shobhit University'),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Divider(
                    color: AppTheme.grey.withOpacity(0.12),
                    height: 1,
                  ),
                ),
                _locRow(
                  'TO',
                  ride['destination'] ?? 'Destination',
                  accent: true,
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Swap
          GestureDetector(
            onTap: () => HapticFeedback.selectionClick(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: AppTheme.navy.withOpacity(0.08)),
              ),
              child: Icon(
                Icons.swap_vert_rounded,
                color: AppTheme.navy,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _locRow(String label, String place, {bool accent = false}) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: AppTheme.inter(
          size: 10,
          color: AppTheme.grey,
          weight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 3),
      Text(
        place,
        style: AppTheme.inter(
          size: 14,
          color: accent ? AppTheme.yellow : AppTheme.navy,
          weight: FontWeight.w700,
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
    ],
  );
}

// ════════════════════════════════════════════════════════════════
// TIME PICKER — LayoutBuilder for responsive pill row
// ════════════════════════════════════════════════════════════════
class _TimePicker extends StatelessWidget {
  final List<String> times;
  final String selected;
  final ValueChanged<String> onSelect;
  const _TimePicker({
    required this.times,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (_, c) {
        return Row(
          children: times.asMap().entries.map((e) {
            final i = e.key;
            final t = e.value;
            final active = selected == t;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  onSelect(t);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOutCubic,
                  margin: EdgeInsets.only(right: i < times.length - 1 ? 8 : 0),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  decoration: BoxDecoration(
                    color: active ? AppTheme.navy : AppTheme.bg,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: active
                          ? AppTheme.navy
                          : Colors.black.withOpacity(0.07),
                    ),
                    boxShadow: active
                        ? [
                            BoxShadow(
                              color: AppTheme.navy.withOpacity(0.22),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : [],
                  ),
                  child: Center(
                    child: Text(
                      t,
                      textAlign: TextAlign.center,
                      style: AppTheme.inter(
                        size: 12,
                        color: active ? Colors.white : AppTheme.grey,
                        weight: active ? FontWeight.w700 : FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ════════════════════════════════════════════════════════════════
// RIDE TYPE PICKER
// ════════════════════════════════════════════════════════════════
class _RideTypePicker extends StatelessWidget {
  final List<({IconData icon, String label, String price})> types;
  final int selected;
  final ValueChanged<int> onSelect;
  const _RideTypePicker({
    required this.types,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: types.asMap().entries.map((e) {
        final i = e.key;
        final type = e.value;
        final active = selected == i;
        return Expanded(
          child: GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              onSelect(i);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              curve: Curves.easeOutCubic,
              margin: EdgeInsets.only(right: i < types.length - 1 ? 10 : 0),
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: active ? AppTheme.navy : AppTheme.bg,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: active
                      ? AppTheme.navy
                      : Colors.black.withOpacity(0.07),
                ),
                boxShadow: active
                    ? [
                        BoxShadow(
                          color: AppTheme.navy.withOpacity(0.26),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : [],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 220),
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: active
                          ? Colors.white.withOpacity(0.10)
                          : Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      type.icon,
                      size: 21,
                      color: active ? AppTheme.yellow : AppTheme.grey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    type.label,
                    style: AppTheme.inter(
                      size: 12.5,
                      color: active ? Colors.white : AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    type.price,
                    style: AppTheme.inter(
                      size: 12,
                      color: active ? AppTheme.yellow : AppTheme.grey,
                      weight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PROMO CARD
// ════════════════════════════════════════════════════════════════
class _PromoCard extends StatelessWidget {
  const _PromoCard();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTheme.yellow.withOpacity(0.13),
              AppTheme.yellow.withOpacity(0.04),
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: AppTheme.yellow.withOpacity(0.28)),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.yellow.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.local_offer_rounded,
                color: AppTheme.yellow,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Apply Promo Code',
                    style: AppTheme.inter(
                      size: 13.5,
                      color: AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Save up to ₹10 on this ride',
                    style: AppTheme.inter(size: 12, color: AppTheme.grey),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: AppTheme.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// PAYMENT CARD
// ════════════════════════════════════════════════════════════════
class _PaymentCard extends StatelessWidget {
  const _PaymentCard();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppTheme.navy.withOpacity(0.06),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.10),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.account_balance_wallet_rounded,
                color: const Color(0xFF4CAF50),
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'UPI / Wallet',
                    style: AppTheme.inter(
                      size: 13.5,
                      color: AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Pay after ride',
                    style: AppTheme.inter(size: 12, color: AppTheme.grey),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.10),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                'Cash',
                style: AppTheme.inter(
                  size: 11.5,
                  color: const Color(0xFF4CAF50),
                  weight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 6),
            Icon(Icons.chevron_right_rounded, color: AppTheme.grey, size: 20),
          ],
        ),
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// FIXED BOTTOM BAR
// ════════════════════════════════════════════════════════════════
class _BottomBar extends StatelessWidget {
  final String price;
  final bool searching;
  final double bottomPad;
  final VoidCallback? onTap;
  const _BottomBar({
    required this.price,
    required this.searching,
    required this.bottomPad,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.09),
            blurRadius: 24,
            offset: const Offset(0, -6),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Price
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Total Fare',
                style: AppTheme.inter(size: 11.5, color: AppTheme.grey),
              ),
              const SizedBox(height: 1),
              Text(
                price,
                style: AppTheme.inter(
                  size: 26,
                  color: AppTheme.navy,
                  weight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(width: 18),
          // Button
          Expanded(
            child: GestureDetector(
              onTap: onTap,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                height: 54,
                decoration: BoxDecoration(
                  color: onTap == null
                      ? AppTheme.navy.withOpacity(0.50)
                      : AppTheme.navy,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: onTap != null
                      ? [
                          BoxShadow(
                            color: AppTheme.navy.withOpacity(0.30),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : [],
                ),
                child: Center(
                  child: searching
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.2,
                                color: AppTheme.yellow,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Finding rider...',
                              style: AppTheme.inter(
                                size: 14,
                                color: Colors.white,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.two_wheeler_rounded,
                              color: AppTheme.yellow,
                              size: 19,
                            ),
                            const SizedBox(width: 9),
                            Text(
                              'Confirm Booking',
                              style: AppTheme.inter(
                                size: 15,
                                color: Colors.white,
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ════════════════════════════════════════════════════════════════
// RIDER FOUND OVERLAY
// ════════════════════════════════════════════════════════════════
class _RiderFoundOverlay extends StatefulWidget {
  final VoidCallback onClose;
  const _RiderFoundOverlay({required this.onClose});
  @override
  State<_RiderFoundOverlay> createState() => _RiderFoundOverlayState();
}

class _RiderFoundOverlayState extends State<_RiderFoundOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    return FadeTransition(
      opacity: _ctrl,
      child: Container(
        color: Colors.black.withOpacity(0.55),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: SlideTransition(
            position: Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
                .animate(
                  CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic),
                ),
            child: Container(
              width: double.infinity,
              padding: EdgeInsets.fromLTRB(24, 28, 24, bottomPad + 24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.10),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF4CAF50),
                      size: 38,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    'Rider Found! 🎉',
                    style: AppTheme.playfair(
                      size: 22,
                      color: AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'Rahul Verma is on his way',
                    style: AppTheme.inter(size: 14, color: AppTheme.grey),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    'Arriving in ~8 mins',
                    style: AppTheme.inter(
                      size: 13,
                      color: AppTheme.yellow,
                      weight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Rider strip
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: AppTheme.yellow.withOpacity(0.15),
                          child: Icon(
                            Icons.person,
                            color: AppTheme.yellow,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rahul Verma',
                                style: AppTheme.inter(
                                  size: 13.5,
                                  color: AppTheme.navy,
                                  weight: FontWeight.w700,
                                ),
                              ),
                              Text(
                                'Hero Splendor  •  HR 06 AB 1234',
                                style: AppTheme.inter(
                                  size: 11.5,
                                  color: AppTheme.grey,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.star_rounded,
                              size: 13,
                              color: AppTheme.yellow,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              '4.8',
                              style: AppTheme.inter(
                                size: 12,
                                color: AppTheme.navy,
                                weight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => HapticFeedback.lightImpact(),
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.bg,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.message_rounded,
                                  size: 17,
                                  color: AppTheme.navy,
                                ),
                                const SizedBox(width: 7),
                                Text(
                                  'Message',
                                  style: AppTheme.inter(
                                    size: 14,
                                    color: AppTheme.navy,
                                    weight: FontWeight.w700,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GestureDetector(
                          onTap: widget.onClose,
                          child: Container(
                            height: 52,
                            decoration: BoxDecoration(
                              color: AppTheme.navy,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.navy.withOpacity(0.28),
                                  blurRadius: 12,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Track Ride',
                                style: AppTheme.inter(
                                  size: 14,
                                  color: Colors.white,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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

// ════════════════════════════════════════════════════════════════
// FADE + SLIDE ENTRY
// ════════════════════════════════════════════════════════════════
class _FadeSlide extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  final Widget child;
  const _FadeSlide({
    required this.ctrl,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.48).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: ctrl,
          curve: Interval(delay, end, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: ctrl,
                curve: Interval(delay, end, curve: Curves.easeOutCubic),
              ),
            ),
        child: child,
      ),
    );
  }
}
