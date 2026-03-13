import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../screens/ride_request_screen.dart';
import '../theme/app_theme.dart';
import '../widgets/rider_components.dart';

class RiderDashboard extends StatefulWidget {
  final VoidCallback onOpenSidebar;
  const RiderDashboard({super.key, required this.onOpenSidebar});

  @override
  State<RiderDashboard> createState() => _RiderDashboardState();
}

class _RiderDashboardState extends State<RiderDashboard>
    with TickerProviderStateMixin {
  bool _isOnline = false;

  // Dummy backend data variables
  String _riderName = 'Abuzar';
  String _ridesToday = '3';
  String _earningsToday = '75';
  String _rating = '4.8';
  String _kmCovered = '14.2';

  Map<String, dynamic>? _pendingRequest = {
    'name': 'Rahul Verma',
    'rating': '4.9',
    'rideType': 'Pillion',
    'price': '₹35',
    'distance': '1.5 km',
    'pickup': 'Shobhit Univ. Main Gate',
    'drop': 'Saharanpur Railway Station',
  };

  final List<Map<String, dynamic>> _recentRides = [
    {
      'name': 'Arjun T.',
      'from': 'Gate 1',
      'to': 'City Center',
      'price': '₹25',
      'time': '2:30 PM',
      'rating': 5,
    },
    {
      'name': 'Sneha R.',
      'from': 'Hostel A',
      'to': 'Bus Stand',
      'price': '₹20',
      'time': '12:00 PM',
      'rating': 4,
    },
    {
      'name': 'Mohit K.',
      'from': 'Library',
      'to': 'Clock Tower',
      'price': '₹30',
      'time': '9:15 AM',
      'rating': 5,
    },
  ];

  late AnimationController _pulseCtrl;
  late AnimationController _entryCtrl;

  @override
  void initState() {
    super.initState();
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 650),
    )..forward();
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  void _toggleOnline() {
    HapticFeedback.mediumImpact();
    setState(() => _isOnline = !_isOnline);
  }

  void _openRequestScreen() async {
    if (_pendingRequest == null) return;

    HapticFeedback.selectionClick();

    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RideRequestScreen(requestData: _pendingRequest!),
      ),
    );

    if (result == true) {
      setState(() => _pendingRequest = null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Ride accepted! Follow the map to pickup.',
            style: AppTheme.inter(size: 13, color: Colors.white),
          ),
          backgroundColor: const Color(0xFF4CAF50),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          margin: const EdgeInsets.all(16),
        ),
      );
    } else if (result == false) {
      setState(() => _pendingRequest = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: topPad + 16, bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 20),

          // 1. Stats/Earnings
          _FadeSlide(ctrl: _entryCtrl, delay: 0.0, child: _buildStats()),
          const SizedBox(height: 20),

          // 2. Online/Offline toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _FadeSlide(
              ctrl: _entryCtrl,
              delay: 0.13,
              child: RiderComponents.onlineToggleCard(
                isOnline: _isOnline,
                onToggle: _toggleOnline,
              ),
            ),
          ),
          const SizedBox(height: 20),

          // 3. NEW: Incoming Request Banner (Sirf tab dikhega jab online ho aur request ho)
          if (_isOnline && _pendingRequest != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: _FadeSlide(
                ctrl: _entryCtrl,
                delay: 0.2,
                child: _buildRequestBanner(),
              ),
            ),
          if (_isOnline && _pendingRequest != null) const SizedBox(height: 24),

          // 4. Dynamic Recent Rides
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  "Today's Rides",
                  style: AppTheme.inter(
                    size: 15,
                    color: AppTheme.navy,
                    weight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    '$_ridesToday completed',
                    style: AppTheme.inter(
                      size: 11,
                      color: AppTheme.navy,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: _recentRides
                  .asMap()
                  .entries
                  .map(
                    (e) => _FadeSlide(
                      ctrl: _entryCtrl,
                      delay: 0.25 + e.key * 0.07,
                      child: RiderComponents.completedRideTile(
                        passengerName: e.value['name'],
                        from: e.value['from'],
                        to: e.value['to'],
                        price: e.value['price'],
                        time: e.value['time'],
                        rating: e.value['rating'],
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  // ── New UI: Sleek Notification Banner ──
  Widget _buildRequestBanner() {
    return GestureDetector(
      onTap: _openRequestScreen,
      child: AnimatedBuilder(
        animation: _pulseCtrl,
        builder: (_, __) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.navy,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.yellow.withOpacity(
                    0.15 + _pulseCtrl.value * 0.2,
                  ),
                  blurRadius: 15,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(
                color: AppTheme.yellow.withOpacity(0.6),
                width: 1.5,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.yellow.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.touch_app_rounded,
                    color: AppTheme.yellow,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'New Ride Request!',
                        style: AppTheme.inter(
                          size: 15,
                          color: Colors.white,
                          weight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        '${_pendingRequest!['distance']} away • ${_pendingRequest!['price']}',
                        style: AppTheme.inter(size: 12, color: AppTheme.yellow),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onOpenSidebar,
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isOnline ? const Color(0xFF4CAF50) : AppTheme.yellow,
                  width: 2,
                ),
              ),
              child: Container(
                width: 38,
                height: 38,
                decoration: const BoxDecoration(
                  color: AppTheme.navy,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.person, color: Colors.white, size: 20),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Good morning 👋',
                  style: AppTheme.inter(size: 11, color: AppTheme.grey),
                ),
                Text(
                  _riderName,
                  style: AppTheme.playfair(
                    size: 18,
                    color: AppTheme.navy,
                    weight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStats() {
    return SizedBox(
      height: 110,
      child: ListView(
        scrollDirection: Axis.horizontal,
        physics: const ClampingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          RiderComponents.statCard(
            icon: Icons.two_wheeler_rounded,
            label: 'Rides',
            value: _ridesToday,
            color: AppTheme.yellow,
          ),
          const SizedBox(width: 10),
          RiderComponents.statCard(
            icon: Icons.currency_rupee_rounded,
            label: "Earnings",
            value: '₹$_earningsToday',
            color: const Color(0xFF4CAF50),
          ),
          const SizedBox(width: 10),
          RiderComponents.statCard(
            icon: Icons.star_rounded,
            label: 'Rating',
            value: _rating,
            color: const Color(0xFF64B5F6),
          ),
          const SizedBox(width: 10),
          RiderComponents.statCard(
            icon: Icons.route_rounded,
            label: 'KM',
            value: _kmCovered,
            color: const Color(0xFFBA68C8),
          ),
        ],
      ),
    );
  }
}

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
    final end = (delay + 0.5).clamp(0.0, 1.0);
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
