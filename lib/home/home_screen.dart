import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:twogo/home/rider_dashboard.dart';
import '../screens/location_select_screen.dart';
import '../screens/map_screen.dart';
import '../screens/profile_sidebar.dart';
import '../screens/rider_earning_tab.dart';
import '../theme/app_theme.dart';
import '../widgets/activity_tab.dart';
import 'admin_dashboard.dart';
import 'custom_bottom_nav_bar.dart';
import 'passenger_components.dart';

enum UserRole { passenger, rider, admin }

class HomeScreen extends StatefulWidget {
  final UserRole role;
  const HomeScreen({super.key, this.role = UserRole.passenger});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with TickerProviderStateMixin {
  int _navIndex = 0;
  late AnimationController _sidebarCtrl;
  bool _sidebarOpen = false;
  late UserRole _currentRole;
  String _fromLocation = 'Set pickup location';
  String _toLocation = 'Set destination';
  int _activeFilter = 0;

  static const _filters = [
    (icon: Icons.search_rounded, label: 'Search Route'),
    (icon: Icons.star_border_rounded, label: 'Saved'),
    (icon: Icons.history_rounded, label: 'Recent'),
  ];

  static const _rides = [
    (
      name: 'Rahul S.',
      from: 'Saharanpur Center',
      to: 'Shobhit Univ.',
      price: '₹25',
      eta: '3 min',
      rating: 4.8,
    ),
    (
      name: 'Aditya K.',
      from: 'Old Bus Stand',
      to: 'Shobhit Univ.',
      price: '₹20',
      eta: '7 min',
      rating: 4.6,
    ),
    (
      name: 'Priya M.',
      from: 'Clock Tower',
      to: 'Gangoh',
      price: '₹30',
      eta: '10 min',
      rating: 4.9,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _currentRole = widget.role; // Initialize with passed role
    _fetchUserRole(); // Then fetch from prefs to be safe
    _sidebarCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
    );
  }

  Future<void> _fetchUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    final roleStr = prefs.getString('user_role');

    if (roleStr != null) {
      UserRole fetchedRole = UserRole.passenger;
      if (roleStr == 'admin')
        fetchedRole = UserRole.admin;
      else if (roleStr == 'rider')
        fetchedRole = UserRole.rider;

      if (_currentRole != fetchedRole) {
        setState(() {
          _currentRole = fetchedRole;
        });
      }
    }
  }

  @override
  void dispose() {
    _sidebarCtrl.dispose();
    super.dispose();
  }

  void _openSidebar() {
    HapticFeedback.lightImpact();
    setState(() => _sidebarOpen = true);
    _sidebarCtrl.forward();
  }

  void _closeSidebar() {
    _sidebarCtrl.reverse().then((_) => setState(() => _sidebarOpen = false));
  }

  Future<void> _openLocation({required bool isFrom}) async {
    HapticFeedback.selectionClick();
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => LocationSelectScreen(isFrom: isFrom)),
    );
    if (result != null) {
      setState(() {
        if (isFrom)
          _fromLocation = result;
        else
          _toLocation = result;
      });
    }
  }

  void _swapLocations() {
    HapticFeedback.selectionClick();
    setState(() {
      final tmp = _fromLocation;
      _fromLocation = _toLocation;
      _toLocation = tmp;
    });
  }

  Widget _buildBody() {
    // 🚨 FIX: Now checking _currentRole instead of _role
    if (_currentRole == UserRole.admin) {
      return AdminDashboard(onOpenSidebar: _openSidebar);
    }

    if (_currentRole == UserRole.rider) {
      if (_navIndex == 0) return RiderDashboard(onOpenSidebar: _openSidebar);
      if (_navIndex == 1) return const RiderEarningsTab();
    }

    // Default to passenger
    if (_navIndex == 0) return _buildPassengerHome();
    if (_navIndex == 1) return const MapTab();
    if (_navIndex == 2) return const ActivityTab();
    return _buildPassengerHome();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // Main content
          _buildBody(),

          // 🚨 FIX: Checking _currentRole
          if (_currentRole != UserRole.admin)
            Align(
              alignment: Alignment.bottomCenter,
              child: CustomBottomNavBar(
                currentIndex: _navIndex,
                role: _currentRole, // Pass the correct role
                onTap: (i) => setState(() => _navIndex = i),
              ),
            ),

          if (_sidebarOpen)
            ProfileSidebar(
              controller: _sidebarCtrl,
              onClose: _closeSidebar,
              role: _currentRole, // Pass the correct role
            ),
        ],
      ),
    );
  }

  Widget _buildPassengerHome() {
    final size = MediaQuery.of(context).size;
    final topPad = MediaQuery.of(context).padding.top;

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: topPad + 16, bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _openSidebar,
                  child: Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.yellow, width: 2),
                    ),
                    child: Container(
                      width: 38,
                      height: 38,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppTheme.navy,
                      ),
                      child: const Icon(
                        Icons.person,
                        color: Colors.white,
                        size: 20,
                      ),
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
                        style: AppTheme.inter(size: 12, color: AppTheme.grey),
                      ),
                      Text(
                        'Abuzar',
                        style: AppTheme.playfair(
                          size: 18,
                          color: AppTheme.navy,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                _NotifButton(),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Heading
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Plan your ride',
                  style: AppTheme.playfair(
                    size: 30,
                    color: AppTheme.navy,
                    weight: FontWeight.w800,
                  ),
                ),
                Text(
                  'Find rides going your way',
                  style: AppTheme.inter(size: 13.5, color: AppTheme.grey),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Location card
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PassengerComponents.locationInputCard(
              fromLocation: _fromLocation,
              toLocation: _toLocation,
              onFromTap: () => _openLocation(isFrom: true),
              onToTap: () => _openLocation(isFrom: false),
              onSwap: _swapLocations,
            ),
          ),
          const SizedBox(height: 20),

          // Filter pills
          SizedBox(
            height: 40,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              itemCount: _filters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 10),
              itemBuilder: (_, i) => PassengerComponents.quickFilterPill(
                icon: _filters[i].icon,
                text: _filters[i].label,
                active: _activeFilter == i,
                onTap: () => setState(() => _activeFilter = i),
              ),
            ),
          ),
          const SizedBox(height: 28),

          // Ride types
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PassengerComponents.sectionHeader(title: 'Ride Types'),
          ),
          const SizedBox(height: 14),
          SizedBox(
            height: size.height * 0.2,
            child: ListView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 24),
              children: [
                PassengerComponents.rideOptionCard(
                  width: size.width * 0.38,
                  title: 'Pillion',
                  price: '₹20–₹30',
                  icon: Icons.two_wheeler_rounded,
                  featured: true,
                  onTap: () {},
                ),
                const SizedBox(width: 14),
                PassengerComponents.rideOptionCard(
                  width: size.width * 0.38,
                  title: 'Scooter',
                  price: '₹15–₹25',
                  icon: Icons.electric_scooter_rounded,
                  onTap: () {},
                ),
                const SizedBox(width: 14),
                PassengerComponents.rideOptionCard(
                  width: size.width * 0.38,
                  title: 'Express',
                  price: '₹35–₹50',
                  icon: Icons.bolt_rounded,
                  onTap: () {},
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),

          // Nearby rides
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: PassengerComponents.sectionHeader(
              title: 'Available Nearby',
              actionLabel: 'View All',
              onAction: () {},
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: _rides
                  .map(
                    (r) => PassengerComponents.nearbyRideCard(
                      name: r.name,
                      from: r.from,
                      to: r.to,
                      price: r.price,
                      eta: r.eta,
                      rating: r.rating,
                      onTap: () {},
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Notification button ────────────────────────────────────────
class _NotifButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) => Stack(
    children: [
      Container(
        width: 42,
        height: 42,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 12),
          ],
        ),
        child: const Icon(
          Icons.notifications_none_rounded,
          color: AppTheme.navy,
          size: 22,
        ),
      ),
      Positioned(
        top: 8,
        right: 10,
        child: Container(
          width: 8,
          height: 8,
          decoration: const BoxDecoration(
            color: Color(0xFFE53935),
            shape: BoxShape.circle,
          ),
        ),
      ),
    ],
  );
}