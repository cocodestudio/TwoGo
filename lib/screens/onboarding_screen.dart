import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:twogo/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen>
    with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  late AnimationController _entryCtrl;
  late AnimationController _bgCtrl;
  late AnimationController _shimmerCtrl;

  late Animation<double> _imageScale;
  late Animation<double> _imageFade;
  late Animation<Offset> _textSlide;
  late Animation<double> _textFade;
  late Animation<Offset> _subtitleSlide;
  late Animation<double> _subtitleFade;
  late Animation<double> _btnScale;
  late Animation<double> _bgFloat;
  late Animation<double> _shimmer;

  static const Color navy = Color(0xFF022B3A);
  static const Color yellow = Color(0xFFF7B32B);
  static const Color titaniumMid = Color(0xFFE8E8E4);
  static const Color grey = Color(0xFF817F75);

  final List<_OnboardPage> pages = [
    _OnboardPage(
      svgAsset: 'assets/icons/onboard_1.svg',
      title: 'Wherever you\'re headed,',
      highlight: 'we\'re ready.',
      subtitle:
          'Share rides with verified university students and make your campus commute effortless.',
      badgeIcon: Icons.location_on_rounded,
      badgeLabel: 'Campus Routes',
    ),
    _OnboardPage(
      svgAsset: 'assets/icons/onboard_2.svg',
      title: 'Your ride,',
      highlight: 'your way!',
      subtitle:
          'Offer a seat or request a ride. Travel safely, split the cost, and save the environment.',
      badgeIcon: Icons.currency_rupee_rounded,
      badgeLabel: '₹20–30 / ride',
    ),
    _OnboardPage(
      svgAsset: 'assets/icons/onboard_3.svg',
      title: 'Real-time tracking',
      highlight: '& safety.',
      subtitle:
          'Know exactly where your ride is. Share live location with friends for peace of mind.',
      badgeIcon: Icons.shield_rounded,
      badgeLabel: 'SOS + Verified',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _initEntryController();

    _bgCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _bgFloat = Tween<double>(
      begin: -14,
      end: 14,
    ).animate(CurvedAnimation(parent: _bgCtrl, curve: Curves.easeInOut));

    _shimmerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    )..repeat();
    _shimmer = Tween<double>(
      begin: -1.5,
      end: 2.5,
    ).animate(CurvedAnimation(parent: _shimmerCtrl, curve: Curves.linear));

    _entryCtrl.forward();
  }

  void _initEntryController() {
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _imageScale = Tween<double>(begin: 0.78, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.65, curve: Curves.easeOutBack),
      ),
    );
    _imageFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.0, 0.55, curve: Curves.easeIn),
      ),
    );
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.25), end: Offset.zero)
        .animate(
          CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.25, 0.75, curve: Curves.easeOutCubic),
          ),
        );
    _textFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.25, 0.70, curve: Curves.easeIn),
      ),
    );
    _subtitleSlide =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(
            parent: _entryCtrl,
            curve: const Interval(0.40, 0.90, curve: Curves.easeOutCubic),
          ),
        );
    _subtitleFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.40, 0.85, curve: Curves.easeIn),
      ),
    );
    _btnScale = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(
        parent: _entryCtrl,
        curve: const Interval(0.60, 1.0, curve: Curves.easeOutBack),
      ),
    );
  }

  Future<void> _onPageChanged(int index) async {
    await _entryCtrl.reverse(from: 0.4);
    if (!mounted) return;
    setState(() => _currentPage = index);
    _entryCtrl.forward(from: 0.0);
  }

  void _nextPage() {
    if (_currentPage < pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AuthScreen()),
      );
    }
  }

  void _prevPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 480),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _skip() => _pageController.jumpToPage(pages.length - 1);

  @override
  void dispose() {
    _pageController.dispose();
    _entryCtrl.dispose();
    _bgCtrl.dispose();
    _shimmerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      body: AnimatedBuilder(
        animation: Listenable.merge([_entryCtrl, _bgCtrl, _shimmerCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8F8F4),
                      Color(0xFFEFEFEB),
                      Color(0xFFE8E8E3),
                    ],
                  ),
                ),
              ),
              _buildBgOrbs(size),
              SafeArea(
                child: Column(
                  children: [
                    _buildTopBar(),
                    Expanded(flex: 5, child: _buildPageView(size)),
                    Expanded(
                      flex: 4,
                      child: _buildTextContent(pages[_currentPage]),
                    ),
                    _buildNavBar(),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildBgOrbs(Size size) {
    return Stack(
      children: [
        Positioned(
          top: -size.width * 0.25 + _bgFloat.value * 0.5,
          left: -size.width * 0.25,
          child: Container(
            width: size.width * 0.65,
            height: size.width * 0.65,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [navy.withOpacity(0.10), navy.withOpacity(0.0)],
              ),
            ),
          ),
        ),
        Positioned(
          bottom: -size.width * 0.2 - _bgFloat.value * 0.5,
          right: -size.width * 0.2,
          child: Container(
            width: size.width * 0.55,
            height: size.width * 0.55,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [yellow.withOpacity(0.12), yellow.withOpacity(0.0)],
              ),
            ),
          ),
        ),
        Positioned(
          top: size.height * 0.42 + _bgFloat.value * 0.8,
          left: -size.width * 0.08,
          child: Transform.rotate(
            angle: 0.3,
            child: Container(
              width: size.width * 0.35,
              height: size.width * 0.08,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                gradient: LinearGradient(
                  colors: [yellow.withOpacity(0.12), yellow.withOpacity(0.0)],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: List.generate(pages.length, (i) {
                final active = _currentPage >= i;
                return Expanded(
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 350),
                    curve: Curves.easeInOut,
                    margin: const EdgeInsets.only(right: 6),
                    height: 4,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(2),
                      gradient: active
                          ? const LinearGradient(
                              colors: [navy, Color(0xFF034A62)],
                            )
                          : null,
                      color: active ? null : grey.withOpacity(0.18),
                    ),
                  ),
                );
              }),
            ),
          ),
          const SizedBox(width: 16),
          GestureDetector(
            onTap: _skip,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: navy.withOpacity(0.06),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close_rounded, color: navy, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPageView(Size size) {
    return PageView.builder(
      controller: _pageController,
      onPageChanged: _onPageChanged,
      itemCount: pages.length,
      itemBuilder: (context, index) =>
          _buildIllustrationCard(size, pages[index]),
    );
  }

  Widget _buildIllustrationCard(Size size, _OnboardPage page) {
    final cardSize = size.width * 0.74;

    return Center(
      child: ScaleTransition(
        scale: _imageScale,
        child: FadeTransition(
          opacity: _imageFade,
          child: Stack(
            alignment: Alignment.bottomRight,
            children: [
              Container(
                width: cardSize,
                height: cardSize,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withOpacity(0.75),
                      Colors.white.withOpacity(0.40),
                      titaniumMid.withOpacity(0.50),
                    ],
                  ),
                  border: Border.all(
                    color: Colors.white.withOpacity(0.88),
                    width: 1.4,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withOpacity(0.08),
                      blurRadius: 50,
                      offset: const Offset(0, 22),
                    ),
                    BoxShadow(
                      color: Colors.white.withOpacity(0.95),
                      blurRadius: 20,
                      spreadRadius: -4,
                      offset: const Offset(-6, -6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      ShaderMask(
                        shaderCallback: (bounds) => LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.transparent,
                            Colors.white.withOpacity(0.15),
                            Colors.transparent,
                          ],
                          stops: [
                            (_shimmer.value - 0.4).clamp(0.0, 1.0),
                            _shimmer.value.clamp(0.0, 1.0),
                            (_shimmer.value + 0.4).clamp(0.0, 1.0),
                          ],
                        ).createShader(bounds),
                        child: Container(color: Colors.white),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: SvgPicture.asset(
                          page.svgAsset,
                          fit: BoxFit.contain,
                          placeholderBuilder: (_) => Icon(
                            Icons.two_wheeler_rounded,
                            size: 90,
                            color: navy.withOpacity(0.25),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                bottom: 14,
                right: 14,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: navy,
                    borderRadius: BorderRadius.circular(24),
                    boxShadow: [
                      BoxShadow(
                        color: navy.withOpacity(0.25),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(page.badgeIcon, color: yellow, size: 14),
                      const SizedBox(width: 6),
                      Text(
                        page.badgeLabel,
                        style: GoogleFonts.inter(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextContent(_OnboardPage page) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textFade,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    page.title,
                    style: GoogleFonts.playfairDisplay(
                      color: navy,
                      fontSize: 30,
                      fontWeight: FontWeight.w700,
                      height: 1.15,
                    ),
                  ),
                  Stack(
                    children: [
                      Text(
                        page.highlight,
                        style: GoogleFonts.playfairDisplay(
                          color: yellow,
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          height: 1.15,
                        ),
                      ),
                      Positioned(
                        bottom: 2,
                        left: 0,
                        right: 0,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                yellow.withOpacity(0.7),
                                yellow.withOpacity(0.0),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          SlideTransition(
            position: _textSlide,
            child: FadeTransition(
              opacity: _textFade,
              child: Row(
                children: [
                  Container(
                    width: 24,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: yellow,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 6,
                    height: 6,
                    decoration: const BoxDecoration(
                      color: yellow,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 5),
                  Container(
                    width: 12,
                    height: 2.5,
                    decoration: BoxDecoration(
                      color: yellow.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          SlideTransition(
            position: _subtitleSlide,
            child: FadeTransition(
              opacity: _subtitleFade,
              child: Text(
                page.subtitle,
                style: GoogleFonts.inter(
                  color: grey,
                  fontSize: 14.5,
                  fontWeight: FontWeight.w400,
                  height: 1.65,
                  letterSpacing: 0.1,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavBar() {
    final isLast = _currentPage == pages.length - 1;

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
      child: ScaleTransition(
        scale: _btnScale,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: _currentPage == 0 ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: GestureDetector(
                onTap: _prevPage,
                child: Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: navy.withOpacity(0.06),
                    shape: BoxShape.circle,
                    border: Border.all(color: navy.withOpacity(0.12), width: 1),
                  ),
                  child: const Icon(
                    Icons.arrow_back_rounded,
                    color: navy,
                    size: 22,
                  ),
                ),
              ),
            ),
            Row(
              children: List.generate(pages.length, (i) {
                final active = i == _currentPage;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: active ? 22 : 7,
                  height: 7,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4),
                    color: active ? navy : grey.withOpacity(0.25),
                  ),
                );
              }),
            ),
            GestureDetector(
              onTap: _nextPage,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                height: 52,
                width: isLast ? 150 : 52,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(30),
                  gradient: const LinearGradient(
                    colors: [navy, Color(0xFF034A62)],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: navy.withOpacity(0.28),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRect(
                  child: Center(
                    child: isLast
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                "Get Started",
                                style: GoogleFonts.inter(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 14,
                                ),
                              ),
                              const SizedBox(width: 6),
                              const Icon(
                                Icons.arrow_forward_rounded,
                                color: yellow,
                                size: 18,
                              ),
                            ],
                          )
                        : const Icon(
                            Icons.arrow_forward_rounded,
                            color: Colors.white,
                            size: 22,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardPage {
  final String svgAsset;
  final String title;
  final String highlight;
  final String subtitle;
  final IconData badgeIcon;
  final String badgeLabel;

  const _OnboardPage({
    required this.svgAsset,
    required this.title,
    required this.highlight,
    required this.subtitle,
    required this.badgeIcon,
    required this.badgeLabel,
  });
}
