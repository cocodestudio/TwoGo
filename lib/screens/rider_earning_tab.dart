import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';
import '../widgets/rider_components.dart';

class RiderEarningsTab extends StatefulWidget {
  const RiderEarningsTab({super.key});

  @override
  State<RiderEarningsTab> createState() => _RiderEarningsTabState();
}

class _RiderEarningsTabState extends State<RiderEarningsTab>
    with SingleTickerProviderStateMixin {
  int _periodIdx = 0;
  final _periods = ['Today', 'This Week', 'This Month'];
  late AnimationController _entryCtrl;

  final _weekData = [
    (day: 'Mon', amount: 45.0),
    (day: 'Tue', amount: 80.0),
    (day: 'Wed', amount: 30.0),
    (day: 'Thu', amount: 95.0),
    (day: 'Fri', amount: 60.0),
    (day: 'Sat', amount: 110.0),
    (day: 'Sun', amount: 75.0),
  ];

  final _transactions = [
    (
      name: 'Arjun T.',
      route: 'Gate 1 → City Center',
      time: '2:30 PM',
      amount: '25',
    ),
    (
      name: 'Sneha R.',
      route: 'Hostel A → Old Bus Stand',
      time: '12:00 PM',
      amount: '20',
    ),
    (
      name: 'Mohit K.',
      route: 'Library → Clock Tower',
      time: '9:15 AM',
      amount: '30',
    ),
    (name: 'Riya S.', route: 'Gate 2 → Gangoh', time: '8:00 AM', amount: '40'),
  ];

  final _summaryByPeriod = [
    (total: '₹75', rides: '3', avg: '₹25', km: '14.2'),
    (total: '₹495', rides: '21', avg: '₹23', km: '89'),
    (total: '₹2,140', rides: '88', avg: '₹24', km: '362'),
  ];

  @override
  void initState() {
    super.initState();
    _entryCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();
  }

  @override
  void dispose() {
    _entryCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final summary = _summaryByPeriod[_periodIdx];

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      padding: EdgeInsets.only(top: topPad + 16, bottom: 110),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Earnings',
              style: AppTheme.playfair(
                size: 28,
                color: AppTheme.navy,
                weight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Track your daily income',
              style: AppTheme.inter(size: 13, color: AppTheme.grey),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.navy.withOpacity(0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: _periods
                    .asMap()
                    .entries
                    .map(
                      (e) => Expanded(
                        child: GestureDetector(
                          onTap: () {
                            HapticFeedback.selectionClick();
                            setState(() => _periodIdx = e.key);
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            curve: Curves.easeOutCubic,
                            padding: const EdgeInsets.symmetric(
                              vertical: 10,
                              horizontal: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _periodIdx == e.key
                                  ? AppTheme.navy
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(14),
                            ),
                            child: Center(
                              child: FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  e.value,
                                  style: AppTheme.inter(
                                    size: 12.5,
                                    color: _periodIdx == e.key
                                        ? Colors.white
                                        : AppTheme.grey,
                                    weight: _periodIdx == e.key
                                        ? FontWeight.w700
                                        : FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _FadeSlide(
              ctrl: _entryCtrl,
              delay: 0.0,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [AppTheme.navy, Color(0xFF03455E)],
                  ),
                  borderRadius: BorderRadius.circular(28),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navy.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Total Earnings',
                      style: AppTheme.inter(size: 13, color: Colors.white54),
                    ),
                    const SizedBox(height: 6),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        summary.total,
                        style: AppTheme.playfair(
                          size: 42,
                          color: Colors.white,
                          weight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        _EarningsMiniStat(
                          icon: Icons.two_wheeler_rounded,
                          label: 'Rides',
                          value: summary.rides,
                        ),
                        _vDivider(),
                        _EarningsMiniStat(
                          icon: Icons.show_chart_rounded,
                          label: 'Avg/Ride',
                          value: summary.avg,
                        ),
                        _vDivider(),
                        _EarningsMiniStat(
                          icon: Icons.route_rounded,
                          label: 'KM',
                          value: summary.km,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _FadeSlide(
              ctrl: _entryCtrl,
              delay: 0.12,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.navy.withOpacity(0.06),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'This Week',
                      style: AppTheme.inter(
                        size: 14,
                        color: AppTheme.navy,
                        weight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      height: 130,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: _weekData
                            .asMap()
                            .entries
                            .map(
                              (e) => RiderComponents.earningsBar(
                                day: e.value.day,
                                amount: e.value.amount,
                                maxAmount: 110,
                                isToday: e.key == _weekData.length - 1,
                              ),
                            )
                            .toList(),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: _FadeSlide(
              ctrl: _entryCtrl,
              delay: 0.22,
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50).withOpacity(0.08),
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(
                    color: const Color(0xFF4CAF50).withOpacity(0.25),
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: const Color(0xFF4CAF50).withOpacity(0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.account_balance_rounded,
                        color: Color(0xFF4CAF50),
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Available to Withdraw',
                            style: AppTheme.inter(
                              size: 12,
                              color: AppTheme.grey,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              '₹75.00',
                              style: AppTheme.inter(
                                size: 20,
                                color: AppTheme.navy,
                                weight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    GestureDetector(
                      onTap: () {
                        HapticFeedback.mediumImpact();
                        _showWithdrawSheet(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: const Color(0xFF4CAF50).withOpacity(0.35),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Text(
                          'Withdraw',
                          style: AppTheme.inter(
                            size: 12.5,
                            color: Colors.white,
                            weight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              'Recent Transactions',
              style: AppTheme.inter(
                size: 16,
                color: AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 14),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              children: _transactions
                  .asMap()
                  .entries
                  .map(
                    (e) => _FadeSlide(
                      ctrl: _entryCtrl,
                      delay: 0.30 + e.key * 0.07,
                      child: RiderComponents.earningsRow(
                        passengerName: e.value.name,
                        route: e.value.route,
                        time: e.value.time,
                        amount: e.value.amount,
                      ),
                    ),
                  )
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  void _showWithdrawSheet(BuildContext context) {
    final bottomPad = MediaQuery.of(context).padding.bottom;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => Container(
        padding: EdgeInsets.fromLTRB(24, 24, 24, bottomPad + 24),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'Withdraw Earnings',
              style: AppTheme.playfair(
                size: 20,
                color: AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              '₹75 will be transferred to your UPI',
              style: AppTheme.inter(size: 13, color: AppTheme.grey),
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.bg,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF4CAF50).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.account_balance_wallet_rounded,
                      color: Color(0xFF4CAF50),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'UPI ID',
                          style: AppTheme.inter(size: 11, color: AppTheme.grey),
                        ),
                        FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Text(
                            'abuzar@upi',
                            style: AppTheme.inter(
                              size: 14,
                              color: AppTheme.navy,
                              weight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () {
                HapticFeedback.heavyImpact();
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '₹75 transfer initiated!',
                      style: AppTheme.inter(size: 13, color: Colors.white),
                    ),
                    backgroundColor: const Color(0xFF4CAF50),
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    margin: const EdgeInsets.all(16),
                  ),
                );
              },
              child: Container(
                width: double.infinity,
                height: 54,
                decoration: BoxDecoration(
                  color: const Color(0xFF4CAF50),
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4CAF50).withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: Text(
                    'Confirm Withdrawal',
                    style: AppTheme.inter(
                      size: 15,
                      color: Colors.white,
                      weight: FontWeight.w700,
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

  Widget _vDivider() =>
      Container(width: 1, height: 32, color: Colors.white.withOpacity(0.15));
}

class _EarningsMiniStat extends StatelessWidget {
  final IconData icon;
  final String label, value;
  const _EarningsMiniStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Icon(icon, color: AppTheme.yellow, size: 18),
        const SizedBox(height: 4),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            value,
            style: AppTheme.inter(
              size: 15,
              color: Colors.white,
              weight: FontWeight.w800,
            ),
          ),
        ),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            label,
            style: AppTheme.inter(size: 11, color: Colors.white38),
          ),
        ),
      ],
    ),
  );
}

class _FadeSlide extends StatelessWidget {
  final AnimationController ctrl;
  final double delay;
  final Widget child;
  const _FadeSlide({
    required this.ctrl,
    required this.delay,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final end = (delay + 0.5).clamp(0.0, 1.0);
    return FadeTransition(
      opacity: Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(
          parent: ctrl,
          curve: Interval(delay, end, curve: Curves.easeOut),
        ),
      ),
      child: SlideTransition(
        position: Tween<Offset>(begin: const Offset(0, 0.08), end: Offset.zero)
            .animate(
              CurvedAnimation(
                parent: ctrl,
                curve: Interval(delay, end, curve: Curves.easeOutCubic),
              ),
            ),
        child: child,
      ),
    );
  }
}
