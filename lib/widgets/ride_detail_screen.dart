import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:twogo/widgets/rebook_screen.dart';
import '../theme/app_theme.dart';

class RideDetailScreen extends StatefulWidget {
  final Map<String, dynamic> ride;
  const RideDetailScreen({super.key, required this.ride});

  @override
  State<RideDetailScreen> createState() => _RideDetailScreenState();
}

class _RideDetailScreenState extends State<RideDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final r = widget.ride;
    final isCancelled = r['status'] == 'cancelled';
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppTheme.bg,
      body: Stack(
        children: [
          // ── Top navy hero area ─────────────────────────────
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 280,
              decoration: BoxDecoration(
                color: AppTheme.navy,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(36),
                ),
              ),
              child: Stack(
                children: [
                  // Map grid bg
                  CustomPaint(
                    size: const Size(double.infinity, 280),
                    painter: _DetailMapPainter(),
                  ),
                  // Back button
                  SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _circleBtn(
                            icon: Icons.arrow_back_rounded,
                            onTap: () => Navigator.pop(context),
                          ),
                          Text(
                            'Ride Details',
                            style: AppTheme.inter(
                              size: 16,
                              color: Colors.white,
                              weight: FontWeight.w700,
                            ),
                          ),
                          _circleBtn(
                            icon: Icons.share_rounded,
                            onTap: () => HapticFeedback.lightImpact(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Route pins
                  Positioned(
                    bottom: 50,
                    left: 40,
                    child: _DetailPin(
                      color: Colors.white,
                      label: r['origin'] ?? 'Origin',
                    ),
                  ),
                  Positioned(
                    bottom: 50,
                    right: 40,
                    child: _DetailPin(
                      color: AppTheme.yellow,
                      label: r['destination'],
                    ),
                  ),
                  // Status badge
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: (r['color'] as Color).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: (r['color'] as Color).withOpacity(0.4),
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: r['color'],
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 7),
                            Text(
                              isCancelled ? 'Cancelled' : 'Completed',
                              style: AppTheme.inter(
                                size: 12,
                                color: r['color'],
                                weight: FontWeight.w700,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Scrollable content ─────────────────────────────
          SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: EdgeInsets.only(top: 260, bottom: bottomPad + 100),
            child: Column(
              children: [
                const SizedBox(height: 20),

                // ── Info Cards ─────────────────────────────────
                _AnimCard(ctrl: _ctrl, delay: 0.0, child: _infoGrid(r)),
                const SizedBox(height: 12),

                // ── Rider Card ─────────────────────────────────
                _AnimCard(ctrl: _ctrl, delay: 0.15, child: _riderCard(r)),
                const SizedBox(height: 12),

                // ── Fare Breakdown ──────────────────────────────
                _AnimCard(ctrl: _ctrl, delay: 0.30, child: _fareBreakdown(r)),
                const SizedBox(height: 12),

                if (!isCancelled) ...[
                  // ── Rating Card ──────────────────────────────
                  _AnimCard(ctrl: _ctrl, delay: 0.45, child: _ratingCard()),
                  const SizedBox(height: 12),
                ],
              ],
            ),
          ),

          // ── Bottom Action ───────────────────────────────────
          if (!isCancelled)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.fromLTRB(20, 14, 20, bottomPad + 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 20,
                      offset: const Offset(0, -4),
                    ),
                  ],
                ),
                child: GestureDetector(
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    Navigator.push(
                      context,
                      createPredictiveRoute(RebookScreen(ride: widget.ride)),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.navy.withOpacity(0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.refresh_rounded,
                          color: AppTheme.yellow,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Rebook This Ride',
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

  Widget _circleBtn({required IconData icon, required VoidCallback onTap}) =>
      GestureDetector(
        onTap: onTap,
        child: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withOpacity(0.15)),
          ),
          child: Icon(icon, color: Colors.white, size: 18),
        ),
      );

  Widget _infoGrid(Map<String, dynamic> r) {
    final items = [
      (Icons.route_rounded, 'Distance', r['distance'] ?? '4.2 km'),
      (Icons.access_time_rounded, 'Duration', r['duration'] ?? '18 min'),
      (Icons.calendar_today_rounded, 'Date', r['date'] ?? ''),
      (Icons.schedule_rounded, 'Time', r['time'] ?? ''),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Trip Info',
          style: AppTheme.inter(
            size: 14,
            color: AppTheme.navy,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.8,
          children: items
              .map(
                (item) => Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.bg,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    children: [
                      Icon(item.$1, size: 16, color: AppTheme.yellow),
                      const SizedBox(width: 8),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            item.$2,
                            style: AppTheme.inter(
                              size: 10,
                              color: AppTheme.grey,
                            ),
                          ),
                          Text(
                            item.$3,
                            style: AppTheme.inter(
                              size: 12,
                              color: AppTheme.navy,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              )
              .toList(),
        ),
      ],
    );
  }

  Widget _riderCard(Map<String, dynamic> r) {
    return Row(
      children: [
        CircleAvatar(
          radius: 24,
          backgroundColor: AppTheme.yellow.withOpacity(0.15),
          child: Icon(Icons.person, color: AppTheme.yellow, size: 24),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                r['riderName'] ?? 'Rider',
                style: AppTheme.inter(
                  size: 14,
                  color: AppTheme.navy,
                  weight: FontWeight.w700,
                ),
              ),
              Row(
                children: [
                  Icon(Icons.star_rounded, size: 13, color: AppTheme.yellow),
                  const SizedBox(width: 3),
                  Text(
                    '${r['riderRating'] ?? 4.5}',
                    style: AppTheme.inter(size: 12, color: AppTheme.grey),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• ${r['type']}',
                    style: AppTheme.inter(size: 12, color: AppTheme.grey),
                  ),
                ],
              ),
            ],
          ),
        ),
        GestureDetector(
          onTap: () => HapticFeedback.lightImpact(),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: AppTheme.bg,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.phone_rounded, color: AppTheme.navy, size: 18),
          ),
        ),
      ],
    );
  }

  Widget _fareBreakdown(Map<String, dynamic> r) {
    final price =
        double.tryParse(r['price'].toString().replaceAll('₹', '')) ?? 25.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Fare Breakdown',
          style: AppTheme.inter(
            size: 14,
            color: AppTheme.navy,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        _fareRow('Base Fare', '₹${(price * 0.7).toStringAsFixed(0)}'),
        _fareRow('Distance Charge', '₹${(price * 0.2).toStringAsFixed(0)}'),
        _fareRow('Platform Fee', '₹${(price * 0.1).toStringAsFixed(0)}'),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Divider(color: AppTheme.navy.withOpacity(0.08), height: 1),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Total',
              style: AppTheme.inter(
                size: 14,
                color: AppTheme.navy,
                weight: FontWeight.w800,
              ),
            ),
            Text(
              r['price'],
              style: AppTheme.inter(
                size: 16,
                color: AppTheme.navy,
                weight: FontWeight.w800,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _fareRow(String label, String value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: AppTheme.inter(size: 13, color: AppTheme.grey)),
        Text(
          value,
          style: AppTheme.inter(
            size: 13,
            color: AppTheme.navy,
            weight: FontWeight.w600,
          ),
        ),
      ],
    ),
  );

  Widget _ratingCard() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Rate Your Ride',
          style: AppTheme.inter(
            size: 14,
            color: AppTheme.navy,
            weight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 14),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            5,
            (i) => GestureDetector(
              onTap: () => HapticFeedback.selectionClick(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  Icons.star_rounded,
                  size: 34,
                  color: i < 4 ? AppTheme.yellow : Colors.grey.shade300,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Detail screen map painter ─────────────────────────────────
class _DetailMapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final p = Paint()
      ..color = Colors.white.withOpacity(0.04)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 35) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 35) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
    // Route line
    final routePaint = Paint()
      ..color = AppTheme.yellow.withOpacity(0.5)
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
    final path = Path()
      ..moveTo(50, size.height * 0.55)
      ..cubicTo(
        size.width * 0.3,
        size.height * 0.2,
        size.width * 0.7,
        size.height * 0.8,
        size.width - 50,
        size.height * 0.55,
      );
    canvas.drawPath(path, routePaint);
    // Glow
    canvas.drawPath(
      path,
      Paint()
        ..color = AppTheme.yellow.withOpacity(0.15)
        ..strokeWidth = 10
        ..style = PaintingStyle.stroke,
    );
  }

  @override
  bool shouldRepaint(_) => false;
}

class _DetailPin extends StatelessWidget {
  final Color color;
  final String label;
  const _DetailPin({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: AppTheme.navy,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.5)),
          ),
          child: Text(
            label,
            style: AppTheme.inter(size: 10, color: color),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Container(width: 2, height: 10, color: color.withOpacity(0.5)),
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
      ],
    );
  }
}

// ── Animated card wrapper ─────────────────────────────────────
class _AnimCard extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  final Widget child;
  const _AnimCard({
    required this.ctrl,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: ctrl,
          curve: Interval(
            delay,
            (delay + 0.5).clamp(0, 1),
            curve: Curves.easeOut,
          ),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.15), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: ctrl,
                curve: Interval(
                  delay,
                  (delay + 0.5).clamp(0, 1),
                  curve: Curves.easeOutCubic,
                ),
              ),
            ),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 20),
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppTheme.navy.withOpacity(0.06),
                blurRadius: 14,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}
