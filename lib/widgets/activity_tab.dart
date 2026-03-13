import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import 'activity_filtersheet.dart';
import 'ride_detail_screen.dart';
import 'rebook_screen.dart';
import 'track_ride_screen.dart';

final List<Map<String, dynamic>> kPastRides = [
  {
    'id': '1',
    'destination': 'Saharanpur City Center',
    'origin': 'Shobhit University',
    'date': 'Mar 29',
    'time': '3:00 PM',
    'price': '₹25',
    'type': 'Scooter',
    'icon': Icons.electric_scooter_rounded,
    'riderName': 'Rahul Verma',
    'riderRating': 4.8,
    'distance': '4.2 km',
    'duration': '18 min',
    'status': 'completed',
    'color': Color(0xFF4CAF50),
  },
  {
    'id': '2',
    'destination': 'District Hospital',
    'origin': 'Shobhit University',
    'date': 'Mar 28',
    'time': '11:30 AM',
    'price': '₹15',
    'type': 'Pillion',
    'icon': Icons.two_wheeler_rounded,
    'riderName': 'Amit Singh',
    'riderRating': 4.5,
    'distance': '2.8 km',
    'duration': '12 min',
    'status': 'completed',
    'color': Color(0xFF4CAF50),
  },
  {
    'id': '3',
    'destination': 'Emporium Mall',
    'origin': 'Shobhit University',
    'date': 'Mar 25',
    'time': '6:15 PM',
    'price': '₹40',
    'type': 'Express',
    'icon': Icons.bolt_rounded,
    'riderName': 'Priya Sharma',
    'riderRating': 4.9,
    'distance': '7.1 km',
    'duration': '22 min',
    'status': 'cancelled',
    'color': Color(0xFFEF5350),
  },
  {
    'id': '4',
    'destination': 'Railway Station',
    'origin': 'Shobhit University',
    'date': 'Mar 22',
    'time': '8:00 AM',
    'price': '₹30',
    'type': 'Scooter',
    'icon': Icons.electric_scooter_rounded,
    'riderName': 'Vikram Das',
    'riderRating': 4.7,
    'distance': '5.5 km',
    'duration': '20 min',
    'status': 'completed',
    'color': Color(0xFF4CAF50),
  },
];

// ══════════════════════════════════════════════════════════════
class ActivityTab extends StatefulWidget {
  const ActivityTab({super.key});

  @override
  State<ActivityTab> createState() => _ActivityTabState();
}

class _ActivityTabState extends State<ActivityTab>
    with SingleTickerProviderStateMixin {
  late AnimationController _entryCtrl;
  String _activeFilter = 'All';
  final _filters = ['All', 'Scooter', 'Pillion', 'Express'];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 700))
      ..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  List<Map<String, dynamic>> get _filtered => _activeFilter == 'All'
      ? kPastRides
      : kPastRides.where((r) => r['type'] == _activeFilter).toList();

  void _openFilter() async {
    HapticFeedback.lightImpact();
    final result = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const ActivityFilterSheet(),
    );
    if (result != null) {
      setState(() => _activeFilter = result);
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Stack(
      children: [
        // Titanium background
        Container(color: AppTheme.bg),

        SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          padding: EdgeInsets.only(top: topPad + 16, bottom: 130),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header ──────────────────────────────────────
              _buildHeader(),
              const SizedBox(height: 24),

              // ── Stats Row ───────────────────────────────────
              _buildStatsRow(),
              const SizedBox(height: 28),

              // ── Upcoming Ride ────────────────────────────────
              _sectionLabel('Upcoming'),
              const SizedBox(height: 14),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _UpcomingCard(
                  onTrack: () => Navigator.push(
                    context,
                    _slideRoute(const TrackRideScreen()),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // ── Filter Pills ─────────────────────────────────
              _sectionLabel('Past Trips'),
              const SizedBox(height: 14),
              _buildFilterPills(),
              const SizedBox(height: 16),

              // ── Past Rides List ──────────────────────────────
              ..._filtered.asMap().entries.map((e) => _buildAnimatedTile(
                e.value,
                e.key,
              )),
            ],
          ),
        ),
      ],
    );
  }

  // ── Header ──────────────────────────────────────────────────
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          FadeTransition(
            opacity: _entryCtrl,
            child: SlideTransition(
              position: Tween<Offset>(
                  begin: const Offset(-0.2, 0), end: Offset.zero)
                  .animate(CurvedAnimation(
                  parent: _entryCtrl, curve: Curves.easeOutCubic)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Activity',
                      style: AppTheme.playfair(
                          size: 34,
                          color: AppTheme.navy,
                          weight: FontWeight.w800)),
                  Text('Your ride history',
                      style:
                      AppTheme.inter(size: 13, color: AppTheme.grey)),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: _openFilter,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppTheme.navy.withOpacity(0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4)),
                ],
              ),
              child: Icon(Icons.tune_rounded, color: AppTheme.navy, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ── Stats row ────────────────────────────────────────────────
  Widget _buildStatsRow() {
    final stats = [
      ('12', 'Total Rides', Icons.route_rounded),
      ('₹310', 'Total Saved', Icons.savings_rounded),
      ('4.8', 'Avg Rating', Icons.star_rounded),
    ];
    return SizedBox(
      height: 88,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const ClampingScrollPhysics(),
        itemCount: stats.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (_, i) => Container(
          width: 110,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                  color: AppTheme.navy.withOpacity(0.06),
                  blurRadius: 12,
                  offset: const Offset(0, 4))
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(stats[i].$3,
                  color: AppTheme.yellow, size: 18),
              const SizedBox(height: 4),
              Text(stats[i].$1,
                  style: AppTheme.inter(
                      size: 16,
                      color: AppTheme.navy,
                      weight: FontWeight.w800)),
              Text(stats[i].$2,
                  style: AppTheme.inter(size: 10.5, color: AppTheme.grey)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 20),
    child: Text(text,
        style: AppTheme.inter(
            size: 16, color: AppTheme.navy, weight: FontWeight.w700)),
  );

  // ── Filter Pills ─────────────────────────────────────────────
  Widget _buildFilterPills() {
    return SizedBox(
      height: 38,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        physics: const ClampingScrollPhysics(),
        itemCount: _filters.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) {
          final active = _activeFilter == _filters[i];
          return GestureDetector(
            onTap: () {
              HapticFeedback.selectionClick();
              setState(() => _activeFilter = _filters[i]);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              padding:
              const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              decoration: BoxDecoration(
                color: active ? AppTheme.navy : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: active
                    ? [
                  BoxShadow(
                      color: AppTheme.navy.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]
                    : [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 6)
                ],
              ),
              child: Text(
                _filters[i],
                style: AppTheme.inter(
                    size: 13,
                    color: active ? Colors.white : AppTheme.grey,
                    weight: FontWeight.w600),
              ),
            ),
          );
        },
      ),
    );
  }

  // ── Animated Ride Tile ───────────────────────────────────────
  Widget _buildAnimatedTile(Map<String, dynamic> ride, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: 350 + index * 80),
      curve: Curves.easeOutCubic,
      builder: (_, v, child) => Opacity(
        opacity: v,
        child: Transform.translate(
          offset: Offset(0, 24 * (1 - v)),
          child: child,
        ),
      ),
      child: Padding(
        padding:
        const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: _PastRideTile(
          ride: ride,
          onTap: () => Navigator.push(
            context,
            _slideRoute(RideDetailScreen(ride: ride)),
          ),
          onRebook: () => Navigator.push(
            context,
            _slideRoute(RebookScreen(ride: ride)),
          ),
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// Upcoming Card
// ══════════════════════════════════════════════════════════════
class _UpcomingCard extends StatelessWidget {
  final VoidCallback onTrack;
  const _UpcomingCard({required this.onTrack});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
              color: AppTheme.navy.withOpacity(0.35),
              blurRadius: 28,
              offset: const Offset(0, 12)),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Column(
          children: [
            // Map preview
            _MapPreview(),
            // Info
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('To Shobhit University',
                                style: AppTheme.inter(
                                    size: 15,
                                    color: Colors.white,
                                    weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Row(children: [
                              Icon(Icons.access_time_rounded,
                                  size: 13, color: AppTheme.yellow),
                              const SizedBox(width: 4),
                              Text('Arriving in ~10 mins',
                                  style: AppTheme.inter(
                                      size: 13, color: AppTheme.yellow)),
                            ]),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: onTrack,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 16, vertical: 10),
                          decoration: BoxDecoration(
                            color: AppTheme.yellow,
                            borderRadius: BorderRadius.circular(16),
                            boxShadow: [
                              BoxShadow(
                                  color: AppTheme.yellow.withOpacity(0.4),
                                  blurRadius: 10,
                                  offset: const Offset(0, 4))
                            ],
                          ),
                          child: Row(children: [
                            Icon(Icons.explore_rounded,
                                color: AppTheme.navy, size: 16),
                            const SizedBox(width: 6),
                            Text('Track',
                                style: AppTheme.inter(
                                    size: 13,
                                    color: AppTheme.navy,
                                    weight: FontWeight.w700)),
                          ]),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  // Rider info strip
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.07),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                          color: Colors.white.withOpacity(0.10)),
                    ),
                    child: Row(children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: AppTheme.yellow.withOpacity(0.2),
                        child: Icon(Icons.person,
                            size: 16, color: AppTheme.yellow),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Rahul Verma',
                                style: AppTheme.inter(
                                    size: 13,
                                    color: Colors.white,
                                    weight: FontWeight.w600)),
                            Text('Hero Splendor • HR 06 AB 1234',
                                style: AppTheme.inter(
                                    size: 11, color: Colors.white38)),
                          ],
                        ),
                      ),
                      Row(children: [
                        Icon(Icons.star_rounded,
                            size: 13, color: AppTheme.yellow),
                        const SizedBox(width: 3),
                        Text('4.8',
                            style: AppTheme.inter(
                                size: 12,
                                color: Colors.white70,
                                weight: FontWeight.w600)),
                      ]),
                    ]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Map Preview with animated route ─────────────────────────────
class _MapPreview extends StatefulWidget {
  @override
  State<_MapPreview> createState() => _MapPreviewState();
}

class _MapPreviewState extends State<_MapPreview>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl =
    AnimationController(vsync: this, duration: const Duration(seconds: 2))
      ..repeat(reverse: true);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: const Color(0xFF011E2A),
      child: Stack(
        children: [
          // Grid lines (fake map)
          CustomPaint(
            size: const Size(double.infinity, 150),
            painter: _MapGridPainter(),
          ),
          // Route
          AnimatedBuilder(
            animation: _ctrl,
            builder: (_, __) => CustomPaint(
              size: const Size(double.infinity, 150),
              painter: _RouteAnimPainter(progress: _ctrl.value),
            ),
          ),
          // Start pin
          Positioned(
            left: 40,
            top: 30,
            child: _MapPin(color: Colors.white, icon: Icons.my_location_rounded),
          ),
          // End pin
          Positioned(
            right: 50,
            bottom: 28,
            child: _MapPin(color: AppTheme.yellow, icon: Icons.location_on_rounded),
          ),
          // Dark gradient overlay at bottom
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 40,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, AppTheme.navy.withOpacity(0.9)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  final Color color;
  final IconData icon;
  const _MapPin({required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(7),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        shape: BoxShape.circle,
        border: Border.all(color: color, width: 2),
        boxShadow: [
          BoxShadow(color: color.withOpacity(0.5), blurRadius: 10)
        ],
      ),
      child: Icon(icon, color: color, size: 13),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 30) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 30) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _RouteAnimPainter extends CustomPainter {
  final double progress;
  const _RouteAnimPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(50, 40)
      ..cubicTo(size.width * 0.3, 20, size.width * 0.6, size.height - 20,
          size.width - 60, size.height - 35);

    final metrics = path.computeMetrics().first;
    final len = metrics.length;

    // Glow
    canvas.drawPath(
        path,
        Paint()
          ..color = AppTheme.yellow.withOpacity(0.15)
          ..strokeWidth = 8
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Main line
    canvas.drawPath(
        metrics.extractPath(0, len),
        Paint()
          ..color = AppTheme.yellow.withOpacity(0.5)
          ..strokeWidth = 2.5
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round);

    // Animated dot
    final tangent = metrics.getTangentForOffset(len * ((progress + 0.5) % 1.0));
    if (tangent != null) {
      canvas.drawCircle(
          tangent.position,
          5,
          Paint()
            ..color = AppTheme.yellow
            ..style = PaintingStyle.fill);
      canvas.drawCircle(
          tangent.position,
          9,
          Paint()
            ..color = AppTheme.yellow.withOpacity(0.3)
            ..style = PaintingStyle.fill);
    }
  }

  @override
  bool shouldRepaint(_RouteAnimPainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════════════
// Past Ride Tile
// ══════════════════════════════════════════════════════════════
class _PastRideTile extends StatelessWidget {
  final Map<String, dynamic> ride;
  final VoidCallback onTap;
  final VoidCallback onRebook;

  const _PastRideTile(
      {required this.ride, required this.onTap, required this.onRebook});

  @override
  Widget build(BuildContext context) {
    final isCancelled = ride['status'] == 'cancelled';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
                color: AppTheme.navy.withOpacity(0.06),
                blurRadius: 12,
                offset: const Offset(0, 4))
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                    color: AppTheme.navy.withOpacity(0.07), width: 1),
              ),
              child:
              Icon(ride['icon'], color: AppTheme.navy, size: 24),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ride['destination'],
                      style: AppTheme.inter(
                          size: 14,
                          color: AppTheme.navy,
                          weight: FontWeight.w700),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 3),
                  Text('${ride['date']} • ${ride['time']} • ${ride['type']}',
                      style: AppTheme.inter(size: 11.5, color: AppTheme.grey)),
                  const SizedBox(height: 5),
                  Row(children: [
                    Text(ride['price'],
                        style: AppTheme.inter(
                            size: 14,
                            color: AppTheme.navy,
                            weight: FontWeight.w800)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: (ride['color'] as Color).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        isCancelled ? 'Cancelled' : 'Completed',
                        style: AppTheme.inter(
                            size: 10,
                            color: ride['color'],
                            weight: FontWeight.w700),
                      ),
                    ),
                  ]),
                ],
              ),
            ),
            const SizedBox(width: 8),
            if (!isCancelled)
              GestureDetector(
                onTap: () {
                  HapticFeedback.lightImpact();
                  onRebook();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                        color: AppTheme.yellow.withOpacity(0.4)),
                  ),
                  child: Row(children: [
                    Icon(Icons.refresh_rounded,
                        color: AppTheme.navy, size: 13),
                    const SizedBox(width: 4),
                    Text('Rebook',
                        style: AppTheme.inter(
                            size: 11.5,
                            color: AppTheme.navy,
                            weight: FontWeight.w700)),
                  ]),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

PageRoute _slideRoute(Widget page) {
  return PageRouteBuilder(
    pageBuilder: (context, animation, secondaryAnimation) => page,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      const begin = Offset(1.0, 0.0);
      const end = Offset.zero;
      const curve = Curves.easeOutCubic;

      var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
      var offsetAnimation = animation.drive(tween);

      return SlideTransition(position: offsetAnimation, child: child);
    },
    transitionDuration: const Duration(milliseconds: 300),
    reverseTransitionDuration: const Duration(milliseconds: 250),
    maintainState: true,
  );
}
