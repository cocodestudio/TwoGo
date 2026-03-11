import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twogo/home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _orbController;
  late AnimationController _shimmerController;
  late Animation<double> _bgReveal;
  late Animation<double> _orb1Scale;
  late Animation<double> _orb2Scale;
  late Animation<double> _orb3Scale;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _taglineFade;
  late Animation<Offset> _taglineSlide;
  late Animation<double> _creditFade;
  late Animation<Offset> _creditSlide;
  late Animation<double> _ringScale1;
  late Animation<double> _ringOpacity1;
  late Animation<double> _ringScale2;
  late Animation<double> _ringOpacity2;
  late Animation<double> _orbFloat;
  late Animation<double> _shimmerPosition;
  static const Color navy = Color(0xFF022B3A);
  static const Color yellow = Color(0xFFF7B32B);
  static const Color titaniumBg = Color(0xFFF5F5F0);
  static const Color titaniumMid = Color(0xFFE8E8E4);
  static const Color grey = Color(0xFF817F75);

  @override
  void initState() {
    super.initState();

    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    // Background reveal
    _bgReveal = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeOut),
      ),
    );

    // Orb scale-ins (staggered)
    _orb1Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.0, 0.35, curve: Curves.elasticOut),
      ),
    );
    _orb2Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.08, 0.42, curve: Curves.elasticOut),
      ),
    );
    _orb3Scale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.14, 0.48, curve: Curves.elasticOut),
      ),
    );

    // Ripple rings
    _ringScale1 = Tween<double>(begin: 0.6, end: 1.6).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.30, 0.70, curve: Curves.easeOut),
      ),
    );
    _ringOpacity1 = Tween<double>(begin: 0.5, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.30, 0.70, curve: Curves.easeOut),
      ),
    );
    _ringScale2 = Tween<double>(begin: 0.6, end: 1.6).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.42, 0.80, curve: Curves.easeOut),
      ),
    );
    _ringOpacity2 = Tween<double>(begin: 0.4, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.42, 0.80, curve: Curves.easeOut),
      ),
    );

    // Logo
    _logoScale = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.60, curve: Curves.elasticOut),
      ),
    );
    _logoFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.25, 0.50, curve: Curves.easeIn),
      ),
    );

    // Tagline
    _taglineFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.58, 0.80, curve: Curves.easeIn),
      ),
    );
    _taglineSlide = Tween<Offset>(begin: const Offset(0, 0.4), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.58, 0.80, curve: Curves.easeOutCubic),
          ),
        );

    // Credit line
    _creditFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.78, 1.0, curve: Curves.easeIn),
      ),
    );
    _creditSlide = Tween<Offset>(begin: const Offset(0, 1), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _mainController,
            curve: const Interval(0.78, 1.0, curve: Curves.easeOutCubic),
          ),
        );

    _orbController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);

    _orbFloat = Tween<double>(
      begin: -12.0,
      end: 12.0,
    ).animate(CurvedAnimation(parent: _orbController, curve: Curves.easeInOut));

    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat();

    _shimmerPosition = Tween<double>(begin: -1.5, end: 2.5).animate(
      CurvedAnimation(parent: _shimmerController, curve: Curves.linear),
    );

    _mainController.forward();
    Timer(const Duration(milliseconds: 4000), () {
      Navigator.pushReplacement(
        context,
        PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(opacity: animation, child: child);
          },
          transitionDuration: const Duration(milliseconds: 800),
        ),
      );
    });
  }

  @override
  void dispose() {
    _mainController.dispose();
    _orbController.dispose();
    _shimmerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: titaniumBg,
      body: AnimatedBuilder(
        animation: Listenable.merge([
          _mainController,
          _orbController,
          _shimmerController,
        ]),
        builder: (context, _) {
          return Stack(
            children: [
              Opacity(
                opacity: _bgReveal.value,
                child: Container(
                  width: size.width,
                  height: size.height,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Color(0xFFF8F8F4),
                        Color(0xFFEFEFEB),
                        Color(0xFFE8E8E3),
                        Color(0xFFF2F2EE),
                      ],
                      stops: [0.0, 0.35, 0.65, 1.0],
                    ),
                  ),
                ),
              ),

              Opacity(
                opacity: _bgReveal.value * 0.06,
                child: CustomPaint(
                  size: size,
                  painter: _GridPainter(color: navy),
                ),
              ),

              Positioned(
                top: -size.width * 0.28 + _orbFloat.value * 0.6,
                left: -size.width * 0.28,
                child: Transform.scale(
                  scale: _orb1Scale.value,
                  child: Container(
                    width: size.width * 0.72,
                    height: size.width * 0.72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        center: const Alignment(0.3, 0.3),
                        radius: 0.8,
                        colors: [
                          navy.withOpacity(0.92),
                          navy.withOpacity(0.75),
                          navy.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.65, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: size.height * 0.17 + _orbFloat.value * 0.8,
                left: -size.width * 0.12,
                child: Transform.scale(
                  scale: _orb2Scale.value,
                  child: Container(
                    width: size.width * 0.42,
                    height: size.width * 0.18,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      gradient: LinearGradient(
                        colors: [
                          yellow.withOpacity(0.95),
                          yellow.withOpacity(0.55),
                          yellow.withOpacity(0.0),
                        ],
                        stops: const [0.0, 0.55, 1.0],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                top: size.height * 0.07 - _orbFloat.value * 0.5,
                right: size.width * 0.1,
                child: Transform.scale(
                  scale: _orb3Scale.value,
                  child: Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [navy.withOpacity(0.90), navy.withOpacity(0.0)],
                      ),
                    ),
                  ),
                ),
              ),

              Positioned(
                bottom: size.height * 0.14 + _orbFloat.value * 0.4,
                right: -size.width * 0.05,
                child: Transform.scale(
                  scale: _orb2Scale.value,
                  child: Transform.rotate(
                    angle: -0.4,
                    child: Container(
                      width: size.width * 0.3,
                      height: size.width * 0.09,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(100),
                        gradient: LinearGradient(
                          colors: [
                            yellow.withOpacity(0.7),
                            yellow.withOpacity(0.0),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),

              Center(
                child: SizedBox(
                  height: size.width * 0.6,
                  width: size.width * 0.6,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      // Ring 1
                      Transform.scale(
                        scale: _ringScale1.value,
                        child: Container(
                          width: size.width * 0.5,
                          height: size.width * 0.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: navy.withOpacity(_ringOpacity1.value),
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                      // Ring 2
                      Transform.scale(
                        scale: _ringScale2.value,
                        child: Container(
                          width: size.width * 0.5,
                          height: size.width * 0.5,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: yellow.withOpacity(_ringOpacity2.value),
                              width: 1.0,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // ── 8. Center: Logo Card + Tagline ────────────
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: size.height * 0.05),

                    // Glass card behind logo
                    Transform.scale(
                      scale: _logoScale.value,
                      child: Opacity(
                        opacity: _logoFade.value,
                        child: _buildLogoCard(size),
                      ),
                    ),

                    const SizedBox(height: 32),

                    // Tagline
                    SlideTransition(
                      position: _taglineSlide,
                      child: FadeTransition(opacity: _taglineFade),
                    ),
                  ],
                ),
              ),

              Align(
                alignment: Alignment.bottomCenter,
                child: SafeArea(
                  bottom: true,
                  child: SlideTransition(
                    position: _creditSlide,
                    child: FadeTransition(
                      opacity: _creditFade,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 28.0),
                        child: _buildCredit(),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Logo inside a premium glass card ───────────────────────
  Widget _buildLogoCard(Size size) {
    return Container(
      width: size.width * 0.52,
      height: size.width * 0.52,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(36),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Colors.white.withOpacity(0.72),
            Colors.white.withOpacity(0.38),
            titaniumMid.withOpacity(0.45),
          ],
        ),
        border: Border.all(color: Colors.white.withOpacity(0.85), width: 1.2),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.10),
            blurRadius: 40,
            spreadRadius: 0,
            offset: const Offset(0, 18),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.9),
            blurRadius: 24,
            spreadRadius: -4,
            offset: const Offset(-6, -6),
          ),
          BoxShadow(
            color: yellow.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(8, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(36),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Shimmer sweep
            AnimatedBuilder(
              animation: _shimmerPosition,
              builder: (_, __) {
                return ShaderMask(
                  shaderCallback: (bounds) {
                    return LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.18),
                        Colors.transparent,
                      ],
                      stops: [
                        (_shimmerPosition.value - 0.4).clamp(0.0, 1.0),
                        _shimmerPosition.value.clamp(0.0, 1.0),
                        (_shimmerPosition.value + 0.4).clamp(0.0, 1.0),
                      ],
                    ).createShader(bounds);
                  },
                  child: Container(color: Colors.white),
                );
              },
            ),
            // Logo
            Padding(
              padding: const EdgeInsets.all(28),
              child: Image.asset(
                'assets/images/splash_logo.png',
                fit: BoxFit.contain,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCredit() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.55),
        borderRadius: BorderRadius.circular(40),
        border: Border.all(color: Colors.white.withOpacity(0.80), width: 1.0),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/cocode.png',
            width: 22,
            height: 22,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: 8),
          RichText(
            text: TextSpan(
              text: "Designed by ",
              style: GoogleFonts.inter(
                color: grey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
              children: [
                TextSpan(
                  text: "CoCode Studio",
                  style: GoogleFonts.inter(
                    color: navy,
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GridPainter extends CustomPainter {
  final Color color;
  _GridPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withOpacity(1.0)
      ..strokeWidth = 0.5;

    const spacing = 32.0;

    for (double x = 0; x < size.width; x += spacing) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += spacing) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => false;
}
