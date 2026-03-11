import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class TrackRideScreen extends StatefulWidget {
  const TrackRideScreen({super.key});

  @override
  State<TrackRideScreen> createState() => _TrackRideScreenState();
}

class _TrackRideScreenState extends State<TrackRideScreen>
    with TickerProviderStateMixin {
  late AnimationController _riderMoveCtrl;
  late AnimationController _pulseCtrl;
  late AnimationController _entryCtrl;
  int _eta = 8;

  @override
  void initState() {
    super.initState();
    _riderMoveCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 5),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();

    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    // Simulate ETA countdown
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 8));
      if (!mounted) return false;
      setState(() => _eta = (_eta - 1).clamp(1, 99));
      return _eta > 1;
    });
  }

  @override
  void dispose() {
    _riderMoveCtrl.dispose();
    _pulseCtrl.dispose();
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF011E2A),
      body: Stack(
        children: [
          // ── Full screen map ──────────────────────────────
          SizedBox(
            width: size.width,
            height: size.height,
            child: _LiveMapView(
              riderCtrl: _riderMoveCtrl,
              pulseCtrl: _pulseCtrl,
            ),
          ),

          // ── Top bar ──────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.arrow_back_rounded,
                        color: AppTheme.navy,
                        size: 18,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.12),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          AnimatedBuilder(
                            animation: _pulseCtrl,
                            builder: (_, __) => Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: const Color(
                                  0xFF4CAF50,
                                ).withOpacity(0.5 + _pulseCtrl.value * 0.5),
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Live Tracking',
                            style: AppTheme.inter(
                              size: 13,
                              color: AppTheme.navy,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Container(
                    width: 42,
                    height: 42,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                        ),
                      ],
                    ),
                    child: GestureDetector(
                      onTap: () => HapticFeedback.lightImpact(),
                      child: Icon(
                        Icons.more_vert_rounded,
                        color: AppTheme.navy,
                        size: 18,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom info sheet ─────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SlideTransition(
              position:
                  Tween<Offset>(
                    begin: const Offset(0, 1),
                    end: Offset.zero,
                  ).animate(
                    CurvedAnimation(
                      parent: _entryCtrl,
                      curve: Curves.easeOutCubic,
                    ),
                  ),
              child: _BottomInfoSheet(eta: _eta, bottomPad: bottomPad),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Live Map ─────────────────────────────────────────────────
class _LiveMapView extends StatelessWidget {
  final AnimationController riderCtrl;
  final AnimationController pulseCtrl;

  const _LiveMapView({required this.riderCtrl, required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Grid map bg
        CustomPaint(size: size, painter: _BigMapPainter()),
        // Route line
        CustomPaint(size: size, painter: _BigRoutePainter()),
        // Destination pin (static)
        Positioned(
          right: size.width * 0.2,
          top: size.height * 0.25,
          child: _buildPin(
            AppTheme.yellow,
            Icons.location_on_rounded,
            'Destination',
          ),
        ),
        // User pin (static)
        Positioned(
          left: size.width * 0.18,
          bottom: size.height * 0.32,
          child: _buildPin(Colors.white, Icons.my_location_rounded, 'You'),
        ),
        // Animated rider
        AnimatedBuilder(
          animation: riderCtrl,
          builder: (_, __) {
            final t = Curves.easeInOut.transform(riderCtrl.value);
            return Positioned(
              left: size.width * (0.25 + t * 0.35),
              top: size.height * (0.52 - t * 0.20),
              child: _RiderDot(pulseCtrl: pulseCtrl),
            );
          },
        ),
      ],
    );
  }

  Widget _buildPin(Color color, IconData icon, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 6),
            ],
          ),
          child: Text(
            label,
            style: AppTheme.inter(
              size: 10,
              color: AppTheme.navy,
              weight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(height: 3),
        Container(
          width: 34,
          height: 34,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: color.withOpacity(0.4), blurRadius: 10),
            ],
          ),
          child: Icon(
            icon,
            size: 16,
            color: color == Colors.white ? AppTheme.navy : AppTheme.navy,
          ),
        ),
      ],
    );
  }
}

class _RiderDot extends StatelessWidget {
  final AnimationController pulseCtrl;
  const _RiderDot({required this.pulseCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: pulseCtrl,
      builder: (_, __) {
        return Stack(
          alignment: Alignment.center,
          children: [
            Container(
              width: 40 + pulseCtrl.value * 16,
              height: 40 + pulseCtrl.value * 16,
              decoration: BoxDecoration(
                color: AppTheme.yellow.withOpacity(0.2 * (1 - pulseCtrl.value)),
                shape: BoxShape.circle,
              ),
            ),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AppTheme.yellow.withOpacity(0.25),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.yellow, width: 2),
              ),
              child: Icon(
                Icons.two_wheeler_rounded,
                color: AppTheme.yellow,
                size: 18,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _BigMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Base color fill
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..color = const Color(0xFF011E2A),
    );

    final gridPaint = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;

    // Grid
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }

    // Road blocks (lighter rectangles)
    final roadPaint = Paint()..color = Colors.white.withOpacity(0.035);
    final roads = [
      Rect.fromLTWH(0, size.height * 0.3, size.width, 40),
      Rect.fromLTWH(0, size.height * 0.6, size.width, 40),
      Rect.fromLTWH(size.width * 0.25, 0, 50, size.height),
      Rect.fromLTWH(size.width * 0.65, 0, 50, size.height),
    ];
    for (final r in roads) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(r, const Radius.circular(2)),
        roadPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_) => false;
}

class _BigRoutePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..moveTo(size.width * 0.22, size.height * 0.68)
      ..cubicTo(
        size.width * 0.35,
        size.height * 0.55,
        size.width * 0.55,
        size.height * 0.40,
        size.width * 0.80,
        size.height * 0.27,
      );

    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.yellow.withOpacity(0.12)
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );

    // Main line
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.yellow.withOpacity(0.6)
        ..strokeWidth = 3.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

// ── Bottom info sheet ─────────────────────────────────────────
class _BottomInfoSheet extends StatelessWidget {
  final int eta;
  final double bottomPad;
  const _BottomInfoSheet({required this.eta, required this.bottomPad});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomPad + 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          Container(
            width: 36,
            height: 4,
            margin: const EdgeInsets.only(bottom: 18),
            decoration: BoxDecoration(
              color: Colors.black12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // ETA Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            decoration: BoxDecoration(
              color: AppTheme.navy,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.access_time_rounded,
                  color: AppTheme.yellow,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Arriving in',
                        style: AppTheme.inter(
                          size: 11.5,
                          color: Colors.white54,
                        ),
                      ),
                      Text(
                        '~$eta minutes',
                        style: AppTheme.inter(
                          size: 17,
                          color: Colors.white,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.yellow.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.yellow.withOpacity(0.3)),
                  ),
                  child: Text(
                    'On Time',
                    style: AppTheme.inter(
                      size: 12,
                      color: AppTheme.yellow,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Rider info
          Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: AppTheme.yellow.withOpacity(0.15),
                child: Icon(Icons.person, color: AppTheme.yellow, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Rahul Verma',
                      style: AppTheme.inter(
                        size: 14,
                        color: AppTheme.navy,
                        weight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      'Hero Splendor • HR 06 AB 1234',
                      style: AppTheme.inter(size: 12, color: AppTheme.grey),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: _actionBtn(Icons.message_rounded),
                  ),
                  const SizedBox(width: 8),
                  GestureDetector(
                    onTap: () => HapticFeedback.lightImpact(),
                    child: _actionBtn(Icons.phone_rounded),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),

          // SOS button
          GestureDetector(
            onTap: () {
              HapticFeedback.heavyImpact();
              _showSOSDialog(context);
            },
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 13),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.07),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.red.withOpacity(0.2)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.sos_rounded, color: Colors.redAccent, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    'SOS Emergency',
                    style: AppTheme.inter(
                      size: 13,
                      color: Colors.redAccent,
                      weight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionBtn(IconData icon) => Container(
    width: 38,
    height: 38,
    decoration: BoxDecoration(
      color: AppTheme.bg,
      borderRadius: BorderRadius.circular(12),
    ),
    child: Icon(icon, color: AppTheme.navy, size: 17),
  );

  void _showSOSDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: Row(
          children: [
            Icon(Icons.warning_rounded, color: Colors.redAccent),
            const SizedBox(width: 8),
            Text(
              'SOS Alert',
              style: AppTheme.inter(
                size: 16,
                color: AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
          ],
        ),
        content: Text(
          'This will alert your emergency contacts and share your live location.',
          style: AppTheme.inter(size: 13, color: AppTheme.grey),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Cancel',
              style: AppTheme.inter(size: 13, color: AppTheme.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.redAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            onPressed: () {
              HapticFeedback.heavyImpact();
              Navigator.pop(context);
            },
            child: Text(
              'Send SOS',
              style: AppTheme.inter(
                size: 13,
                color: Colors.white,
                weight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
