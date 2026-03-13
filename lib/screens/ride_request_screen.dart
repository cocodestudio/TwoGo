import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class RideRequestScreen extends StatefulWidget {
  final Map<String, dynamic> requestData;
  const RideRequestScreen({super.key, required this.requestData});

  @override
  State<RideRequestScreen> createState() => _RideRequestScreenState();
}

class _RideRequestScreenState extends State<RideRequestScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _timerCtrl;
  int _timeLeft = 15;

  @override
  void initState() {
    super.initState();
    _timerCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 15),
    )..forward();
    _startCountdown();
  }

  void _startCountdown() async {
    for (int i = 14; i >= 0; i--) {
      await Future.delayed(const Duration(seconds: 1));
      if (!mounted) return;
      setState(() => _timeLeft = i);
    }
    if (mounted) {
      Navigator.pop(context, false); // Auto decline on timeout
    }
  }

  @override
  void dispose() {
    _timerCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final data = widget.requestData;

    return Scaffold(
      backgroundColor: AppTheme.navy,
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 20),

            // Header Timer
            Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  SizedBox(
                    width: 70,
                    height: 70,
                    child: CircularProgressIndicator(
                      value: _timeLeft / 15,
                      strokeWidth: 4,
                      backgroundColor: Colors.white.withOpacity(0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        _timeLeft <= 5 ? Colors.red : AppTheme.yellow,
                      ),
                    ),
                  ),
                  Text(
                    '$_timeLeft',
                    style: AppTheme.playfair(
                      size: 24,
                      color: Colors.white,
                      weight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Tap to Accept',
              style: AppTheme.inter(size: 13, color: Colors.white54),
            ),
            const SizedBox(height: 30),

            // Map Placeholder UI
            Expanded(
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: const Color(0xFF03364A),
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: Colors.white.withOpacity(0.05)),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.map_rounded,
                      size: 60,
                      color: Colors.white.withOpacity(0.2),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Route Preview',
                      style: AppTheme.inter(size: 14, color: Colors.white38),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),

            // Request Details Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Passenger Info
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        backgroundColor: AppTheme.navy.withOpacity(0.08),
                        child: const Icon(Icons.person, color: AppTheme.navy),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              data['name'],
                              style: AppTheme.inter(
                                size: 16,
                                color: AppTheme.navy,
                                weight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(
                                  Icons.star_rounded,
                                  size: 14,
                                  color: AppTheme.yellow,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  '${data['rating']} • ${data['rideType']}',
                                  style: AppTheme.inter(
                                    size: 13,
                                    color: AppTheme.grey,
                                    weight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            data['price'],
                            style: AppTheme.playfair(
                              size: 26,
                              color: AppTheme.navy,
                              weight: FontWeight.w900,
                            ),
                          ),
                          Text(
                            data['distance'],
                            style: AppTheme.inter(
                              size: 13,
                              color: const Color(0xFF4CAF50),
                              weight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Divider(color: AppTheme.grey.withOpacity(0.15), height: 1),
                  const SizedBox(height: 24),

                  // Route Info
                  Row(
                    children: [
                      Column(
                        children: [
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.navy,
                              shape: BoxShape.circle,
                            ),
                          ),
                          Container(
                            width: 2,
                            height: 30,
                            color: AppTheme.grey.withOpacity(0.2),
                          ),
                          Container(
                            width: 10,
                            height: 10,
                            decoration: const BoxDecoration(
                              color: AppTheme.yellow,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Pickup',
                              style: AppTheme.inter(
                                size: 11,
                                color: AppTheme.grey,
                              ),
                            ),
                            Text(
                              data['pickup'],
                              style: AppTheme.inter(
                                size: 14,
                                color: AppTheme.navy,
                                weight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Drop-off',
                              style: AppTheme.inter(
                                size: 11,
                                color: AppTheme.grey,
                              ),
                            ),
                            Text(
                              data['drop'],
                              style: AppTheme.inter(
                                size: 14,
                                color: AppTheme.navy,
                                weight: FontWeight.w700,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Action Buttons
                  Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, false), // Decline
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppTheme.bg,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: AppTheme.grey.withOpacity(0.2),
                              ),
                            ),
                            child: Center(
                              child: Text(
                                'Decline',
                                style: AppTheme.inter(
                                  size: 15,
                                  color: AppTheme.grey,
                                  weight: FontWeight.w700,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        flex: 2,
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context, true), // Accept
                          child: Container(
                            height: 58,
                            decoration: BoxDecoration(
                              color: AppTheme.navy,
                              borderRadius: BorderRadius.circular(18),
                              boxShadow: [
                                BoxShadow(
                                  color: AppTheme.navy.withOpacity(0.3),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                'Accept Ride',
                                style: AppTheme.inter(
                                  size: 16,
                                  color: Colors.white,
                                  weight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
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