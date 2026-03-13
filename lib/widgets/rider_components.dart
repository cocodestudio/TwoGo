import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class RiderComponents {
  static Widget onlineToggleCard({
    required bool isOnline,
    required VoidCallback onToggle,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeOutCubic,
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isOnline
              ? [const Color(0xFF1B5E20), const Color(0xFF2E7D32)]
              : [AppTheme.navy, const Color(0xFF03364A)],
        ),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: (isOnline ? const Color(0xFF4CAF50) : AppTheme.navy)
                .withOpacity(0.35),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    isOnline ? "You're Online" : "You're Offline",
                    style: AppTheme.playfair(
                      size: 18,
                      color: Colors.white,
                      weight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  isOnline
                      ? 'Accepting ride requests nearby'
                      : 'Go online to start accepting rides',
                  style: AppTheme.inter(size: 12, color: Colors.white60),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 64,
              height: 36,
              decoration: BoxDecoration(
                color: isOnline
                    ? const Color(0xFF4CAF50)
                    : Colors.white.withOpacity(0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isOnline
                      ? const Color(0xFF4CAF50)
                      : Colors.white.withOpacity(0.3),
                ),
              ),
              child: Stack(
                alignment: Alignment.centerLeft,
                children: [
                  AnimatedPositioned(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutBack,
                    left: isOnline ? 28 : 2,
                    child: Container(
                      width: 32,
                      height: 32,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isOnline
                            ? Icons.power_settings_new_rounded
                            : Icons.power_off_rounded,
                        size: 16,
                        color: isOnline
                            ? const Color(0xFF4CAF50)
                            : AppTheme.grey,
                      ),
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

  static Widget statCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      width: 120,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12), // Vertical padding kam ki
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF001F3F).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min, // Jitni zaroorat hai utni hi height lega
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(height: 8), // Spacer hata kar fixed gap diya
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 18,
                color: Color(0xFF001F3F),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: Colors.grey),
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Text bada hua toh kat jayega, overflow nahi karega
          ),
        ],
      ),
    );
  }

  static Widget completedRideTile({
    required String passengerName,
    required String from,
    required String to,
    required String price,
    required String time,
    required int rating,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppTheme.bg,
              shape: BoxShape.circle,
              border: Border.all(
                color: AppTheme.yellow.withOpacity(0.4),
                width: 1.5,
              ),
            ),
            child: const Icon(Icons.person, color: AppTheme.navy, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  passengerName,
                  style: AppTheme.inter(
                    size: 13.5,
                    color: AppTheme.navy,
                    weight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '$from → $to',
                  style: AppTheme.inter(size: 11, color: AppTheme.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    ...List.generate(
                      5,
                      (i) => Icon(
                        Icons.star_rounded,
                        size: 10,
                        color: i < rating
                            ? AppTheme.yellow
                            : Colors.grey.shade300,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      time,
                      style: AppTheme.inter(size: 10, color: AppTheme.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              price,
              style: AppTheme.inter(
                size: 12,
                color: const Color(0xFF4CAF50),
                weight: FontWeight.w800,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static Widget scheduleTipCard({
    required bool scheduleEnabled,
    required ValueChanged<bool> onToggle,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppTheme.yellow.withOpacity(0.08),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.yellow.withOpacity(0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.yellow.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.schedule_rounded,
              color: AppTheme.yellow,
              size: 18,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Auto-Manage Schedule',
                  style: AppTheme.inter(
                    size: 13,
                    color: AppTheme.navy,
                    weight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Auto offline during class hours',
                  style: AppTheme.inter(size: 11, color: AppTheme.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Switch(
            value: scheduleEnabled,
            onChanged: (v) {
              HapticFeedback.selectionClick();
              onToggle(v);
            },
            activeColor: AppTheme.yellow,
            activeTrackColor: AppTheme.yellow.withOpacity(0.3),
          ),
        ],
      ),
    );
  }

  static Widget earningsBar({
    required String day,
    required double amount,
    required double maxAmount,
    required bool isToday,
  }) {
    final fraction = maxAmount > 0 ? (amount / maxAmount).clamp(0.0, 1.0) : 0.0;
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isToday)
          Container(
            margin: const EdgeInsets.only(bottom: 4),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
            decoration: BoxDecoration(
              color: AppTheme.yellow,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              '₹${amount.toInt()}',
              style: AppTheme.inter(
                size: 9,
                color: AppTheme.navy,
                weight: FontWeight.w700,
              ),
            ),
          )
        else
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '₹${amount.toInt()}',
              style: AppTheme.inter(size: 9, color: AppTheme.grey),
            ),
          ),
        AnimatedContainer(
          duration: const Duration(milliseconds: 600),
          curve: Curves.easeOutCubic,
          width: 24,
          height: 70 * fraction,
          decoration: BoxDecoration(
            color: isToday ? AppTheme.yellow : AppTheme.navy.withOpacity(0.12),
            borderRadius: BorderRadius.circular(6),
            boxShadow: isToday
                ? [
                    BoxShadow(
                      color: AppTheme.yellow.withOpacity(0.3),
                      blurRadius: 6,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : [],
          ),
        ),
        const SizedBox(height: 6),
        Text(
          day,
          style: AppTheme.inter(
            size: 10,
            color: isToday ? AppTheme.navy : AppTheme.grey,
            weight: isToday ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ],
    );
  }

  static Widget streakBonusCard({
    required int ridesCount,
    required int targetRides,
  }) {
    final progress = (ridesCount / targetRides).clamp(0.0, 1.0);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.navy, Color(0xFF03455E)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppTheme.navy.withOpacity(0.25),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.local_fire_department_rounded,
                color: AppTheme.yellow,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Daily Streak Bonus',
                  style: AppTheme.inter(
                    size: 13.5,
                    color: Colors.white,
                    weight: FontWeight.w700,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.yellow.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '₹20 bonus',
                  style: AppTheme.inter(
                    size: 11,
                    color: AppTheme.yellow,
                    weight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            'Complete $targetRides rides today to unlock',
            style: AppTheme.inter(size: 11, color: Colors.white54),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.10),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF4CAF50),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '$ridesCount / $targetRides rides done',
            style: AppTheme.inter(size: 10, color: Colors.white38),
          ),
        ],
      ),
    );
  }

  static Widget earningsRow({
    required String passengerName,
    required String route,
    required String time,
    required String amount,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: const Color(
              0xFF001F3F,
            ).withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withOpacity(0.10),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_outline_rounded,
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
                  passengerName,
                  style: const TextStyle(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF001F3F),
                  ),
                ),
                Text(
                  route,
                  style: const TextStyle(fontSize: 11.5, color: Colors.grey),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '+$amount',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF4CAF50),
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                time,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
