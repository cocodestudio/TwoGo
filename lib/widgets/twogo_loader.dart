import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

// ══════════════════════════════════════════════════════════════
//  TwoGoLoader — drop-in premium loading widget
//  Usage:
//    TwoGoLoader()                    // default size
//    TwoGoLoader(size: 180)           // custom size
//    TwoGoLoader(message: 'Finding rides...')
// ══════════════════════════════════════════════════════════════

class TwoGoLoader extends StatefulWidget {
  final double size;
  final String? message;

  const TwoGoLoader({super.key, this.size = 160, this.message});

  @override
  State<TwoGoLoader> createState() => _TwoGoLoaderState();
}

class _TwoGoLoaderState extends State<TwoGoLoader>
    with TickerProviderStateMixin {
  // Bike wheel spin
  late AnimationController _wheelCtrl;
  // Bike body bob
  late AnimationController _bobCtrl;
  // Pulse rings (wifi-like)
  late AnimationController _pulseCtrl;
  // Outer ring rotate
  late AnimationController _ringCtrl;
  // Dot trail behind bike
  late AnimationController _trailCtrl;

  @override
  void initState() {
    super.initState();

    _wheelCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat();

    _bobCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);

    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _trailCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _wheelCtrl.dispose();
    _bobCtrl.dispose();
    _pulseCtrl.dispose();
    _ringCtrl.dispose();
    _trailCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.size;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: s,
          height: s,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // ── Pulse rings (wifi/radar style) ──────────────
              ...[0.0, 0.33, 0.66].map(
                (offset) => _PulseRing(
                  controller: _pulseCtrl,
                  offset: offset,
                  baseSize: s,
                ),
              ),

              // ── Rotating dashed outer ring ──────────────────
              AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: _ringCtrl.value * 2 * math.pi,
                  child: CustomPaint(
                    size: Size(s * 0.88, s * 0.88),
                    painter: _DashedRingPainter(
                      color: AppTheme.yellow.withOpacity(0.25),
                      dashCount: 24,
                      strokeWidth: 1.5,
                    ),
                  ),
                ),
              ),

              // ── Counter-rotating dotted inner ring ──────────
              AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) => Transform.rotate(
                  angle: -_ringCtrl.value * 2 * math.pi * 0.6,
                  child: CustomPaint(
                    size: Size(s * 0.70, s * 0.70),
                    painter: _DashedRingPainter(
                      color: AppTheme.navy.withOpacity(0.45),
                      dashCount: 16,
                      strokeWidth: 1.2,
                    ),
                  ),
                ),
              ),

              // ── Solid circle background ─────────────────────
              Container(
                width: s * 0.56,
                height: s * 0.56,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [const Color(0xFF03455E), AppTheme.navy],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navy.withOpacity(0.6),
                      blurRadius: 24,
                      spreadRadius: 4,
                    ),
                    BoxShadow(
                      color: AppTheme.yellow.withOpacity(0.12),
                      blurRadius: 16,
                      spreadRadius: -2,
                    ),
                  ],
                ),
              ),

              // ── Bike (bob animation) ─────────────────────────
              AnimatedBuilder(
                animation: _bobCtrl,
                builder: (_, __) {
                  final bob = Tween<double>(begin: -2.0, end: 2.0).evaluate(
                    CurvedAnimation(parent: _bobCtrl, curve: Curves.easeInOut),
                  );
                  return Transform.translate(
                    offset: Offset(0, bob),
                    child: _BikeWidget(size: s * 0.30, wheelCtrl: _wheelCtrl),
                  );
                },
              ),

              // ── Speed lines (left of bike) ──────────────────
              AnimatedBuilder(
                animation: _trailCtrl,
                builder: (_, __) => Positioned(
                  left: s * 0.12,
                  child: _SpeedLines(
                    opacity: _trailCtrl.value,
                    containerSize: s * 0.12,
                  ),
                ),
              ),

              // ── Yellow arc glow at bottom ───────────────────
              Positioned(
                bottom: s * 0.17,
                child: Container(
                  width: s * 0.30,
                  height: 3,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(2),
                    gradient: LinearGradient(
                      colors: [
                        Colors.transparent,
                        AppTheme.yellow.withOpacity(0.6),
                        Colors.transparent,
                      ],
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.yellow.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),

        if (widget.message != null) ...[
          const SizedBox(height: 20),
          _LoadingText(message: widget.message!),
        ],
      ],
    );
  }
}

// ── Bike SVG-style widget drawn with CustomPainter ─────────────
class _BikeWidget extends StatelessWidget {
  final double size;
  final AnimationController wheelCtrl;

  const _BikeWidget({required this.size, required this.wheelCtrl});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: wheelCtrl,
      builder: (_, __) => CustomPaint(
        size: Size(size * 2.2, size),
        painter: _BikePainter(
          wheelAngle: wheelCtrl.value * 2 * math.pi,
          bodyColor: Colors.white,
          accentColor: AppTheme.yellow,
        ),
      ),
    );
  }
}

class _BikePainter extends CustomPainter {
  final double wheelAngle;
  final Color bodyColor;
  final Color accentColor;

  _BikePainter({
    required this.wheelAngle,
    required this.bodyColor,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;

    final bodyPaint = Paint()
      ..color = bodyColor
      ..strokeWidth = h * 0.07
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    final accentPaint = Paint()
      ..color = accentColor
      ..strokeWidth = h * 0.06
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final wheelPaint = Paint()
      ..color = bodyColor
      ..strokeWidth = h * 0.065
      ..style = PaintingStyle.stroke;

    final spokePaint = Paint()
      ..color = bodyColor.withOpacity(0.5)
      ..strokeWidth = h * 0.03
      ..strokeCap = StrokeCap.round;

    // Wheel centers
    final rWheelCenter = Offset(w * 0.78, h * 0.72);
    final fWheelCenter = Offset(w * 0.22, h * 0.72);
    final wheelR = h * 0.26;

    // Draw wheels
    for (final center in [rWheelCenter, fWheelCenter]) {
      canvas.drawCircle(center, wheelR, wheelPaint);
      // Spokes
      for (int i = 0; i < 6; i++) {
        final angle = wheelAngle + (i * math.pi / 3);
        final spokeEnd = Offset(
          center.dx + math.cos(angle) * wheelR * 0.85,
          center.dy + math.sin(angle) * wheelR * 0.85,
        );
        canvas.drawLine(center, spokeEnd, spokePaint);
      }
      // Hub
      canvas.drawCircle(
        center,
        wheelR * 0.14,
        Paint()
          ..color = accentColor
          ..style = PaintingStyle.fill,
      );
    }

    // Rear frame
    final seatPost = Offset(w * 0.60, h * 0.28);
    final bbCenter = Offset(w * 0.55, h * 0.68);

    // Chain stay
    canvas.drawLine(rWheelCenter, bbCenter, bodyPaint);
    // Seat stay
    canvas.drawLine(rWheelCenter, seatPost, bodyPaint);
    // Seat tube
    canvas.drawLine(seatPost, bbCenter, bodyPaint);

    // Front fork
    final headTube = Offset(w * 0.35, h * 0.30);
    canvas.drawLine(fWheelCenter, headTube, bodyPaint);

    // Top tube (accent colored)
    canvas.drawLine(seatPost, headTube, accentPaint);

    // Down tube
    canvas.drawLine(headTube, bbCenter, bodyPaint);

    // Handlebar
    final handlebar = Offset(w * 0.30, h * 0.22);
    canvas.drawLine(headTube, handlebar, bodyPaint);
    canvas.drawLine(
      handlebar,
      Offset(handlebar.dx - w * 0.05, handlebar.dy + h * 0.08),
      bodyPaint,
    );

    // Seat
    canvas.drawLine(
      Offset(seatPost.dx - w * 0.07, seatPost.dy - h * 0.02),
      Offset(seatPost.dx + w * 0.06, seatPost.dy - h * 0.02),
      Paint()
        ..color = accentColor
        ..strokeWidth = h * 0.07
        ..strokeCap = StrokeCap.round,
    );

    // Rider silhouette (simple)
    final riderPaint = Paint()
      ..color = bodyColor.withOpacity(0.90)
      ..strokeWidth = h * 0.09
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..style = PaintingStyle.stroke;

    // Body
    final hipPt = Offset(seatPost.dx, seatPost.dy + h * 0.02);
    final shoulderPt = Offset(w * 0.40, h * 0.14);
    canvas.drawLine(hipPt, shoulderPt, riderPaint);

    // Head (helmet)
    canvas.drawCircle(
      Offset(shoulderPt.dx - w * 0.02, shoulderPt.dy - h * 0.10),
      h * 0.10,
      Paint()
        ..color = accentColor
        ..style = PaintingStyle.fill,
    );

    // Arm to handlebar
    canvas.drawLine(shoulderPt, handlebar, riderPaint);

    // Leg (pedaling — static for simplicity)
    canvas.drawLine(
      hipPt,
      Offset(bbCenter.dx + w * 0.03, bbCenter.dy - h * 0.02),
      riderPaint,
    );
  }

  @override
  bool shouldRepaint(_BikePainter old) => old.wheelAngle != wheelAngle;
}

// ── Wifi/Radar pulse ring ───────────────────────────────────────
class _PulseRing extends StatelessWidget {
  final AnimationController controller;
  final double offset;
  final double baseSize;

  const _PulseRing({
    required this.controller,
    required this.offset,
    required this.baseSize,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final t = ((controller.value + offset) % 1.0);
        final scale = 0.56 + t * 0.44; // grows from inner circle outward
        final opacity = (1.0 - t) * 0.55;

        return Container(
          width: baseSize * scale,
          height: baseSize * scale,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.yellow.withOpacity(opacity),
              width: 1.5,
            ),
          ),
        );
      },
    );
  }
}

// ── Dashed ring painter ─────────────────────────────────────────
class _DashedRingPainter extends CustomPainter {
  final Color color;
  final int dashCount;
  final double strokeWidth;

  _DashedRingPainter({
    required this.color,
    required this.dashCount,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    final dashAngle = (2 * math.pi) / dashCount;
    final gapFraction = 0.45;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = i * dashAngle;
      final sweepAngle = dashAngle * (1 - gapFraction);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_DashedRingPainter old) => false;
}

// ── Speed lines ─────────────────────────────────────────────────
class _SpeedLines extends StatelessWidget {
  final double opacity;
  final double containerSize;

  const _SpeedLines({required this.opacity, required this.containerSize});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(containerSize, containerSize * 1.2),
      painter: _SpeedLinesPainter(opacity: opacity),
    );
  }
}

class _SpeedLinesPainter extends CustomPainter {
  final double opacity;
  _SpeedLinesPainter({required this.opacity});

  @override
  void paint(Canvas canvas, Size size) {
    final lines = [0.25, 0.45, 0.60, 0.75, 0.88];
    for (int i = 0; i < lines.length; i++) {
      final y = size.height * lines[i];
      final lineOpacity = opacity * (0.5 - i * 0.08).clamp(0.0, 0.5);
      final paint = Paint()
        ..color = Colors.white.withOpacity(lineOpacity)
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;
      final len = size.width * (0.9 - i * 0.15);
      canvas.drawLine(
        Offset(size.width - len, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(_SpeedLinesPainter old) => old.opacity != opacity;
}

// ── Animated loading text ───────────────────────────────────────
class _LoadingText extends StatefulWidget {
  final String message;
  const _LoadingText({required this.message});

  @override
  State<_LoadingText> createState() => _LoadingTextState();
}

class _LoadingTextState extends State<_LoadingText>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  int _dotCount = 1;

  @override
  void initState() {
    super.initState();
    _ctrl =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 500),
        )..addStatusListener((s) {
          if (s == AnimationStatus.completed) {
            setState(() => _dotCount = (_dotCount % 3) + 1);
            _ctrl.reset();
            _ctrl.forward();
          }
        });
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      '${widget.message}${'.' * _dotCount}',
      style: AppTheme.inter(
        size: 13,
        color: Colors.white54,
        weight: FontWeight.w500,
      ),
    );
  }
}
