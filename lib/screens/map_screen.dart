import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

final _dummyRiders = [
  _Rider(name: 'Rahul V.', dist: '0.3 km', x: 0.38, y: 0.22, type: 'Pillion'),
  _Rider(name: 'Amit S.', dist: '0.6 km', x: 0.62, y: 0.18, type: 'Scooter'),
  _Rider(name: 'Priya K.', dist: '0.9 km', x: 0.72, y: 0.38, type: 'Express'),
  _Rider(name: 'Dev R.', dist: '1.1 km', x: 0.25, y: 0.42, type: 'Pillion'),
  _Rider(name: 'Nisha M.', dist: '1.4 km', x: 0.55, y: 0.52, type: 'Scooter'),
  _Rider(name: 'Arjun T.', dist: '1.8 km', x: 0.80, y: 0.58, type: 'Express'),
];

class _Rider {
  final String name, dist, type;
  final double x, y;
  const _Rider({
    required this.name,
    required this.dist,
    required this.x,
    required this.y,
    required this.type,
  });
}

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> with TickerProviderStateMixin {
  late AnimationController _riderFloatCtrl; // gentle up-down float for riders
  late AnimationController _pulseCtrl; // pulse rings
  late AnimationController _entryCtrl; // bottom card entry
  late AnimationController _scanCtrl; // radar scan line

  _Rider? _selectedRider;

  @override
  void initState() {
    super.initState();

    _riderFloatCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3000),
    )..repeat();
  }

  @override
  void dispose() {
    _riderFloatCtrl.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF011E2A),
      body: Stack(
        children: [
          // ── Full screen map canvas ─────────────────────────
          SizedBox.expand(child: CustomPaint(painter: _MapCanvasPainter())),

          // ── Radar scan overlay ─────────────────────────────
          AnimatedBuilder(
            animation: _scanCtrl,
            builder: (_, __) => CustomPaint(
              size: size,
              painter: _RadarScanPainter(
                progress: _scanCtrl.value,
                center: Offset(size.width * 0.50, size.height * 0.44),
              ),
            ),
          ),

          // ── User location pulse ────────────────────────────
          _UserLocationDot(
            x: size.width * 0.50,
            y: size.height * 0.44,
            pulseCtrl: _pulseCtrl,
          ),

          // ── Rider dots on map ──────────────────────────────
          ..._dummyRiders.asMap().entries.map((e) {
            final i = e.key;
            final rider = e.value;
            return _AnimatedRiderPin(
              rider: rider,
              floatCtrl: _riderFloatCtrl,
              floatOffset: i * 0.18, // staggered float
              x: size.width * rider.x,
              y: size.height * rider.y,
              isSelected: _selectedRider?.name == rider.name,
              onTap: () {
                HapticFeedback.selectionClick();
                setState(() {
                  _selectedRider = _selectedRider?.name == rider.name
                      ? null
                      : rider;
                });
              },
            );
          }),

          // ── Top search bar ─────────────────────────────────
          _TopSearchBar(entryCtrl: _entryCtrl),

          // ── Right side controls ─────────────────────────────
          _RightControls(
            entryCtrl: _entryCtrl,
            onLocate: () => HapticFeedback.mediumImpact(),
          ),

          // ── Bottom floating panel ──────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: _BottomPanel(
              entryCtrl: _entryCtrl,
              selectedRider: _selectedRider,
              riders: _dummyRiders,
              bottomPad: bottomPad,
              onClearSelection: () => setState(() => _selectedRider = null),
            ),
          ),
        ],
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// MAP CANVAS
// ══════════════════════════════════════════════════════════════
class _MapCanvasPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF011E2A),
    );

    // Grid
    final gridP = Paint()
      ..color = Colors.white.withOpacity(0.035)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 36) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridP);
    }
    for (double y = 0; y < size.height; y += 36) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridP);
    }

    // Roads (wider lighter bands)
    final roadP = Paint()..color = Colors.white.withOpacity(0.055);
    // Horizontal roads
    _drawRoad(canvas, size, isHoriz: true, pos: 0.28, width: 28);
    _drawRoad(canvas, size, isHoriz: true, pos: 0.50, width: 36);
    _drawRoad(canvas, size, isHoriz: true, pos: 0.70, width: 22);
    // Vertical roads
    _drawRoad(canvas, size, isHoriz: false, pos: 0.22, width: 24);
    _drawRoad(canvas, size, isHoriz: false, pos: 0.50, width: 40);
    _drawRoad(canvas, size, isHoriz: false, pos: 0.72, width: 22);

    // Blocks (city buildings)
    final blockP = Paint()..color = Colors.white.withOpacity(0.03);
    final blocks = [
      Rect.fromLTWH(size.width * 0.05, size.height * 0.08, 70, 55),
      Rect.fromLTWH(size.width * 0.28, size.height * 0.06, 90, 48),
      Rect.fromLTWH(size.width * 0.55, size.height * 0.05, 60, 65),
      Rect.fromLTWH(size.width * 0.76, size.height * 0.10, 55, 42),
      Rect.fromLTWH(size.width * 0.05, size.height * 0.33, 65, 50),
      Rect.fromLTWH(size.width * 0.30, size.height * 0.32, 80, 44),
      Rect.fromLTWH(size.width * 0.58, size.height * 0.30, 55, 55),
      Rect.fromLTWH(size.width * 0.76, size.height * 0.35, 60, 40),
      Rect.fromLTWH(size.width * 0.05, size.height * 0.55, 72, 50),
      Rect.fromLTWH(size.width * 0.30, size.height * 0.57, 85, 48),
      Rect.fromLTWH(size.width * 0.62, size.height * 0.56, 50, 55),
      Rect.fromLTWH(size.width * 0.78, size.height * 0.58, 55, 42),
    ];
    for (final b in blocks) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(b, const Radius.circular(4)),
        blockP,
      );
    }

    // Yellow accent dots (intersections)
    final dotP = Paint()
      ..color = const Color(0xFFF7B32B).withOpacity(0.08)
      ..style = PaintingStyle.fill;
    final intersections = [
      Offset(size.width * 0.22, size.height * 0.28),
      Offset(size.width * 0.50, size.height * 0.28),
      Offset(size.width * 0.72, size.height * 0.28),
      Offset(size.width * 0.22, size.height * 0.50),
      Offset(size.width * 0.72, size.height * 0.50),
      Offset(size.width * 0.22, size.height * 0.70),
      Offset(size.width * 0.50, size.height * 0.70),
      Offset(size.width * 0.72, size.height * 0.70),
    ];
    for (final pt in intersections) {
      canvas.drawCircle(pt, 5, dotP);
    }
  }

  void _drawRoad(
    Canvas canvas,
    Size size, {
    required bool isHoriz,
    required double pos,
    required double width,
  }) {
    final p = Paint()..color = Colors.white.withOpacity(0.055);
    final rect = isHoriz
        ? Rect.fromLTWH(0, size.height * pos - width / 2, size.width, width)
        : Rect.fromLTWH(size.width * pos - width / 2, 0, width, size.height);
    canvas.drawRect(rect, p);
  }

  @override
  bool shouldRepaint(_) => false;
}

// ══════════════════════════════════════════════════════════════
// RADAR SCAN
// ══════════════════════════════════════════════════════════════
class _RadarScanPainter extends CustomPainter {
  final double progress;
  final Offset center;
  const _RadarScanPainter({required this.progress, required this.center});

  @override
  void paint(Canvas canvas, Size size) {
    const maxRadius = 140.0;
    final angle = progress * 2 * math.pi - math.pi / 2;

    // Sweep gradient arc
    final sweepPaint = Paint()
      ..shader = SweepGradient(
        startAngle: angle - 1.2,
        endAngle: angle,
        colors: [Colors.transparent, const Color(0xFFF7B32B).withOpacity(0.12)],
      ).createShader(Rect.fromCircle(center: center, radius: maxRadius))
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, maxRadius, sweepPaint);

    // Scan line
    final lineEnd = Offset(
      center.dx + math.cos(angle) * maxRadius,
      center.dy + math.sin(angle) * maxRadius,
    );
    canvas.drawLine(
      center,
      lineEnd,
      Paint()
        ..color = const Color(0xFFF7B32B).withOpacity(0.35)
        ..strokeWidth = 1.5,
    );

    // Range rings
    for (final r in [50.0, 95.0, 140.0]) {
      canvas.drawCircle(
        center,
        r,
        Paint()
          ..color = const Color(0xFFF7B32B).withOpacity(0.07)
          ..strokeWidth = 1
          ..style = PaintingStyle.stroke,
      );
    }
  }

  @override
  bool shouldRepaint(_RadarScanPainter old) => old.progress != progress;
}

// ══════════════════════════════════════════════════════════════
// USER LOCATION DOT
// ══════════════════════════════════════════════════════════════
class _UserLocationDot extends StatelessWidget {
  final double x, y;
  final AnimationController pulseCtrl;
  const _UserLocationDot({
    required this.x,
    required this.y,
    required this.pulseCtrl,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: x - 24,
      top: y - 24,
      child: AnimatedBuilder(
        animation: pulseCtrl,
        builder: (_, __) {
          final t = pulseCtrl.value;
          return SizedBox(
            width: 48,
            height: 48,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Outer pulse
                Container(
                  width: 20 + t * 28,
                  height: 20 + t * 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.yellow.withOpacity(0.15 * (1 - t)),
                  ),
                ),
                // Inner ring
                Container(
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.yellow.withOpacity(0.25),
                    border: Border.all(color: AppTheme.yellow, width: 2.5),
                  ),
                ),
                // Center dot
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppTheme.yellow,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// RIDER PIN
// ══════════════════════════════════════════════════════════════
class _AnimatedRiderPin extends StatelessWidget {
  final _Rider rider;
  final AnimationController floatCtrl;
  final double floatOffset, x, y;
  final bool isSelected;
  final VoidCallback onTap;

  const _AnimatedRiderPin({
    required this.rider,
    required this.floatCtrl,
    required this.floatOffset,
    required this.x,
    required this.y,
    required this.isSelected,
    required this.onTap,
  });

  Color get _typeColor {
    switch (rider.type) {
      case 'Express':
        return const Color(0xFF64B5F6);
      case 'Scooter':
        return const Color(0xFF81C784);
      default:
        return AppTheme.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: floatCtrl,
      builder: (_, __) {
        final t = ((floatCtrl.value + floatOffset) % 1.0);
        final sinT = math.sin(t * math.pi);
        final bobY = sinT * 5.0;

        return Positioned(
          left: x - 28,
          top: y - 56 - bobY,
          child: GestureDetector(
            onTap: onTap,
            child: AnimatedScale(
              scale: isSelected ? 1.15 : 1.0,
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutBack,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Name + distance chip
                  AnimatedOpacity(
                    opacity: isSelected ? 1.0 : 0.85,
                    duration: const Duration(milliseconds: 200),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? _typeColor
                            : Colors.white.withOpacity(0.92),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.18),
                            blurRadius: 8,
                            offset: const Offset(0, 3),
                          ),
                        ],
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            rider.name,
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w700,
                              color: isSelected ? Colors.white : AppTheme.navy,
                            ),
                          ),
                          Text(
                            rider.dist,
                            style: TextStyle(
                              fontSize: 9.5,
                              color: isSelected
                                  ? Colors.white.withOpacity(0.85)
                                  : AppTheme.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Stem
                  Container(
                    width: 2,
                    height: 6,
                    color: isSelected
                        ? _typeColor
                        : Colors.white.withOpacity(0.6),
                  ),
                  // Icon dot
                  Container(
                    width: isSelected ? 32 : 28,
                    height: isSelected ? 32 : 28,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected
                          ? _typeColor
                          : Colors.white.withOpacity(0.15),
                      border: Border.all(
                        color: isSelected
                            ? _typeColor
                            : Colors.white.withOpacity(0.55),
                        width: 2,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (isSelected ? _typeColor : Colors.black)
                              .withOpacity(0.3),
                          blurRadius: isSelected ? 12 : 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      rider.type == 'Express'
                          ? Icons.bolt_rounded
                          : Icons.two_wheeler_rounded,
                      size: isSelected ? 16 : 14,
                      color: isSelected ? Colors.white : Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// ══════════════════════════════════════════════════════════════
// TOP SEARCH BAR
// ══════════════════════════════════════════════════════════════
class _TopSearchBar extends StatelessWidget {
  final AnimationController entryCtrl;
  const _TopSearchBar({required this.entryCtrl});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, -1), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: entryCtrl, curve: Curves.easeOutCubic),
            ),
        child: Padding(
          padding: EdgeInsets.fromLTRB(16, topPad + 12, 72, 0),
          child: GestureDetector(
            onTap: () => HapticFeedback.selectionClick(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.18),
                    blurRadius: 16,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Icon(Icons.search_rounded, color: AppTheme.grey, size: 18),
                  const SizedBox(width: 10),
                  Text(
                    'Search riders, places...',
                    style: TextStyle(
                      fontSize: 13.5,
                      color: AppTheme.grey,
                      fontWeight: FontWeight.w500,
                    ),
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

// ══════════════════════════════════════════════════════════════
// RIGHT SIDE CONTROLS
// ══════════════════════════════════════════════════════════════
class _RightControls extends StatelessWidget {
  final AnimationController entryCtrl;
  final VoidCallback onLocate;
  const _RightControls({required this.entryCtrl, required this.onLocate});

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPad + 8,
      right: 16,
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(1, 0), end: Offset.zero)
            .animate(
              CurvedAnimation(parent: entryCtrl, curve: Curves.easeOutCubic),
            ),
        child: Column(
          children: [
            _FloatBtn(
              icon: Icons.my_location_rounded,
              onTap: onLocate,
              active: true,
            ),
            const SizedBox(height: 10),
            _FloatBtn(
              icon: Icons.layers_rounded,
              onTap: () => HapticFeedback.lightImpact(),
            ),
          ],
        ),
      ),
    );
  }
}

class _FloatBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final bool active;
  const _FloatBtn({
    required this.icon,
    required this.onTap,
    this.active = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: active ? AppTheme.yellow : Colors.white,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Icon(
          icon,
          color: active ? AppTheme.navy : AppTheme.grey,
          size: 20,
        ),
      ),
    );
  }
}

// ══════════════════════════════════════════════════════════════
// BOTTOM PANEL
// ══════════════════════════════════════════════════════════════
class _BottomPanel extends StatelessWidget {
  final AnimationController entryCtrl;
  final _Rider? selectedRider;
  final List<_Rider> riders;
  final double bottomPad;
  final VoidCallback onClearSelection;

  const _BottomPanel({
    required this.entryCtrl,
    required this.selectedRider,
    required this.riders,
    required this.bottomPad,
    required this.onClearSelection,
  });

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: Tween<Offset>(
        begin: const Offset(0, 1),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: entryCtrl, curve: Curves.easeOutCubic)),
      child: Container(
        margin: EdgeInsets.only(bottom: bottomPad + 90),
        child: selectedRider != null
            ? _SelectedRiderCard(
                rider: selectedRider!,
                onClose: onClearSelection,
              )
            : _NearbyRidersStrip(riders: riders),
      ),
    );
  }
}

// ── Nearby riders horizontal strip ───────────────────────────
class _NearbyRidersStrip extends StatelessWidget {
  final List<_Rider> riders;
  const _NearbyRidersStrip({required this.riders});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 20, bottom: 10),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.navy.withOpacity(0.85),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withOpacity(0.12)),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 7,
                      height: 7,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${riders.length} riders nearby',
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Horizontal scroll cards
        SizedBox(
          height: 96,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            physics: const BouncingScrollPhysics(),
            itemCount: riders.length,
            separatorBuilder: (_, __) => const SizedBox(width: 10),
            itemBuilder: (_, i) => _RiderChip(rider: riders[i]),
          ),
        ),
      ],
    );
  }
}

class _RiderChip extends StatelessWidget {
  final _Rider rider;
  const _RiderChip({required this.rider});

  Color get _typeColor {
    switch (rider.type) {
      case 'Express':
        return const Color(0xFF64B5F6);
      case 'Scooter':
        return const Color(0xFF81C784);
      default:
        return AppTheme.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => HapticFeedback.selectionClick(),
      child: Container(
        width: 120,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.navy.withOpacity(0.88),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.10)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    rider.type == 'Express'
                        ? Icons.bolt_rounded
                        : Icons.two_wheeler_rounded,
                    size: 15,
                    color: _typeColor,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 6,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    rider.dist,
                    style: TextStyle(
                      fontSize: 9.5,
                      color: _typeColor,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rider.name,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  rider.type,
                  style: TextStyle(fontSize: 10.5, color: Colors.white38),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ── Selected rider expanded card ──────────────────────────────
class _SelectedRiderCard extends StatelessWidget {
  final _Rider rider;
  final VoidCallback onClose;
  const _SelectedRiderCard({required this.rider, required this.onClose});

  Color get _typeColor {
    switch (rider.type) {
      case 'Express':
        return const Color(0xFF64B5F6);
      case 'Scooter':
        return const Color(0xFF81C784);
      default:
        return AppTheme.yellow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppTheme.navy.withOpacity(0.95),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: _typeColor.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 24,
              offset: const Offset(0, 8),
            ),
            BoxShadow(
              color: _typeColor.withOpacity(0.12),
              blurRadius: 20,
              spreadRadius: -2,
            ),
          ],
        ),
        child: Column(
          children: [
            // Header
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: _typeColor.withOpacity(0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _typeColor.withOpacity(0.4),
                      width: 2,
                    ),
                  ),
                  child: Icon(Icons.person, color: _typeColor, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        rider.name,
                        style: const TextStyle(
                          fontSize: 15,
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Row(
                        children: [
                          Icon(
                            Icons.star_rounded,
                            size: 12,
                            color: AppTheme.yellow,
                          ),
                          const SizedBox(width: 3),
                          Text(
                            '4.8  •  ${rider.type}',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
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
                      size: 16,
                      color: Colors.white54,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            // Info row
            Row(
              children: [
                _infoChip(Icons.route_rounded, rider.dist, _typeColor),
                const SizedBox(width: 8),
                _infoChip(Icons.access_time_rounded, '~3 min', Colors.white54),
                const SizedBox(width: 8),
                _infoChip(Icons.currency_rupee_rounded, '25', Colors.white54),
              ],
            ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.07),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.message_rounded,
                            size: 15,
                            color: Colors.white70,
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Message',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.white70,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 13),
                      decoration: BoxDecoration(
                        color: _typeColor,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: _typeColor.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.two_wheeler_rounded,
                            size: 16,
                            color: AppTheme.navy,
                          ),
                          const SizedBox(width: 7),
                          Text(
                            'Book ${rider.name.split(' ')[0]}',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppTheme.navy,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label, Color color) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 5),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}