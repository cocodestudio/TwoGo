import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../home/home_screen.dart';
import '../utils/api_config.dart';
import '../utils/custom_toast.dart';
import 'package:http_parser/http_parser.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with TickerProviderStateMixin {
  static const Color navy = Color(0xFF022B3A);
  static const Color yellow = Color(0xFFF7B32B);
  static const Color grey = Color(0xFF817F75);

  late TabController _tabCtrl;
  late AnimationController _slideCtrl;
  late AnimationController _orbCtrl;

  late Animation<Offset> _formSlide;
  late Animation<double> _formFade;
  late Animation<double> _orbFloat;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  final _rollCtrl = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false; // Loading State Backend ke liye
  String _role = 'passenger';
  String _gender = 'male'; // ← ADDED
  String? _idImagePath;

  @override
  void initState() {
    super.initState();

    _tabCtrl = TabController(length: 2, vsync: this)..addListener(_onTabChange);

    _orbCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    )..repeat(reverse: true);
    _orbFloat = Tween<double>(
      begin: -10,
      end: 10,
    ).animate(CurvedAnimation(parent: _orbCtrl, curve: Curves.easeInOut));

    _slideCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 480),
    );
    _formSlide = Tween<Offset>(
      begin: const Offset(0, 0.06),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOutCubic));
    _formFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _slideCtrl, curve: Curves.easeOut));

    _slideCtrl.forward();
  }

  void _onTabChange() {
    if (_tabCtrl.indexIsChanging) {
      HapticFeedback.selectionClick();
      _slideCtrl.forward(from: 0.0);
      setState(() {
        _isLoading = false; // Tab change par loading reset
      });
    }
  }

  @override
  void dispose() {
    _tabCtrl.dispose();
    _slideCtrl.dispose();
    _orbCtrl.dispose();
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    _confirmCtrl.dispose();
    _rollCtrl.dispose();
    super.dispose();
  }

  bool get _isLogin => _tabCtrl.index == 0;

  Future<void> _handleAuth() async {
    FocusScope.of(context).unfocus();

    if (_isLogin) {
      await _login();
    } else {
      await _register();
    }
  }

  Future<void> _login() async {
    if (_emailCtrl.text.isEmpty || _passCtrl.text.isEmpty) {
      CustomToast.show(
        context,
        'Please Enter Email or Password!',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final Map<String, String> headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };

      final Map<String, dynamic> body = {
        'email': _emailCtrl.text.trim(),
        'password': _passCtrl.text,
      };
      print("Connecting to: ${ApiConfig.login}");

      final response = await http
          .post(
            Uri.parse(ApiConfig.login),
            headers: headers,
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 && data['success'] == true) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('auth_token', data['token']);

        String userRoleStr = data['user']['role'];
        await prefs.setString('user_role', userRoleStr);

        if (!mounted) return;
        UserRole targetRole = UserRole.passenger;
        if (userRoleStr == 'admin')
          targetRole = UserRole.admin;
        else if (userRoleStr == 'rider')
          targetRole = UserRole.rider;

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => HomeScreen(role: targetRole)),
        );
      } else {
        CustomToast.show(
          context,
          data['message'] ?? 'Login failed.',
          isError: true,
        );
      }
    } catch (e) {
      print("Login Error: $e");
      CustomToast.show(
        context,
        'Network Error: Check if server is running',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _register() async {
    // 1. Frontend Validations
    if (_nameCtrl.text.isEmpty ||
        _emailCtrl.text.isEmpty ||
        _passCtrl.text.isEmpty ||
        _rollCtrl.text.isEmpty) {
      CustomToast.show(context, 'Please fill all fields', isError: true);
      return;
    }
    if (_passCtrl.text != _confirmCtrl.text) {
      CustomToast.show(context, 'Passwords do not match', isError: true);
      return;
    }
    if (_idImagePath == null) {
      CustomToast.show(
        context,
        'Please upload your ID Card for verification',
        isError: true,
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(ApiConfig.register),
      );
      request.headers.addAll({'Accept': 'application/json'});
      request.fields['name'] = _nameCtrl.text.trim();
      request.fields['email'] = _emailCtrl.text.trim();
      request.fields['password'] = _passCtrl.text;
      request.fields['password_confirmation'] =
          _confirmCtrl.text; // Exact match for Laravel 'confirmed'
      request.fields['roll_number'] = _rollCtrl.text.trim();
      request.fields['role'] = _role.toLowerCase(); // Safety lowercase
      request.fields['gender'] = _gender.toLowerCase(); // Safety lowercase

      if (_idImagePath != null) {
        request.files.add(
          await http.MultipartFile.fromPath('id_image', _idImagePath!),
        );
      }

      print("Sending Register Request...");

      var streamedResponse = await request.send();
      var response = await http.Response.fromStream(streamedResponse);

      print("Backend Response: ${response.statusCode} - ${response.body}");

      final data = jsonDecode(response.body);

      if (response.statusCode == 201 && data['success'] == true) {
        CustomToast.show(
          context,
          'Account submitted! Please wait for admin approval.',
        );

        _nameCtrl.clear();
        _passCtrl.clear();
        _confirmCtrl.clear();
        _rollCtrl.clear();
        setState(() => _idImagePath = null);

        _tabCtrl.animateTo(0);
      } else {
        String errorMsg = data['message'] ?? 'Registration failed.';
        CustomToast.show(context, errorMsg, isError: true);
      }
    } catch (e) {
      print("Register Catch Error: $e");
      CustomToast.show(
        context,
        'Network error. Try again later.',
        isError: true,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F0),
      resizeToAvoidBottomInset: true,
      body: AnimatedBuilder(
        animation: Listenable.merge([_orbCtrl, _slideCtrl]),
        builder: (context, _) {
          return Stack(
            children: [
              // ... (Same UI Code logic as before for backgrounds and orbs)
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFFF8F8F4),
                      Color(0xFFEFEFEB),
                      Color(0xFFE4E4E0),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: -size.width * 0.32 + _orbFloat.value,
                left: -size.width * 0.32,
                child: Container(
                  width: size.width * 0.82,
                  height: size.width * 0.82,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [navy.withOpacity(0.11), navy.withOpacity(0.0)],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: -size.width * 0.22 - _orbFloat.value,
                right: -size.width * 0.22,
                child: Container(
                  width: size.width * 0.62,
                  height: size.width * 0.62,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        yellow.withOpacity(0.13),
                        yellow.withOpacity(0.0),
                      ],
                    ),
                  ),
                ),
              ),
              SafeArea(
                child: LayoutBuilder(
                  builder: (ctx, constraints) {
                    return SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 26,
                        vertical: 20,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 8),
                            _buildLogo(),
                            const SizedBox(height: 34),
                            _buildTabPill(),
                            const SizedBox(height: 28),
                            _buildHeadline(),
                            const SizedBox(height: 26),
                            SlideTransition(
                              position: _formSlide,
                              child: FadeTransition(
                                opacity: _formFade,
                                child: _buildFormCard(),
                              ),
                            ),
                            if (_isLogin) ...[
                              const SizedBox(height: 10),
                              _buildForgotPassword(),
                            ],
                            const SizedBox(height: 28),
                            _buildCTAButton(), // Button updated with logic
                            const SizedBox(height: 32),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ── Logo + wordmark ──────────────────────────────────────
  Widget _buildLogo() {
    return Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: navy,
            borderRadius: BorderRadius.circular(13),
            boxShadow: [
              BoxShadow(
                color: navy.withOpacity(0.22),
                blurRadius: 14,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: const Icon(Icons.two_wheeler_rounded, color: yellow, size: 22),
        ),
        const SizedBox(width: 11),
        Text(
          "TwoGo",
          style: GoogleFonts.playfairDisplay(
            color: navy,
            fontSize: 23,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }

  // ── Segmented tab pill (Login / Register) ────────────────
  Widget _buildTabPill() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: navy.withOpacity(0.055),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TabBar(
        controller: _tabCtrl,
        indicator: BoxDecoration(
          color: navy,
          borderRadius: BorderRadius.circular(13),
          boxShadow: [
            BoxShadow(
              color: navy.withOpacity(0.25),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w700,
          fontSize: 14.5,
        ),
        unselectedLabelStyle: GoogleFonts.inter(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        labelColor: Colors.white,
        unselectedLabelColor: grey,
        splashFactory: NoSplash.splashFactory,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        tabs: const [
          Tab(text: "Login"),
          Tab(text: "Register"),
        ],
      ),
    );
  }

  // ── Animated headline ────────────────────────────────────
  Widget _buildHeadline() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      child: Column(
        key: ValueKey(_isLogin),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            _isLogin ? "Welcome back," : "Join the ride,",
            style: GoogleFonts.playfairDisplay(
              color: navy,
              fontSize: 31,
              fontWeight: FontWeight.w700,
              height: 1.1,
            ),
          ),
          Text(
            _isLogin ? "hop in. 🏍️" : "it's free. 🎉",
            style: GoogleFonts.playfairDisplay(
              color: yellow,
              fontSize: 31,
              fontWeight: FontWeight.w800,
              height: 1.1,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _isLogin
                ? "Sign in to access your campus rides."
                : "Create your account and start commuting smarter.",
            style: GoogleFonts.inter(color: grey, fontSize: 13.5, height: 1.55),
          ),
        ],
      ),
    );
  }

  // ── Glass form card ──────────────────────────────────────
  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.92), width: 1.3),
        boxShadow: [
          BoxShadow(
            color: navy.withOpacity(0.07),
            blurRadius: 32,
            offset: const Offset(0, 14),
          ),
          BoxShadow(
            color: Colors.white.withOpacity(0.88),
            blurRadius: 18,
            spreadRadius: -4,
            offset: const Offset(-5, -5),
          ),
        ],
      ),
      child: AnimatedSize(
        duration: const Duration(milliseconds: 340),
        curve: Curves.easeInOutCubic,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_isLogin) ...[
              _field(
                label: "Full Name",
                icon: Icons.person_outline_rounded,
                controller: _nameCtrl,
              ),
              const SizedBox(height: 20),
              _buildGenderSelector(),
              const SizedBox(height: 16),
            ],
            _field(
              label: "Email / University ID",
              icon: Icons.alternate_email_rounded,
              controller: _emailCtrl,
            ),
            const SizedBox(height: 16),
            _field(
              label: "Password",
              icon: Icons.lock_outline_rounded,
              controller: _passCtrl,
              isPassword: true,
              obscure: _obscurePass,
              onToggle: () => setState(() => _obscurePass = !_obscurePass),
            ),
            if (!_isLogin) ...[
              const SizedBox(height: 16),
              _field(
                label: "Confirm Password",
                icon: Icons.lock_outline_rounded,
                controller: _confirmCtrl,
                isPassword: true,
                obscure: _obscureConfirm,
                onToggle: () =>
                    setState(() => _obscureConfirm = !_obscureConfirm),
              ),
              const SizedBox(height: 16),
              _field(
                label: "Roll Number",
                icon: Icons.badge_outlined,
                controller: _rollCtrl,
              ),
              const SizedBox(height: 20),
              _buildIdUpload(),
              const SizedBox(height: 24),
              _buildRoleSelector(),
            ],
          ],
        ),
      ),
    );
  }

  // ── Student ID card upload ───────────────────────────────
  Widget _buildIdUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Student ID Card",
          style: GoogleFonts.inter(
            color: navy,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: _pickIdImage,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 260),
            height: _idImagePath != null ? 110 : 72,
            width: double.infinity,
            decoration: BoxDecoration(
              color: _idImagePath != null
                  ? navy.withOpacity(0.04)
                  : const Color(0xFFF5F5F0),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: _idImagePath != null
                    ? yellow.withOpacity(0.6)
                    : grey.withOpacity(0.22),
                width: _idImagePath != null ? 1.5 : 1,
              ),
            ),
            child: _idImagePath != null
                ? Row(
                    children: [
                      const SizedBox(width: 16),
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: yellow.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(
                          Icons.image_rounded,
                          color: yellow,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "ID card selected ✓",
                              style: GoogleFonts.inter(
                                color: navy,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              _idImagePath!.split('/').last,
                              style: GoogleFonts.inter(
                                color: grey,
                                fontSize: 11.5,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      GestureDetector(
                        onTap: () => setState(() => _idImagePath = null),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Icon(
                            Icons.close_rounded,
                            size: 18,
                            color: grey.withOpacity(0.7),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: navy.withOpacity(0.07),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.upload_rounded,
                          size: 17,
                          color: navy.withOpacity(0.55),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        "Upload ID card photo",
                        style: GoogleFonts.inter(
                          color: navy.withOpacity(0.6),
                          fontSize: 13.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  Future<void> _pickIdImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => _idImagePath = picked.path);
  }

  // ── Role selector (Passenger / Rider) ────────────────────
  Widget _buildRoleSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "I want to",
          style: GoogleFonts.inter(
            color: navy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: _roleCard(
                role: 'passenger',
                icon: Icons.accessibility_new_rounded,
                title: "Passenger",
                subtitle: "I need a ride",
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _roleCard(
                role: 'rider',
                icon: Icons.two_wheeler_rounded,
                title: "Rider",
                subtitle: "I offer rides",
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _roleCard({
    required String role,
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    final selected = _role == role;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _role = role);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 260),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: selected ? navy : const Color(0xFFF5F5F0),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected ? navy : grey.withOpacity(0.18),
            width: selected ? 2 : 1,
          ),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: navy.withOpacity(0.22),
                    blurRadius: 14,
                    offset: const Offset(0, 5),
                  ),
                ]
              : [],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: selected ? yellow : navy.withOpacity(0.07),
                borderRadius: BorderRadius.circular(11),
              ),
              child: Icon(
                icon,
                size: 20,
                color: selected ? navy : navy.withOpacity(0.45),
              ),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: GoogleFonts.inter(
                color: selected ? Colors.white : navy,
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: GoogleFonts.inter(
                color: selected ? Colors.white.withOpacity(0.65) : grey,
                fontSize: 11.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? yellow : Colors.transparent,
                    border: Border.all(
                      color: selected ? yellow : grey.withOpacity(0.35),
                      width: 1.5,
                    ),
                  ),
                  child: selected
                      ? const Icon(Icons.check_rounded, size: 11, color: navy)
                      : null,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // ── Gender selector (Male / Female) ─────────────────────  ← NEW
  Widget _buildGenderSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: GoogleFonts.inter(
            color: navy,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F0),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: grey.withOpacity(0.16), width: 1),
          ),
          child: Row(
            children: [
              Expanded(
                child: _genderOption(
                  value: 'male',
                  icon: Icons.male_rounded,
                  label: 'Male',
                ),
              ),
              Container(width: 1, color: grey.withOpacity(0.15)),
              Expanded(
                child: _genderOption(
                  value: 'female',
                  icon: Icons.female_rounded,
                  label: 'Female',
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _genderOption({
    required String value,
    required IconData icon,
    required String label,
  }) {
    final selected = _gender == value;
    final isMale = value == 'male';
    // Blue for male, pink for female — subtle premium colors
    final color = isMale ? const Color(0xFF1565C0) : const Color(0xFFAD1457);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        setState(() => _gender = value);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 230),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected ? color : Colors.transparent,
          borderRadius: BorderRadius.horizontal(
            left: isMale ? const Radius.circular(15) : Radius.zero,
            right: isMale ? Radius.zero : const Radius.circular(15),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 230),
              padding: const EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: selected
                    ? Colors.white.withOpacity(0.15)
                    : Colors.transparent,
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 19,
                color: selected ? Colors.white : grey.withOpacity(0.7),
              ),
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: GoogleFonts.inter(
                fontSize: 13.5,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                color: selected ? Colors.white : grey.withOpacity(0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Forgot password ──────────────────────────────────────
  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerRight,
      child: GestureDetector(
        onTap: () => debugPrint("Forgot Password"),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Text(
            "Forgot Password?",
            style: GoogleFonts.inter(
              color: navy,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  // ── Primary CTA ──────────────────────────────────────────
  Widget _buildCTAButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _handleAuth, // Logic Connected here
        style: ElevatedButton.styleFrom(
          backgroundColor: navy,
          disabledBackgroundColor: navy.withOpacity(0.7), // Faded when loading
          foregroundColor: Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
        child: _isLoading
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  color: yellow,
                  strokeWidth: 2.5,
                ), // Sleek Loading Indicator
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _isLogin ? "Login" : "Create Account",
                    style: GoogleFonts.inter(
                      fontSize: 15.5,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: 28,
                    height: 28,
                    decoration: const BoxDecoration(
                      color: yellow,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: navy,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  // ── Reusable input field ─────────────────────────────────
  Widget _field({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
    bool obscure = false,
    VoidCallback? onToggle,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.inter(
            color: navy,
            fontSize: 12.5,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 7),
        Container(
          height: 52,
          decoration: BoxDecoration(
            color: const Color(0xFFF5F5F0),
            borderRadius: BorderRadius.circular(13),
            border: Border.all(color: grey.withOpacity(0.16), width: 1),
          ),
          child: Row(
            children: [
              const SizedBox(width: 14),
              Icon(icon, color: navy.withOpacity(0.45), size: 19),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: controller,
                  obscureText: isPassword ? obscure : false,
                  style: GoogleFonts.inter(color: navy, fontSize: 14),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    hintText: "Enter ${label.toLowerCase()}",
                    hintStyle: GoogleFonts.inter(
                      color: grey.withOpacity(0.65),
                      fontSize: 13.5,
                    ),
                    isDense: true,
                  ),
                ),
              ),
              if (isPassword)
                GestureDetector(
                  onTap: onToggle,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      obscure
                          ? Icons.visibility_off_outlined
                          : Icons.visibility_outlined,
                      color: navy.withOpacity(0.4),
                      size: 19,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
